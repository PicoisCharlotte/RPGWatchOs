//
//  Hero.swift
//  watchOs Extension
//
//  Created by Lukile on 06/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import Foundation
import UIKit

class Hero : Fight, Observer {
    let CONST_LABEL_HERO: String = "Hero HP : "
    
    var hpHero: Int
    var damageHero: Int = 5
    var imageHero: UIImage = UIImage(named: "hero")!
    
    var requestState: String = ""
    
    private var timer: Timer?
    
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
    
    func initHp() -> String {
        return String(self.hpHero)
    }
    
    func setLabelInitHp(label: UILabel, heroMaxHp: String) {
        label.text = CONST_LABEL_HERO + self.initHp() + " / " + heroMaxHp
    }
    
    func updateHp(label: UILabel, heroMaxHp: String) {
        label.text = CONST_LABEL_HERO + self.initHp() + " / " + heroMaxHp
    }
    
    func zeroHp(label: UILabel, heroMaxHp: String) {
        label.text = CONST_LABEL_HERO + " 0 / " + heroMaxHp
    }
    
    func update() {
        print("in hero : \(self.requestState) reacted to event")
    }
    
    func usesPotion(heroLabel: UILabel, heroMaxHp: String, replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            print("self.requestState  POTION : \(self.requestState )")
            if self.requestState == "potion" {
            heroLabel.text = String(self.hpHero)
            
            let gap = Int(heroMaxHp)! - self.hpHero
            if gap <= 10 {
                self.hpHero += gap
            } else {
                self.hpHero += 10
            }
            self.updateHp(label: heroLabel, heroMaxHp:  heroMaxHp)
            
            
                replyHandler(["message" : "USE POTION"])
            }
        }
     
    }
    
    func usePotion(heroLabel: UILabel, heroMaxHp: String) {
        DispatchQueue.main.async {
            heroLabel.text = String(self.hpHero)
            
            let gap = Int(heroMaxHp)! - self.hpHero
            if gap <= 10 {
                self.hpHero += gap
            } else {
                self.hpHero += 10
            }
            self.updateHp(label: heroLabel, heroMaxHp:  heroMaxHp)
        }
    }
    
   
}
