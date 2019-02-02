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
    @objc dynamic var image: String?
    @objc dynamic var rssFeed: MyRSSFeed?
    @objc dynamic var isRead: Bool = false
    @objc dynamic var isStarred: Bool = false
    
    var description_NoHtml: String {
        get {
            // Removes all HTML tags
            return remove(from: itemDescription, pattern: "\\<.*?\\>")
        }
    }
    
    convenience init(_ rssItem: RSSItem?, _ myRssFeed: MyRSSFeed) {
        self.init(with: rssItem?.title ?? "Unknown", type: .myRssItem)
        
        self.articleLink = rssItem?.link ?? "Unknown"
        self.author = rssItem?.author ?? "Unknown author"
        self.itemDescription = rssItem?.itemDescription ?? "Unknown"
        self.date = rssItem?.pubDate
        self.rssFeed = myRssFeed
        
        setImage(rssItem)
    }
    
    override static func primaryKey() -> String? {
        return "articleLink"
    }
    
    /**
     Finds any image inside the RSSItem and sets it in MyRSSItem.
     
     Images can be found in:
     
     1/ ItemDescription - this image has to be removed from here
     
     2/ Contents
     
     3/ MediaThumbnail
     */
    private func setImage(_ rssItem: RSSItem?) {
        if let descImages = rssItem?.imagesFromDescription {
            if descImages.count > 0 {
                image = descImages.first!
                itemDescription = remove(from: itemDescription, pattern: "\\<img.*?\\>")
                return
            }
        }
        
        if let contentImages = rssItem?.imagesFromContent {
            if contentImages.count > 0 {
                image = contentImages.first!
                return
            }
        }
        
        if let thumbnail = rssItem?.mediaThumbnail {
            image = thumbnail
            return
        }
    }
    
    private func remove(from value: String, pattern: String) -> String {
        let value: NSMutableString = NSMutableString(string: self.itemDescription)
        let regex = try? NSRegularExpression(pattern: pattern)
        regex?.replaceMatches(in: value, options: .reportProgress, range: NSRange(location: 0,length: value.length), withTemplate: "")
        
        return value as String
    }
}
