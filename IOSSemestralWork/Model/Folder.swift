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
    let folders = List<Folder>()
    
    convenience init(with title: String) {
        self.init(with: title, type: .folder)
    }
}
