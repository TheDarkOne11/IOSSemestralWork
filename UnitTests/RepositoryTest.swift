//
//  RepositoryTest.swift
//  UnitTests
//
//  Created by Petr Budík on 12/07/2019.
//  Copyright © 2019 Petr Budík. All rights reserved.
//

import XCTest
import RealmSwift
@testable import IOSSemestralWork
@testable import Common

class RepositoryTest: XCTestCase {
    private var dependencies: TestDependency!
    
    private lazy var repository: IRepository = { self.dependencies.repository }()
    
    private lazy var root: Folder = { self.dependencies.rootFolder }()
    private let folderA = Folder(withTitle: "A")
    private let folderAA = Folder(withTitle: "AA")
    private let folderAB = Folder(withTitle: "AB")
    private let folderB = Folder(withTitle: "B")
    
    private let rssItem1 = itemWith(title: "1")
    private let rssItemA1 = itemWith(title: "A1")
    private let rssItemAA1 = itemWith(title: "AA1")
    private let rssItemAB1 = itemWith(title: "AB1")
    private let rssItemB1 = itemWith(title: "B1")
    
    override func setUp() {
        super.setUp()
        
        dependencies = TestDependency()
        
        initRealmDb()
    }
    
    /**
     Operations which are done only when the app is launched for the first time.
     */
    private func initRealmDb() {
        let defaults = dependencies.userDefaults
        
        // Set important values in UserDefaults
        defaults.set(NSDate(), forKey: UserDefaults.Keys.lastUpdate.rawValue)
        
        dependencies.dbHandler.realmEdit(errorMsg: "Could not init the test DB.") {
            let feed1 = MyRSSFeed(title: "1", link: "Link")
            let feedA1 = MyRSSFeed(title: "A1", link: "Link")
            let feedAA1 = MyRSSFeed(title: "AA1", link: "Link")
            let feedAB1 = MyRSSFeed(title: "AB1", link: "Link")
            let feedB1 = MyRSSFeed(title: "B1", link: "Link")
            
            root.folders.append(folderA)
            folderA.folders.append(folderAA)
            folderA.folders.append(folderAB)
            root.folders.append(folderB)
            
            root.feeds.append(feed1)
            folderA.feeds.append(feedA1)
            folderAA.feeds.append(feedAA1)
            folderAB.feeds.append(feedAB1)
            folderB.feeds.append(feedB1)
            
            feed1.myRssItems.append(rssItem1)
            feedA1.myRssItems.append(rssItemA1)
            feedAA1.myRssItems.append(rssItemAA1)
            feedAB1.myRssItems.append(rssItemAB1)
            feedB1.myRssItems.append(rssItemB1)
        }
    }
    
    private static func itemWith(title: String) -> MyRSSItem {
        let item = MyRSSItem.init()
        item.itemId = UUID().uuidString
        item.title = title
        return item
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetAllRssItems() {
        let itemsOfRoot = [rssItem1, rssItemA1, rssItemAA1, rssItemAB1, rssItemB1].map { $0.title }
        let itemsOfA = [rssItemA1, rssItemAA1, rssItemAB1].map { $0.title }
        let itemsOfAA = [rssItemAA1].map { $0.title }
        let itemsOfAB = [rssItemAB1].map { $0.title }
        let itemsOfB = [rssItemB1].map { $0.title }
        
        // Basic
        XCTAssertEqual(repository.getAllRssItems(of: root, predicate: nil).map({ $0.title }), itemsOfRoot)
        XCTAssertEqual(repository.getAllRssItems(of: folderA, predicate: nil).map({ $0.title }), itemsOfA)
        XCTAssertEqual(repository.getAllRssItems(of: folderAA, predicate: nil).map({ $0.title }), itemsOfAA)
        XCTAssertEqual(repository.getAllRssItems(of: folderAB, predicate: nil).map({ $0.title }), itemsOfAB)
        XCTAssertEqual(repository.getAllRssItems(of: folderB, predicate: nil).map({ $0.title }), itemsOfB)
        
        // Custom predicate
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate(format: "title LIKE %@", "*A*")])
        XCTAssertEqual(repository.getAllRssItems(of: root, predicate: predicate).map({ $0.title }), itemsOfRoot.filter { $0.contains("A") })
    }
    
}
