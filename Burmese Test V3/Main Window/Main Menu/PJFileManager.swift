//
//  FileManager.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 27/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

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
    
    var warningAlert : NSAlert {
        let alert = NSAlert()
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        return alert
    }
    
    @objc func loadWordsFromFile(_ fileURL: URL, into dataSource: TableViewDataSource)->TableViewDataSource?
    {
        // Load the words file from the URL into the designated dataSource
        let fileManager = FileManager()
        infoPrint("", #function, self.className)
        
        let path = fileURL.path
        //let newURL = URL(fileURLWithPath: path)
        infoPrint(path, #function, self.className)
        if fileManager.fileExists(atPath: fileURL.path) {
            /*if let data:NSData =  FileManager.default.contents(atPath: fileURL.path) as? NSData {
                do {
                    if let BMTArray = try PropertyListSerialization.propertyList(from: data as Data, options: PropertyListSerialization.MutabilityOptions.mutableContainersAndLeaves, format: nil) as? NSArray {
                        dataSource.words.removeAll()
                        dataSource.sourceFile = URL(fileURLWithPath: fileURL.path)
                        for wordDictionary : Any in BMTArray {
                            if let wordDict = wordDictionary as? Dictionary<String,String> {
                                let word = Words(wordDictionary:wordDict)
                                dataSource.words.append(word)
                            }
                        }
                    }
                }catch{
                    print("Error occured while reading from the plist file")
                }
            }*/
            
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
        
        infoPrint("", #function, self.className)
        
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
        infoPrint("", #function, self.className)
        
        let tabViewController = getWordsTabViewDelegate()
        
        tabViewController.dataSources[index] = dataSource
        if let name = dataSource.sourceFile?.path.lastPathComponent {
            tabViewController.tabViewItems[index].label = name
        }
        if let tableView = tabViewController.tabViewControllersList[index].tableView as? PJTableView {
            tableView.dataSource = tabViewController.dataSources[index]
            tableView.delegate = tabViewController.dataSources[index]
            tableView.registerTableForDrag()
            if let dataSource = tableView.dataSource as? TableViewDataSource {
                dataSource.sortTable(tableView, sortBy: SortKeys.English.rawValue)
            }
            
            if tableView.isHidden {
                tableView.isHidden = false
            }
            tableView.reloadData()
        }
    }
    
    func setUpNewBMTFor(_ dataSource : TableViewDataSource, with url: URL) {
        
        infoPrint("", #function, self.className)
        
        let tabViewController = getWordsTabViewDelegate()
        tabViewController.dataSources.append(dataSource)
        let newViewController = BMTViewController()
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
        selectWordsTab()
    }
    
    func loadFileAtURL(_ url: URL, reverting: Bool) {
        
        infoPrint("", #function, self.className)
        // Check each datasource to see if it's already loaded and load if not
        var invalidFile = false
        
        let dataSourceIndex = loadedIndexForUrl(url)
        let fileAlreadyLoaded = dataSourceIndex > -1
        
        // Check if the first dataSource has no valid url
        let tabViewController = getWordsTabViewDelegate()
        
        if tabViewController.dataSources[0].sourceFile == nil {
            let newDataSource = tabViewController.dataSources[0]
            if let newDataSource = self.loadWordsFromFile(url, into: newDataSource) {
                loadDataSource(newDataSource, at: 0)
                selectWordsTab()
                getMainMenuController().closeWordsFileMenuItem.isEnabled = true
                getMainMenuController().saveFileMenuItem.isEnabled = true
                getMainMenuController().saveAsFileMenuItem.isEnabled = true
            }
            else
            {
                invalidFile = true
            }
        }
        else {
            if fileAlreadyLoaded && reverting == false {
                return
            }
            else {
                let wordsTabView = tabViewController.tabView
                if let newDataSource = self.loadWordsFromFile(url, into: TableViewDataSource()) {
                
                    switch reverting {
                    case true:
                        //Revert the file
                        loadDataSource(newDataSource, at: dataSourceIndex)
                        selectTabForExistingFile(at: dataSourceIndex)
                    case false:
                        if tabViewController.dataSources.count == 0 {
                            if let tableView = tabViewController.tabViewControllersList[0].tableView {
                                //newDataSource.sortTable(tableView, sortBy: newDataSource.sortBy)
                                tableView.dataSource = nil
                                tableView.delegate = nil
                                tabViewController.dataSources.append(TableViewDataSource())
                                loadDataSource(newDataSource, at: 0)
                                if let viewController =  tabViewController.tabViewItems.first?.viewController as? BMTViewController {
                                    tabViewController.tabViewControllersList.append(viewController)
                                }
                            }
                        }
                        else {
                        
                            //Create a new tab, BMTView and dataSource
                            
                            setUpNewBMTFor(newDataSource, with: url)
                            wordsTabView.selectLastTabViewItem(self)
                            selectWordsTab()
                        }
                    }
                }
            }
        }
        
        if !self.openFiles.contains(url) && invalidFile == false
        {
            self.openFiles.append(url)
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
    }
    
    func fileAlreadyLoaded(_ url: URL)-> (Bool, Int)
    {
        infoPrint("", #function, self.className)
        
        var loadedAtIndex = -1
        
        for dataSource in getWordsTabViewDelegate().dataSources {
            loadedAtIndex = loadedAtIndex + 1
            if dataSource.sourceFile == url {
                return (true, loadedAtIndex)
            }
        }
        return (false, -1)
    }
    
    func askToRevert(fileAtUrl: URL)->NSApplication.ModalResponse {
        
        infoPrint("", #function, self.className)
        
        let alert = revertFileAlert
        alert.messageText = "Do you want to revert to the latest version of \(fileAtUrl.path.lastPathComponent)?"
        return alert.runModal()
    }
    
    func requestToRevertDataSource(dataSource: TableViewDataSource)->NSApplication.ModalResponse
    {
        infoPrint("", #function, self.className)
        
        if let url = dataSource.sourceFile {
            let alertResponse = askToRevert(fileAtUrl: url)
            return alertResponse
        }
        return .alertSecondButtonReturn
    }
    
    func saveFileForDataSource(_ dataSource : TableViewDataSource, at index: Int) {
        
        infoPrint("", #function, self.className)
        
        if let url = dataSource.sourceFile {
            let alertResponse = requestToRevertDataSource(dataSource: dataSource)
            switch alertResponse {
            case .alertFirstButtonReturn:
                if let fileManager = getMainWindowController().mainFileManager {
                    fileManager.loadFileAtURL(url, reverting: true )
                }
                dataSource.needsSaving = false
                getWordsTabViewDelegate().tabViewControllersList[index].tableView.reloadData()
            case .alertSecondButtonReturn:
                print("Cancelled")
            default:
                print("Unhandled alert response \(alertResponse)")
            }
        }
    }
    
    func fileIsInvalid(at fileUrl: URL)->Bool{
    
        // try to load the file into an NSArray and show an error if we fail
        
        if NSArray(contentsOf: fileUrl) != nil {
            return false
        }
        let alert = warningAlert
        alert.messageText = "File is not a valid BMT file.\n\(fileUrl.path)"
        alert.runModal()
        return true
    }
    
    @objc func loadOrWarn(_ url: URL)
    {
        infoPrint("", #function, self.className)
        
        // Test to see if it's a valid file
        
        if fileIsInvalid(at: url) {
            return
        }
        
        let result = fileAlreadyLoaded(url)
        let loaded = result.0
        let loadedAtIndex = result.1
        if !loaded {
            if let fileManager = getMainWindowController().mainFileManager {
                fileManager.loadFileAtURL(url, reverting: false)
            }
        }
        else {
            // If the file needs saving ask the user to confirm the save before loading the file
            
            let dataSource = getWordsTabViewDelegate().dataSources[loadedAtIndex]
            switch dataSource.needsSaving {
            case true:
                saveFileForDataSource(dataSource, at: loadedAtIndex)
                fallthrough
            case false:
                selectTabForExistingFile(at: loadedAtIndex)
            }
        }
        let view = getWordsTabViewDelegate().tabViewControllersList[0].view
        view.isHidden = false
    }
    
    func convertToPlist(_ arrayToConvert: [Words])->[Dictionary<NSString, NSString>]
    {
        infoPrint("", #function, self.className)
        
        var convertedArray = [Dictionary<NSString, NSString>]()
        if arrayToConvert.count > 0 {
            let fieldNames : [String] = ["Burmese","Roman","English","Insertion","Lesson","wordIndex","categoryIndex","category","wordCategory","isTitle"]
            for item : Words in arrayToConvert {
                var convertDict = Dictionary<NSString,NSString>()
                let fieldValues = [item.burmese,item.roman,item.english,item.insertion,item.lesson,item.wordindex,item.categoryindex,item.category,item.wordcategory,"\(item.istitle)"]
                
                for fieldNum in 0 ..< fieldNames.count {
                    if fieldValues[fieldNum] != "" && fieldValues[fieldNum] != nil {
                        convertDict[fieldNames[fieldNum] as NSString] = fieldValues[fieldNum] as NSString?
                    }
                }
                convertedArray.append(convertDict)
            }
        }
        return convertedArray
    }
    
    func saveWordsToFile(_ fileURL: URL)->String
    {
        infoPrint("", #function, self.className)
        
        let index = getCurrentIndex()
        let wordsTabController = getWordsTabViewDelegate()
        switch index {
        case -1:
            break
        default:
            let dataSource = wordsTabController.dataSources[index]
            let pListToSave : [Dictionary<NSString, NSString>] = self.convertToPlist(dataSource.words)
            _ = PropertyListSerialization.propertyList(pListToSave, isValidFor: PropertyListSerialization.PropertyListFormat.binary)
            
            let plistData : Data?
            do {
                plistData = try PropertyListSerialization.data(fromPropertyList: pListToSave, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
                do {
                    try plistData!.write(to: fileURL, options: NSData.WritingOptions.atomicWrite)
                        wordsTabController.tabViewItems[index].label = fileURL.path.lastPathComponent
                    } catch let error as NSError {
                        print("Could not write \(error), \(error.userInfo)")
                        return "Failed to save file \(fileURL.path)"
                    }
            } catch let error as NSError {
                NSAlert(error: error).runModal()
                //plistData = nil
                return "Failed to save file \(fileURL.path)"
            }
        }
        return "Saved \(fileURL.path)"
    }
    
    override init() {
        super.init()
        infoPrint("Created new filemanager", #function, self.className)
    }
    
    deinit {
        infoPrint("Removed filemanager", #function, self.className)
    }
}
