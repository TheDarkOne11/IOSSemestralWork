//
//  TableItem.swift
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

protocol Item {
    var itemId: String { get }
    var title: String { get }
    var type: ItemType { get }
}
