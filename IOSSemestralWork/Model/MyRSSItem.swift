//
//  MyRSSItem.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation
import AlamofireRSSParser

class MyRSSItem: Item {
    @objc dynamic var articleLink: String = UUID().uuidString
    @objc dynamic var itemDescription: String = ""
    @objc dynamic var author: String = ""
    @objc dynamic var date: Date?
    
    convenience init(with rssItem: RSSItem?) {
        self.init(with: rssItem?.title ?? "Unknown", type: .myRssItem)
        
        self.articleLink = rssItem?.link ?? "Unknown"
        self.author = rssItem?.author ?? "Unknown author"
        self.itemDescription = rssItem?.itemDescription ?? "Unknown"
        self.date = rssItem?.pubDate
    }
    
    override static func primaryKey() -> String? {
        return "articleLink"
    }
}
