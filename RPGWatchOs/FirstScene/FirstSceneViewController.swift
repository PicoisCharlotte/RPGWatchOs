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
    private var session = WCSession.default
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var label: UILabel!
    
    @IBAction func touchUP() {
        UIView.animate(withDuration: 0.75, animations: {self.imageView.frame.origin.y += 50})
    }
    
    func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    var tempValue: CGFloat = 0
    var currDir: Void?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isSuported() {
            session.delegate = self
            session.activate()
        }
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")

        let screenWidth = screensize.width
        let screenHeight = screensize.height
        
        print("width : ", screenWidth)
        print("height : ", screenHeight)

        
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
                //if(self.imageView.frame.maxY > 180) {
                UIView.animate(withDuration: 0.75, animations: {self.imageView.frame.origin.y -= 30})
               // } else {
                  //  print("Image goes out of screen on the top")
               // }
            }
            
        }
        
        if message["request"] as? String == "left" {
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                self.label.text = "left pressed"
                UIView.animate(withDuration: 0.75, animations: {self.imageView.frame.origin.x -= 30})
            }
        }
        
        if message["request"] as? String == "right" {
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                self.label.text = "right pressed"
                UIView.animate(withDuration: 0.75, animations: {self.imageView.frame.origin.x += 30})
            }
        }
        
        if message["request"] as? String == "down" {
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
            
            DispatchQueue.main.async {
                self.label.text = "down pressed"
                UIView.animate(withDuration: 0.75, animations: {self.imageView.frame.origin.y += 30})
            }
        }
    }
}
