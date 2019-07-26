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
    public lazy var userDefaults: UserDefaults = UserDefaults.init(suiteName: "group.cz.budikpet.IOSSemestralWork")!

    public lazy var repository: IRepository = Repository(dependencies: AppDependency.shared)
    
    public lazy var titleValidator: TitleValidator = TitleValidator()
    public lazy var itemCreateableValidator: ItemCreateableValidator = ItemCreateableValidator(dependencies: AppDependency.shared)
    public lazy var rssFeedResponseValidator: RSSFeedResponseValidator = RSSFeedResponseValidator()
}

extension AppDependency: HasTitleValidator, HasItemCreateableValidator, HasRSSFeedResponseValidator { }
extension AppDependency: HasRepository { }
extension AppDependency: HasUserDefaults { }
extension AppDependency: HasRealm {
    /**
     Provides Realm DB object. Automatically creates in-memory Realm DB object when testing.
     */
    private static func realm() -> Realm {
        do {
            let fileURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.cz.budikpet.IOSSemestralWork")!
                .appendingPathComponent("default.realm")
            let config = Realm.Configuration(fileURL: fileURL)
            
            return try Realm(configuration: config)
        } catch {
            fatalError("Error initializing new Realm for the first time: \(error)")
        }
    }
}
