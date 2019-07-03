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
    let realm: Realm!
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    /**
     
     - parameter errorMsg: An error string which displays when an exception is thrown.
     - parameter editCode: A function where we create, edit or delete any Realm objects.
     */
    func realmEdit(errorMsg: String, editCode: () -> Void) {
        do {
            try realm.write {
                editCode()
            }
        } catch {
            print("\(errorMsg): \(error)")
        }
    }
    
    // MARK: PolyItem methods
    
    func remove(_ polyItem: PolyItem) {
        if let folder = polyItem.folder {
            self.remove(folder)
        } else if let feed = polyItem.myRssFeed {
            self.remove(feed)
        }
    }
    
    // MARK: Folder methods
    
    func create(_ folder: Folder) {
        // Save the folder to Realm
        realmEdit(errorMsg: "Could not add a new folder to Realm") {
            if let parentFolder = folder.parentFolder {
                parentFolder.polyItems.append(folder)
            } else {
                realm.add(folder)
                
                let polyItem = PolyItem()
                polyItem.folder = folder
                realm.add(polyItem)
            }
        }
    }
    
    func remove(_ folder: Folder) {
        // Remove folders contents
        for feed in folder.polyItems {
            remove(feed)
        }
        
        realmEdit(errorMsg: "Error occured when removing a folder \(folder.title)") {
            realm.delete(folder)
        }
    }
    
    // MARK: MyRSSFeed methods
    
    func create(_ myRssFeed: MyRSSFeed) {
        realmEdit(errorMsg: "Error occured when creating a new MyRSSFeed") {
            myRssFeed.folder!.polyItems.append(myRssFeed)
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
     - parameter myRssFeed: The RSS feed whose RSS items we are downloading.
     */
    func update(_ myRssFeed: MyRSSFeed, completed: @escaping (DownloadStatus) -> Void) {
        
        // Check if internet is reachable
        if !NetworkReachabilityManager()!.isReachable {
            completed(.Unreachable)
            return
        }
        
        var request = URLRequest(url: NSURL.init(string: myRssFeed.link)! as URL)
        request.httpMethod = "GET"
        request.timeoutInterval = 2 // 2 secs
        
        Alamofire
            .request(request)
            .responseRSS() { (response) -> Void in
                self.checkResponse(myRssFeed, response, completed: completed)
        }
        
    }
    
    private func checkResponse(_ myRssFeed: MyRSSFeed, _ response: DataResponse<RSSFeed>, completed: @escaping (DownloadStatus) -> Void) {
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
    
    /**
     Persists the new or updated RSS items.
     */
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
