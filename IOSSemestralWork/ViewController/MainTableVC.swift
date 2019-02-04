//
//  ItemsTableViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireRSSParser
import RealmSwift
import Toast_Swift

/**
 Displays the primary TableView for all possible items.
 */
class MainTableVC: ItemTableVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get all folders
        folders = realm.objects(Folder.self)
            .filter("NOT title CONTAINS[cd] %@", "None")
            .sorted(byKeyPath: "title")
        
        // Get all feeds from "None" folder. They are supposed to be displayed in this screen
        feeds = realm.objects(Folder.self)
            .filter("title CONTAINS[cd] %@", "None")[0]
            .myRssFeeds
            .sorted(byKeyPath: "title")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}
