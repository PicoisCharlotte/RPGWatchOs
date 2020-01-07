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
    
    
    var babyMonsterDeclaration: Monster = Monster.TypeMonster.babyMonster.instance
    var juniorMonsterDeclaration: Monster = Monster.TypeMonster.juniorMonster.instance
    var heroDeclaration: Hero = Hero(hp: 30, damage: 5)

    var monsters: [Monster] = []

    @IBOutlet var label: UILabel!
    
    private var totalMonsterOnMap = 0
    private var allMonstersBeaten: Bool = false
    
    private var session = WCSession.default
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var chest: UIImageView!
    @IBOutlet var lock: UIImageView!
    
    @IBOutlet var gameArea: UIView!
    
    @IBOutlet var babyMonster: UIImageView!
    @IBOutlet var juniorMonster: UIImageView!
    @IBOutlet var hero: UIImageView!
    
    func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    var tempValue: CGFloat = 0
    var currDir: Void?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.monsters.append(babyMonsterDeclaration)
        self.monsters.append(juniorMonsterDeclaration)
        if isSuported() {
            session.delegate = self
            session.activate()
        }
        totalMonsterOnMap = monsters.count
        
        hero.image = heroDeclaration.imageHero
        babyMonster.image = babyMonsterDeclaration.imageMonster
        juniorMonster.image = juniorMonsterDeclaration.imageMonster
        lock.image = UIImage(named: "yellowlocklocked")
        
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
        
        DispatchQueue.main.async {
            if self.totalMonsterOnMap == 0 {
                self.chest.image = UIImage(named: "chest")
                print(self.totalMonsterOnMap)
            }
            print(self.totalMonsterOnMap)
        }
        
        
        if message["request"] as? String == "up" {
            
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                self.label.text = "up pressed"
                if(self.imageView.frame.minY + self.imageView.frame.height > self.gameArea.frame.minY) {
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
                if self.imageView.frame.maxY < self.gameArea.frame.maxY {
                UIView.animate(withDuration: 0.3, animations: {self.imageView.frame.origin.y += 30})
                } else {
                    print("Image goes out of screen on the bottom")
                }
            }
        }
        
        if message["request"] as? String == "action" {
            DispatchQueue.main.async {
                let disposition = self.imageView.frame.maxY - 123
                self.label.text = "action pressed"
                
                print(" dispo " , self.imageView.frame.maxY)
                print(self.babyMonster.frame.maxY)
                print(self.babyMonster.frame.minY)
                if self.totalMonsterOnMap == 0  && disposition == self.chest.frame.maxY {
                    replyHandler(["item" : "yellow key dropped"])
                } else if (self.imageView.frame.maxY >= self.babyMonster.frame.minY && self.imageView.frame.maxY <= self.babyMonster.frame.maxY){
                    print("babymonster")
                    self.babyMonsterDeclaration.takeDamage(damage: self.heroDeclaration.attack())
                } else if (disposition == self.juniorMonster.frame.maxY){
                    print("juniormonster")
                }
                if(self.babyMonsterDeclaration.hpMonster <= 0){
                    if let index = self.monsters.firstIndex(where: {
                        $0.imageMonster == self.babyMonsterDeclaration.imageMonster
                    }){
                        self.monsters.remove(at: index)
                    }
                }
                print("count ::: " , self.monsters.count)
            }
        }
    }
}
