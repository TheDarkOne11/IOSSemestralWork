//
//  MyRSSFeed.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

class MyRSSFeed: Item {
    @objc dynamic var link: String = ""
    @objc dynamic var folder: Folder?
    let myRssItems = List<MyRSSItem>()
    
    /**
     False when its link doesn't lead to a website or the links website isn't a RSS feed.
     */
    @objc dynamic var isOk: Bool = true
    
    convenience init(title: String, link: String, in folder: Folder) {
        self.init(with: title, type: .myRssFeed)
        self.folder = folder
        self.link = link
    }
    
    func unreadItemsCount() -> Int {
        return myRssItems.filter("isRead == false").count
    }
}
