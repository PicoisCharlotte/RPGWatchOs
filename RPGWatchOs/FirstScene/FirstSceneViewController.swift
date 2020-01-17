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
    
    var directionManager: DirectionManager = DirectionManager()
    
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
            replyHandler(["message" : "going up"])
            
            directionManager.goUp(heroImage: self.hero, gameArea: self.gameArea)
          
        }
        
        if message["request"] as? String == "left" {
            replyHandler(["message" : "goind left"])
            
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
        
        if message["request"] as? String == "yellow key"
            && self.directionManager.checkIfIsOnImage(heroImage: self.hero, image: self.lock){
            
            DispatchQueue.main.async {
                changeStatusLock()
                replyHandler(["message" : "USE YELLOW KEY"])
                self.unlock = true
                loadNextView()
            }
        }
        
        if message["request"] as? String == "potion" {
            replyHandler(["message" : "USE POTION"])
            
            self.heroDeclaration.usePotion(heroLabel: self.hpHeroLabel, heroMaxHp: self.heroMaxHp)
        }
        
        if message["request"] as? String == "action" {
            DispatchQueue.main.async {
                
                var damageTakenByMonster: Int = self.heroDeclaration.attack()
                
                if self.monsters.count == 0
                    && self.directionManager.checkIfIsOnImage(heroImage: self.hero, image: self.chest)
                    && !self.isChestOpen {
                    replyHandler(["item" : "yellow key"])
                    self.chest.image = UIImage(named: "openchest")
                    
                    self.isChestOpen = true
                    
                  
                    
                } else if self.directionManager.checkIfIsOnImage(heroImage: self.hero,image: self.babyMonster) {
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
                    }
                    if self.potion {
                        replyHandler(["item" : "potion"])
                        self.potion = false
                        self.babyMonster.removeFromSuperview()
                    }
                    
                } else if self.directionManager.checkIfIsOnImage(heroImage: self.hero, image: self.juniorMonster) {
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

                } else if self.directionManager.checkIfIsOnImage(heroImage: self.hero, image: self.lock)
                    && self.monsters.count == 0 {
                    self.unlock = true
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
        
        func loadNextView() {
            if self.unlock {
                let secondSceneViewController = SecondSceneViewController(nibName: "SecondSceneViewController", bundle: nil)
                
                secondSceneViewController.heroHpFromPreviousScene = self.heroDeclaration.hpHero
                secondSceneViewController.heroDamageFromPreviousScene = self.heroDeclaration.damageHero
                
                secondSceneViewController.heroMaxHp =  self.heroMaxHp
                self.navigationController?.pushViewController(secondSceneViewController, animated: true)
                
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
                self.potion = monster.setPotion(image: image)
            }
            
            if self.monsters.count == 0 {
                self.chest.image = UIImage(named: "lockchest")
            }
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
