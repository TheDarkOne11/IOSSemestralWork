//
//  SpecialItem.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 07/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

public class SpecialItem: Item {
    /**
     - Folder: A folder to be selected
     - [NSPredicate]: Predicates used to filter items of the selected Folder
     */
    public typealias ActionResult = (Folder, NSCompoundPredicate?)
    public typealias Action = () -> ActionResult
    public let action: Action
    
    public let itemId: String = UUID().uuidString
    public let title: String
    public let type: ItemType = ItemType.specialItem
    public let imgName: String
    public let predicate: NSCompoundPredicate?
    
    public init(withTitle title: String, imageName imgName: String, predicate: NSCompoundPredicate? = nil, _ action: @escaping Action) {
        self.title = title
        self.action = action
        self.imgName = imgName
        self.predicate = predicate
    }
    
    public func itemsCount() -> Int {
        return action().0.getRssItemsCount(predicate: predicate)
    }
}
