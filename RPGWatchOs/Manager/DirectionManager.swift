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
}
