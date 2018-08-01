//
//  Burmese_Test_V3UITests.swift
//  Burmese Test V3UITests
//
//  Created by Philip Powell on 28/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import XCTest

class Burmese_Test_V3UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOpenDocument() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.windows["Burmese Test V3"]/*@START_MENU_TOKEN@*/.tabs["Words"]/*[[".tabGroups.tabs[\"Words\"]",".tabs[\"Words\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        
        let menuBarsQuery = app.menuBars
        menuBarsQuery.menuBarItems["File"].click()
        
            let menuBarsQuery2 = menuBarsQuery
            menuBarsQuery2/*@START_MENU_TOKEN@*/.menuItems["Open…"]/*[[".menuBarItems[\"File\"]",".menus.menuItems[\"Open…\"]",".menuItems[\"Open…\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
        
        let normalized = app.windows["Burmese Test V3"].coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        var coordinate = normalized.withOffset(CGVector(dx: 500, dy: 150))
        coordinate.click()
        coordinate = normalized.withOffset(CGVector(dx: 760, dy: 510))
        coordinate.click()
        // return
        let generalPlistWindow = app.windows["General.bmt"]
        menuBarsQuery.menuBarItems["Word Type"].click()
        let wordTypeMenuBarItem = menuBarsQuery.menuBarItems["Word Type"]
        wordTypeMenuBarItem.click()
        menuBarsQuery.menuItems.matching(identifier: "Alicia Lessons.bmt").menuItems["Select All"].click()
        
        //menuBarsQuery/*@START_MENU_TOKEN@*/.menuItems.matching(identifier: "general.plist").menuItems["Select All"]/*[[".menuBarItems[\"Word Type\"]",".menus.menuItems[\"general.plist\"]",".menus.menuItems[\"Select All\"]",".menuItems[\"Select All\"]",".menuItems[\"general.plist\"]",".menus.menuItems.matching(identifier: \"general.plist\")",".menuItems.matching(identifier: \"general.plist\")"],[[[-1,6,2],[-1,5,2],[-1,0,1]],[[-1,4,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        wordTypeMenuBarItem.click()
    }
    
}
