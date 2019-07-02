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
        folders = realm.objects(PolyItem.self)
            .filter("folder != nil")
            .filter("NOT folder.title CONTAINS[cd] %@", UserDefaultsKeys.NoneFolderTitle.rawValue)
            .sorted(byKeyPath: "folder.title")
        
        // Get all feeds from "None" folder. They are supposed to be displayed in this screen
        feeds = realm.objects(PolyItem.self)
            .filter("folder != nil")
            .filter("folder.title CONTAINS[cd] %@", UserDefaultsKeys.NoneFolderTitle.rawValue)
            .first?
            .folder?.myRssFeeds
            .filter("myRssFeed != nil")
            .sorted(byKeyPath: "myRssFeed.title")
    }
}
