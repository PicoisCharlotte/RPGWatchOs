//
//  InventoryManager.swift
//  watchOs Extension
//
//  Created by PicoisCharlotte on 05/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import Foundation

class InventoryManager{
    static let sharedInventoryManager = InventoryManager()
    var items: [String] = []
    
    init(){
        
    }
    
    func addItem(item: String){
        items.append(item)
    }
}
