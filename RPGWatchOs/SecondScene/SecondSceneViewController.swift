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
    
    var heroHpFromFirstScene: Int = 0
    var heroDamageFromFirstScene: Int = 0
    
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
        self.heroDeclaration.hpHero = heroHpFromFirstScene
        self.heroDeclaration.damageHero = heroDamageFromFirstScene
        
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
    
    @IBAction func addAccessory(_ sender: Any) {
    }
}

extension SecondSceneViewController: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    
}
