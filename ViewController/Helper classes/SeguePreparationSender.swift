//
//  SeguePreparationSender.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 23/01/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

class SeguePreparationSender<Type: Object> {
    let title: String?
    let rssItems: Results<Type>
    
    init(rssItems: Results<Type>, title: String?) {
        self.title = title
        self.rssItems = rssItems
    }
}
