//
//  ConfigHomeKitViewController.swift
//  RPGWatchOs
//
//  Created by Lukile on 12/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import UIKit
import HomeKit

class ConfigHomeKitViewController: UIViewController {
    private(set) var selectedHome: HMHome!
    private(set) var accessory : HMAccessory!
    
    @IBOutlet var locksTable: UITableView!
    
    private var listLocks: [HMAccessory] = [] {
        didSet {
            self.locksTable.reloadData()
        }
    }
    
    class func newInstance(home: HMHome) -> ConfigHomeKitViewController {
        let asvc = ConfigHomeKitViewController()
        asvc.selectedHome = home
        return asvc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locksTable.delegate = self
        self.locksTable.dataSource = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(touchSearchAccessory))
    }
    @objc func touchSearchAccessory() {
        let search = LocksSearchViewControllerViewController.newInstance(home: self.selectedHome)
        self.present(search, animated: true)
    }
}

extension ConfigHomeKitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ListLocksManager.default.listLocks.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let accessory = ListLocksManager.default.listLocks[indexPath.row]
        cell.textLabel?.text = accessory.name
        return cell
    }
}

extension ConfigHomeKitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let accessory = ListLocksManager.default.listLocks[indexPath.row]
        print(accessory)
    }
}
