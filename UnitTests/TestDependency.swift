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
    static let shared = TestDependency()
    private lazy var realmConfig: Realm.Configuration = Realm.Configuration(inMemoryIdentifier: UUID().uuidString, encryptionKey: nil, readOnly: false, schemaVersion: 0, migrationBlock: nil, objectTypes: nil)
    
    lazy var realm: Realm = TestDependency.realm()
    lazy var rootFolder: Folder = TestDependency.getRootFolder()
    
    lazy var dbHandler: DBHandler = DBHandler(dependencies: TestDependency.shared)
    lazy var repository: IRepository = Repository(dependencies: TestDependency.shared)
}

extension TestDependency: HasRepository { }
extension TestDependency: HasRealm { }
extension TestDependency: HasRootFolder {
    private static func getRootFolder() -> Folder {
        guard let rootFolder = shared.realm.objects(Folder.self).filter("title == %@", L10n.rootFolder).first else {
            fatalError("The root folder must already exist in Realm")
        }
        
        return rootFolder
    }
}
extension TestDependency: HasDBHandler {
    /**
     Provides Realm DB object. Automatically creates in-memory Realm DB object when testing.
     */
    private static func realm() -> Realm {
        do {
            return try Realm(configuration: shared.realmConfig)
        } catch {
            fatalError("Error initializing new Realm for the first time: \(error)")
        }
    }
}
