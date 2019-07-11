//
//  MyRSSFeed.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

class MyRSSFeed: Object, Item {
    @objc dynamic var itemId: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var link: String = ""
    let folder = LinkingObjects(fromType: Folder.self, property: "feeds")
    let myRssItems = List<MyRSSItem>()
    
    /**
     False when its link doesn't lead to a website or the links website isn't a RSS feed.
     */
    @objc dynamic var isOk: Bool = true
    
    var type: ItemType = .myRssFeed
    
    convenience init(title: String, link: String) {
        self.init()
        self.title = title
        self.link = link
    }
    
    override static func primaryKey() -> String? {
        return "itemId"
    }
}
