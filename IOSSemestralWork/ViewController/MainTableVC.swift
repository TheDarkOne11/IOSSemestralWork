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
    // Shown folders
    var folders: Results<Folder>?
    
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
    
    // MARK: TableView helper methods
    
    override func fill(cell: UITableViewCell, at row: Int) -> UITableViewCell? {
        if let cell = super.fill(cell: cell, at: row) {
            return cell
        }
        
        // First show custom folders then RSS feeds without folder
        if row < folders!.count + specialFoldersCount {
            // Show folder
            guard let folder = folders?[row - specialFoldersCount] else {
                print("Error when loading folders to display in the tableView")
                fatalError()
            }
            
            cell.textLabel?.text = folder.title + " (Folder)"
        } else {
            // Show RSSFeed
            guard let feed = feeds?[row - folders!.count - specialFoldersCount] else {
                print("Error when loading feeds to display in the tableView")
                fatalError()
            }
            
            cell.textLabel?.text = feed.title + " (MyRSSFeed)"
        }
        
        return cell
    }
    
    // MARK: - TableView methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section) + folders!.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if indexPath.row < specialFoldersCount {
            return
        }
        
        guard let folders = self.folders else {
            print("Error when selecting a folder")
            fatalError()
        }
        
        // TODO: Go to the folder's contents only when an edge of the cell is selected, otherwise show RSSItems of its feeds
        
        if indexPath.row < folders.count + specialFoldersCount {
            // Go to FolderTableVC
            // TODO: Maybe do the same for folder we did for RSSItems
            performSegue(withIdentifier: "ShowFolderContents", sender: nil)
        } else {
            // Go to RSSFeedTableVC
            let currFeed = feeds![indexPath.row - folders.count - specialFoldersCount]
            
            // Change rssItems from List to Results
            let sender = SeguePreparationSender(rssItems: currFeed.myRssItems.filter("TRUEPREDICATE"), title: currFeed.title)
            
            performSegue(withIdentifier: "ShowRssItems", sender: sender)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
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
        
        if segue.identifier ==  "ShowFolderContents" {
            // Show folder
            guard let folder = folders?[indexPath.row - specialFoldersCount] else {
                print("Error when loading folders to display in the tableView")
                fatalError()
            }
            
            let destinationVC = segue.destination as! FolderTableVC
            destinationVC.selectedFolder = folder
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
