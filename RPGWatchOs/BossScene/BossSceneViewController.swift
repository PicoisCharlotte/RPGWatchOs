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
    
    var directionManager: DirectionManager = DirectionManager()
    var imageManager: ImageManager = ImageManager()
    
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
    @IBOutlet var victory: UIImageView!
    
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
            replyHandler(["message" : "going up"])
            
            directionManager.goUp(heroImage: self.hero, gameArea: self.gameArea)
        }
        
        if message["request"] as? String == "left" {
            replyHandler(["message" : "going left"])
            
           directionManager.goLeft(heroImage: self.hero, gameArea: self.gameArea)
        }
        
        if message["request"] as? String == "right" {
            replyHandler(["message" : "going right"])
            
            directionManager.goRight(heroImage: self.hero, gameArea: self.gameArea)
        }
        
        if message["request"] as? String == "down" {
            replyHandler(["message" : "going down"])
            
            directionManager.goDown(heroImage: self.hero, gameArea: self.gameArea)

        }
        
        if message["request"] as? String == "potion" {
            replyHandler(["message" : "USE POTION"])
            
            self.heroDeclaration.usePotion(heroLabel: self.hpHeroLabel, heroMaxHp: self.heroMaxHp)
        }
        
        if message["request"] as? String == "action" {
            DispatchQueue.main.async {
                
                var damageTakenByMonster: Int = self.heroDeclaration.attack()
                
                if self.monsters.count == 0 {
                    self.gameOver.image = UIImage(named: "win")
                    
                } else if self.imageManager.checkIfIsOnImage(heroImage: self.hero, image: self.boss)
                    && self.bossDeclaration.hpMonster > 0 {
                    let bossName: String = (Monster.TypeMonster.bossMonster).rawValue + " : "
                    self.bossDeclaration.takeDamage(damage: damageTakenByMonster)
                    self.hpBossLabel.text = bossName + String(self.bossDeclaration.hpMonster) + " / " + self.bossMaxHp
                    
                    defeatMonster(monster: self.bossDeclaration, image: self.boss, monsterName: bossName)
                    
                    guard self.timer == nil else { return }
                    self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                        timer in self.heroDeclaration.takeDamage(damage: self.bossDeclaration.attack())
                        
                        self.hpHeroLabel.text = self.CONST_LABEL_HERO + String(self.heroDeclaration.hpHero) + " / " + self.heroMaxHp
                        
                        stopTimer(monster: self.bossDeclaration)
                    }
                    
                }
            }
        }
        
        func stopTimer(monster: Monster) {
            if self.heroDeclaration.hpHero <= 0 || monster.hpMonster <= 0 {
                
                if self.heroDeclaration.hpHero <= 0 {
                    DispatchQueue.main.async {
                        self.hero.isHidden = true
                        self.hpHeroLabel.text = self.CONST_LABEL_HERO + " 0 / " + self.heroMaxHp
                        self.gameOver.image = UIImage(named: "died")
                        session.sendMessage(["msg" : "GameOver"], replyHandler: nil) { (error) in
                            print("Error sending message: \(error)")
                        }
                    }
                }
                self.timer?.invalidate()
                self.timer = nil
            }
        }
        
        func defeatMonster(monster: Monster, image: UIImageView, monsterName: String) {
            
            if(monster.hpMonster <= 0){
                if let index = self.monsters.firstIndex(where: {
                    $0.imageMonster == monster.imageMonster
                }){
                    
                    self.monsters.remove(at: index)
                    self.hpBossLabel.text = monsterName + " has been defeated"
                    
                }
            }
            
            if monster.hpMonster <= 0
                && self.heroDeclaration.hpHero > 0 {
                image.isHidden = true
                victory.image = UIImage(named: "victory")
                hero.isHidden = true
                gameOver.image = UIImage(named: "win")
                
            }
        }
    }
}
