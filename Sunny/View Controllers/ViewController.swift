import UIKit
import CoreLocation
import RealmSwift

class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var weatherIconImageView: UIImageView!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var feelsLikeTemperatureLabel: UILabel!
    
    // MARK: - Public Properties
    
    var networkWeatherManager = NetworkWeatherManager()
    
    var city: String? = nil
    
    private var activityIndicator = UIActivityIndicatorView()
    
    private let realm = try! Realm()
    
    lazy var locationManager: CLLocationManager = {
        let locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locManager.requestWhenInUseAuthorization()
        return locManager
    }()
    
    // MARK: - Action
    
    @IBAction func searchPressed(_ sender: UIButton) {
        presentSearchAlertController(withTitle: Constants.placeHolder, message: nil, style: .alert) { [weak self] city in
            guard let self = self else { return }
            self.networkWeatherManager.fentchCurrentWeather(forRequestType: .cityName(city: city))
            guard !MockCities.shared.cities.contains(city) else { return }
            MockCities.shared.cities.append(city)
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupApplication()
        setupIndicator()
        view.addSubview(activityIndicator)
        guard let city = city else { return }
        networkWeatherManager.fentchCurrentWeather(forRequestType: .cityName(city: city))
    }
    
    // MARK: - Private Methods
    private func setupIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = false
        activityIndicator.style = .large
        activityIndicator.startAnimating()
    }
    
    private func setupApplication() {
        networkWeatherManager.delegate = self
        guard CLLocationManager.locationServicesEnabled() else { return }
        locationManager.requestLocation()
    }
}

// MARK: - NetworkWeatherManagerDelegate

extension ViewController: NetworkWeatherManagerDelegate {
    func updateInteface(_: NetworkWeatherManager, with currentWeather: CurrentWeather) {
        DispatchQueue.main.async {
            self.cityLabel.text = currentWeather.cityName
            self.temperatureLabel.text = currentWeather.temperatureString
            self.feelsLikeTemperatureLabel.text = currentWeather.feelsLikeTemperatureString
            self.weatherIconImageView.image = UIImage(systemName: currentWeather.systemIconNameString)
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Нет доступа", message: "Подключитесь к сети", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Понятно", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func showInfo() {
        let alert = UIAlertController(title: "Нет доступа к сети", message: "Были загруженны последние сохранённые данные.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Понятно", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func hideActivityView() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        networkWeatherManager.fentchCurrentWeather(forRequestType: .coordinate(latitude: latitude, longitude: longitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
