//
//  TestDependency.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 04/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift
@testable import IOSSemestralWork

final class TestDependency{
    private init() { }
    static let shared = TestDependency()
    
    lazy var realm: Realm = TestDependency.realm()
    lazy var dbHandler: DBHandler = DBHandler(realm: TestDependency.realm())
    
    lazy var repository: IRepository = Repository(dependencies: TestDependency.shared)
}

extension TestDependency: HasRepository { }
extension TestDependency: HasDBHandler {
    /**
     Provides Realm DB object. Automatically creates in-memory Realm DB object when testing.
     */
    private static func realm() -> Realm {
        do {
            return try Realm(configuration: Realm.Configuration(inMemoryIdentifier: "test", encryptionKey: nil, readOnly: false, schemaVersion: 0, migrationBlock: nil, objectTypes: nil))
        } catch {
            fatalError("Error initializing new Realm for the first time: \(error)")
        }
    }
}
