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
    
    convenience init(with title: String, link: String) {
        self.init(with: title, type: .myRssFeed)
        self.link = link
    }
}
