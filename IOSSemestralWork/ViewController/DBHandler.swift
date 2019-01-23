//
//  DBHandler.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 22/01/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import AlamofireRSSParser

/**
 This class has all methods for manipulation with Models in Realm database.
 */
class DBHandler {
    let realm = try! Realm()
    
    // MARK: Folder methods
    
    func create(folder: Folder) {
        // Save the folder to Realm
        do {
            try realm.write {
               realm.add(folder)
            }
        } catch {
            print("Could not add a new folder to Realm: \(error)")
        }
    }
    
    // MARK: MyRSSFeed methods
    
    func create(feed myRssFeed: MyRSSFeed, in folder: Folder) {
        do {
            try realm.write {
                folder.myRssFeeds.append(myRssFeed)
            }
        } catch {
            print("Error occured when creating a new MyRSSFeed: \(error)")
        }
    }
    
    /**
     Downloads items of the selected feed using AlamofireRSSParser.
     */
    func update(feed myRssFeed: MyRSSFeed) {
        
        Alamofire.request(myRssFeed.link).responseRSS() { (response) -> Void in
            
            if(response.result.isFailure) {
                // TODO: Return internet offline or website doesn't exist
                print(response.error!)
                return
            }
            
            if let feed: RSSFeed = response.result.value {
                
                if(feed.items.count == 0 && feed.link == nil && feed.title == nil) {
                    // TODO: Return website is not an RSS feed
                    return
                }
                
                // Add all items to the MyRSSFeed
                do {
                    try self.realm.write {
                        for item in feed.items {
                            let myRssItem = MyRSSItem(with: item)
                            
                            self.realm.add(myRssItem, update: true)
                            
                            // Add the item only if it doesn't exist already
                            if myRssFeed.myRssItems.index(of: myRssItem) == nil {
                                myRssFeed.myRssItems.append(myRssItem)
                            }
                        }
                    }
                } catch {
                    print("Error when adding a MyRSSItem to MyRSSFeed: \(error)")
                }
                print("Items of \(myRssFeed.title) updated: \(myRssFeed.myRssItems.count)")
            }
        }
        
    }
}
