//
//  BossSceneViewController.swift
//  RPGWatchOs
//
//  Created by Lukile on 14/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import UIKit
import WatchConnectivity
import HomeKit

class BossSceneViewController: UIViewController {
    let CONST_MONSTER_HP: String = "-- / --"
    let CONST_LABEL_HERO: String = "Hero HP : "
    
    var heroHpFromPreviousScene: Int = 0
    var heroDamageFromPreviousScene: Int = 0
    
    var heroDeclaration: Hero = Hero(hp: 0, damage: 0)

    var bossDeclaration: Monster = Monster.TypeMonster.bossMonster.instance
    
    var heroMaxHp: String = ""
    var bossMaxHp: String = ""
    
    var monsters: [Monster] = []


    @IBOutlet var hpBossLabel: UILabel!
    @IBOutlet var hpHeroLabel: UILabel!
    
    @IBOutlet var label: UILabel!
    
    @IBOutlet var gameArea: UIView!
    
    @IBOutlet var hero: UIImageView!
    @IBOutlet var boss: UIImageView!
    
    @IBOutlet var gameOver: UIImageView!
    
    private var session = WCSession.default

    private var timer: Timer?

    func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.heroDeclaration.hpHero = heroHpFromPreviousScene
        self.heroDeclaration.damageHero = heroDamageFromPreviousScene
        self.bossMaxHp = String(self.bossDeclaration.hpMonster)
        
        self.monsters.append(bossDeclaration)
        
        if isSuported() {
            session.delegate = self
            session.activate()
        }
        
        hero.image = heroDeclaration.imageHero
        boss.image = UIImage(named: "bossfinal")
        
        self.hpHeroLabel.text = CONST_LABEL_HERO + String(self.heroDeclaration.hpHero) + " / " + self.heroMaxHp
        self.hpBossLabel.text = CONST_MONSTER_HP
        
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
        
    }
}

extension BossSceneViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
         print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        if message["request"] as? String == "up" {
            
            
            
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                self.label.text = "up pressed"
                print("imageView minY : \(self.hero.frame.minY)")
                print("imageView minY + height : \(self.hero.frame.minY + self.hero.frame.height)")
                print("gameArea minY : \(self.gameArea.frame.minY)")
                
                if(self.hero.frame.minY > self.gameArea.frame.minY) {
                    UIView.animate(withDuration: 0.3, animations: {self.hero.frame.origin.y -= 30})
                } else {
                    print("Image goes out of screen on the top")
                }
            }
            
        }
        
        if message["request"] as? String == "left" {
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                self.label.text = "left pressed"
                if(self.hero.frame.maxX - self.hero.frame.width > self.gameArea.frame.minX) {
                    UIView.animate(withDuration: 0.3, animations: {self.hero.frame.origin.x -= 30})
                } else {
                    print("Image goes out of screen on the left")
                }
            }
        }
        
        if message["request"] as? String == "right" {
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                if (self.hero.frame.maxX < self.gameArea.frame.maxX) {
                    self.label.text = "right pressed"
                    UIView.animate(withDuration: 0.3, animations: {self.hero.frame.origin.x += 30})
                } else {
                    print("Image goes out of screen on the right")
                }
            }
        }
        
        if message["request"] as? String == "down" {
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                self.label.text = "down pressed"
                
                if self.hero.frame.maxY + self.hero.frame.height < self.gameArea.frame.height {
                    UIView.animate(withDuration: 0.3, animations: {self.hero.frame.origin.y += 30})
                } else {
                    print("Image goes out of screen on the bottom")
                }
            }
        }
        
        if message["request"] as? String == "action" {
            DispatchQueue.main.async {
                
                self.label.text = "action pressed"
                var damageTakenByMonster: Int = self.heroDeclaration.attack()
                
                if self.monsters.count == 0 {
                    self.gameOver.image = UIImage(named: "win")
                    
                } else if checkIfIsOnImage(image: self.boss)
                    && self.bossDeclaration.hpMonster > 0 {
                    let bossName: String = (Monster.TypeMonster.bossMonster).rawValue + " : " + self.bossDeclaration.takeDamage(damage: damageTakenByMonster)
                    
                }
            }
        }
    }
    
    
}