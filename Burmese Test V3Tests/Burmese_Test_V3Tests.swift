//
//  Burmese_Test_V3Tests.swift
//  Burmese Test V3Tests
//
//  Created by Philip Powell on 28/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import XCTest
@testable import Burmese_Test_V3

class Burmese_Test_V3Tests: XCTestCase {
    
    let fileUrl = URL(string: "/users/peejpowell/BMTFiles/general.plist")!
    let folderUrl = URL(string: "/users/peejpowell/BMTFiles")!
    
    func testPJFileManagerIsDir() {
        XCTAssertTrue(PJFileManager().isDir(self.folderUrl))
        XCTAssertFalse(PJFileManager().isDir(self.fileUrl))
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
