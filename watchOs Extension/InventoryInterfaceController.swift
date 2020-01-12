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
        
        self.inventoryTableView.setNumberOfRows(list.count, withRowType: "inventoryCell")
        
        for index in 0 ..< self.list.count {
            if let cellController =
                self.inventoryTableView.rowController(at: index) as? InventoryTableRowController {
                cellController.inventoryCell.setText(list[index])
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let item = Inventory.sharedInventory.items[rowIndex]
        if isReachable() {
            session.sendMessage(["request": item], replyHandler: {reply in
                self.label.setText(reply["version"] as? String)
            }, errorHandler: {error in
                print("ERROR : ", error)
            })
          
            removeRowInInventory(item: item)
        
        } else {
            print("IPhone is not reachable")
        }
        inventoryTableView.setNumberOfRows(self.inventoryShared.items.count, withRowType: "inventoryCell")
        
        for index in 0 ..< self.list.count {
            print(list[index])
            if let cellController =
                self.inventoryTableView.rowController(at: index) as? InventoryTableRowController {
                cellController.inventoryCell.setText(list[index])
            }
        }
    }
    
    private func isReachable() -> Bool {
        return session.isReachable
    }
    
    func addRowInInventory(item: String) {
        self.inventoryShared.addItem(item: item)
    }
    
    func removeRowInInventory(item: String) {
        print("self.inventoryShared.items : \(self.inventoryShared.items)")
        self.inventoryShared.removeItem(item: item)
    }
}
