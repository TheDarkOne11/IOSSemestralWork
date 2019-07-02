//
//  Folder.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

class Folder: Item {
    let myRssFeeds = List<PolyItem>()
    
    convenience init(with title: String) {
        self.init(with: title, type: .folder)
    }
}

extension List where Element == PolyItem {
    func append(_ item: Item) {
        let polyItem = PolyItem()
        switch item.type {
        case .folder:
            polyItem.folder = item as? Folder
        case .myRssFeed:
            polyItem.myRssFeed = item as? MyRSSFeed
        case .myRssItem:
            polyItem.myRssItem = item as? MyRSSItem
        }
        
        self.append(polyItem)
    }
}
