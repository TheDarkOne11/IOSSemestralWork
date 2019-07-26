//
//  Validator.swift
//  Data
//
//  Created by Petr Budík on 21/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireRSSParser
import Common

public protocol HasTitleValidator {
    var titleValidator: TitleValidator { get }
}

public class TitleValidator {
    
    public init() {
    }
    
    public func validate(_ title: String) -> Bool {
        let textCount = title.trimmingCharacters(in: .whitespacesAndNewlines).count
        
        return textCount > 0
    }
}

public protocol HasItemCreateableValidator {
    var itemCreateableValidator: ItemCreateableValidator { get }
}

public class ItemCreateableValidator {
    public typealias Dependencies = HasRepository
    private let dependencies: Dependencies
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    public func validate(newItem: Item, itemForUpdate: Item? = nil) -> Bool {
        let hasDuplicate = dependencies.repository.exists(newItem)
        
        return hasDuplicate == nil || hasDuplicate?.itemId == itemForUpdate?.itemId
    }
}

public protocol HasRSSFeedResponseValidator {
    var rssFeedResponseValidator: RSSFeedResponseValidator { get }
}

public class RSSFeedResponseValidator {
    
    public func validate(_ response: DataResponse<RSSFeed>) -> DownloadStatus {
        // Validate the response
        if let mimeType =  response.response?.mimeType {
            if mimeType != "application/rss+xml" && mimeType != "text/xml" {
                // Website exists but isn't a RSS feed
                return .notRSSFeed
            }
        } else {
            // Website doesn't exist
            return .doesNotExist
        }
        
        if let feed: RSSFeed = response.result.value {
            if feed.items.count <= 0 {
                return .emptyFeed
            }
        }
        
        // Website is RSS feed, we can store info
        return .OK
    }
}
