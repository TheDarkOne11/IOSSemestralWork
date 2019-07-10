//
//  Repository.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 02/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift

protocol HasRepository {
    var repository: IRepository { get }
}

protocol IRepository {
    /** Currently selected folder, RSS feed or RSS item */
    var selectedItem: MutableProperty<Item> { get }
    
    func create(rssFeed feed: MyRSSFeed) -> SignalProducer<MyRSSFeed, MyRSSFeedError>
    func update(selectedFeed oldFeed: MyRSSFeed, with newFeed: MyRSSFeed) -> SignalProducer<MyRSSFeed, MyRSSFeedError>
}

final class Repository: IRepository {
    typealias Dependencies = HasDBHandler & HasRealm & HasRootFolder
    private let dependencies: Dependencies
    
    let selectedItem: MutableProperty<Item>
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.selectedItem = MutableProperty<Item>(dependencies.rootFolder)
    }
    
    func create(rssFeed feed: MyRSSFeed) -> SignalProducer<MyRSSFeed, MyRSSFeedError> {
        // Check for duplicates
        let cleanLink = feed.link.replacingOccurrences(of: "http://", with: "")
        if let duplicateFeed = dependencies.realm.objects(MyRSSFeed.self).filter("link CONTAINS[cd] %@", cleanLink).first {
            return SignalProducer(error: .exists(duplicateFeed))
        }
        
        // Save the new feed
        dependencies.dbHandler.create(feed)
        return SignalProducer(value: feed)
    }
    
    func update(selectedFeed oldFeed: MyRSSFeed, with newFeed: MyRSSFeed) -> SignalProducer<MyRSSFeed, MyRSSFeedError> {
        //TODO: Error handling – change errorMsg to a closure
        dependencies.dbHandler.realmEdit(errorMsg: "Error occured when updating the RSSFeed") {
            let oldFolder = oldFeed.folder
            let oldIndex = oldFolder?.feeds.index(matching: "link == %@", oldFeed.link)

            // Update properties
            oldFeed.title = newFeed.title
            oldFeed.link = newFeed.link
            oldFeed.folder = newFeed.folder

            // Change folders
            oldFolder?.feeds.remove(at: oldIndex!)
            newFeed.folder?.feeds.append(oldFeed)
        }
        return SignalProducer(value: oldFeed)
    }
}
