//
//  AppDelegate.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 28/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print("Realm DB location: \(Realm.Configuration.defaultConfiguration.fileURL!)")
        
        // Initialize realm for the first time. That should be the only time an exception is thrown.
        do {
            let realm = try Realm()
            
            if realm.isEmpty {
                firstTimeInit(realm)
            }
        } catch {
            print("Error initializing new Realm for the first time: \(error)")
        }
        
        return true
    }
    
    /**
     Operations which are done only when the app is launched for the first time.
     */
    private func firstTimeInit(_ realm: Realm) {
        let dbHandler = DBHandler()
        let defaults = UserDefaults.standard
        
        // Create special "None" folder
        dbHandler.create(Folder(with: UserDefaultsKeys.NoneFolderTitle.rawValue))
        
        // Set important values in UserDefaults
        defaults.set(NSDate(), forKey: UserDefaultsKeys.LastUpdate.rawValue)
        
        // TODO: Debugging images, remove
        let none: Folder = realm.objects(Folder.self).filter("title CONTAINS[cd] %@", UserDefaultsKeys.NoneFolderTitle.rawValue).first!
        dbHandler.create(MyRSSFeed(title: "IdnesZpravodaj_None", link: "https://servis.idnes.cz/rss.aspx?c=zpravodaj", folder: none))
        dbHandler.create(MyRSSFeed(title: "Wired_MedThumb", link: "http://wired.com/feed/rss", folder: none))
        dbHandler.create(MyRSSFeed(title: "Lifehacker_DescImg", link: "https://lifehacker.com/rss", folder: none))
        dbHandler.create(MyRSSFeed(title: "FOX_MedThumb_Bad", link: "http://feeds.foxnews.com/foxnews/latest", folder: none))
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

