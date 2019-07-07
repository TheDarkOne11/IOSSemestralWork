//
//  SpecialItem.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 07/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

class SpecialItem: TableItem {
    typealias Action = () -> [Item]
    let action: Action
    
    let itemId: String = UUID().uuidString
    let title: String
    let type: ItemType = ItemType.specialItem
    
    init(withTitle title: String, with action: @escaping Action) {
        self.title = title
        self.action = action
    }
}
