//
//  UIImageView.swift
//  Puplo Pro
//
//  Created by Ahmed on 18/11/2025.
//

import Foundation
import UIKit
import Kingfisher
// MARK: - load image function using kingfisher
extension UIImageView{
    func loadImage(_ url : URL?) {
        self.kf.setImage(
            with: url,
            placeholder: UIImage(named: "logo"),
            options: [.scaleFactor(UIScreen.main.scale),.transition(.fade(1)),.cacheOriginalImage])
            self.kf.indicatorType = .activity
     }
  }
