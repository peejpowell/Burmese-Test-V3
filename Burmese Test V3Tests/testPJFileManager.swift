//
//  testPJFileManager.swift
//  Burmese Test V3Tests
//
//  Created by Philip Powell on 29/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import XCTest
@testable import Burmese_Test_V3

class testPJFileManager: XCTestCase {

    let fileUrl = URL(string: "file:///users/peejpowell/BMTFiles/general.plist")!
    let folderUrl = URL(string: "file:///users/peejpowell/BMTFiles")!
    
    let fileManager = PJFileManager()
    var newDataSource = TableViewDataSource()
    
    func testPJFileManagerIsDir() {
        XCTAssertTrue(fileManager.isDir(self.folderUrl))
        XCTAssertFalse(fileManager.isDir(self.fileUrl))
    }
    
    func testPJFileManagerLoadWordsFromFile() {
        newDataSource = fileManager.loadWordsFromFile(fileUrl, into: newDataSource)
        XCTAssert(newDataSource.words.count > 0, "Datasource is empty.")
    }
    
    func testPJFileManagerAskToRevertFile()
    {
        XCTAssert(fileManager.askToRevert(fileAtUrl: fileUrl) == .alertFirstButtonReturn)
        XCTAssert(fileManager.askToRevert(fileAtUrl: fileUrl) == .alertSecondButtonReturn)
    }
}
