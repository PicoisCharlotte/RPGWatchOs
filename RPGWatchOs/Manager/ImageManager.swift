//
//  ImageManager.swift
//  RPGWatchOs
//
//  Created by Lukile on 18/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import Foundation
import UIKit

class ImageManager {
    
    func checkIfIsOnImage(heroImage: UIImageView, image: UIImageView) -> Bool {
        let computeHeroFrame = heroImage.frame.maxX
            + heroImage.frame.minX
            + heroImage.frame.width
        let computeImageFrame = image.frame.minX + image.frame.maxX
        
        if heroImage.frame.maxY >= image.frame.minY
            && heroImage.frame.maxY <= image.frame.maxY
            && heroImage.frame.maxX <= image.frame.maxX
            && computeHeroFrame >= computeImageFrame {
            
            return true
        }
        return false
    }
}
