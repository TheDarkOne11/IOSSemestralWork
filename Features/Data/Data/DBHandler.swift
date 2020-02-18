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
import ReactiveSwift
import Common

/**
 This class has all methods for manipulation with Models in Realm database.
 */
class DBHandler {
    typealias Dependencies = HasRealm & HasRSSFeedResponseValidator
    private let dependencies: Dependencies
    
    lazy var folders: Results<Folder> = self.dependencies.realm.objects(Folder.self)
    lazy var feeds: Results<MyRSSFeed> = self.dependencies.realm.objects(MyRSSFeed.self)
    lazy var rssItems: Results<MyRSSItem> = self.dependencies.realm.objects(MyRSSItem.self)
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    /**
     
     - parameter errorMsg: An error string which displays when an exception is thrown.
     - parameter editCode: A function where we create, edit or delete any Realm objects.
     */
    func realmEdit(errorCode: ((Error) -> Void)? = nil, editCode: (Realm) -> Void) {
        do {
            try dependencies.realm.write {
                editCode(dependencies.realm)
            }
        } catch {
            print("Error occured: \(error)")
            if let errorCode = errorCode {
                errorCode(error)
            }
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
    
    private func remove(_ folder: Folder) {
        realmEdit() { realm in
            // Remove folders contents
            for folder in folder.folders {
                realm.delete(folder)
            }
            
            for feed in folder.feeds {
                realm.delete(feed)
            }
            
            realm.delete(folder)
        }
    }
    
    // MARK: MyRSSFeed methods
    
    private func remove(_ myRssFeed: MyRSSFeed) {
        realmEdit() { realm in
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
            completed(.unreachable)
            return
        }
        
        for feed in feeds {
            
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
    
    func validate(_ link: String) -> SignalProducer<DownloadStatus, Never> {
        // Check if internet is reachable
        if !NetworkReachabilityManager()!.isReachable {
            return SignalProducer.init(value: .unreachable)
        }
        
        var request = URLRequest(url: NSURL.init(string: link)! as URL)
        request.httpMethod = "GET"
        request.timeoutInterval = 2 // 2 secs
        
        return SignalProducer<DownloadStatus, Never> { (observer, lifetime) in
            Alamofire
                .request(request)
                .responseRSS() { (response) -> Void in
                    observer.send(value: self.dependencies.rssFeedResponseValidator.validate(response))
                    observer.sendCompleted()
            }
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
            completed(.unreachable)
            return
        }
        
        var request = URLRequest(url: NSURL.init(string: myRssFeed.link)! as URL)
        request.httpMethod = "GET"
        request.timeoutInterval = 2 // 2 secs
        
        Alamofire
            .request(request)
            .responseRSS() { (response) -> Void in
                let validation = self.dependencies.rssFeedResponseValidator.validate(response)
                
                if validation == .OK || validation == .emptyFeed {
                    if let feed: RSSFeed = response.result.value {
                        
                        // Add all items to the MyRSSFeed
                        self.persistRssItems(feed, myRssFeed)
                    }
                }
                completed(validation)
        }
        
    }
    
    /**
     Persists the new or updated RSS items.
     */
    private func persistRssItems(_ feed: RSSFeed, _ myRssFeed: MyRSSFeed) {
        realmEdit() { realm in
            if myRssFeed.title == myRssFeed.link, let title = feed.title {
                myRssFeed.title = title
            }
            
            for item in feed.items {
                let newRssItem = MyRSSItem(item)
                
                // Add the item only if it doesn't exist already
                if rssItems.filter("articleLink CONTAINS[cd] %@", newRssItem.articleLink ?? "").count == 0 {
                    myRssFeed.myRssItems.append(newRssItem)
                }
            }
        }
    }
}
