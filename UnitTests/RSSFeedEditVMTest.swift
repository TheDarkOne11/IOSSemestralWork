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
    typealias Dependencies = HasRepository & HasDBHandler & HasRealm
    private let dependencies: Dependencies = TestDependency.shared
    
    private lazy var viewModel: IRSSFeedEditVM = {
        return RSSFeedEditVM(dependencies: dependencies)
    }()
    
    override func setUp() {
        super.setUp()
        try! dependencies.realm.write { () -> Void in
            dependencies.realm.deleteAll()
        }
        
        initRealmDb()
        
        let folder: Folder = dependencies.realm.objects(Folder.self).filter("title == %@", "None").first!
        
        viewModel.feedName.value = "Custom title"
        viewModel.link.value = "google.com"
        viewModel.selectedFolder.value = folder
    }
    
    /**
     Operations which are done only when the app is launched for the first time.
     */
    private func initRealmDb() {
        let defaults = UserDefaults.standard
        
        // Create special "None" folder
        let folderNone: Folder = Folder(withTitle: UserDefaultsKeys.NoneFolderTitle.rawValue)
        dependencies.dbHandler.create(folderNone)
        
        // Set important values in UserDefaults
        defaults.set(NSDate(), forKey: UserDefaultsKeys.LastUpdate.rawValue)
        
        let folderIdnes = Folder(withTitle: "Idnes", in: folderNone)
        dependencies.dbHandler.create(folderIdnes)
        dependencies.dbHandler.create(MyRSSFeed(title: "Zpravodaj", link: "https://servis.idnes.cz/rss.aspx?c=zpravodaj", in: folderIdnes))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCreateOk() {
        let expectation = XCTestExpectation(description: "Valid viewModel data returns no error")
        
        let polyItemsCount = self.dependencies.realm.objects(PolyItem.self).count
        let rssFeedsCount = self.dependencies.realm.objects(MyRSSFeed.self).count
        
        viewModel.saveBtnAction.completed.observeValues {
            let rssFeedRes = self.dependencies.realm.objects(MyRSSFeed.self).filter("title CONTAINS[cd] %@", self.viewModel.feedName.value)
            let polyItemRes = self.dependencies.realm.objects(PolyItem.self).filter("myRssFeed.title CONTAINS[cd] %@", self.viewModel.feedName.value)
            
            XCTAssertTrue(polyItemRes.count == 1)
            XCTAssertTrue(rssFeedRes.count == 1)
            XCTAssertEqual(polyItemsCount + 1, self.dependencies.realm.objects(PolyItem.self).count)
            XCTAssertEqual(rssFeedsCount + 1, self.dependencies.realm.objects(MyRSSFeed.self).count)
            
            let rssFeed: MyRSSFeed = rssFeedRes.first!
            let polyItem: PolyItem = polyItemRes.first!
            
            XCTAssertNotNil(polyItem.myRssFeed)
            XCTAssertTrue(polyItem.myRssFeed!.itemId == rssFeed.itemId)
            
            XCTAssertNotNil(rssFeed.folder)
            XCTAssertTrue(rssFeed.link.contains(self.viewModel.link.value))
            XCTAssertTrue(rssFeed.link.starts(with: "http://"))
            
            expectation.fulfill()
        }
        
        viewModel.saveBtnAction.apply().start()
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testCreateOk_hasHttp() {
        let oldLink = viewModel.link.value
        viewModel.link.value = "http://\(oldLink)"
        
        testCreateOk()
    }
    
    func testCreateError() {
        let expectation = XCTestExpectation(description: "Valid viewModel data returns error")
        
        dependencies.dbHandler.create(MyRSSFeed(title: viewModel.feedName.value, link: viewModel.link.value, in: viewModel.selectedFolder.value))
        
        let polyItemsCount = self.dependencies.realm.objects(PolyItem.self).count
        let rssFeedsCount = self.dependencies.realm.objects(MyRSSFeed.self).count
        
        viewModel.saveBtnAction.errors.observeValues { error in
            let rssFeedRes = self.dependencies.realm.objects(MyRSSFeed.self).filter("title CONTAINS[cd] %@", self.viewModel.feedName.value)
            let polyItemRes = self.dependencies.realm.objects(PolyItem.self).filter("myRssFeed.title CONTAINS[cd] %@", self.viewModel.feedName.value)
            
            XCTAssertEqual(polyItemRes.count, 1)
            XCTAssertEqual(rssFeedRes.count, 1)
            XCTAssertEqual(polyItemsCount, self.dependencies.realm.objects(PolyItem.self).count)
            XCTAssertEqual(rssFeedsCount, self.dependencies.realm.objects(MyRSSFeed.self).count)
            
            let rssFeed: MyRSSFeed = rssFeedRes.first!
            let polyItem: PolyItem = polyItemRes.first!
            
            XCTAssertNotNil(polyItem.myRssFeed)
            XCTAssertEqual(polyItem.myRssFeed!.itemId, rssFeed.itemId)
            
            XCTAssertNotNil(rssFeed.folder)
            XCTAssertTrue(rssFeed.link.contains(self.viewModel.link.value))
            
            switch error {
            case .exists(let existingFeed):
                XCTAssertEqual(rssFeed.itemId, existingFeed.itemId)
            }
            
            expectation.fulfill()
        }
        viewModel.saveBtnAction.apply().start()
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testCreateError_hasHttp() {
        let oldLink = viewModel.link.value
        viewModel.link.value = "http://\(oldLink)"
        
        testCreateError()
    }
    
    func testUpdateOk() {
        let expectation = XCTestExpectation(description: "Valid viewModel data returns no error")
        
        let folder: Folder = dependencies.realm.objects(Folder.self).filter("title == %@", "None").first!
        let feedForUpdate = MyRSSFeed(title: viewModel.feedName.value, link: viewModel.link.value, in: viewModel.selectedFolder.value)
        
        // Data of the newly updated feed
        viewModel.feedName.value = "Updated title"
        viewModel.link.value = "seznam.cz"
        viewModel.selectedFolder.value = folder
        viewModel.feedForUpdate.value = feedForUpdate
        
        dependencies.dbHandler.create(feedForUpdate)
        
        let polyItemsCount = dependencies.realm.objects(PolyItem.self).count
        let rssFeedsCount = dependencies.realm.objects(MyRSSFeed.self).count
        
        viewModel.saveBtnAction.completed.observeValues {
            let rssFeedRes = self.dependencies.realm.objects(MyRSSFeed.self).filter("title CONTAINS[cd] %@", self.viewModel.feedName.value)
            let polyItemRes = self.dependencies.realm.objects(PolyItem.self).filter("myRssFeed.title CONTAINS[cd] %@", self.viewModel.feedName.value)
            
            XCTAssertTrue(polyItemRes.count == 1)
            XCTAssertTrue(rssFeedRes.count == 1)
            XCTAssertEqual(polyItemsCount, self.dependencies.realm.objects(PolyItem.self).count)
            XCTAssertEqual(rssFeedsCount, self.dependencies.realm.objects(MyRSSFeed.self).count)
            
            let rssFeed: MyRSSFeed = rssFeedRes.first!
            let polyItem: PolyItem = polyItemRes.first!
            
            XCTAssertNotNil(polyItem.myRssFeed)
            XCTAssertTrue(polyItem.myRssFeed!.itemId == rssFeed.itemId)
            
            XCTAssertNotNil(rssFeed.folder)
            XCTAssertTrue(rssFeed.link.contains(self.viewModel.link.value))
            XCTAssertTrue(rssFeed.link.starts(with: "http://"))
            
            expectation.fulfill()
        }
        
        viewModel.saveBtnAction.apply().start()
        
        wait(for: [expectation], timeout: 10)
    }
    
    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measure {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    
}
