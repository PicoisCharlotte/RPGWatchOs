//
//  FirstSceneViewController.swift
//  RPGWatchOs
//
//  Created by Lukile on 01/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import UIKit
import WatchConnectivity

class FirstSceneViewController: UIViewController {
    let screensize: CGRect = UIScreen.main.bounds
    @IBOutlet var gameOverImageView: UIImageView!
    
    let CONST_MONSTER_HP: String = "-- / --"
    let CONST_LABEL_HERO: String = "Hero HP : "
    var monsterLabel: String = ""
    
    var babyMonsterDeclaration: Monster = Monster.TypeMonster.babyMonster.instance
    var juniorMonsterDeclaration: Monster = Monster.TypeMonster.juniorMonster.instance
    var heroDeclaration: Hero = Hero(hp: 300, damage: 5)

    var heroMaxHp: String = ""
    var babymonsterMaxHp: String = ""
    var juniormonsterMaxHp: String = ""
    
    private var potion: Bool = false
    
    var monsters: [Monster] = []

    @IBOutlet var label: UILabel!
    
    private var allMonstersBeaten: Bool = false
    
    private var session = WCSession.default
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var chest: UIImageView!
    @IBOutlet var lock: UIImageView!
    
    @IBOutlet var gameArea: UIView!
    
    @IBOutlet var babyMonster: UIImageView!
    @IBOutlet var juniorMonster: UIImageView!
    @IBOutlet var hero: UIImageView!
    
    private var isChestOpen: Bool = false
    private var timer: Timer?
    
    @IBOutlet var hpHeroLabel: UILabel!
    @IBOutlet var hpMonsterLabel: UILabel!
    
    func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    var tempValue: CGFloat = 0
    var currDir: Void?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.heroMaxHp = String(self.heroDeclaration.hpHero)
        self.babymonsterMaxHp = String(self.babyMonsterDeclaration.hpMonster)
        self.juniormonsterMaxHp = String(self.juniorMonsterDeclaration.hpMonster)

        self.monsters.append(babyMonsterDeclaration)
        self.monsters.append(juniorMonsterDeclaration)
        
        if isSuported() {
            session.delegate = self
            session.activate()
        }
        
        hero.image = heroDeclaration.imageHero
        babyMonster.image = babyMonsterDeclaration.imageMonster
        juniorMonster.image = juniorMonsterDeclaration.imageMonster
        lock.image = UIImage(named: "yellowlocklocked")
        
        self.hpHeroLabel.text = CONST_LABEL_HERO + heroMaxHp + " / " + heroMaxHp
        self.hpMonsterLabel.text = CONST_MONSTER_HP
        
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
    }


}

extension FirstSceneViewController: WCSessionDelegate {
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
                print("imageView minY : \(self.imageView.frame.minY)")
                print("imageView minY + height : \(self.imageView.frame.minY + self.imageView.frame.height)")
                print("gameArea minY : \(self.gameArea.frame.minY)")
                
                if(self.imageView.frame.minY > self.gameArea.frame.minY) {
                UIView.animate(withDuration: 0.3, animations: {self.imageView.frame.origin.y -= 30})
                } else {
                    print("Image goes out of screen on the top")
                }
            }
          
        }
        
        if message["request"] as? String == "left" {
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                self.label.text = "left pressed"
                if(self.imageView.frame.maxX - self.imageView.frame.width > self.gameArea.frame.minX) {
                UIView.animate(withDuration: 0.3, animations: {self.imageView.frame.origin.x -= 30})
                } else {
                     print("Image goes out of screen on the left")
                }
            }
        }
        
        if message["request"] as? String == "right" {
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                if (self.imageView.frame.maxX < self.gameArea.frame.maxX) {
                self.label.text = "right pressed"
                UIView.animate(withDuration: 0.3, animations: {self.imageView.frame.origin.x += 30})
                } else {
                    print("Image goes out of screen on the right")
                }
            }
        }
        
        if message["request"] as? String == "down" {
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                self.label.text = "down pressed"
             
                if self.imageView.frame.maxY + self.imageView.frame.height < self.gameArea.frame.height {
                UIView.animate(withDuration: 0.3, animations: {self.imageView.frame.origin.y += 30})
                } else {
                    print("Image goes out of screen on the bottom")
                }
            }
        }
        
        if message["request"] as? String == "potion" {
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                self.hpHeroLabel.text = String(self.heroDeclaration.hpHero)

                let gap = Int(self.heroMaxHp)! - self.heroDeclaration.hpHero
                if gap <= 10 {
                    self.heroDeclaration.hpHero += gap
                } else {
                    self.heroDeclaration.hpHero += 10
                }
                
                self.hpHeroLabel.text = self.CONST_LABEL_HERO + String(self.heroDeclaration.hpHero) + " / " + self.heroMaxHp
            }
        }
        
        if message["request"] as? String == "action" {
            DispatchQueue.main.async {
                self.label.text = "action pressed"
                var damageTakenByMonster: Int = self.heroDeclaration.attack()
                
                if self.monsters.count == 0
                    && checkIfIsOnImage(image: self.chest)
                    && !self.isChestOpen {
                    replyHandler(["item" : "yellow key"])
                    self.chest.image = UIImage(named: "openchest")
                    
                    self.isChestOpen = true
                    
                } else if (checkIfIsOnImage(image: self.babyMonster)) {
                        if self.babyMonsterDeclaration.hpMonster > 0 {

                        let monsterName: String = (Monster.TypeMonster.babyMonster).rawValue + " : "
                        self.babyMonsterDeclaration.takeDamage(damage: damageTakenByMonster)
                        self.hpMonsterLabel.text = monsterName + String(self.babyMonsterDeclaration.hpMonster) + " / " + self.babymonsterMaxHp
                       
                        defeatMonster(monster: self.babyMonsterDeclaration, image: self.babyMonster, monsterName: monsterName)
                        
                        

                        guard self.timer == nil else { return }
                        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                            timer in self.heroDeclaration.takeDamage(damage: self.babyMonsterDeclaration.attack())
                            
                                self.hpHeroLabel.text = self.CONST_LABEL_HERO + String(self.heroDeclaration.hpHero) + " / " + self.heroMaxHp
                            
                            stopTimer(monster: self.babyMonsterDeclaration)
                            
                        }
                
                        print("AFTER DEAFEAT  -> self.heroDeclaration.hpHero \(self.heroDeclaration.hpHero)")

                    }
                    
                    if self.potion {
                        replyHandler(["item" : "potion"])
                        self.potion = false
                        self.babyMonster.isHidden = true
                    }
                    
                } else if (checkIfIsOnImage(image: self.juniorMonster)) {
                    if self.juniorMonsterDeclaration.hpMonster > 0 {
                    
                        let monsterName: String = (Monster.TypeMonster.juniorMonster).rawValue + " : "
                        
                        self.juniorMonsterDeclaration.takeDamage(damage: damageTakenByMonster)
                        
                        self.hpMonsterLabel.text = monsterName + String(self.juniorMonsterDeclaration.hpMonster) + " / " + self.juniormonsterMaxHp
                       
                        
                        defeatMonster(monster: self.juniorMonsterDeclaration, image: self.juniorMonster, monsterName: monsterName)
                        
                        
                        guard self.timer == nil else { return }
                        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                            timer in self.heroDeclaration.takeDamage(damage: self.juniorMonsterDeclaration.attack())
                            
                            self.hpHeroLabel.text = self.CONST_LABEL_HERO + String(self.heroDeclaration.hpHero) + " / " + self.heroMaxHp
                            
                            stopTimer(monster: self.juniorMonsterDeclaration)
                            
                        }
                        
                        print("AFTER DEAFEAT  -> self.heroDeclaration.hpHero \(self.heroDeclaration.hpHero)")

                    }
                    if self.potion {
                        replyHandler(["item" : "potion"])
                        self.potion = false
                        self.juniorMonster.isHidden = true
                    }
                }
                
                
               
            }
        }
        
        func stopTimer(monster: Monster) {
            if self.heroDeclaration.hpHero <= 0 || monster.hpMonster <= 0 {
                
                if self.heroDeclaration.hpHero <= 0 {
                    DispatchQueue.main.async {
                        self.imageView.isHidden = true
                        self.label.isHidden = true
                        self.hpHeroLabel.text = self.CONST_LABEL_HERO + " 0 / " + self.heroMaxHp
                        self.gameOverImageView.image = UIImage(named: "died")
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
                    self.hpMonsterLabel.text = monsterName + " has been defeated"
                }
              
            }
            
            if monster.hpMonster <= 0 {
                if(monster.hadPotion()) {
                    image.image = UIImage(named: "potion")
                    self.potion = true
                } else {
                    image.isHidden = true
                }
            }
            if self.monsters.count == 0 {
                self.chest.image = UIImage(named: "lockchest")
            }
        }
        
        func checkIfIsOnImage(image: UIImageView) -> Bool {
            if self.imageView.frame.maxY >= image.frame.minY
                && self.imageView.frame.maxY <= image.frame.maxY
                && self.imageView.frame.maxX <= image.frame.maxX
                && self.imageView.frame.minX <= image.frame.minX {

                
                    
                return true
            }
            return false
        }
    }
}
