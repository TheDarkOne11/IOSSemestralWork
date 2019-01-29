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
            dbHandler.create(folder: Folder(with: "None", isContentsViewable: true))
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
        
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowAddFeed" {
            // Add feed button pressed
            let destinationVC = (segue.destination as! UINavigationController).topViewController as! NewFeedVC
            destinationVC.delegate = self
            
            return
        }
    }
}

// MARK: Data manipulation

extension MainTableVC: NewFeedDelegate {
    func feedCreated(feed myRssFeed: MyRSSFeed) {
        // Validate the address by running update of the feed
        dbHandler.update(feed: myRssFeed) { (success) in
            self.tableView.reloadData()
            
            switch success {
                
            case .OK:
                break
            case .NotOK:
                print("Feed \(myRssFeed.title) probably has a wrong link")
                
                self.view.makeToast("Could not download any RSS items. \nPlease check the RSS feed link you provided.")
                do {
                    try self.realm.write {
                        myRssFeed.isOk = false
                    }
                } catch {
                    print("Error occured when setting rssFeed.isOk to false: \(error)")
                }
                break
            case .Unreachable:
                print("Internet is unreachable. Please try updating later.")
                
                self.view.makeToast("Internet is unreachable. Please try updating later.")
                break
            }
        }
    }
    
}
