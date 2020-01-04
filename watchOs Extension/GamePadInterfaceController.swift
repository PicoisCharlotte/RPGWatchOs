//
//  GamePadInterfaceController.swift
//  watchOs Extension
//
//  Created by Lukile on 01/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit

class GamePadInterfaceController: WKInterfaceController, WCSessionDelegate {
    private var session = WCSession.default

    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet var sendButton: WKInterfaceButton!
    
    private func isReachable() -> Bool {
        return session.isReachable
    }
    
    @IBAction func backButton() {
        if session.isReachable {
            self.pushController(withName: "main", context: "Pad")
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        print("awake")

    }
    
    func manageDirection(direction: String) {
        if isReachable() {
            print("IPhone is reachable")
            session.sendMessage(["request" : direction], replyHandler: {reply in
                self.label.setText(reply["version"] as? String)
            }, errorHandler: {error in
                // catch any errors here
                print("ERROR : ", error)
            })
        } else {
            print("IPhone is not reachable")
        }
    }
    
    
    
    @IBAction func onTouchUp() {
        manageDirection(direction: "up")
    }
    
    @IBAction func onTouchLeft() {
        manageDirection(direction: "left")
    }
    
    @IBAction func onTouchRight() {
        manageDirection(direction: "right")
    }
    
    @IBAction func onTouchDown() {
       manageDirection(direction: "down")
    }
    
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if isSuported() {
            session.delegate = self
            session.activate()
        }
    }
    
    private func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("back is pressed")
    }
}
