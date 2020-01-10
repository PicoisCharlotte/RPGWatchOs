//
//  Hero.swift
//  watchOs Extension
//
//  Created by Lukile on 06/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import Foundation
import UIKit

class Hero : Fight{
    
    var hpHero: Int
    var damageHero: Int = 5
    var imageHero: UIImage = UIImage(named: "hero")!
    
    init(hp: Int, damage: Int) {
        self.hpHero = hp
        self.damageHero = damage
    }
    
    func attack() -> Int {
        let lower = self.damageHero - 2
        let upper = self.damageHero + 2
        return Int(arc4random_uniform(UInt32(upper - lower))) + lower
    }
    
    func takeDamage(damage: Int) {
        self.hpHero -= damage
    }
}
