//
//  DirectionManager.swift
//  RPGWatchOs
//
//  Created by Lukile on 16/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import Foundation
import UIKit

class DirectionManager {
    func goUp(heroImage: UIImageView, gameArea: UIView){
        DispatchQueue.main.async {
            if(heroImage.frame.minY > gameArea.frame.minY) {
                UIView.animate(withDuration: 0.3, animations: {heroImage.frame.origin.y -= 30})
            } else {
                print("Image goes out of screen on the top")
            }
        }
    }
    
    func goDown(heroImage: UIImageView, gameArea: UIView) {
        DispatchQueue.main.async {
            if heroImage.frame.maxY + heroImage.frame.height < gameArea.frame.height {
                UIView.animate(withDuration: 0.3, animations: {heroImage.frame.origin.y += 30})
            } else {
                print("Image goes out of screen on the bottom")
            }
        }
    
    }
    
    func goLeft(heroImage: UIImageView, gameArea: UIView) {
        DispatchQueue.main.async {
            
            if(heroImage.frame.maxX - heroImage.frame.width > gameArea.frame.minX) {
                UIView.animate(withDuration: 0.3, animations: {heroImage.frame.origin.x -= 30})
            } else {
                print("Image goes out of screen on the left")
            }
        }
    }
    
    func goRight(heroImage: UIImageView, gameArea: UIView) {
        DispatchQueue.main.async {
            if (heroImage.frame.maxX < gameArea.frame.maxX) {
                UIView.animate(withDuration: 0.3, animations: {heroImage.frame.origin.x += 30})
            } else {
                print("Image goes out of screen on the right")
            }
        }
    }
    
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
