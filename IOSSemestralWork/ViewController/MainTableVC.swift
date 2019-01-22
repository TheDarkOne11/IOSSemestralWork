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

/**
 Displays the primary TableView for all possible items.
 */
class MainTableVC: ItemTableVC {
    // Shown folders
    var folders: Results<Folder>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get all folders but "None" folder
        folders = realm.objects(Folder.self)
            .filter("NOT title CONTAINS[cd] %@", "None")
        
        // If the app is run for the first time we need to create the special None folder
        if let folders = self.folders {
            if folders.isEmpty {
                dbHandler.create(folder: Folder(with: "None", isContentsViewable: true))
            }
        }
        
        // Get all feeds from "None" folder. They are supposed to be displayed in this screen
        feeds = realm.objects(Folder.self)
            .filter("title CONTAINS[cd] %@", "None")[0]
            .myRssFeeds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @IBAction func editBtnPressed(_ sender: UIBarButtonItem) {
        // TODO: Temporary code, remove!
        let folders = realm.objects(Folder.self)
        
        for folder in folders {
            for feed in folder.myRssFeeds {
                dbHandler.update(feed: feed)
            }
        }
    }
    
    // MARK: TableView methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section) + folders!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        // First show folders then RSS feeds
        if indexPath.row < folders!.count {
            // Show folder
            guard let folder = folders?[indexPath.row] else {
                print("Error when loading folders to display in the tableView")
                fatalError()
            }
            
            cell.textLabel?.text = folder.title + " (Folder)"
        } else {
            // Show RSSFeed
            guard let feed = feeds?[indexPath.row - folders!.count] else {
                print("Error when loading feeds to display in the tableView")
                fatalError()
            }
            
            cell.textLabel?.text = feed.title + " (MyRSSFeed)"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let folders = self.folders else {
            print("Error when selecting a folder")
            fatalError()
        }
        
        // TODO: Go to the folder's contents only when an edge of the cell is selected, otherwise show RSSItems of its feeds
        
        if indexPath.row < folders.count {
            // Go to FolderTableVC
            performSegue(withIdentifier: "ShowFolderContents", sender: nil)
            
        } else {
            // Go to RSSFeedTableVC
            performSegue(withIdentifier: "ShowRssItems", sender: nil)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAddFeed" {
            // Add feed button pressed
            let destinationVC = (segue.destination as! UINavigationController).topViewController as! NewFeedVC
            destinationVC.delegate = self
            
            return
        }
        
        guard let indexPath = tableView.indexPathForSelectedRow else {
            print("Unreacheable tableViewCell selected.")
            fatalError()
        }
        
        switch segue.identifier {
        case "ShowFolderContents":
            // Show folder
            guard let folder = folders?[indexPath.row] else {
                print("Error when loading folders to display in the tableView")
                fatalError()
            }
            
            let destinationVC = segue.destination as! FolderTableVC
            destinationVC.selectedFolder = folder
            break
        case "ShowRssItems":
            // Show RSSFeed
            guard let feed = feeds?[indexPath.row - folders!.count] else {
                print("Error when loading feeds to display in the tableView")
                fatalError()
            }
            
            let destinationVC = segue.destination as! RSSFeedTableVC
            destinationVC.selectedFeed = feed
            break
        default:
            print("Unknown segue in MainTableVC.")
            fatalError()
        }
    }
}

// MARK: Data manipulation

extension MainTableVC: NewFeedDelegate {
    func feedCreated(feed myRssFeed: MyRSSFeed) {
        // Validate the address by running update of the feed
        // TODO: Validation
        dbHandler.update(feed: myRssFeed)
        
        tableView.reloadData()
    }
    
}
