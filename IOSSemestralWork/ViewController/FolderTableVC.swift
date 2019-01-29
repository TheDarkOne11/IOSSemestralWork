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
        
        folders = nil
        
        // Get all feeds from "None" folder. They are supposed to be displayed in this screen
        feeds = realm.objects(Folder.self)
            .filter("title CONTAINS[cd] %@", selectedFolder!.title)[0]
            .myRssFeeds
    }
    
    // MARK: TableView helper methods
    
    override func fill(cell: UITableViewCell, at row: Int) -> UITableViewCell? {
        if let cell = super.fill(cell: cell, at: row) {
            return cell
        }
        
        guard let feed = feeds?[row - specialFoldersCount] else {
            print("Error when loading feeds to display in the tableView")
            fatalError()
        }
        
        cell.textLabel?.text = feed.title + " (MyRSSFeed)"
        
        return cell
    }
}
