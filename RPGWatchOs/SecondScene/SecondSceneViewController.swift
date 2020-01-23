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

class SecondSceneViewController: UIViewController, Observable {
    let CONST_MONSTER_HP: String = "-- / --"
    
    var requestState: String = ""
    let movementObserver = DirectionManager()
    
    private lazy var observers = [Observer]()
    
    var directionManager: DirectionManager = DirectionManager()
    var imageManager: ImageManager = ImageManager()
    var fightManager: FightManager = FightManager()
    
    var heroHpFromPreviousScene: Int = 0
    var heroDamageFromPreviousScene: Int = 0
    
    var heroDeclaration: Hero = Hero(hp: 200, damage: 5)
    
    var juniorMonsterDeclaration: Monster = Monster.TypeMonster.juniorMonster.instance
    var seniorMonsterDeclaration: Monster = Monster.TypeMonster.seniorMonster.instance
    
    var heroMaxHp: String = ""
    var juniormonsterMaxHp: String = ""
    var seniormonsterMaxHp: String = ""
    
    var monsters: [Monster] = []
    var monstersImageView: [UIImageView] = []

    var listLockManager = ListLocksManager.default
    
    private var session = WCSession.default
    
    private var potionJuniorMonster: Bool = false
    private var potionSeniorMonster: Bool = false

    private var unlock: Bool = false
    
    @IBOutlet var hpMonsterLabel: UILabel!
    @IBOutlet var hpHeroLabel: UILabel!
    
    @IBOutlet var hero: UIImageView!
    
    @IBOutlet var gameArea: UIView!
    @IBOutlet var viewGameArea: UIView!
    @IBOutlet var chest: UIImageView!
    @IBOutlet var bossLock: UIImageView!
    @IBOutlet var juniorMonster: UIImageView!
    @IBOutlet var seniorMonster: UIImageView!
    
    @IBOutlet var gameOverImageView: UIImageView!
    
    private var timer: Timer?
    
    private let homeManager = HMHomeManager()
    private var selectedHome : HMHome!
    @IBOutlet var addAccessory: UIButton!
    
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

extension SecondSceneViewController: WCSessionDelegate {
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
        case "boss key":
            if self.imageManager.checkIfIsOnImage(heroImage: self.hero, image: self.bossLock) {
                DispatchQueue.main.async {
                    changeStatusLock()
                    replyHandler(["message" : "USE BOSS KEY"])
                    self.unlock = true
                    loadNextView()
                }
            }
            break
        case "action":
            DispatchQueue.main.async {
                
                var damageTakenByMonster: Int = self.heroDeclaration.attack()
                
                if self.fightManager.openChest(monsters: self.monsters, hero: self.hero, chest: self.chest) {
                    replyHandler(["item" : "boss key"])
                    
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
                        self.juniorMonster.isHidden = true
                    }
                    
                } else if self.imageManager.checkIfIsOnImage(heroImage: self.hero, image: self.seniorMonster) {
                    if self.seniorMonsterDeclaration.hpMonster > 0 {
                        
                        let monsterName: String = (Monster.TypeMonster.seniorMonster).rawValue + " : "
                        
                        self.seniorMonsterDeclaration.takeDamage(damage: damageTakenByMonster)
                        
                        self.hpMonsterLabel.text = monsterName + String(self.seniorMonsterDeclaration.hpMonster) + " / " + self.seniormonsterMaxHp
                        
                        
                        self.monsters = self.seniorMonsterDeclaration.defeatMonster(monsters: self.monsters,
                                                                                    image: self.seniorMonster,
                                                                                    monsterName: monsterName,
                                                                                    monsterLabel: self.hpMonsterLabel,
                                                                                    chestImage: self.chest)
                        
                        if self.seniorMonsterDeclaration.hpMonster <= 0 {
                            self.potionSeniorMonster = self.seniorMonsterDeclaration.hasPotion(image: self.seniorMonster)
                        }
                        
                        
                        guard self.timer == nil else { return }
                        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                            timer in self.heroDeclaration.takeDamage(damage: self.seniorMonsterDeclaration.attack())
                            
                            self.heroDeclaration.updateHp(label: self.hpHeroLabel, heroMaxHp: self.heroMaxHp)
                            
                            stopTimer(monster: self.seniorMonsterDeclaration)
                            
                        }
                    }
                    if self.potionSeniorMonster {
                        replyHandler(["item" : "potion"])
                        self.potionSeniorMonster = false
                        self.seniorMonster.removeFromSuperview()
                    }
                    
                } else if self.imageManager.checkIfIsOnImage(heroImage: self.hero, image: self.bossLock)
                    && self.monsters.count == 0 {
                    self.unlock = true
                }
            }
        
            break
        default:
            break
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
                let bossSceneViewController = BossSceneViewController(nibName: "BossSceneViewController", bundle: nil)
                
                bossSceneViewController.heroHpFromPreviousScene = self.heroDeclaration.hpHero
                bossSceneViewController.heroDamageFromPreviousScene = self.heroDeclaration.damageHero
                
                bossSceneViewController.heroMaxHp =  self.heroMaxHp
                self.navigationController?.pushViewController(bossSceneViewController, animated: true)
                
            }
        }
        
        func stopTimer(monster: Monster) {
            if self.heroDeclaration.hpHero <= 0 || monster.hpMonster <= 0 {
                
                if self.heroDeclaration.hpHero <= 0 {
                    DispatchQueue.main.async {
                        self.bossLock.removeFromSuperview()
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
    }
}
