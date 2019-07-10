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

protocol HasDBHandler {
    var dbHandler: DBHandler { get }
}

enum DownloadStatus: String {
    case OK
    case NotOK
    case Unreachable
}

/**
 This class has all methods for manipulation with Models in Realm database.
 */
class DBHandler {
    typealias Dependencies = HasRealm
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    /**
     
     - parameter errorMsg: An error string which displays when an exception is thrown.
     - parameter editCode: A function where we create, edit or delete any Realm objects.
     */
    func realmEdit(errorMsg: String, editCode: () -> Void) {
        do {
            try dependencies.realm.write {
                editCode()
            }
        } catch {
            print("\(errorMsg): \(error)")
        }
    }
    
    // MARK: Item methods
    
    func remove(_ item: Item) {
        switch item.type {
        case .folder:
            let folder = item as! Folder
            remove(folder)
        case .myRssFeed:
            let feed = item as! MyRSSFeed
            remove(feed)
        case .myRssItem:
            let rssItem = item as! MyRSSItem
            remove(rssItem)
        case .specialItem:
            fatalError("Should not be able to remove SpecialItem.")
        }
    }
    
    // MARK: Folder methods
    
    func create(_ folder: Folder) {
        // Save the folder to Realm
        realmEdit(errorMsg: "Could not add a new folder to Realm") {
            dependencies.realm.add(folder)  //TODO: Remove method
        }
    }
    
    func remove(_ folder: Folder) {
        // Remove folders contents
//        for folder in folder.folders {
//            remove(folder)
//        }
//
//        for feed in folder.feeds {
//            remove(feed)
//        }
        
        realmEdit(errorMsg: "Error occured when removing a folder \(folder.title)") {
            for folder in folder.folders {
                dependencies.realm.delete(folder)
            }
            
            for feed in folder.feeds {
                dependencies.realm.delete(feed)
            }
            
            dependencies.realm.delete(folder)
        }
    }
    
    // MARK: MyRSSFeed methods
    
    func create(_ myRssFeed: MyRSSFeed) {
        realmEdit(errorMsg: "Error occured when creating a new MyRSSFeed") {
            myRssFeed.folder.first?.feeds.append(myRssFeed) //TODO: Remove method?
        }
    }
    
    func remove(_ myRssFeed: MyRSSFeed) {
        realmEdit(errorMsg: "Error occured when removing a folder \(myRssFeed.title)") {
            dependencies.realm.delete(myRssFeed.myRssItems)
            dependencies.realm.delete(myRssFeed)
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
        
        for feed in dependencies.realm.objects(MyRSSFeed.self) {
            
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
                let myRssItem = MyRSSItem(item)
                
                // Add the item only if it doesn't exist already
                if dependencies.realm.object(ofType: MyRSSItem.self, forPrimaryKey: myRssItem.itemId) == nil {
                    myRssFeed.myRssItems.append(myRssItem)
                }
            }
        }
    }
}
