//
//  SharedHomeManager.swift
//  SampleHome
//
//  Created by PicoisCharlotte on 03/12/2019.
//  Copyright © 2019 PicoisCharlotte. All rights reserved.
//

import Foundation
import HomeKit

class SharedHomeManager {
    
    static let `default` = SharedHomeManager()
    
    lazy var manager = HMHomeManager()
}
