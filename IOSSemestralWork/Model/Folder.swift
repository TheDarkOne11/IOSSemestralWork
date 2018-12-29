//
//  Folder.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation

class Folder: Item {
    var myRssFeeds = [MyRSSFeed]()
    
    // Can we see MyRSSFeeds in a separate window?
    var isContentsViewable = false
    
    init(with title: String, isContentsViewable: Bool? = false) {
        super.init(with: title, type: .folder)
        self.isContentsViewable = isContentsViewable!
    }
}
