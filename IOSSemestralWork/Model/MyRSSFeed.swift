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
    let myRssItems = List<MyRSSItem>()
    
    /**
     False when its link doesn't lead to a website or the links website isn't a RSS feed.
     */
    @objc dynamic var isOk: Bool = true
    
    convenience init(with title: String, link: String) {
        self.init(with: title, type: .myRssFeed)
        self.link = link
    }
}
