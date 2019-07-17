//
//  AppDependency.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 04/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import Foundation
import RealmSwift
import Resources


/**
 Singleton that holds all instances of dependencies. Used for Dependency Injection.
 
 - TAG: appDependency
 */
public final class AppDependency{
    private init() { }
    public static let shared = AppDependency()
    
    public lazy var realm: Realm = AppDependency.realm()
    public lazy var rootFolder: Folder = AppDependency.getRootFolder()
    public lazy var userDefaults: UserDefaults = UserDefaults.standard

    public lazy var dbHandler: DBHandler = DBHandler(dependencies: AppDependency.shared)
    public lazy var repository: IRepository = Repository(dependencies: AppDependency.shared)
}

extension AppDependency: HasRepository { }
extension AppDependency: HasDBHandler { }
extension AppDependency: HasUserDefaults { }
extension AppDependency: HasRootFolder {
    private static func getRootFolder() -> Folder {
        guard let itemId = shared.userDefaults.string(forKey: UserDefaults.Keys.rootFolderItemId.rawValue) else {
            // Create root folder
            let rootFolder: Folder = Folder(withTitle: L10n.Base.rootFolder)
            
            shared.dbHandler.create(rootFolder)
            shared.userDefaults.set(rootFolder.itemId, forKey: UserDefaults.Keys.rootFolderItemId.rawValue)
            
            return rootFolder
        }
        
        guard let rootFolder = shared.realm.objects(Folder.self).filter("itemId == %@", itemId).first else {
            fatalError("The root folder must already exist in Realm.")
        }
        
        if rootFolder.title != L10n.Base.rootFolder {
            // Update name of the root folder
            shared.dbHandler.realmEdit(errorMsg: "Could not update name of the root folder.") {
                rootFolder.title = L10n.Base.rootFolder
            }
        }
        
        return rootFolder
    }
}
extension AppDependency: HasRealm {
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
