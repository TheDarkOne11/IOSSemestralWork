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
        
        // If the special "None" folder doesn't exist (app run for the first time) create it
        if folders!.isEmpty {
            dbHandler.create(Folder(with: "None", isContentsViewable: true))
            
            // TODO: Debugging images, remove
            let none: Folder = realm.objects(Folder.self).filter("title CONTAINS[cd] %@", "None").first!
            dbHandler.create(MyRSSFeed(title: "IdnesZpravodaj_None", link: "https://servis.idnes.cz/rss.aspx?c=zpravodaj", folder: none))
            dbHandler.create(MyRSSFeed(title: "Wired_MedThumb", link: "http://wired.com/feed/rss", folder: none))
            dbHandler.create(MyRSSFeed(title: "Lifehacker_DescImg", link: "https://lifehacker.com/rss", folder: none))
            dbHandler.create(MyRSSFeed(title: "FOX_MedThumb_Bad", link: "http://feeds.foxnews.com/foxnews/latest", folder: none))
        }
        
        // Filter "None" folder out
        folders = folders!.filter("NOT title CONTAINS[cd] %@", "None")
        
        // Get all feeds from "None" folder. They are supposed to be displayed in this screen
        feeds = realm.objects(Folder.self)
            .filter("title CONTAINS[cd] %@", "None")[0]
            .myRssFeeds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @IBAction func editBtnPressed(_ sender: UIBarButtonItem) {
        // TODO: Implement
    }
}
