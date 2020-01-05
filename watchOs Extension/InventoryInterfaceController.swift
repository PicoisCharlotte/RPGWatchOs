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
    
    @IBOutlet var inventoryTableView: WKInterfaceTable!
    var keyList: [String] = []

    static let instance = InventoryTableRowController()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.keyList = InventoryManager.sharedInventoryManager.items
        
        self.inventoryTableView.setNumberOfRows(keyList.count, withRowType: "inventoryCell")
        
        for index in 0 ..< self.keyList.count {
            if let cellController =
                self.inventoryTableView.rowController(at: index) as? InventoryTableRowController {
                cellController.inventoryCell.setText(keyList[index])
            }
        }
    }
    
    func addRowInInventory(item: String) {
        InventoryManager.sharedInventoryManager.addItem(item: item)
    }
}
