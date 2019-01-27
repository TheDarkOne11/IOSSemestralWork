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
     Downloads items of the all feeds.
     - parameter completed: A function that is called when all feeds are updated.
     */
    func updateAll(completed: @escaping (Bool) -> Void) {
        // DispatchGroup enables us to trigger some code when all async requests are done
        let myGroup = DispatchGroup()
        
        // Check if internet is reachable
        if !NetworkReachabilityManager()!.isReachable {
            completed(false)
            return
        }
        
        for feed in realm.objects(MyRSSFeed.self) {
            
            // Do not update bad feeds
            if !feed.isOk {
                continue
            } else {
                myGroup.enter()
            }
            
            self.update(feed: feed) { (success) -> Void in
                // Triggered when an update is done
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main) {
            // Triggered when all updates are done
            print("Finished all updates.")
            completed(true)
        }
    }
    
    /**
     Downloads items of the selected feed using AlamofireRSSParser.
     - parameter completed: A function that is called when an asynchronous Alamofire request ends.
     */
    func update(feed myRssFeed: MyRSSFeed, completed: @escaping (Bool) -> Void) {
        
        // Check if internet is reachable
        if !NetworkReachabilityManager()!.isReachable {
            completed(true)
            return
        }
        
        Alamofire.request(myRssFeed.link).responseRSS() { (response) -> Void in
            // Validate the response
            if let mimeType =  response.response?.mimeType {
                if mimeType != "application/rss+xml" {
                    // Website exists but isn't a RSS feed
                    completed(false)
                    return
                }
            } else {
                // Website doesn't exist
                completed(false)
                return
            }
            
            // Website is RSS feed, we can store info
            if let feed: RSSFeed = response.result.value {
                
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
                    completed(false)
                    return
                }
                
                completed(true)
            }
        }
        
    }
}
