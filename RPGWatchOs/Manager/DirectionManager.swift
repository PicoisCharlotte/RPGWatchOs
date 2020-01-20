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
    let CONST_MVMT: CGFloat = 30
    let CONST_DURATION: TimeInterval = 0.3
    
    let CONST_MARGIN: CGFloat = 35
    
    func goUp(heroImage: UIImageView, gameArea: UIView){
        DispatchQueue.main.async {
            
            if(heroImage.frame.minY + heroImage.frame.maxY + self.CONST_MVMT > gameArea.frame.minY) {
                UIView.animate(withDuration: self.CONST_DURATION, animations: {heroImage.frame.origin.y -= self.CONST_MVMT})
            } else {
                print("Image goes out of screen on the top")
            }
        }
    }
    
    func goDown(heroImage: UIImageView, gameArea: UIView) {
        DispatchQueue.main.async {
            if heroImage.frame.maxY + heroImage.frame.height < gameArea.frame.height {
                UIView.animate(withDuration: self.CONST_DURATION, animations: {heroImage.frame.origin.y += self.CONST_MVMT})
            } else {
                print("Image goes out of screen on the bottom")
            }
        }
    
    }
    
    func goLeft(heroImage: UIImageView, gameArea: UIView) {
        DispatchQueue.main.async {
            
            if(heroImage.frame.maxX - heroImage.frame.width  > gameArea.frame.minX + self.CONST_MARGIN) {
                UIView.animate(withDuration: self.CONST_DURATION, animations: {heroImage.frame.origin.x -= self.CONST_MVMT})
            } else {
                print("Image goes out of screen on the left")
            }
        }
    }
    
    func goRight(heroImage: UIImageView, gameArea: UIView) {
        DispatchQueue.main.async {
            if (heroImage.frame.maxX < gameArea.frame.maxX - self.CONST_MARGIN) {
                UIView.animate(withDuration: self.CONST_DURATION, animations: {heroImage.frame.origin.x += self.CONST_MVMT})
            } else {
                print("Image goes out of screen on the right")
            }
        }
    }
    
 
}
