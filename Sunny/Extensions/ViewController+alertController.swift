import UIKit

extension ViewController {
    func presentSearchAlertController(
        withTitle title: String?,
        message: String?,
        style: UIAlertController.Style,
        completionHandler: @escaping (String) -> Void
    ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        alertController.addTextField { textField in
            textField.placeholder = Constants.placeHolder
        }
        
        let search = UIAlertAction(title: Constants.titleAlert, style: .default) { action in
            let textField = alertController.textFields?.first
            guard let cityName = textField?.text else { return }
            guard cityName != "" else { return }
            let city = cityName.split(separator: " ").joined(separator: "%20")
            completionHandler(city)
        }
        
        let cancel = UIAlertAction(title: Constants.titleCancelButton, style: .cancel, handler: nil)
        
        alertController.addAction(search)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
}
