//
//  MyRSSFeed.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 29/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation

class MyRSSFeed: Item {
    var link: String = ""
    
    init(with title: String) {
        super.init(with: title, type: .myRssFeed)
    }
}
