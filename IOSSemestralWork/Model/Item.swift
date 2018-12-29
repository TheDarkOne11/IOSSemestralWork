//
//  Item.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation

enum ItemType {
    case folder
    case myRssFeed
    case myRssItem
}

class Item {
    var title: String
    var type: ItemType
    
    init(with title: String, type: ItemType) {
        self.title = title
        self.type = type
    }
}
