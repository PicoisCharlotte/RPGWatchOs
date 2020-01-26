//
//  HomeViewController.swift
//  RPGWatchOs
//
//  Created by PicoisCharlotte on 09/01/2020.
//  Copyright © 2020 Lukile. All rights reserved.
//

import UIKit
import HomeKit

class HomeViewController: UIViewController {
    
    @IBOutlet var homeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.homeTableView.delegate = self
        self.homeTableView.dataSource = self
        
        addHomeManager()
        
    }
    
    func presentAlert(message: String){
        let alert = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Fermer", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func addHomeManager(){
        SharedHomeManager.default.manager.addHome(withName: "RPG Home") {
            (home, err) in
            if err != nil {
                //self.presentAlert(message: "Impossible de créer la maison avec le nom '\("RPG Home")'")
                return
            }
            print(err as Any)
            self.dismiss(animated: true)
        }
        
    }
}
extension HomeViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedHomeManager.default.manager.homes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let home = SharedHomeManager.default.manager
            .homes[indexPath.row]
        cell.textLabel?.text = home.name
        return cell
    }
}
extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let manager = SharedHomeManager.default.manager
        let home = manager.homes[indexPath.row]
        
        manager.removeHome(home) {
            (err) in
            self.homeTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let manager = SharedHomeManager.default.manager
        let home = manager.homes[indexPath.row]
        self.navigationController?.pushViewController(ConfigHomeKitViewController.newInstance(home: home), animated: true)
    }
}

extension HomeViewController: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        self.homeTableView.reloadData()
    }
}
