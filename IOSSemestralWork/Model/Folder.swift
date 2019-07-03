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
    @objc dynamic var parentFolder: Folder?
    let polyItems = List<PolyItem>()
    
    convenience init(with title: String, in folder: Folder? = nil) {
        self.init(with: title, type: .folder)
        self.parentFolder = folder
    }
}
