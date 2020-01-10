//
//  LocksSearchViewControllerViewController.swift
//  RPGWatchOs
//
//  Created by PicoisCharlotte on 09/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import UIKit
import HomeKit

class LocksSearchViewControllerViewController: UIViewController {
    
    private(set) var selectedHome: HMHome!
    private let browser = HMAccessoryBrowser()
     private var accessories: [HMAccessory] = [] {
         didSet {
             self.locksTableView.reloadData()
         }
     }

    @IBOutlet var locksTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        browser.delegate = self
            self.locksTableView.delegate = self
            self.locksTableView.dataSource = self
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        browser.startSearchingForNewAccessories()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        browser.stopSearchingForNewAccessories()
    }

    class func newInstance(home: HMHome) -> LocksSearchViewControllerViewController {
        let asvc = LocksSearchViewControllerViewController()
        asvc.selectedHome = home
        return asvc
    }
}

extension LocksSearchViewControllerViewController: HMAccessoryBrowserDelegate {
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        if self.accessories.first(where :{ $0.uniqueIdentifier == accessory.uniqueIdentifier }) == nil {
            self.accessories.append(accessory)
        }
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        if let index = self.accessories.firstIndex(where :{ $0.uniqueIdentifier == accessory.uniqueIdentifier }) {
            self.accessories.remove(at: index)
        }
    }
}

extension LocksSearchViewControllerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accessories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell()
           let accessory = self.accessories[indexPath.row]
           cell.textLabel?.text = accessory.name
           return cell
    }
}

extension LocksSearchViewControllerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let accessory = self.accessories[indexPath.row]
        self.selectedHome.addAccessory(accessory) { (err) in
            guard err == nil else {
                return
            }
        }
        ListLocksManager.default.listLocks.append(accessory)
    }
}

