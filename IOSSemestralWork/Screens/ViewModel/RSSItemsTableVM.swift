////
////  RSSFeedTableVM.swift
////  IOSSemestralWork
////
////  Created by Petr Budík on 12/07/2019.
////  Copyright © 2019 Petr Budík. All rights reserved.
////
//
//import Foundation
//import ReactiveSwift
//import RealmSwift
//
//protocol IRSSItemsTableVM {
//    
//}
//
//final class RSSItemsTableVM: BaseViewModel, IRSSItemsTableVM {
//    typealias Dependencies = HasRepository & HasDBHandler & HasRealm & HasRootFolder & HasUserDefaults
//    private let dependencies: Dependencies!
//    
//    let downloadStatus = MutableProperty<DownloadStatus?>(nil)
//    
//    let selectedItem: Item
//    let shownItems: Results<MyRSSItem>
//    
//    private let specialItems: [SpecialItem] = []
//    
//    let screenTitle: String
//    
//    init(dependencies: Dependencies, selectedItem: Item, predicate: NSCompoundPredicate? = nil) {
//        self.dependencies = dependencies
//        self.selectedItem = selectedItem
//        
//        if let selectedItem = dependencies.repository.selectedItem.value as? MyRSSFeed {
//            shownItems = selectedItem.myRssItems.filter(NSPredicate(value: true))
//        } else if let selectedItem = dependencies.repository.selectedItem.value as? Folder {
//            
//        } else {
//            fatalError("Should be a Folder or RSSFeed.")
//        }
//        
//        self.screenTitle = selectedItem.itemId == dependencies.rootFolder.itemId ? L10n.ItemTableView.baseTitle : selectedItem.title
//        
//        super.init()
//    }
//}
