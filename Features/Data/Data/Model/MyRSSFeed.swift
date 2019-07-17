//
//  MyRSSFeed.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

public class MyRSSFeed: Object, Item {
    @objc dynamic public var itemId: String = UUID().uuidString
    @objc dynamic public var title: String = ""
    @objc dynamic public var link: String = ""
    public let folder = LinkingObjects(fromType: Folder.self, property: "feeds")
    public let myRssItems = List<MyRSSItem>()
    
    /**
     False when its link doesn't lead to a website or the links website isn't a RSS feed.
     */
    @objc dynamic public var isOk: Bool = true
    
    public var type: ItemType = .myRssFeed
    
    public convenience init(title: String, link: String) {
        self.init()
        self.title = title
        self.link = link
    }
    
    override public static func primaryKey() -> String? {
        return "itemId"
    }
}
