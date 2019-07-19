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
    
    func create(rssFeed feed: MyRSSFeed, parentFolder: Folder) -> SignalProducer<MyRSSFeed, RSSFeedCreationError>
    func create(newFolder: Folder, parentFolder: Folder) -> SignalProducer<Folder, RSSFeedCreationError>
    func update(selectedFeed oldFeed: MyRSSFeed, with newFeed: MyRSSFeed, parentFolder: Folder) -> SignalProducer<MyRSSFeed, RSSFeedCreationError>
    func getAllRssItems(of folder: Folder, predicate: NSCompoundPredicate?) -> Results<MyRSSItem>
    
    func exists(_ item: Item) -> Bool
}

public final class Repository: IRepository {
    public typealias Dependencies = HasDBHandler & HasRealm & HasRootFolder
    private let dependencies: Dependencies
    
    public let selectedItem: MutableProperty<Item>
    public lazy var folders: Results<Folder> = self.dependencies.realm.objects(Folder.self)
    public lazy var feeds: Results<MyRSSFeed> = self.dependencies.realm.objects(MyRSSFeed.self)
    public lazy var rssItems: Results<MyRSSItem> = self.dependencies.realm.objects(MyRSSItem.self)
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.selectedItem = MutableProperty<Item>(dependencies.rootFolder)
    }
    
    public func create(rssFeed feed: MyRSSFeed, parentFolder: Folder) -> SignalProducer<MyRSSFeed, RSSFeedCreationError> {
        // Check for duplicates
        if exists(feed) {
            return SignalProducer(error: .exists)
        }
        
        // Save the new feed
        dependencies.dbHandler.realmEdit(errorMsg: "Could not create a feed.") {
            parentFolder.feeds.append(feed)
        }
        return SignalProducer(value: feed)
    }
    
    public func create(newFolder: Folder, parentFolder: Folder) -> SignalProducer<Folder, RSSFeedCreationError> {
        return SignalProducer<Folder, RSSFeedCreationError> { (observer, lifetime) in
            if self.exists(newFolder) {
                observer.send(error: .exists)
            }
            
            self.dependencies.dbHandler.realmEdit(errorMsg: "Could not create the folder.") {
                parentFolder.folders.append(newFolder)
            }
            
            observer.send(value: newFolder)
            observer.sendCompleted()
        }
    }
    
    public func update(selectedFeed oldFeed: MyRSSFeed, with newFeed: MyRSSFeed, parentFolder: Folder) -> SignalProducer<MyRSSFeed, RSSFeedCreationError> {
        //TODO: Error handling – change errorMsg to a closure
        dependencies.dbHandler.realmEdit(errorMsg: "Error occured when updating the RSSFeed") {
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
        }
        return SignalProducer(value: oldFeed)
    }
    
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
            let rssItem = item as! MyRSSItem
            return rssItems.filter("articleLink CONTAINS[cd] %@", rssItem.articleLink).count != 0
        case .specialItem:
            return false
        }
    }
}
