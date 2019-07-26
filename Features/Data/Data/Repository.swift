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
import Resources
import ReactiveSwift

public protocol HasRepository {
    var repository: IRepository { get }
}

public protocol IRepository {
    /** Currently selected folder, RSS feed or RSS item */
    var selectedItem: MutableProperty<Item> { get }
    var rootFolder: Folder { get }
    var folders: Results<Folder> { get }
    var feeds: Results<MyRSSFeed> { get }
    var rssItems: Results<MyRSSItem> { get }
    
    func realmEdit(errorCode: ((Error) -> Void)?, editCode: (Realm) -> Void)
    func getAllRssItems(of folder: Folder, predicate: NSCompoundPredicate?) -> Results<MyRSSItem>
    func exists(_ item: Item) -> Item?
    
    func create(rssFeed feed: MyRSSFeed, parentFolder: Folder) -> SignalProducer<MyRSSFeed, RealmObjectError>
    func create(newFolder: Folder, parentFolder: Folder) -> SignalProducer<Folder, RealmObjectError>
    func update(selectedFeed oldFeed: MyRSSFeed, with newFeed: MyRSSFeed, parentFolder: Folder) -> SignalProducer<MyRSSFeed, RealmObjectError>
    func update(selectedFolder oldFolder: Folder, with newFolder: Folder, parentFolder: Folder) -> SignalProducer<Folder, RealmObjectError>
    func updateAllFeeds(completed: @escaping (DownloadStatus) -> Void)
    func validate(link: String) -> SignalProducer<DownloadStatus, Never>
    func remove(_ item: Item)
}

public final class Repository: IRepository {
    public typealias Dependencies = HasRealm & HasUserDefaults & HasRSSFeedResponseValidator
    private let dependencies: Dependencies
    
    private let dbHandler: DBHandler
    
    private var _rootFolder: Folder!
    public var rootFolder: Folder {
        return _rootFolder
    }
    
    private var _selectedItem: MutableProperty<Item>!
    public var selectedItem: MutableProperty<Item> {
        return _selectedItem
    }
    
    public lazy var folders: Results<Folder> = self.dbHandler.folders
    public lazy var feeds: Results<MyRSSFeed> = self.dbHandler.feeds
    public lazy var rssItems: Results<MyRSSItem> = self.dbHandler.rssItems
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.dbHandler = DBHandler(dependencies: dependencies)
        self._rootFolder = getRootFolder()
        self._selectedItem = MutableProperty<Item>(_rootFolder)
    }
    
    private func getRootFolder() -> Folder {
        guard let itemId = dependencies.userDefaults.string(forKey: UserDefaults.Keys.rootFolderItemId.rawValue) else {
            // Create root folder
            let rootFolder: Folder = Folder(withTitle: L10n.Base.rootFolder)
            
            realmEdit(errorCode: nil) { realm in
                realm.add(rootFolder)
            }
            dependencies.userDefaults.set(rootFolder.itemId, forKey: UserDefaults.Keys.rootFolderItemId.rawValue)
            
            return rootFolder
        }
        
        guard let rootFolder = folders.filter("itemId == %@", itemId).first else {
            fatalError("The root folder must already exist in Realm.")
        }
        
        if rootFolder.title != L10n.Base.rootFolder {
            // Update name of the root folder
            realmEdit(errorCode: nil) { realm in
                rootFolder.title = L10n.Base.rootFolder
            }
        }
        
        return rootFolder
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
    
    public func exists(_ item: Item) -> Item? {
        switch item.type {
        case .folder:
            return folders.filter("title == %@", item.title).first
        case .myRssFeed:
            let feed = item as! MyRSSFeed
            let cleanLink = feed.link.replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "https://", with: "")
            return feeds.filter("link CONTAINS[cd] %@", cleanLink).first
        case .myRssItem:
            guard let articleLink = (item as! MyRSSItem).articleLink else {
                return nil
            }
            
            return rssItems.filter("articleLink CONTAINS[cd] %@", articleLink).first
        case .specialItem:
            return nil
        }
    }
}

// MARK: CRUD methods

extension Repository {
    public func create(rssFeed feed: MyRSSFeed, parentFolder: Folder) -> SignalProducer<MyRSSFeed, RealmObjectError> {
        return SignalProducer<MyRSSFeed, RealmObjectError> { (observer, lifetime) in
            // Check for duplicates
            if self.exists(feed) != nil {
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
    
    public func create(newFolder: Folder, parentFolder: Folder) -> SignalProducer<Folder, RealmObjectError> {
        return SignalProducer<Folder, RealmObjectError> { (observer, lifetime) in
            if self.exists(newFolder) != nil {
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
    
    public func update(selectedFeed oldFeed: MyRSSFeed, with newFeed: MyRSSFeed, parentFolder: Folder) -> SignalProducer<MyRSSFeed, RealmObjectError> {
        return SignalProducer<MyRSSFeed, RealmObjectError> { (observer, lifetime) in
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
                
                observer.send(value: oldFeed)
                observer.sendCompleted()
            })
        }
    }
    
    public func update(selectedFolder oldFolder: Folder, with newFolder: Folder, parentFolder: Folder) -> SignalProducer<Folder, RealmObjectError> {
        return SignalProducer<Folder, RealmObjectError> { (observer, lifetime) in
            self.dbHandler.realmEdit(errorCode: { error in
                observer.send(error: .unknown)
                return
            }, editCode: { realm in
                let oldParentFolder = oldFolder.parentFolder.first!
                let oldIndex = oldFolder.folders.index(matching: "title == %@", oldFolder.title)
                
                // Update properties
                oldFolder.title = newFolder.title
                
                // Change folders
                if oldParentFolder.itemId != parentFolder.itemId {
                    oldParentFolder.folders.remove(at: oldIndex!)
                    parentFolder.folders.append(oldFolder)
                }
                
                observer.send(value: oldFolder)
                observer.sendCompleted()
            })
        }
    }
    
    public func updateAllFeeds(completed: @escaping (DownloadStatus) -> Void) {
        dbHandler.updateAll(completed: completed)
    }
    
    public func validate(link: String) -> SignalProducer<DownloadStatus, Never> {
        return dbHandler.validate(link)
    }
    
    public func remove(_ item: Item) {
        dbHandler.remove(item)
    }
}
