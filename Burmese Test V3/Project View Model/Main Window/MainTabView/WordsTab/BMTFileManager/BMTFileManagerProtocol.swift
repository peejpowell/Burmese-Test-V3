//
//  BMTFileManagerProtocol.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 01/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

// MARK: BMTFileManager Protocols

protocol BMTFileCreator {
    func createNewDocument(_ notification: Notification)
}

protocol BMTFileCloser {
    
    /**
     Calls the nonObjc version of itself to close the document in the currently open Words tab.
     
     If the file has been edited a request to save it will be issued.
     - Parameter sender: The object calling this function.
     */
    func closeDocument(_ sender: Any?)
    
    /**
     Closes the document in the currently open Words tab.
     
     If the file has been edited a request to save it will be issued.
     
     Note: This function does all the work but cannot be used with @objc due to the enum.
     - Parameter sender: The object calling this function.
     - Returns: a CloseResponse
     */
    func closeDocumentNonObjc(_ sender: Any?)->CloseResponse
    
    /**
     Attempts to close all open files.
     
     Can be cancelled or the file saved/not saved depending on the users response.
     - Parameter aNotification: A Notification
     */
    func closeAllFiles(_ aNotification: Notification)
}

protocol BMTFileSaver {
    
    func saveFileForDataSource(_ dataSource : TableViewDataSource, tableView: NSTableView)
    
    /**
     Shows a save document panel and asks for a file name before attempting to save the file.
     
     - Parameter aNotification: A Notification
     */
    func saveDocumentAs(_ aNotification: Notification)->Bool
    
}

protocol BMTFileLoader {
    
    func revertToSaved(_ aNotification : Notification)
    
    func askToRevert(fileAtUrl: URL)->NSApplication.ModalResponse
    
    func requestToRevertDataSource(dataSource: TableViewDataSource)->NSApplication.ModalResponse
    
    func tabOfFileWithURL(_ url: URL)->NSTabViewItem?
    
    /**
     If url is a file, calls the loadBMTFromURL function to load it.
     If url is a directory it recurses through each file in it calling itself to load it or continue into the directory and repeat.
     - Parameter url: URL of a file or directory
     */
    func loadRequestedUrl(_ url: URL)
    
    func openRecentFile(url: URL)
    
    func openRecentFiles()
    
    //func loadedIndexForUrl(_ url: URL)->Int
    
    func loadDataSource(_ dataSource: TableViewDataSource, into tabItem: NSTabViewItem)
    
    func loadWordsFromFile(_ fileURL: URL, into dataSource: TableViewDataSource)->TableViewDataSource?
    
    func loadFileAtURL(_ url: URL, reverting: Bool)
    
    func loadBMTFromURL(_ url: URL)
    
    /**
     Shows an open document panel and tries to load the resulting file/folder.
     
     If a folder is selected all BMT files will be loaded recursively.
     
     If a file is selected an attempt will be made to load it into the datasource.
     - Parameter aNotification: A Notification
     */
    func openDocument(_ aNotification: Notification)
    
}
