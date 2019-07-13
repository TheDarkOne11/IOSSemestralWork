//
//  ItemTableVM.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 07/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift

struct ShownItems {
    let specialItems: [SpecialItem]
    let folders: List<Folder>
    let feeds: List<MyRSSFeed>
    
    func getItem(at index: Int) -> Item {
        if index < specialItems.count {
            return specialItems[index]
        } else if index < specialItems.count + folders.count {
            return folders[index - specialItems.count]
        } else {
            return feeds[index - specialItems.count - folders.count]
        }
    }
}

protocol IItemTableVM {
    var selectedItem: Folder { get }
    var shownItems: ShownItems! { get }
    var downloadStatus: MutableProperty<DownloadStatus?> { get }
    var screenTitle: String { get }
    
    func edit(_ folder: Folder, title: String)
    func remove(_ item: Item)
    func updateAllFeeds()
    func select(_ item: Item)
}

final class ItemTableVM: BaseViewModel, IItemTableVM {
    typealias Dependencies = HasRepository & HasDBHandler & HasRealm & HasRootFolder & HasUserDefaults
    private let dependencies: Dependencies!
    
    let downloadStatus = MutableProperty<DownloadStatus?>(nil)
    
    /** SpecialItems, Folders and MyRSSFeeds. */
    private(set) var shownItems: ShownItems!
    
    /** Folder */
    let selectedItem: Folder
    
    private let specialItems: [SpecialItem] = []
    
    let screenTitle: String
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        
        if let selectedItem = dependencies.repository.selectedItem.value as? Folder {
            self.selectedItem = selectedItem
        } else {
            fatalError("Should be a Folder.")
        }
        
        self.screenTitle = selectedItem.itemId == dependencies.rootFolder.itemId ? L10n.ItemTableView.baseTitle : selectedItem.title
        
        super.init()
        
        shownItems = getItems()
    }
    
    func edit(_ folder: Folder, title: String) {
        dependencies.dbHandler.realmEdit(errorMsg: "Error occured when editing a folder", editCode: {
            folder.title = title
        })
    }
    
    func remove(_ item: Item) {
        dependencies.dbHandler.remove(item)
    }
    
    private func getItems() -> ShownItems {
        let allItems = SpecialItem(withTitle: L10n.Base.allItems, imageName: "all") { () -> SpecialItem.ActionResult in
            return (self.selectedItem, nil)
        }
        
        let predicateUnread = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "isRead == false")])
        let unreadItems = SpecialItem(withTitle: L10n.Base.unreadItems, imageName: "unread", predicate: predicateUnread) { () -> SpecialItem.ActionResult in
            return (self.selectedItem, NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "isRead == false")]))
        }
        
        let predicateStarred = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "isStarred == true")])
        let starredItems = SpecialItem(withTitle: L10n.Base.starredItems, imageName: "star", predicate: predicateStarred) { () -> SpecialItem.ActionResult in
            return (self.selectedItem, NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "isStarred == true")]))
        }
        
        return ShownItems(specialItems: [allItems, unreadItems, starredItems], folders: selectedItem.folders, feeds: selectedItem.feeds)
    }
    
    func updateAllFeeds() {
        dependencies.dbHandler.updateAll() { [weak self] status in
            
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
}
