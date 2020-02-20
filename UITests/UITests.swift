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

    func testExample() {
        app.launch()
        
        let tableView = app.tables["ItemTableVC_TableView"]
        XCTAssertTrue(tableView.exists)
        
        
//        let app = XCUIApplication()
//        let itemtablevcTableviewTable = app/*@START_MENU_TOKEN@*/.tables["ItemTableVC_TableView"]/*[[".otherElements[\"ItemTableVC\"].tables[\"ItemTableVC_TableView\"]",".tables[\"ItemTableVC_TableView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        itemtablevcTableviewTable.tap()
//        itemtablevcTableviewTable.swipeDown()
//        app/*@START_MENU_TOKEN@*/.tables["ItemTableVC_TableView"].staticTexts["Starred items"]/*[[".otherElements[\"ItemTableVC\"].tables[\"ItemTableVC_TableView\"]",".cells.staticTexts[\"Starred items\"]",".staticTexts[\"Starred items\"]",".tables[\"ItemTableVC_TableView\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.swipeDown()
//        app.navigationBars["Starred items"].buttons["RSSFeed reader"].tap()
//        itemtablevcTableviewTable.swipeDown()
        
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
