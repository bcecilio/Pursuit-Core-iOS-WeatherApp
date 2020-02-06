//
//  WeatherController.swift
//  WeatherApp
//
//  Created by Brendon Cecilio on 1/31/20.
//  Copyright © 2020 David Rifkin. All rights reserved.
//

import UIKit

class WeatherController: UIViewController {
    
    @IBOutlet weak var placenameLabel: UILabel!
    
    private let weatherView = WeatherView()
    
    private var photos = [Picture]()
    
    var weatherData = [DailyDatum]() {
        didSet {
            DispatchQueue.main.async {
                self.weatherView.collectionView.reloadData()
            }
        }
    }
    var zipcodeQuery = String() {
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
        loadData(zipcodeQuery: "90210")
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
    
    public func loadData(zipcodeQuery: String) {
        ZipCodeHelper.getLatLong(fromZipCode: zipcodeQuery) { [weak self] (result) in
            switch result {
            case .failure(let fetchingError):
                print("\(fetchingError)")
            case .success(let location):
                self?.getWeather(lat: location.lat, long: location.long, placeName: location.placeName)
//                self?.placenameLabel.text = location.placeName
            }
        }
    }
    
    public func loadPhotos(photos: String) {
        WeatherAPIClient.getPhotos(photos: photos) { (result) in
            switch result {
            case .failure(let appError):
                print("\(appError)")
            case .success(let photos):
                self.photos = photos
            }
        }
    }
}

extension WeatherController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherData.count
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailStoryboard = UIStoryboard(name: "Detail", bundle: nil)
        guard let detailVC = detailStoryboard.instantiateViewController(identifier: "DetailController") as? DetailController else {
            fatalError("could not downcast to DETAILCONTROLLER")
        }
        detailVC.detailData = weatherData[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension WeatherController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let searchText = textField.text else {
            print("no text")
            return true
        }
        zipcodeQuery = searchText
        return true
    }
}
