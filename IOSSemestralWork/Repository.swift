//
//  Repository.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 02/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift

final class Repository {
    let realm = try! Realm()
    let dbHandler = DBHandler()
    
    func create(title: String, link: String, folder: Folder) -> SignalProducer<MyRSSFeed, MyRSSFeedError> {
        // Check for duplicates
        if let duplicateFeed = realm.objects(MyRSSFeed.self).filter("link CONTAINS[cd] %@", link).first {
            return SignalProducer(error: .exists(duplicateFeed))
        }
        
        // Save the new feed
        let myRssFeed = MyRSSFeed(title: title, link: link, in: folder)
        dbHandler.create(myRssFeed)
        return SignalProducer(value: myRssFeed)
    }
    
    func update(selectedFeed feed: MyRSSFeed, title: String, link: String, folder: Folder) -> SignalProducer<MyRSSFeed, MyRSSFeedError> {
        // TODO: Error handling – change errorMsg to a closure
        dbHandler.realmEdit(errorMsg: "Error occured when updating the RSSFeed") {
            let oldFolder = feed.folder
            let oldIndex = oldFolder?.polyItems.index(matching: "myRssFeed.link == %@", feed.link)
            let oldItem = oldFolder?.polyItems[oldIndex!]

            // Update properties
            feed.title = title
            feed.link = link
            feed.folder = folder

            // Change folders
            oldFolder?.polyItems.remove(at: oldIndex!)
            folder.polyItems.append(oldItem!)
        }
        return SignalProducer(value: feed)
    }
}
