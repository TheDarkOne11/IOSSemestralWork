//
//  Folder.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

class Folder: Item {
    let myRssFeeds = List<MyRSSFeed>()
    
    // Can we see MyRSSFeeds in a separate window?
    @objc dynamic var isContentsViewable = false
    
    convenience init(with title: String, isContentsViewable: Bool? = false) {
        self.init(with: title, type: .folder)
        self.isContentsViewable = isContentsViewable!
    }
}
