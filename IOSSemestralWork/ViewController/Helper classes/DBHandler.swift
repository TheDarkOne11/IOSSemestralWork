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

enum DownloadStatus: String {
    case OK
    case NotOK
    case Unreachable
}

/**
 This class has all methods for manipulation with Models in Realm database.
 */
class DBHandler {
    let realm = try! Realm()
    
    func realmEdit(errorMsg: String, editCode: () -> Void) {
        do {
            try realm.write {
                editCode()
            }
        } catch {
            print("\(errorMsg): \(error)")
        }
    }
    
    // MARK: Folder methods
    
    func create(_ folder: Folder) {
        // Save the folder to Realm
        realmEdit(errorMsg: "Could not add a new folder to Realm") {
            realm.add(folder)
        }
    }
    
    func remove(_ folder: Folder) {
        // Remove folders contents
        for feed in folder.myRssFeeds {
            remove(feed)
        }
        
        realmEdit(errorMsg: "Error occured when removing a folder \(folder.title)") {
            realm.delete(folder)
        }
    }
    
    // MARK: MyRSSFeed methods
    
    func create(_ myRssFeed: MyRSSFeed) {
        realmEdit(errorMsg: "Error occured when creating a new MyRSSFeed") {
            myRssFeed.folder!.myRssFeeds.append(myRssFeed)
        }
    }
    
    func remove(_ myRssFeed: MyRSSFeed) {
        realmEdit(errorMsg: "Error occured when removing a folder \(myRssFeed.title)") {
            realm.delete(myRssFeed.myRssItems)
            realm.delete(myRssFeed)
        }
    }
    
    // MARK: MyRSSItem methods
    
    /**
     Downloads items of the all feeds.
     - parameter completed: A function that is called when all feeds are updated.
     */
    func updateAll(completed: @escaping (DownloadStatus) -> Void) {
        // DispatchGroup enables us to trigger some code when all async requests are done
        let myGroup = DispatchGroup()
        
        // Check if internet is reachable
        if !NetworkReachabilityManager()!.isReachable {
            completed(.Unreachable)
            return
        }
        
        for feed in realm.objects(MyRSSFeed.self) {
            
            // Do not update bad feeds
            if !feed.isOk {
                continue
            } else {
                myGroup.enter()
            }
            
            self.update(feed) { (success) -> Void in
                // Triggered when an update is done
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main) {
            // Triggered when all updates are done
            print("Finished all updates.")
            completed(.OK)
        }
    }
    
    /**
     Downloads items of the selected feed using AlamofireRSSParser.
     - parameter completed: A function that is called when an asynchronous Alamofire request ends.
     */
    func update(_ myRssFeed: MyRSSFeed, completed: @escaping (DownloadStatus) -> Void) {
        
        // Check if internet is reachable
        if !NetworkReachabilityManager()!.isReachable {
            completed(.Unreachable)
            return
        }
        
        Alamofire.request(myRssFeed.link).responseRSS() { (response) -> Void in
            // Validate the response
            if let mimeType =  response.response?.mimeType {
                if mimeType != "application/rss+xml" && mimeType != "text/xml" {
                    // Website exists but isn't a RSS feed
                    completed(.NotOK)
                    return
                }
            } else {
                // Website doesn't exist
                completed(.NotOK)
                return
            }
            
            // Website is RSS feed, we can store info
            if let feed: RSSFeed = response.result.value {
                
                // Add all items to the MyRSSFeed
                self.persistRssItems(feed, myRssFeed)
                
                completed(.OK)
            }
        }
        
    }
    
    private func persistRssItems(_ feed: RSSFeed, _ myRssFeed: MyRSSFeed) {
        realmEdit(errorMsg: "Error when adding items to MyRSSFeed") {
            if myRssFeed.title == myRssFeed.link, let title = feed.title {
                myRssFeed.title = title
            }
            
            for item in feed.items {
                let myRssItem = MyRSSItem(item, myRssFeed)
                
                // Add the item only if it doesn't exist already
                if realm.object(ofType: MyRSSItem.self, forPrimaryKey: myRssItem.articleLink) == nil {
                    realm.add(myRssItem, update: false)
                    
                    myRssFeed.myRssItems.append(myRssItem)
                }
            }
        }
    }
}
