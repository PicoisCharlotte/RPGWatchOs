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

class FirstSceneViewController: UIViewController, Observable {
  
    
    @IBOutlet var gameOverImageView: UIImageView!
    
    var requestState: String = ""
    let movementObserver = DirectionManager()
    
    private lazy var observers = [Observer]()
    
    var unlock: Bool = false
    
    let CONST_MONSTER_HP: String = "-- / --"
    
    var directionManager: DirectionManager = DirectionManager()
    var imageManager: ImageManager = ImageManager()
    var fightManager: FightManager = FightManager()
    
    var babyMonsterDeclaration: Monster = Monster.TypeMonster.babyMonster.instance
    var juniorMonsterDeclaration: Monster = Monster.TypeMonster.juniorMonster.instance
    var heroDeclaration: Hero = Hero(hp: 200, damage: 5)

    var heroMaxHp: String = ""
    var babymonsterMaxHp: String = ""
    var juniormonsterMaxHp: String = ""
    
    private var potionBabyMonster: Bool = false
    private var potionJuniorMonster: Bool = false
    
    var monsters: [Monster] = []
    var monstersImageView: [UIImageView] = []
    
    var listLockManager = ListLocksManager.default
    
    private var session = WCSession.default
    @IBOutlet var chest: UIImageView!
    @IBOutlet var lock: UIImageView!
    
    @IBOutlet var gameArea: UIView!
    @IBOutlet var viewGameArea: UIView!
    
    @IBOutlet var babyMonster: UIImageView!
    @IBOutlet var juniorMonster: UIImageView!
    @IBOutlet var hero: UIImageView!
    
    private var timer: Timer?
    
    @IBOutlet var hpHeroLabel: UILabel!
    @IBOutlet var hpMonsterLabel: UILabel!
    @IBOutlet var addAccessory: UIButton!
    
    private let homeManager = HMHomeManager()
    private var selectedHome : HMHome!
    
    func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    func attach(observer: Observer) {
        observers.append(observer)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.attach(observer: movementObserver)
        self.attach(observer: heroDeclaration)
        
        self.gameArea.layer.contents = #imageLiteral(resourceName: "scene").cgImage
        
        self.heroMaxHp = self.heroDeclaration.initHp()
        
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
        
        self.monstersImageView.append(babyMonster)
        self.monstersImageView.append(juniorMonster)
        
        print("baby monster maxY: \(self.babyMonster.frame.maxY)")
        print("baby monster minY: \(self.babyMonster.frame.minY)")

        lock.image = UIImage(named: "yellowlocklocked")
        
        self.heroDeclaration.setLabelInitHp(label: self.hpHeroLabel, heroMaxHp: self.heroMaxHp)
        
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
    
    func notify() {
        print("Notifying observers...\n")
        observers.forEach({ $0.update() })
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
        movementObserver.requestState = message["request"] as! String
        movementObserver.movement(heroImage: self.hero, gameArea: self.viewGameArea, replyHandler: replyHandler)
        self.notify()
        
        heroDeclaration.requestState = message["request"] as! String
        heroDeclaration.usesPotion(heroLabel: self.hpHeroLabel, heroMaxHp: self.heroMaxHp, replyHandler: replyHandler)
        self.notify()
        
        switch message["request"] as? String {
        case "yellow key":
            if self.imageManager.checkIfIsOnImage(heroImage: self.hero, image: self.lock){
                
                DispatchQueue.main.async {
                    changeStatusLock()
                    replyHandler(["message" : "USE YELLOW KEY"])
                    self.unlock = true
                    loadNextView()
                }
            }
            break
        case "action":
            DispatchQueue.main.async {
                var damageTakenByMonster: Int = self.heroDeclaration.attack()
            
                if self.fightManager.openChest(monsters: self.monsters, hero: self.hero, chest: self.chest) {
                    replyHandler(["item" : "yellow key"])
                    
                } else if self.imageManager.checkIfIsOnImage(heroImage: self.hero,image: self.babyMonster) {
                    if self.babyMonsterDeclaration.hpMonster > 0 {
                        
                        let monsterName: String = (Monster.TypeMonster.babyMonster).rawValue + " : "
                        self.babyMonsterDeclaration.takeDamage(damage: damageTakenByMonster)
                        self.hpMonsterLabel.text = monsterName + String(self.babyMonsterDeclaration.hpMonster) + " / " + self.babymonsterMaxHp
                        
                        
                        self.monsters = self.babyMonsterDeclaration.defeatMonster(monsters: self.monsters,
                                                                                  image: self.babyMonster,
                                                                                  monsterName: monsterName,
                                                                                  monsterLabel: self.hpMonsterLabel,
                                                                                  chestImage: self.chest)
                        if self.babyMonsterDeclaration.hpMonster <= 0 {
                            self.potionBabyMonster = self.babyMonsterDeclaration.hasPotion(image: self.babyMonster)
                        }
                        
                        guard self.timer == nil else { return }
                        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                            timer in self.heroDeclaration.takeDamage(damage: self.babyMonsterDeclaration.attack())
                            
                            self.heroDeclaration.updateHp(label: self.hpHeroLabel, heroMaxHp: self.heroMaxHp)
                            
                            stopTimer(monster: self.babyMonsterDeclaration)
                            
                        }
                    }
                    if self.potionBabyMonster {
                        replyHandler(["item" : "potion"])
                        self.potionBabyMonster = false
                        self.babyMonster.isHidden = true
                    }
                    
                } else if self.imageManager.checkIfIsOnImage(heroImage: self.hero, image: self.juniorMonster) {
                    if self.juniorMonsterDeclaration.hpMonster > 0 {
                        
                        let monsterName: String = (Monster.TypeMonster.juniorMonster).rawValue + " : "
                        
                        self.juniorMonsterDeclaration.takeDamage(damage: damageTakenByMonster)
                        
                        self.hpMonsterLabel.text = monsterName + String(self.juniorMonsterDeclaration.hpMonster) + " / " + self.juniormonsterMaxHp
                        
                        self.monsters = self.juniorMonsterDeclaration.defeatMonster(monsters: self.monsters,
                                                                                    image: self.juniorMonster,
                                                                                    monsterName: monsterName,
                                                                                    monsterLabel: self.hpMonsterLabel,
                                                                                    chestImage: self.chest)
                        
                        if self.juniorMonsterDeclaration.hpMonster <= 0 {
                            self.potionJuniorMonster = self.juniorMonsterDeclaration.hasPotion(image: self.juniorMonster)
                        }
                        
                        guard self.timer == nil else { return }
                        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                            timer in self.heroDeclaration.takeDamage(damage: self.juniorMonsterDeclaration.attack())
                            self.heroDeclaration.updateHp(label: self.hpHeroLabel, heroMaxHp: self.heroMaxHp)
                            
                            stopTimer(monster: self.juniorMonsterDeclaration)
                        }
                        
                    }
                    if self.potionJuniorMonster {
                        replyHandler(["item" : "potion"])
                        self.potionJuniorMonster = false
                        self.juniorMonster.removeFromSuperview()
                    }
                    
                } else if self.imageManager.checkIfIsOnImage(heroImage: self.hero, image: self.lock)
                    && self.monsters.count == 0 {
                    self.unlock = true
                }
            }
            break
        
            
        default: break
            
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
                        self.lock.removeFromSuperview()
                        self.heroDeclaration.zeroHp(label: self.hpHeroLabel, heroMaxHp: self.heroMaxHp)
                        self.gameOverImageView.image = UIImage(named: "died")
                        self.gameArea.removeFromSuperview()
                        self.hpHeroLabel.removeFromSuperview()
                        self.hpMonsterLabel.removeFromSuperview()
                        self.addAccessory.removeFromSuperview()
                        self.view.backgroundColor = .black
                        self.hero.removeFromSuperview()
                        for monster in 0 ..< self.monstersImageView.count {
                            self.monstersImageView[monster].removeFromSuperview()
                        }
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
