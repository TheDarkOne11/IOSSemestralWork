//
//  Folder.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

public class Folder: Object, Item {
    @objc dynamic public var itemId: String = UUID().uuidString
    @objc dynamic public var title: String = ""
    public let parentFolder = LinkingObjects(fromType: Folder.self, property: "folders")
    public let folders = List<Folder>()
    public let feeds = List<MyRSSFeed>()
    
    public var type: ItemType = .folder
    
    public convenience init(withTitle title: String) {
        self.init()
        self.title = title
    }
    
    override public static func primaryKey() -> String? {
        return "itemId"
    }
    
    public func getRssItemsCount(predicate: NSCompoundPredicate? = nil) -> Int {
        var count = 0
        
        for folder in folders {
            count += folder.getRssItemsCount(predicate: predicate)
        }
        
        if let predicate = predicate {
            for feed in feeds {
                count += feed.myRssItems.filter(predicate).count
            }
        } else {
            for feed in feeds {
                count += feed.myRssItems.count
            }
        }
        
        return count
    }
}
