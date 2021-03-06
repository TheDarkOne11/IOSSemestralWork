//
//  RSSFeedTableVM.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 12/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift
import Data
import Common

protocol IRSSItemsTableVM {
    var selectedItem: Item { get }
    var shownItems: Results<MyRSSItem> { get }
    var downloadStatus: MutableProperty<DownloadStatus?> { get }
    var title: String {get}
    
    func updateAllFeeds()
    func select(_ item: Item)
    func lastUpdateDate() -> NSDate
}

/**
 VM for displaying `MyRSSItem`s.
*/
final class RSSItemsTableVM: BaseViewModel, IRSSItemsTableVM {
    typealias Dependencies = HasRepository & HasUserDefaults
    private let dependencies: Dependencies!
    
    let downloadStatus = MutableProperty<DownloadStatus?>(nil)
    
    let selectedItem: Item
    let shownItems: Results<MyRSSItem>
    let title: String
    
    private let specialItems: [SpecialItem] = []
        
    init(dependencies: Dependencies, title: String, selectedItem: Item, predicate: NSCompoundPredicate? = nil) {
        self.dependencies = dependencies
        self.selectedItem = selectedItem
        self.title = title
        
        if let selectedItem = selectedItem as? MyRSSFeed {
            shownItems = selectedItem.myRssItems.filter(NSPredicate(value: true))
        } else if let selectedItem = selectedItem as? Folder {
            shownItems = dependencies.repository.getAllRssItems(of: selectedItem, predicate: predicate)
        } else {
            fatalError("Should be a Folder or RSSFeed.")
        }
        
        super.init()
    }
    
    func updateAllFeeds() {
        dependencies.repository.updateAllFeeds() { [weak self] status in
            
            // Hiding of the RefreshView is delayed to at least 0.5 s so that the updateLabel is visible.
            let deadline = DispatchTime.now() + .milliseconds(500)
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self?.downloadStatus.value = status
                
                self?.checkStatus(status)
            }
        }
    }
    
    /**
     Checks status of the update.
     */
    private func checkStatus(_ status: DownloadStatus) {
        if status == DownloadStatus.OK {
            dependencies.userDefaults.set(NSDate(), forKey: UserDefaults.Keys.lastUpdate.rawValue)
        }
    }
    
    func select(_ item: Item) {
        dependencies.repository.selectedItem.value = item
    }
    
    func lastUpdateDate() -> NSDate {
        return dependencies.userDefaults.object(forKey: UserDefaults.Keys.lastUpdate.rawValue) as! NSDate
    }
}
