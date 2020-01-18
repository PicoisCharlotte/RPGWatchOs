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
    
    var potion: Bool = false

    
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
    
    func takeDamage(damage: Int){
        self.hpMonster -= damage
    }
    
    func hasPotion(image: UIImageView) -> Bool {
        if(Bool.random()) {
            image.image = UIImage(named: "potion")
            return true
        } else {
            image.removeFromSuperview()
            return false
        }
    }
    
    func defeatMonster(monsters: [Monster], image: UIImageView, monsterName: String, monsterLabel: UILabel, chestImage: UIImageView?) -> [Monster] {
        var monstersList = monsters
        if(self.hpMonster <= 0){
            if let index = monstersList.firstIndex(where: {
                $0.imageMonster == self.imageMonster
            }){
                
                monstersList.remove(at: index)
                monsterLabel.text = monsterName + " has been defeated"
            }
        }

        if monstersList.count == 0 {
            chestImage!.image = UIImage(named: "lockchest")
        }
        
        return monstersList
    }
    
    enum TypeMonster: String {
        case babyMonster = "babyMonster"
        case juniorMonster = "juniorMonster"
        case seniorMonster = "seniorMonster"
        case bossMonster = "boss"
        
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


