//
//  Item.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

enum ItemType: String {
    case folder
    case myRssFeed
    case myRssItem
    case specialItem
}

protocol TableItem {
    var itemId: String { get }
    var title: String { get }
    var type: ItemType { get }
}

class Item: Object, TableItem {
    @objc dynamic var itemId = UUID().uuidString
    @objc dynamic var title: String = "SomeItem"
    
    var type: ItemType = .specialItem
    
    convenience init(with title: String, type: ItemType) {
        self.init()
        self.title = title
        self.type = type
    }
    
    override static func primaryKey() -> String? {
        return "itemId"
    }
}
