//
//  FavoritesCell.swift
//  WeatherApp
//
//  Created by Brendon Cecilio on 2/7/20.
//  Copyright © 2020 David Rifkin. All rights reserved.
//

import UIKit
import ImageKit

class FavoritesCell: UICollectionViewCell {
    
    @IBOutlet weak var favoriteImageView: UIImageView!
    
    public func configureCell(for image: Picture) {
        favoriteImageView.getImage(with: image.largeImageURL) { [weak self] (result) in
            switch result {
            case .failure(_):
                DispatchQueue.main.async {
                    self?.favoriteImageView.image = UIImage(systemName: "exclamationmark.fill")
                }
            case .success(let image):
                DispatchQueue.main.async {
                    self?.favoriteImageView.image = image
                }
            }
        }
    }
}
