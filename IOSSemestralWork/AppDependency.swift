//
//  AppDependency.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 04/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift

final class AppDependency{
    private init() { }
    static let shared = AppDependency()
    
    lazy var realm: Realm = AppDependency.realm()
    lazy var dbHandler: DBHandler = DBHandler(realm: AppDependency.realm())
    
    lazy var repository: IRepository = Repository(dependencies: AppDependency.shared)
}

extension AppDependency: HasRepository { }
extension AppDependency: HasDBHandler {
    /**
     Provides Realm DB object. Automatically creates in-memory Realm DB object when testing.
     */
    private static func realm() -> Realm {
        do {
            return try Realm();
        } catch {
            fatalError("Error initializing new Realm for the first time: \(error)")
        }
    }
}
