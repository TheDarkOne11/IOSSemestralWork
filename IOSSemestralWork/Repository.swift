//
//  Repository.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 02/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

final class Repository {
    let realm = try! Realm()
    let dbHandler = DBHandler()
    
    func save(title: String, link: String, folder: Folder) {
        // Save the new feed
        let myRssFeed = MyRSSFeed(title: title, link: link, folder: folder)
        dbHandler.create(myRssFeed)
    }
    
    func update(oldFeed: MyRSSFeed, title: String, link: String, folder: Folder) {
        dbHandler.realmEdit(errorMsg: "Error occured when updating the RSSFeed") {
            let oldFolder: Folder = oldFeed.folder!
            let index: Int = oldFolder.myRssFeeds.index(of: oldFeed)!
            
            oldFeed.title = title
            oldFeed.link = link
            
            // Change folders
            oldFolder.myRssFeeds.remove(at: index)
            oldFeed.folder = folder
            folder.myRssFeeds.append(oldFeed)
        }
    }
}
