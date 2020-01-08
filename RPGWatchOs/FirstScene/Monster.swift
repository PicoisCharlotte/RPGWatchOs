//
//  Monster.swift
//  watchOs Extension
//
//  Created by Lukile on 06/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import Foundation
import UIKit

class Monster : Fight {
    
    var hpMonster: Int
    var damageMonster: Int = 5
    var imageMonster: UIImage
    
    init(hp: Int, damage: Int, image: UIImage!) {
        self.hpMonster = hp
        self.damageMonster = damage
        self.imageMonster = image
    }
    
    func attack() -> Int{
        let lower = self.damageMonster - 2
        let upper = self.damageMonster + 2
        return Int(arc4random_uniform(UInt32(upper - lower))) + lower
    }
    
    func hadPotion() -> Bool {
        let potion = Bool.random()
        if potion {
            return true
        }
        return false
    }
    
    func takeDamage(damage: Int){
        self.hpMonster -= damage
    }
    
    enum TypeMonster: String {
        case babyMonster = "babyMonster"
        case juniorMonster = "juniorMonster"
        case seniorMonster
        case bossMonster
        
        var instance: Monster {
            switch self {
            case .babyMonster: return Monster(hp: 10, damage: 5, image: UIImage(named: "babymonster"))
                
            case .juniorMonster: return Monster(hp: 15, damage: 6, image: UIImage(named: "juniormonster")!)
                
            case .seniorMonster: return Monster(hp: 20, damage: 10,  image: UIImage(named: "seniormonster")!)
                
            case .bossMonster: return Monster(hp: 30, damage: 20,  image: UIImage(named: "bossfinal"))
            }
        }
    }
}


