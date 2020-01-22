//
//  DirectionManager.swift
//  RPGWatchOs
//
//  Created by Lukile on 16/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import Foundation
import UIKit
import WatchConnectivity

class DirectionManager: Observer {
    let CONST_MVMT: CGFloat = 30
    let CONST_DURATION: TimeInterval = 0.3
    
    let CONST_MARGIN: CGFloat = 35
    
    var requestState: String = ""
    
    func goUp(heroImage: UIImageView, gameArea: UIView){
        DispatchQueue.main.async {
            
            if(heroImage.frame.minY > 0) {
                UIView.animate(withDuration: self.CONST_DURATION, animations: {heroImage.frame.origin.y -= self.CONST_MVMT})
            } else {
                print("Image goes out of screen on the top")
            }
        }
    }
    
    func goDown(heroImage: UIImageView, gameArea: UIView) {
        DispatchQueue.main.async {
            if heroImage.frame.maxY < gameArea.frame.size.height - (heroImage.frame.size.height / 2) {
                UIView.animate(withDuration: self.CONST_DURATION, animations: {heroImage.frame.origin.y += self.CONST_MVMT})
            } else {
                print("Image goes out of screen on the bottom")
            }
        }
    
    }
    
    func goLeft(heroImage: UIImageView, gameArea: UIView) {
        DispatchQueue.main.async {
            
            if(heroImage.frame.minX > 0) {
                UIView.animate(withDuration: self.CONST_DURATION, animations: {heroImage.frame.origin.x -= self.CONST_MVMT})
            } else {
                print("Image goes out of screen on the left")
            }
        }
    }
    
    func goRight(heroImage: UIImageView, gameArea: UIView) {
        DispatchQueue.main.async {
            if (heroImage.frame.maxX < gameArea.frame.size.width) {
                UIView.animate(withDuration: self.CONST_DURATION, animations: {heroImage.frame.origin.x += self.CONST_MVMT})
            } else {
                print("Image goes out of screen on the right")
            }
        }
    }
    
    func update() {
        print("in update direction :  \(self.requestState) reacted to event")  
    }
   
    func movement(heroImage: UIImageView, gameArea: UIView, replyHandler: @escaping ([String : Any]) -> Void) {
        
        switch self.requestState {
            case "up":
                replyHandler(["message" : "going up"])
                self.goUp(heroImage: heroImage, gameArea: gameArea)
                break
            case "down":
                replyHandler(["message" : "going down"])
                self.goDown(heroImage: heroImage, gameArea: gameArea)
                break
            case "left":
                replyHandler(["message" : "going left"])
                self.goLeft(heroImage: heroImage, gameArea: gameArea)
                break
            case "right":
                replyHandler(["message" : "going right"])
                self.goRight(heroImage: heroImage, gameArea: gameArea)
                break
            default:
                break
        }
    }
}

