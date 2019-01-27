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
    func updateAll(completed: @escaping () -> Void) {
        // DispatchGroup enables us to trigger some code when all async requests are done
        let myGroup = DispatchGroup()
        
        // TODO: Remove debugging code that is causing delays
        var i = 1000
        for feed in realm.objects(MyRSSFeed.self) {
            myGroup.enter()
            
            let deadline = DispatchTime.now() + .milliseconds(2000 + i)
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.update(feed: feed) { (success) -> Void in
                    // Triggered when an update is done
                    print("Items of \(feed.title) updated: \(feed.myRssItems.count)")
                    myGroup.leave()
                }
            }
            
            i += 1000
        }
        
        myGroup.notify(queue: .main) {
            // Triggered when all updates are done
            print("Finished all updates.")
            completed()
        }
    }
    
    /**
     Downloads items of the selected feed using AlamofireRSSParser.
     - parameter completed: A function that is called when an asynchronous Alamofire request ends.
     */
    func update(feed myRssFeed: MyRSSFeed, completed: @escaping (Bool) -> Void) {
        
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
                    return
                }
                
                completed(true)
            }
        }
        
    }
}
