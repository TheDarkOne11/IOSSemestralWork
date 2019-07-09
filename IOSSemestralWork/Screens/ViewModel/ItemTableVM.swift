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

protocol IItemTableVM {
    typealias ShownItems = ([SpecialItem], List<PolyItem>)
    var selectedItem: Folder { get }
    var currentlyShownItems: MutableProperty<ShownItems?> { get }
    var downloadStatus: MutableProperty<DownloadStatus?> { get }
    var screenTitle: String { get }
    
    func remove(_ polyItem: PolyItem)
    func updateAllFeeds()
    func select(_ item: Item)
}

final class ItemTableVM: BaseViewModel, IItemTableVM {
    typealias Dependencies = HasRepository & HasDBHandler & HasRealm & HasRootFolder & HasUserDefaults
    private let dependencies: Dependencies!
    
    let downloadStatus = MutableProperty<DownloadStatus?>(nil)
    
    /** SpecialItems, Folders and MyRSSFeeds. */
    let currentlyShownItems = MutableProperty<ShownItems?>(nil)
    
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
        
        currentlyShownItems.value = getItems()
    }
    
    func remove(_ polyItem: PolyItem) {
        dependencies.dbHandler.remove(polyItem)
    }
    
    private func getItems() -> ShownItems {
        let allItems = SpecialItem(withTitle: L10n.Base.allItems, imageName: "all") { () -> SpecialItem.ActionResult in
            return (self.selectedItem, Array<NSPredicate>())
        }
        
        let unreadItems = SpecialItem(withTitle: L10n.Base.unreadItems, imageName: "unread") { () -> SpecialItem.ActionResult in
            return (self.selectedItem, [NSPredicate(format: "isRead == false")])
        }
        
        let starredItems = SpecialItem(withTitle: L10n.Base.starredItems, imageName: "star") { () -> SpecialItem.ActionResult in
            return (self.selectedItem, [NSPredicate(format: "isStarred == true")])
        }
        
        return ([allItems, unreadItems, starredItems], selectedItem.polyItems)
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
