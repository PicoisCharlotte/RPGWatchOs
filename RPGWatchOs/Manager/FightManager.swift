//
//  FightManager.swift
//  RPGWatchOs
//
//  Created by PicoisCharlotte on 07/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import Foundation
import UIKit
import WatchConnectivity

class FightManager {
    private var session = WCSession.default
    
    private var isChestOpened: Bool = false
    
    var imageManager: ImageManager = ImageManager()
    
    func openChest(monsters: [Monster], hero: UIImageView, chest: UIImageView) -> Bool {
        if monsters.count == 0
            && self.imageManager.checkIfIsOnImage(heroImage: hero, image: chest)
            && !self.isChestOpened {
            chest.image = UIImage(named: "openchest")
            self.isChestOpened = true
            return true
        }
        return false
    }
    
    
}

protocol Fight {
    func attack() -> Int
    func takeDamage(damage: Int)
}
