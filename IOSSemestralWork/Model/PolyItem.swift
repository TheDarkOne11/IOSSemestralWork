//
//  PolyItem.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 07/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

class PolyItem: Object {
    @objc dynamic var folder: Folder? = nil
    @objc dynamic var myRssFeed: MyRSSFeed? = nil
    @objc dynamic var myRssItem: MyRSSItem? = nil
}
