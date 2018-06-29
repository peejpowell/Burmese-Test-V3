//
//  FileManager.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 27/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

extension FileManager {
    
    func isDir(_ url:URL) -> Bool
    {
        // Is it a directory?
        do {
            let fileAttribs = try self.attributesOfItem(atPath: url.path)
            if let fileType : FileAttributeType = fileAttribs[FileAttributeKey.type] as? FileAttributeType {
                if fileType == FileAttributeType.typeDirectory {
                    return true
                }
            }
        } catch let error {
            print(error)
        }
        return false
    }
    
}

class PJFileManager : FileManager
{
    var openFiles = [URL]() {
        didSet(oldValue) {
            infoPrint("changed from: \(oldValue) to: \(self.openFiles)", #function, self.className)
            let data = NSKeyedArchiver.archivedData(withRootObject: self.openFiles)
            UserDefaults.standard.set(data, forKey: "OpenFiles")
        }
    }
    
    var revertFileAlert : NSAlert {
        let alert = NSAlert()
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "Revert")
        alert.addButton(withTitle: "Cancel")
        return alert
    }
    
    func loadWordsFromFile(_ fileURL: URL, into dataSource: TableViewDataSource)->TableViewDataSource
    {
        // Load the words file from the URL into the designated dataSource
        //let fileManager = FileManager()
        
        if self.fileExists(atPath: fileURL.path) {
            
            if let wordDictionariesNSA  = NSArray(contentsOf: fileURL) {
                dataSource.words.removeAll()
                dataSource.sourceFile = URL(fileURLWithPath: fileURL.path)
                for wordDictionary : Any in wordDictionariesNSA {
                    if let wordDict = wordDictionary as? Dictionary<String,String> {
                        let word = Words(wordDictionary:wordDict)
                        dataSource.words.append(word)
                    }
                }
            }
        }
        else {
            print("Unable to find the file : \(fileURL.path)")
        }
        return dataSource
    }
    
    func loadedIndexForUrl(_ url: URL)->Int {
        var dataSourceIndex = -1
        var foundFile = false
        for dataSource in getWordsTabViewDelegate().dataSources
        {
            if dataSource.sourceFile == url {
                foundFile = true
                dataSourceIndex += 1
                break
            }
            dataSourceIndex += 1
        }
        if foundFile {
            return dataSourceIndex
        }
        else {
            return -1
        }
    }
    
    func loadDataSource(_ dataSource: TableViewDataSource, at index: Int)
    {
        let tabViewController = getWordsTabViewDelegate()
        
        tabViewController.dataSources[index] = dataSource
        if let name = dataSource.sourceFile?.path.lastPathComponent {
            tabViewController.tabViewItems[index].label = name
        }
        if let tableView = tabViewController.tabViewControllersList[index].tableView {
            tableView.dataSource = tabViewController.dataSources[index]
            tableView.delegate = tabViewController.dataSources[index]
            
            if tableView.isHidden {
                tableView.isHidden = false
            }
            tableView.reloadData()
        }
    }
    
    func loadFileAtURL(_ url: URL, reverting: Bool) {
        // Check each datasource to see if it's already loaded and load if not
        
        let dataSourceIndex = loadedIndexForUrl(url)
        let fileAlreadyLoaded = dataSourceIndex > -1
        
        // Check if the first dataSource has no valid url
        let tabViewController = getWordsTabViewDelegate()
        
        if tabViewController.dataSources[0].sourceFile == nil {
            var newDataSource = tabViewController.dataSources[0]
            newDataSource = self.loadWordsFromFile(url, into: newDataSource)
            loadDataSource(newDataSource, at: 0)
        }
        else {
            if fileAlreadyLoaded && reverting == false {
                return
            }
            else {
                let wordsTabView = tabViewController.tabView
                let newDataSource = self.loadWordsFromFile(url, into: TableViewDataSource())
                
                switch reverting {
                case true:
                    //Revert the file
                    loadDataSource(newDataSource, at: dataSourceIndex)
                    switch dataSourceIndex {
                    case getCurrentIndex():
                        break
                    default:
                        selectTabForExistingFile(at: dataSourceIndex)
                    }
                case false:
                    if tabViewController.dataSources.count == 0 {
                        if let tableView = tabViewController.tabViewControllersList[0].tableView {
                            //newDataSource.sortTable(tableView, sortBy: newDataSource.sortBy)
                            tableView.dataSource = nil
                            tableView.delegate = nil
                            tabViewController.dataSources.append(TableViewDataSource())
                            loadDataSource(newDataSource, at: 0)
                            if let viewController =  tabViewController.tabViewItems.first?.viewController as? BMTTabViewController
                            {
                                tabViewController.tabViewControllersList.append(viewController)
                            }
                        }
                    }
                    else {
                    
                    //Create a new tab, BMTView and dataSource

                        func setUpNewBMTFor(_ dataSource : TableViewDataSource) {
                       
                            tabViewController.dataSources.append(newDataSource)
                            let newViewController = BMTTabViewController()
                            let view = newViewController.view
                            if let tableView = view.viewWithTag(100) as? NSTableView {
                                if let dataSource = tabViewController.dataSources.last {
                                    tableView.dataSource = dataSource
                                    tableView.delegate = dataSource
                                }
                            }
                            tabViewController.tabViewControllersList.append(newViewController)
                            let newTabViewItem = NSTabViewItem()
                            newTabViewItem.label = url.path.lastPathComponent
                            newTabViewItem.viewController = newViewController
                            
                            tabViewController.tabViewItems.append(newTabViewItem)
                        }
                        
                        setUpNewBMTFor(newDataSource)
                        wordsTabView.selectLastTabViewItem(self)
                    }
                }
            }
        }
        
        if !self.openFiles.contains(url) && !url.lastPathComponent.containsString("di")
        {
            self.openFiles.append(url)
        }
        
        getMainMenuController().updateRecentsMenu(with: url)
    
        if let mainWindow = getMainWindowController().window {
            mainWindow.title = url.lastPathComponent
            mainWindow.representedURL = url
        
            /*if !self.openFiles.contains(url)
            {
                self.openFiles.append(url)
            }*/
            return
        }
    }
    
    func fileAlreadyLoaded(_ url: URL)-> (Bool, Int)
    {
        var loadedAtIndex = -1
        
        for dataSource in getWordsTabViewDelegate().dataSources
        {
            loadedAtIndex = loadedAtIndex + 1
            if dataSource.sourceFile == url
            {
                return (true, loadedAtIndex)
            }
        }
        return (false, -1)
    }
    
    func askToRevert(fileAtUrl: URL)->NSApplication.ModalResponse {
        let alert = revertFileAlert
        alert.messageText = "Do you want to revert to the latest version of \(fileAtUrl.path.lastPathComponent)?"
        return alert.runModal()
    }
    
    func requestToRevertDataSource(dataSource: TableViewDataSource)->NSApplication.ModalResponse
    {
        if let url = dataSource.sourceFile {
            let alertResponse = askToRevert(fileAtUrl: url)
            return alertResponse
        }
        return .alertSecondButtonReturn
    }
    
    func saveFileForDataSource(_ dataSource : TableViewDataSource, at index: Int)
    {
        let fileManager = PJFileManager()
        
        if let url = dataSource.sourceFile
        {
            let alertResponse = requestToRevertDataSource(dataSource: dataSource)
            switch alertResponse {
            case .alertFirstButtonReturn:
                fileManager.loadFileAtURL(url, reverting: true )
                dataSource.needsSaving = false
                getWordsTabViewDelegate().tabViewControllersList[index].tableView.reloadData()
            case .alertSecondButtonReturn:
                print("Cancelled")
            default:
                print("Unhandled alert response \(alertResponse)")
            }
        }
    }
    
    func loadOrWarn(_ url: URL)
    {
        let fileManager = PJFileManager()
        
        let result = fileAlreadyLoaded(url)
        let loaded = result.0
        let loadedAtIndex = result.1
        if !loaded {
            fileManager.loadFileAtURL(url, reverting: false)
        }
        else {
            // If the file needs saving ask the user to confirm the save before loading the file
            
            let dataSource = getWordsTabViewDelegate().dataSources[loadedAtIndex]
            dataSource.needsSaving = true
            switch dataSource.needsSaving {
            case true:
                saveFileForDataSource(dataSource, at: loadedAtIndex)
                fallthrough
            case false:
                selectTabForExistingFile(at: loadedAtIndex)
            }
        }
    }
}
