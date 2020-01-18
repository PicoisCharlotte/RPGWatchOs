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
    
    var isBoss: Bool = true
    
    @IBOutlet var hpBossLabel: UILabel!
    @IBOutlet var hpHeroLabel: UILabel!
        
    @IBOutlet var gameArea: UIView!
    
    @IBOutlet var hero: UIImageView!
    @IBOutlet var boss: UIImageView!
    @IBOutlet var victory: UIImageView!
    
    @IBOutlet var gameOver: UIImageView!
    @IBOutlet var victoryScreen: UIImageView!
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
        
         self.heroDeclaration.setLabelInitHp(label: self.hpHeroLabel, heroMaxHp: self.heroMaxHp)
        
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
        switch message["request"] as? String {
        case "up":
            replyHandler(["message" : "going up"])
            directionManager.goUp(heroImage: self.hero, gameArea: self.gameArea)
            break
        case "down":
            replyHandler(["message" : "going down"])
            directionManager.goDown(heroImage: self.hero, gameArea: self.gameArea)
            break
        case "left":
            replyHandler(["message" : "going left"])
            directionManager.goLeft(heroImage: self.hero, gameArea: self.gameArea)
            break
        case "right":
            replyHandler(["message" : "going right"])
            directionManager.goRight(heroImage: self.hero, gameArea: self.gameArea)
            break
        case "potion":
            replyHandler(["message" : "USE POTION"])
            self.heroDeclaration.usePotion(heroLabel: self.hpHeroLabel, heroMaxHp: self.heroMaxHp)
            break
        case "action":
            DispatchQueue.main.async {
                var damageTakenByMonster: Int = self.heroDeclaration.attack()
                
                if self.monsters.count == 0 {
                    self.gameOver.image = UIImage(named: "win")
                    
                } else if self.imageManager.checkIfIsOnImage(heroImage: self.hero, image: self.boss)
                    && self.bossDeclaration.hpMonster > 0 {
                    let bossName: String = (Monster.TypeMonster.bossMonster).rawValue + " : "
                    self.bossDeclaration.takeDamage(damage: damageTakenByMonster)
                    self.hpBossLabel.text = bossName + String(self.bossDeclaration.hpMonster) + " / " + self.bossMaxHp
                    
                    if self.bossDeclaration.hpMonster <= 0
                        && self.heroDeclaration.hpHero > 0 {
                        removeFromSuperviewWin()
                    }
                    
                    guard self.timer == nil else { return }
                    self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                        timer in self.heroDeclaration.takeDamage(damage: self.bossDeclaration.attack())
                        
                        self.heroDeclaration.updateHp(label: self.hpHeroLabel, heroMaxHp: self.heroMaxHp)
                        
                        stopTimer(monster: self.bossDeclaration)
                    }
                    
                }
            }
            break
        default:
            break
        }
        
        func stopTimer(monster: Monster) {
            if self.heroDeclaration.hpHero <= 0 || monster.hpMonster <= 0 {
                
                if self.heroDeclaration.hpHero <= 0 {
                    DispatchQueue.main.async {
                        self.hero.removeFromSuperview()
                         self.heroDeclaration.zeroHp(label: self.hpHeroLabel, heroMaxHp: self.heroMaxHp)
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
        
        func removeFromSuperviewWin() {
            self.boss.removeFromSuperview()
            self.victory.image = UIImage(named: "victory")
            self.hero.removeFromSuperview()
            self.victoryScreen.image = UIImage(named: "win")
            self.gameArea.removeFromSuperview()
            self.hpBossLabel.removeFromSuperview()
            self.hpHeroLabel.removeFromSuperview()
        }
    }
}
