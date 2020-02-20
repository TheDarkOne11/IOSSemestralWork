//
//  AppDelegate.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 28/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import RealmSwift
import Toast_Swift
import Data

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appFlowCoordinator: AppFlowCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        prepareRealm()

        // Set background fetch intervals
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        // Set default Toast values
        ToastManager.shared.duration = 2.0
        ToastManager.shared.position = .bottom
        ToastManager.shared.style.backgroundColor = UIColor.black.withAlphaComponent(0.71)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        appFlowCoordinator = AppFlowCoordinator()
        appFlowCoordinator.start(in: window!)
        
        return true
    }
    
    // MARK: Realm preparation
    
    /**
     Prepares Realm DB data if the application is launched in DEBUG mode or in UI testing mode.
     */
    private func prepareRealm() {
        if Globals.isUITesting {
            UIView.setAnimationsEnabled(false)
            uiTestingInit()
        } else if !Globals.isProduction {
            print("Realm DB location: \(Globals.dependencies.realm.configuration.fileURL!)")
            
            if Globals.dependencies.realm.isEmpty {
                firstTimeDebugInit()
            }
        }
        
        
    }
    
    private func uiTestingInit() {
        let dependencies = Globals.dependencies
        let defaults = dependencies.userDefaults
        
        // Set important values in UserDefaults
        defaults.set(NSDate(), forKey: UserDefaults.Keys.lastUpdate.rawValue)
        
        dependencies.repository.realmEdit(errorCode: nil) { realm in
            let folder1 = Folder(withTitle: "Folder1")
            dependencies.repository.rootFolder.folders.append(folder1)
            dependencies.repository.rootFolder.feeds.append(MyRSSFeed(title: "Feed1", link: "Link1"))
            folder1.feeds.append(MyRSSFeed(title: "Feed1.1", link: "Link1.1"))
        }
        
//        dependencies.repository.updateAllFeeds { _ in}
    }
    
    /**
     Operations which are done only when the app is launched for the first time in DEBUG mode.
     */
    private func firstTimeDebugInit() {
        Globals.dependencies.userDefaults.set(NSDate(), forKey: UserDefaults.Keys.lastUpdate.rawValue)
        
        let repository = Globals.dependencies.repository
        let rootFolder = repository.rootFolder
        let folderIdnes = Folder(withTitle: "Idnes")
        let folderImages = Folder(withTitle: "WithImages")
        
        repository.realmEdit(errorCode: nil) { realm in
            rootFolder.folders.append(objectsIn: [folderIdnes, folderImages])
            rootFolder.feeds.append(MyRSSFeed(title: "FOX", link: "http://feeds.foxnews.com/foxnews/latest"))
            
            folderIdnes.feeds.append(MyRSSFeed(title: "Zpravodaj", link: "https://servis.idnes.cz/rss.aspx?c=zpravodaj"))
            folderIdnes.feeds.append(MyRSSFeed(title: "Sport", link: "https://servis.idnes.cz/rss.aspx?c=sport"))
            
            folderImages.feeds.append(MyRSSFeed(title: "Wired", link: "http://wired.com/feed/rss"))
            folderImages.feeds.append(MyRSSFeed(title: "Lifehacker", link: "https://lifehacker.com/rss"))
        }
    }
    
    // MARK: Background fetch
    
    /**
     Background fetch.
     */
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Started Background fetch")
//        let dbHandler = DBHandler()
//
//        // Updates RSS feeds, calls completionHandler approprietly
//        dbHandler.updateAll { (status) in
//            switch status {
//            case .OK:
//                self.updateUI()
//                Globals.dependencies.userDefaults.set(NSDate(), forKey: UserDefaults.Keys.lastUpdate.rawValue)
//                completionHandler(.newData)
//            case .NotOK:
//                completionHandler(.failed)
//            case .Unreachable:
//                // No internet connection. Tells Ios that it should run backgroundFetch again sooner
//                completionHandler(.noData)
//            }
//        }
    }
    
    /**
     Update UI after Background fetch.
     */
    private func updateUI() {
//        if let navController = window?.rootViewController as? UINavigationController {
//            if let mainVc = navController.topViewController as? ItemTableVC {
//                mainVc.tableView.reloadData()
//            }
//        }
    }
    
    // MARK: Other methods
    
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

