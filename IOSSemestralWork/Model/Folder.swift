//
//  Folder.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

class Folder: Object, Item {
    @objc dynamic var itemId: String = UUID().uuidString
    @objc dynamic var title: String = ""
    let parentFolder = LinkingObjects(fromType: Folder.self, property: "folders")
    let folders = List<Folder>()
    let feeds = List<MyRSSFeed>()
    
    var type: ItemType = .folder
    
    convenience init(withTitle title: String) {
        self.init()
        self.title = title
    }
    
    override static func primaryKey() -> String? {
        return "itemId"
    }
}
