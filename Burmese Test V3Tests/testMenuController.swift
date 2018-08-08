//
//  testMenuController.swift
//  Burmese Test V3Tests
//
//  Created by Philip Powell on 08/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import XCTest
@testable import Burmese_Test_V3

class testMenuController: XCTestCase {

    var testValue : String?
    let menuController = MenuController()
    var testMenu = NSMenu()
    var testMenuItem = NSMenuItem(title: "Test", action: #selector(action(sender:)), keyEquivalent: "")
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        testMenu.addItem(testMenuItem)
        testMenu.addItem(NSMenuItem.separator())
        testMenu.addItem(NSMenuItem(title: "Select All", action: nil, keyEquivalent: ""))
        testMenu.addItem(NSMenuItem(title: "Select None", action: nil, keyEquivalent: ""))
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func action(sender: Any?) {
        self.testValue = "Changed"
    }
    
    func testToggleCurrent() {
        testMenuItem.state = .off
        self.menuController.toggleCurrent(testMenuItem)
        XCTAssert(testMenuItem.state == .on)
        self.menuController.toggleCurrent(testMenuItem)
        XCTAssert(testMenuItem.state == .off)
    }
    
    func testSelectAll() {
        
    }
    
    func testTest() {
        
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
