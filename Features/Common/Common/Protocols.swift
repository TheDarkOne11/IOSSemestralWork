//
//  Protocols.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 06/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

public protocol HasUserDefaults {
    var userDefaults: UserDefaults { get }
}

public protocol HasRealm {
    var realm: Realm { get }
}

public protocol HasRootFolder {
    var rootFolder: Folder { get }
}
