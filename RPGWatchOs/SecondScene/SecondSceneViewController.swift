//
//  SecondSceneViewController.swift
//  RPGWatchOs
//
//  Created by Lukile on 13/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import UIKit
import WatchConnectivity
import HomeKit

class SecondSceneViewController: UIViewController {
    let CONST_MONSTER_HP: String = "-- / --"
    let CONST_LABEL_HERO: String = "Hero HP : "
    
    var heroHpFromPreviousScene: Int = 0
    var heroDamageFromPreviousScene: Int = 0
    
    var heroDeclaration: Hero = Hero(hp: 0, damage: 0)
    
    var juniorMonsterDeclaration: Monster = Monster.TypeMonster.juniorMonster.instance
    var seniorMonsterDeclaration: Monster = Monster.TypeMonster.seniorMonster.instance
    
    var heroMaxHp: String = ""
    var juniormonsterMaxHp: String = ""
    var seniormonsterMaxHp: String = ""
    
    var monsters: [Monster] = []

    var listLockManager = ListLocksManager.default
    
    @IBOutlet var label: UILabel!

    private var session = WCSession.default
    
    private var potion: Bool = false
    private var unlock: Bool = false
    
    @IBOutlet var hpMonsterLabel: UILabel!
    @IBOutlet var hpHeroLabel: UILabel!
    
    @IBOutlet var hero: UIImageView!
    
    @IBOutlet var gameArea: UIView!
    @IBOutlet var chest: UIImageView!
    @IBOutlet var bossLock: UIImageView!
    @IBOutlet var juniorMonster: UIImageView!
    @IBOutlet var seniorMonster: UIImageView!
    
    @IBOutlet var gameOverImageView: UIImageView!
    
    private var isChestOpen: Bool = false
    private var timer: Timer?
    
    private let homeManager = HMHomeManager()
    private var selectedHome : HMHome!
    
    func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.heroDeclaration.hpHero = heroHpFromPreviousScene
        self.heroDeclaration.damageHero = heroDamageFromPreviousScene
        
        self.juniormonsterMaxHp = String(self.juniorMonsterDeclaration.hpMonster)
        self.seniormonsterMaxHp = String(self.seniorMonsterDeclaration.hpMonster)
        
        self.monsters.append(juniorMonsterDeclaration)
        self.monsters.append(seniorMonsterDeclaration)
        
        if isSuported() {
            session.delegate = self
            session.activate()
        }
        
        hero.image = heroDeclaration.imageHero
        juniorMonster.image = juniorMonsterDeclaration.imageMonster
        seniorMonster.image = seniorMonsterDeclaration.imageMonster
        bossLock.image = UIImage(named: "bossdoor")

        self.hpHeroLabel.text = CONST_LABEL_HERO + String(self.heroDeclaration.hpHero) + " / " + self.heroMaxHp
        self.hpMonsterLabel.text = CONST_MONSTER_HP

         print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
        
    }
    
    func getHome(){
        print(homeManager.homes)
        for home in homeManager.homes{
            if home.name.contains("LOCKS"){
                self.selectedHome = home
                return
            }
        }
        createEscapeHome()
    }
    
    private func createEscapeHome(){
        self.homeManager.addHome(withName: "\("LOCKS") Home", completionHandler: { (home, err) in
            self.selectedHome = home
        })
    }
    
    @IBAction func addAccessory(_ sender: Any) {
        self.navigationController?.pushViewController(HomeViewController(), animated: true)
    }
}

extension SecondSceneViewController: WCSessionDelegate {
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
        
        if message["request"] as? String == "boss key" {
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                
                print("click on yellow key")
                if checkIfIsOnImage(image: self.bossLock) {
                    changeStatusLock()
                    replyHandler(["message" : "yellow key used"])
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
                    replyHandler(["item" : "boss key"])
                    self.chest.image = UIImage(named: "openchest")
                    
                    self.isChestOpen = true
                    
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
                        self.juniorMonster.removeFromSuperview()
                    }
                    
                } else if (checkIfIsOnImage(image: self.seniorMonster)) {
                    if self.seniorMonsterDeclaration.hpMonster > 0 {
                       
                        let monsterName: String = (Monster.TypeMonster.seniorMonster).rawValue + " : "
                        
                        self.seniorMonsterDeclaration.takeDamage(damage: damageTakenByMonster)
                        
                        self.hpMonsterLabel.text = monsterName + String(self.seniorMonsterDeclaration.hpMonster) + " / " + self.seniormonsterMaxHp
                        
                        
                        defeatMonster(monster: self.seniorMonsterDeclaration, image: self.seniorMonster, monsterName: monsterName)
                        
                        
                        guard self.timer == nil else { return }
                        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                            timer in self.heroDeclaration.takeDamage(damage: self.seniorMonsterDeclaration.attack())
                            
                            self.hpHeroLabel.text = self.CONST_LABEL_HERO + String(self.heroDeclaration.hpHero) + " / " + self.heroMaxHp
                            
                            stopTimer(monster: self.seniorMonsterDeclaration)
                            
                        }
                        
                    }
                    if self.potion {
                        replyHandler(["item" : "potion"])
                        self.potion = false
                        self.seniorMonster.removeFromSuperview()
                    }
                    
                } else if (checkIfIsOnImage(image: self.bossLock))
                    && self.monsters.count == 0 {
                    self.unlock = true
                }
                if self.unlock {
                   print("unlock")
                    
                }
            }
        }
        
        func changeStatusLock(){
            
            for accessory in self.listLockManager.listLocks ?? []{
                guard let characteristic = accessory.findCharacteristic(type: HMCharacteristicTypeTargetLockMechanismState),
                    let value = characteristic.value as? Int,
                    let state = HMCharacteristicValueLockMechanismState(rawValue: value) else { continue }
                print(characteristic.value)
                if state == .secured {
                    characteristic.writeValue(0) { (_) in }
                    self.unlock = true
                }
            }
        }
        
        func stopTimer(monster: Monster) {
            if self.heroDeclaration.hpHero <= 0 || monster.hpMonster <= 0 {
                
                if self.heroDeclaration.hpHero <= 0 {
                    DispatchQueue.main.async {
                        self.hero.isHidden = true
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
        
        func getStateLock() -> HMCharacteristic?{
            print("listHM \(self.listLockManager.listLocks.count)")
            if let lock = self.listLockManager.listLocks.first?.services.first(where: { $0.serviceType == HMServiceTypeLockMechanism}) {
                return lock.characteristics.first { $0.characteristicType == HMCharacteristicTypeCurrentLockMechanismState }
            }
            return nil
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
            if self.hero.frame.maxY >= image.frame.minY
                && self.hero.frame.maxY <= image.frame.maxY
                && self.hero.frame.maxX <= image.frame.maxX
                && self.hero.frame.minX <= image.frame.minX {
                
                return true
            }
            return false
        }
    }
}


