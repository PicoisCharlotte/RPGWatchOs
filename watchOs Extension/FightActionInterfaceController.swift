//
//  FightActionInterfaceController.swift
//  watchOs Extension
//
//  Created by Lukile on 03/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit

class FightActionInterfaceContoller: WKInterfaceController, WCSessionDelegate {
    private var session = WCSession.default
    
    private var itemList: [String] = []
    
    var hasBeenCalled = false
    
   
    @IBOutlet var label: WKInterfaceLabel!
    
    private var inventoryInterfaceController = InventoryInterfaceController()
    
    @IBAction func backButton() {
        if session.isReachable {
            self.pushController(withName: "main", context: "Pad")
        }
    }
    
    @IBAction func onTouchFight() {
        
    }
    
    @IBAction func onTouchAction() {
        if isReachable() {
            print("IPhone is reachable")
        
            session.sendMessage(["request" : "action"], replyHandler: {reply in
                self.label.setText(reply["version"] as? String)
            }, errorHandler: {error in
                // catch any errors here
                print("ERROR : ", error)
                
            })
            self.inventoryInterfaceController.addRowInInventory(item: "red key")
            
        } else {
            print("IPhone is not reachable")
        }
    }
   
    
    private func isReachable() -> Bool {
        return session.isReachable
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if isSuported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func called() -> Bool{
        return hasBeenCalled
    }
    
    private func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
}
