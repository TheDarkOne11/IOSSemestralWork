//
//  SpecialItem.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 07/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

class SpecialItem: Item {
    /**
     - Folder: A folder to be selected
     - [NSPredicate]: Predicates used to filter items of the selected Folder
     */
    typealias ActionResult = (Folder, NSCompoundPredicate?)
    typealias Action = () -> ActionResult
    let action: Action
    
    let itemId: String = UUID().uuidString
    let title: String
    let type: ItemType = ItemType.specialItem
    let imgName: String
    let predicate: NSCompoundPredicate?
    
    init(withTitle title: String, imageName imgName: String, predicate: NSCompoundPredicate? = nil, _ action: @escaping Action) {
        self.title = title
        self.action = action
        self.imgName = imgName
        self.predicate = predicate
    }
    
    func itemsCount() -> Int {
        return action().0.getRssItemsCount(predicate: predicate)
    }
}
