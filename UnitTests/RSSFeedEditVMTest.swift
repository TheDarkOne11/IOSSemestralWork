//
//  UnitTests.swift
//  UnitTests
//
//  Created by Petr Budík on 03/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import XCTest
@testable import IOSSemestralWork

class UnitTests: XCTestCase {
    
    private let viewModel = RSSFeedEditVM()
    private let realm = RealmProvider.realm()
    private let dbHandler = DBHandler(realm: RealmProvider.realm())

    override func setUp() {
        super.setUp()
        try! realm.write { () -> Void in
            realm.deleteAll()
        }
        
        initRealmDb()
        
        let folder: Folder = realm.objects(Folder.self).filter("title == %@", "None").first!
        
        viewModel.title.value = "Custom title"
        viewModel.link.value = "Custom link"
        viewModel.folder.value = folder
    }
    
    /**
     Operations which are done only when the app is launched for the first time.
     */
    private func initRealmDb() {
        let defaults = UserDefaults.standard
        
        // Create special "None" folder
        let folderNone: Folder = Folder(with: UserDefaultsKeys.NoneFolderTitle.rawValue)
        dbHandler.create(folderNone)
        
        // Set important values in UserDefaults
        defaults.set(NSDate(), forKey: UserDefaultsKeys.LastUpdate.rawValue)
        
        if !AppDelegate.isProduction {
            let folderIdnes = Folder(with: "Idnes", in: folderNone)
            let folderImages = Folder(with: "WithImages", in: folderNone)
            
            dbHandler.create(folderIdnes)
            dbHandler.create(folderImages)
            
            dbHandler.create(MyRSSFeed(title: "Zpravodaj", link: "https://servis.idnes.cz/rss.aspx?c=zpravodaj", in: folderIdnes))
            dbHandler.create(MyRSSFeed(title: "Sport", link: "https://servis.idnes.cz/rss.aspx?c=sport", in: folderIdnes))
            dbHandler.create(MyRSSFeed(title: "Wired", link: "http://wired.com/feed/rss", in: folderImages))
            dbHandler.create(MyRSSFeed(title: "Lifehacker", link: "https://lifehacker.com/rss", in: folderImages))
            dbHandler.create(MyRSSFeed(title: "FOX", link: "http://feeds.foxnews.com/foxnews/latest", in: folderNone))
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreate() {
        
    }
    
    func testUpdate() {
        let folder: Folder = realm.objects(Folder.self).filter("title == %@", "None").first!
        let feedForUpdate = realm.objects(MyRSSFeed.self).filter("title == %@", "Custom title").first
        
        viewModel.title.value = "Custom title"
        viewModel.link.value = "Custom link"
        viewModel.folder.value = folder
        viewModel.feedForUpdate.value = feedForUpdate
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
