//
//  FirstSceneViewController.swift
//  RPGWatchOs
//
//  Created by Lukile on 01/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import UIKit
import WatchConnectivity
import HomeKit

class FirstSceneViewController: UIViewController {
    @IBOutlet var gameOverImageView: UIImageView!
    
    var unlock: Bool = false
    
    let CONST_MONSTER_HP: String = "-- / --"
    let CONST_LABEL_HERO: String = "Hero HP : "
    
    var babyMonsterDeclaration: Monster = Monster.TypeMonster.babyMonster.instance
    var juniorMonsterDeclaration: Monster = Monster.TypeMonster.juniorMonster.instance
    var heroDeclaration: Hero = Hero(hp: 300, damage: 5)

    var heroMaxHp: String = ""
    var babymonsterMaxHp: String = ""
    var juniormonsterMaxHp: String = ""
    
    private var potion: Bool = false
    
    var monsters: [Monster] = []
    
    var listLockManager = ListLocksManager.default


    @IBOutlet var label: UILabel!
    
    private var session = WCSession.default
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
    
    private let homeManager = HMHomeManager()
    private var selectedHome : HMHome!
    
    func isSuported() -> Bool {
        return WCSession.isSupported()
    }
  
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
            
            print("self.gameArea.frame.height : \(self.gameArea.frame.height)")
            print("self.gameArea.frame.maxY : \(self.gameArea.frame.maxY)")

            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                self.label.text = "up pressed"
                print("hero minY : \(self.hero.frame.minY)")
                print("hero minY + height : \(self.hero.frame.minY + self.hero.frame.height)")
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
        
        if message["request"] as? String == "yellow key" {
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                
                print("click on yellow key")
                if checkIfIsOnImage(image: self.lock) {
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
                        self.babyMonster.removeFromSuperview()
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

                    }
                    if self.potion {
                        replyHandler(["item" : "potion"])
                        self.potion = false
                        self.juniorMonster.removeFromSuperview()
                    }

                } else if (checkIfIsOnImage(image: self.lock))
                    && self.monsters.count == 0 {
                    self.unlock = true
                }
                
                if self.unlock {
                    let secondSceneViewController = SecondSceneViewController(nibName: "SecondSceneViewController", bundle: nil)
                    
                    secondSceneViewController.heroHpFromPreviousScene = self.heroDeclaration.hpHero
                    secondSceneViewController.heroDamageFromPreviousScene = self.heroDeclaration.damageHero
                    
                        secondSceneViewController.heroMaxHp =  self.heroMaxHp
                    self.navigationController?.pushViewController(secondSceneViewController, animated: true)

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


extension HMAccessory {
    func findCharacteristic(type: String) -> HMCharacteristic? {
        for service in self.services{
            for characteristic in service.characteristics{
                if characteristic.characteristicType == type {
                    return characteristic
                }
            }
        }
        
        return nil
    }
}
