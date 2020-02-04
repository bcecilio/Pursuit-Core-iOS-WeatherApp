//
//  WeatherController.swift
//  WeatherApp
//
//  Created by Brendon Cecilio on 1/31/20.
//  Copyright © 2020 David Rifkin. All rights reserved.
//

import UIKit

class WeatherController: UIViewController {
    
    private let weatherView = WeatherView()
    
    var weatherData = [DailyDatum]() {
        didSet {
            DispatchQueue.main.async {
                self.weatherView.collectionView.reloadData()
            }
        }
    }
    var zipcodeQuery = "11377" {
        didSet {
            loadData(zipcodeQuery: zipcodeQuery)
        }
    }
    
    override func loadView() {
        view = weatherView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        navigationItem.title = "Weather"
        weatherView.collectionView.register(UINib(nibName: "WeatherCell", bundle: nil), forCellWithReuseIdentifier: "weatherCell")
        weatherView.collectionView.delegate = self
        weatherView.collectionView.dataSource = self
        weatherView.textField.delegate = self
        loadData(zipcodeQuery: zipcodeQuery)
    }
    
    private func getWeather(lat: Double, long: Double, placeName: String) {
        WeatherAPIClient.getWeather(lat: lat, long: long) { [weak self] (result) in
            switch result {
            case .failure(let appError):
                print("\(appError)")
            case .success(let weather):
                self?.weatherData = weather.daily.data
            }
        }
    }
    
    private func loadData(zipcodeQuery: String) {
        ZipCodeHelper.getLatLong(fromZipCode: zipcodeQuery) { [weak self] (result) in
            switch result {
            case .failure(let fetchingError):
                print("\(fetchingError)")
            case .success(let location):
                self?.getWeather(lat: location.lat, long: location.long, placeName: location.placeName)
            }
        }
    }
}

extension WeatherController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath) as? WeatherCell else {
            fatalError("could not dequeue WeatherCell")
        }
        let weatherCell = weatherData[indexPath.row]
        cell.configureCell(weatherData: weatherCell)
        cell.layer.cornerRadius = 7
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxSize: CGSize = UIScreen.main.bounds.size
        let itemWidth: CGFloat = maxSize.width * 1.0
        return CGSize(width: itemWidth, height: 450)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

extension WeatherController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchText = textField.text else {
            print("no text")
            return true
        }
        zipcodeQuery = searchText
        return true
    }
}
