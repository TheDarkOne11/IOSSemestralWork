//
//  UITests.swift
//  UITests
//
//  Created by Petr Budík on 20/02/2020.
//  Copyright © 2020 Petr Budík. All rights reserved.
//

import XCTest
@testable import IOSSemestralWork
@testable import Data
@testable import Common

class UITests: XCTestCase {    
    private var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        app = XCUIApplication()
        
        // Then we can use ProcessInfo.processInfo.arguments.contains('--uitesting') in the application to check
        app.launchArguments.append("--uitesting")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func invokePullToRefresh(_ tableView: XCUIElement) {
        // Drag the screen to activate PullToRefresh
        let firstCell = tableView.cells.element(boundBy: 0)
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 12))
        start.press(forDuration: 0.5, thenDragTo: finish)
    }

    /**
     Check the initial ItemTableVC screen. Check PullToRefresh.
     */
    func testBaseItemScreen() {
        app.launch()
        
        let tableView = app.tables["ItemTableVC_TableView"]
        
        // Check table itself
        XCTAssertTrue(tableView.exists)
        XCTAssertEqual(tableView.cells.staticTexts.containing(NSPredicate(format: "label == %@", "All items")).count, 1)
        XCTAssertEqual(tableView.cells.staticTexts.containing(NSPredicate(format: "label == %@", "Unread items")).count, 1)
        XCTAssertEqual(tableView.cells.staticTexts.containing(NSPredicate(format: "label == %@", "Starred items")).count, 1)
        XCTAssertEqual(tableView.cells.staticTexts.containing(NSPredicate(format: "label == %@", "0")).count, 5)
        
        // PullToRefresh test
        XCTAssertFalse(tableView.staticTexts["PullToRefresh_UpdateLabel"].exists)
        invokePullToRefresh(tableView)
        XCTAssertTrue(tableView.staticTexts["PullToRefresh_UpdateLabel"].exists)
        
        // PullToRefresh added exactly one MyRSSItem to each MyRSSFeed
        XCTAssertEqual(tableView.cells.staticTexts.containing(NSPredicate(format: "label == %@", "0")).count, 1)
        XCTAssertEqual(tableView.cells.staticTexts.containing(NSPredicate(format: "label == %@", "1")).count, 2)
        XCTAssertEqual(tableView.cells.staticTexts.containing(NSPredicate(format: "label == %@", "2")).count, 2)
    }
    
    /**
     Read one MyRSSItem. Check if number of unread items went down.
     */
    func testReadArticle() {
        app.launch()
        
        let itemsTableView = app.tables["ItemTableVC_TableView"]
        let allItemsCell = itemsTableView.staticTexts["All items"]
        let allItems_backBtn = app.navigationBars["All items"].buttons["RSSFeed reader"]
        
        invokePullToRefresh(itemsTableView)
        
        allItemsCell.tap()
        
        app.tables["RSSItemsTableVC_TableView"].cells.element(boundBy: 0).tap()
        app.navigationBars.buttons["All items"].tap()
        allItems_backBtn.tap()
        
        // Check if number of unread items is lower than number of all items
        XCTAssertEqual(itemsTableView.cells.element(boundBy: 0).staticTexts.containing(NSPredicate(format: "label == %@", "2")).count, 1)
        XCTAssertEqual(itemsTableView.cells.element(boundBy: 1).staticTexts.containing(NSPredicate(format: "label == %@", "1")).count, 1)
    }
    
    /**
     Try adding a new MyRSSFeed. Does not use internet, uses simplified validation for link.
     */
    func testAddFeed() {
        app.launch()
        
        let newName = "New Feed"
        let newLink = "http://newLink"
        
        let addRssFeedNavigationBar = app.navigationBars["Add RSS feed"]
        let cancelButton = addRssFeedNavigationBar.buttons["Cancel"]
        let addButton = app.navigationBars["RSSFeed reader"].buttons["Add"]
        let doneButton = addRssFeedNavigationBar.buttons["Done"]
        let feedNameField = app.tables["RSSFeedEditVC_TableView"].textFields["RSSFeedEditVC_feedNameField"]
        let feedLinkField = app.tables["RSSFeedEditVC_TableView"].children(matching: .any).textFields["RSSFeedEditVC_ErrorTextField_LinkField"]
        
        addButton.tap()
        XCTAssertFalse(doneButton.isEnabled)
        XCTAssertTrue(cancelButton.isEnabled)
        cancelButton.tap()
        
        addButton.tap()
        feedNameField.tap()
                feedNameField.typeText(newName)
        XCTAssertFalse(doneButton.isEnabled)
        
        feedLinkField.tap()
        feedLinkField.typeText(newLink)
        sleep(2)
        XCTAssertTrue(doneButton.isEnabled)
        doneButton.tap()
    }

//    func testLaunchPerformance() {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
