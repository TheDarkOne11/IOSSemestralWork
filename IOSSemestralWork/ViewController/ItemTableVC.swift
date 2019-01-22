//
//  ItemTableViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import RealmSwift

// TODO: Pokud má feed špatnou adresu (adresa není RSS feed nebo neexistuje), udělám u něj v tableView nějaký vizuální indikátor (červený trojúhelník), možná i u jeho folderu. Tuto informaci musím uložit ve feedu, možná i ve folderu. Vizuální indikátor nezobrazíme, pokud se nemůžeme připojit k internetu. To uděláme v update liště.
class ItemTableVC: UITableViewController {    
    // All feeds that aren't inside a folder and are supposed to be shown
    var feeds: List<MyRSSFeed>?
    
    let realm = try! Realm()
    
    let dbHandler = DBHandler()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load static folders
        // TODO: Create static folders
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds!.count
    }
}
