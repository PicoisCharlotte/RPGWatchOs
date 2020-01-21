//
//  Observable.swift
//  RPGWatchOs
//
//  Created by Lukile on 21/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import Foundation

protocol Observable: class {
    func attach(observer: Observer)
    func notify()
}
