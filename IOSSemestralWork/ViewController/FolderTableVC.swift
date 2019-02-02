//
//  FolderTableViewController.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import RealmSwift

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
    
    override func allRssItems() -> Results<MyRSSItem> {
        guard let selectedFolder = self.selectedFolder else {
            print("Error occured, selectedFolder should already be initialized.")
            fatalError()
        }
        
        return super.allRssItems().filter("rssFeed.folder.title CONTAINS[cd] %@", selectedFolder.title)
    }
}
