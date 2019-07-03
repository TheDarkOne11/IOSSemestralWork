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
//            let oldFolder: Folder = feed.folder!
//            let oldIndex: Int = oldFolder.myRssFeeds.index(of: feed)!
//            
//            feed.title = title
//            feed.link = link
//            
//            // Change folders
//            oldFolder.polyItems.remove(at: oldIndex)
//            feed.folder = folder
//            folder.polyItems.append(feed)
        }
        return SignalProducer(value: feed)
    }
}
