import Foundation
import CoreLocation
import RealmSwift

// MARK: - NetworkWeatherManagerDelegate

protocol NetworkWeatherManagerDelegate: class {
    func updateInteface(_: NetworkWeatherManager, with currentWeather: CurrentWeather)
    func showAlert()
    func showInfo()
    func hideActivityView()
}

// MARK: - NetworkWeatherManager

class NetworkWeatherManager {
    
    enum RequestType {
        case cityName(city: String)
        case coordinate(latitude: Double, longitude: Double)
    }
    
    // MARK: - Delegate
    
    weak var delegate: NetworkWeatherManagerDelegate?
    
    private let realm = try! Realm()
    
    // MARK: - Public Methods
    
    func fentchCurrentWeather(forRequestType requestType: RequestType) {
        var urlString = ""
        var cityName = ""
        
        switch requestType {
        case .cityName(let city):
            cityName = city
            urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&apikey=\(Constants.apiKey)&units=metric"
        case .coordinate(let latitude, let longitude):
            urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&apikey=\(Constants.apiKey)&units=metric"
        }
        performRequest(withURLString: urlString, cityName: cityName)
    }
    
    // MARK: - Private Methods
    
    private func performRequest(withURLString urlString: String, cityName: String) {
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            guard (error == nil) else {
                DispatchQueue.main.async {
                    self.loadFromRealm(cityName: cityName)
                }
                return
            }
            guard let data = data else { return }
            guard let currentWeather = self.parseJSON(withData: data) else { return }
            self.delegate?.updateInteface(self, with: currentWeather)
            self.delegate?.hideActivityView()
            DispatchQueue.main.async {
                self.addToRealm(currentWeather: currentWeather)
            }
        }
        task.resume()
    }
    
    private func loadFromRealm(cityName: String) {
        let allCache = self.realm.objects(RealmModel.self).filter("cityName=%@", cityName)
        guard let tergetCity = allCache.first else {
            self.delegate?.showAlert()
            return
        }
        self.delegate?.showInfo()
        let currentWeather = CurrentWeather(realmModel: tergetCity)
        self.delegate?.updateInteface(self, with: currentWeather)
    }
    
    private func addToRealm(currentWeather: CurrentWeather) {
        let model = RealmModel()
        model.cityName = currentWeather.cityName
        model.conditionCode = currentWeather.conditionCode
        model.feelsLikeTemperature = currentWeather.feelsLikeTemperature
        model.temperature = currentWeather.temperature

        try? realm.write {
            realm.add(model, update: .modified)
        }
    }
    
    private func parseJSON(withData data: Data) -> CurrentWeather? {
        let decoder = JSONDecoder()
        guard let currentWeatherData = try? decoder.decode(CurrentWeatherData.self, from: data) else { return nil }
        guard let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData) else { return nil }
        return currentWeather
    }
}
