//
//  Repository.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 02/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift
import Common
import ReactiveSwift

public protocol HasRepository {
    var repository: IRepository { get }
}

public protocol IRepository {
    /** Currently selected folder, RSS feed or RSS item */
    var selectedItem: MutableProperty<Item> { get }
    var folders: Results<Folder> { get }
    var feeds: Results<MyRSSFeed> { get }
    var rssItems: Results<MyRSSItem> { get }
    
    func realmEdit(errorCode: ((Error) -> Void)?, editCode: (Realm) -> Void)
    func getAllRssItems(of folder: Folder, predicate: NSCompoundPredicate?) -> Results<MyRSSItem>
    func exists(_ item: Item) -> Bool
    
    
    func create(rssFeed feed: MyRSSFeed, parentFolder: Folder) -> SignalProducer<MyRSSFeed, RSSFeedCreationError>
    func create(newFolder: Folder, parentFolder: Folder) -> SignalProducer<Folder, RSSFeedCreationError>
    func update(selectedFeed oldFeed: MyRSSFeed, with newFeed: MyRSSFeed, parentFolder: Folder) -> SignalProducer<MyRSSFeed, RSSFeedCreationError>
    func updateAll(completed: @escaping (DownloadStatus) -> Void)
    func remove(_ item: Item)
}

public final class Repository: IRepository {
    public typealias Dependencies = HasRealm & HasRootFolder
    private let dependencies: Dependencies
    
    private let dbHandler: DBHandler
    
    public let selectedItem: MutableProperty<Item>
    public lazy var folders: Results<Folder> = self.dbHandler.folders
    public lazy var feeds: Results<MyRSSFeed> = self.dbHandler.feeds
    public lazy var rssItems: Results<MyRSSItem> = self.dbHandler.rssItems
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.dbHandler = DBHandler(dependencies: dependencies)
        self.selectedItem = MutableProperty<Item>(dependencies.rootFolder)
    }
    
    /**
     - parameter errorMsg: Code that runs when an exception is thrown.
     - parameter editCode: A function where we create, edit or delete any Realm objects.
     */
    public func realmEdit(errorCode: ((Error) -> Void)? = nil, editCode: (Realm) -> Void) {
        dbHandler.realmEdit(errorCode: errorCode, editCode: editCode)
    }
    
    /**
     Returns all RSSItems from this folder and its subfolders.
     */
    public func getAllRssItems(of folder: Folder, predicate: NSCompoundPredicate? = nil) -> Results<MyRSSItem> {
        let folderNames: [String] = getAllFolderNames(from: folder)
        let foldersPredicate = NSPredicate(format: "ANY rssFeed.folder.title IN %@", folderNames)
                
        if let predicate = predicate {
            return rssItems
                .filter(predicate)
                .filter(foldersPredicate)
        } else {
            return rssItems.filter(foldersPredicate)
        }
    }
    
    private func getAllFolderNames(from folder: Folder) -> [String] {
        var folderNames: [String] = [folder.title]
        
        for subfolder in folder.folders {
            folderNames.append(contentsOf: getAllFolderNames(from: subfolder))
        }
        
        return folderNames
    }
    
    public func exists(_ item: Item) -> Bool {
        switch item.type {
        case .folder:
            return folders.filter("title == %@", item.title).count != 0
        case .myRssFeed:
            let feed = item as! MyRSSFeed
            let cleanLink = feed.link.replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "https://", with: "")
            return feeds.filter("link CONTAINS[cd] %@", cleanLink).count != 0
        case .myRssItem:
            guard let articleLink = (item as! MyRSSItem).articleLink else {
                return false
            }
            
            return rssItems.filter("articleLink CONTAINS[cd] %@", articleLink).count != 0
        case .specialItem:
            return false
        }
    }
}

// MARK: CRUD methods

extension Repository {
    public func create(rssFeed feed: MyRSSFeed, parentFolder: Folder) -> SignalProducer<MyRSSFeed, RSSFeedCreationError> {
        return SignalProducer<MyRSSFeed, RSSFeedCreationError> { (observer, lifetime) in
            // Check for duplicates
            if self.exists(feed) {
                observer.send(error: .exists)
                return
            }
            
            // Save the new feed
            self.dbHandler.realmEdit(errorCode: { error in
                observer.send(error: .unknown)
                return
            }, editCode: { realm in
                parentFolder.feeds.append(feed)
            })
            
            observer.send(value: feed)
            observer.sendCompleted()
        }
    }
    
    public func create(newFolder: Folder, parentFolder: Folder) -> SignalProducer<Folder, RSSFeedCreationError> {
        return SignalProducer<Folder, RSSFeedCreationError> { (observer, lifetime) in
            if self.exists(newFolder) {
                observer.send(error: .exists)
                return
            }
            
            self.dbHandler.realmEdit(errorCode: { error in
                observer.send(error: .unknown)
                return
            }, editCode: { realm in
                parentFolder.folders.append(newFolder)
            })
            
            observer.send(value: newFolder)
            observer.sendCompleted()
        }
    }
    
    public func update(selectedFeed oldFeed: MyRSSFeed, with newFeed: MyRSSFeed, parentFolder: Folder) -> SignalProducer<MyRSSFeed, RSSFeedCreationError> {
        return SignalProducer<MyRSSFeed, RSSFeedCreationError> { (observer, lifetime) in
            self.dbHandler.realmEdit(errorCode: { error in
                observer.send(error: .unknown)
                return
            }, editCode: { realm in
                let oldFolder = oldFeed.folder.first
                let oldIndex = oldFolder?.feeds.index(matching: "link == %@", oldFeed.link)
                
                // Update properties
                oldFeed.title = newFeed.title
                oldFeed.link = newFeed.link
                
                // Change folders
                if oldFolder?.itemId != parentFolder.itemId {
                    oldFolder?.feeds.remove(at: oldIndex!)
                    parentFolder.feeds.append(oldFeed)
                }
            })
        }
    }
    
    public func updateAll(completed: @escaping (DownloadStatus) -> Void) {
        dbHandler.updateAll(completed: completed)
    }
    
    public func remove(_ item: Item) {
        dbHandler.remove(item)
    }
}
