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
    var screenTitle: String { get }
    
    func remove(_ polyItem: PolyItem)
}

final class ItemTableVM: BaseViewModel, IItemTableVM {
    typealias Dependencies = HasRepository & HasDBHandler & HasRealm & HasRootFolder
    private let dependencies: Dependencies!
    
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
        
        self.screenTitle = selectedItem.itemId == dependencies.rootFolder.itemId ? "RSSFeed reader" : selectedItem.title
        
        super.init()
        
        currentlyShownItems.value = getItems()
    }
    
    func remove(_ polyItem: PolyItem) {
        dependencies.dbHandler.remove(polyItem)
    }
    
    private func getItems() -> ShownItems {
        let allItems = SpecialItem(withTitle: "All items", imageName: "all") { () -> SpecialItem.ActionResult in
            return (self.selectedItem, Array<NSPredicate>())
        }
        
        let unreadItems = SpecialItem(withTitle: "Unread items", imageName: "unread") { () -> SpecialItem.ActionResult in
            return (self.selectedItem, [NSPredicate(format: "isRead == false")])
        }
        
        let starredItems = SpecialItem(withTitle: "Starred items", imageName: "starred") { () -> SpecialItem.ActionResult in
            return (self.selectedItem, [NSPredicate(format: "isStarred == true")])
        }
        
        return ([allItems, unreadItems, starredItems], selectedItem.polyItems)
    }
}
