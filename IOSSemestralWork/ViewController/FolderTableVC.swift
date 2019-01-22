//
//  FolderTableViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit

/**
 Displays the TableView of the selected folders items.
 */
class FolderTableVC: ItemTableVC {
    
    var selectedFolder: Folder? {
        didSet {
            title = selectedFolder!.title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get all feeds from "None" folder. They are supposed to be displayed in this screen
        feeds = realm.objects(Folder.self)
            .filter("title CONTAINS[cd] %@", selectedFolder?.title)[0]
            .myRssFeeds
    }
    
    // MARK: TableView methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        
        guard let feed = feeds?[indexPath.row] else {
            print("Error when loading feeds to display in the tableView")
            fatalError()
        }
        
        cell.textLabel?.text = feed.title + " (MyRSSFeed)"
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowRssItems", sender: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            print("Unreacheable tableViewCell selected.")
            fatalError()
        }
        
        switch segue.identifier {
        case "ShowRssItems":
            // Show RSSFeed
            guard let feed = feeds?[indexPath.row] else {
                print("Error when loading feeds to display in the tableView")
                fatalError()
            }
            
            let destinationVC = segue.destination as! RSSFeedTableVC
            destinationVC.selectedFeed = feed
        default:
            print("Unknown segue in MainTableVC.")
            fatalError()
        }
    }
}
