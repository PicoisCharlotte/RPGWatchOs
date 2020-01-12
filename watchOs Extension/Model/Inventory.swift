//
//  Inventory.swift
//  watchOs Extension
//
//  Created by Lukile on 05/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import Foundation

class Inventory {
    static let sharedInventory = Inventory()
    var items: [String] = []
    
    init(){
        
    }
    
    func addItem(item: String){
        items.append(item)
    }
    
    func removeItem(item: String){
        if let index = self.items.firstIndex(where: {
            $0 == item
        }){
            self.items.remove(at: index)
        }
    }
}
