//
//  CitiesViewController.swift
//  Sunny
//
//  Created by Harbros38 on 3/22/21.
//  Copyright © 2021 Ivan Akulov. All rights reserved.
//

import UIKit

class CitiesViewController: UIViewController {
    
    private let tableview = UITableView()
    private let identifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createFrames()
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableview)
    }
    
    private func createFrames() {
        tableview.frame = UIScreen.main.bounds
        let background = UIView()
        background.frame = UIScreen.main.bounds
        let backgroundImage = UIImageView(image: UIImage(named: "background"))
        backgroundImage.frame = background.frame
        background.addSubview(backgroundImage)
        tableview.backgroundView = background
    }
}

extension CitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        let vc = navigationController?.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.city = MockCities.shared.cities[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CitiesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MockCities.shared.cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        cell.textLabel?.text = MockCities.shared.cities[indexPath.row]
        cell.backgroundColor = .clear
        return cell
    }
}
