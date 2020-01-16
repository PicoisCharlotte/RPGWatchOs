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
    var list: [String] = []
    
    let inventoryShared = Inventory.sharedInventory
    
    static let instance = InventoryTableRowController()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.list = self.inventoryShared.items
        
       reloadTable(tableList: list)
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let item = Inventory.sharedInventory.items[rowIndex]
        if isReachable() {        
            if Inventory.sharedInventory.items[rowIndex] == "yellow key" {
                
                session.sendMessage(["request" : "yellow key"], replyHandler: {reply in
                    self.label.setText(reply["version"] as? String)
                }, errorHandler: {error in
                    // catch any errors here
                    print("ERROR : ", error)
                })
                
                
            } else {
                session.sendMessage(["request": item], replyHandler: {reply in
                    self.label.setText(reply["version"] as? String)
                }, errorHandler: {error in
                    print("ERROR : ", error)
                })
                
                removeRowInInventory(item: item)
            }
            
        } else {
            print("IPhone is not reachable")
        }
        reloadTable(tableList: self.inventoryShared.items)
    }
    
    private func isReachable() -> Bool {
        return session.isReachable
    }
    
    func reloadTable(tableList: [String]) {
        inventoryTableView.setNumberOfRows(tableList.count, withRowType: "inventoryCell")

        for index in 0 ..< tableList.count {
            if let cellController =
                self.inventoryTableView.rowController(at: index) as? InventoryTableRowController {
                cellController.inventoryCell.setText(tableList[index])
            }
        }
    }
    
    func addRowInInventory(item: String) {
        self.inventoryShared.addItem(item: item)
    }
    
    func removeRowInInventory(item: String) {
        print("self.inventoryShared.items : \(self.inventoryShared.items)")
        self.inventoryShared.removeItem(item: item)
    }
}
