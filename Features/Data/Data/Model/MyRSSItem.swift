//
//  MyRSSItem.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireRSSParser
import Resources

public class MyRSSItem: Object, Item {
    @objc dynamic public var itemId = UUID().uuidString
    @objc dynamic public var title: String = ""
    @objc dynamic public var articleLink: String?
    @objc dynamic public var itemDescription: String = ""
    @objc dynamic public var author: String?
    @objc dynamic public var date: Date?
    @objc dynamic public var image: String?
    @objc dynamic public var isRead: Bool = false
    @objc dynamic public var isStarred: Bool = false
    
    public let rssFeed = LinkingObjects(fromType: MyRSSFeed.self, property: "myRssItems")
    public var type: ItemType = .myRssItem
    public var description_NoHtml: String {
        get {
            // Removes all HTML tags
            return remove(from: itemDescription, pattern: "\\<.*?\\>")
        }
    }
    
    public convenience init(_ rssItem: RSSItem?) {
        self.init()
        
        self.title = rssItem?.title ?? L10n.MyRssItem.missingTitle
        self.articleLink = rssItem?.link
        self.author = rssItem?.author
        self.itemDescription = rssItem?.itemDescription ?? L10n.MyRssItem.missingDescription
        self.date = rssItem?.pubDate
        
        setImage(rssItem)
    }
    
    override public static func primaryKey() -> String? {
        return "itemId"
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
    
    /**
     Removes all things matching the pattern from the HTML string.
     
     - parameter value: The String we search for matches at.
     - parameter pattern: The Regex pattern to find matches with.
     */
    private func remove(from value: String, pattern: String) -> String {
        let value: NSMutableString = NSMutableString(string: self.itemDescription)
        let regex = try? NSRegularExpression(pattern: pattern)
        regex?.replaceMatches(in: value, options: .reportProgress, range: NSRange(location: 0,length: value.length), withTemplate: "")
        
        return value as String
    }
}
