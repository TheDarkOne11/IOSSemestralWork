//
//  Protocols.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 06/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

protocol HasUserDefaults {
    var userDefaults: UserDefaults { get }
}

protocol HasRealm {
    var realm: Realm { get }
}

protocol HasRootFolder {
    var rootFolder: Folder { get }
}
