//
//  InterfaceController.swift
//  watchOs Extension
//
//  Created by Lukile on 01/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
let session = WCSession.default
    @IBAction func onTouchPlay() {
        
        if session.isReachable {
            self.pushController(withName: "play", context: "Pad")
        }
    }
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
   
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}


extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("\(activationState.rawValue)")
    }
}
