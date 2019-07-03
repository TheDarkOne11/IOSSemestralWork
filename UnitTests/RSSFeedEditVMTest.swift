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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel.title.value = "Custom title"
        viewModel.link.value = "Custom link"
    }
    

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
