//
//  InventoryInterfaceController.swift
//  watchOs Extension
//
//  Created by Lukile on 03/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit

class InventoryInterfaceController: WKInterfaceController {
    private var session = WCSession.default

    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet var inventoryTableView: WKInterfaceTable!
    var keyList: [String] = []
    
    private func isReachable() -> Bool {
           return session.isReachable
       }
    
    static let instance = InventoryTableRowController()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.keyList = Inventory.sharedInventory.items
        
        self.inventoryTableView.setNumberOfRows(keyList.count, withRowType: "inventoryCell")
        
        for index in 0 ..< self.keyList.count {
            if let cellController =
                self.inventoryTableView.rowController(at: index) as? InventoryTableRowController {
                cellController.inventoryCell.setText(keyList[index])
            }
        }
    }
    
    func addRowInInventory(item: String) {
        Inventory.sharedInventory.addItem(item: item)
    }
    
    func removeRowInInventory(item: String) {
        Inventory.sharedInventory.removeItem(item: item)
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {

        if isReachable() {
            print("IPhone is reachable")
            if Inventory.sharedInventory.items[rowIndex] == "yellow key" {
                
                    session.sendMessage(["request" : "yellow key"], replyHandler: {reply in
                        self.label.setText(reply["version"] as? String)
                    }, errorHandler: {error in
                        // catch any errors here
                        print("ERROR : ", error)
                    })
                    
               
            }
            
        } else {
           print("IPhone is not reachable")
       }
        print("TABLE \(Inventory.sharedInventory.items[rowIndex])")
    }
}

