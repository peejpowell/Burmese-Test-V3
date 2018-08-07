//
//  BMTFileManager.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 01/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static var loadRecentFiles: Notification.Name {
        return .init(rawValue: "BMTFileManager.loadRecentFiles")
    }
    
    static var openDocument: Notification.Name {
        return .init(rawValue: "BMTFileManager.openDocument")
    }
    
    static var closeDocument: Notification.Name {
        return .init(rawValue: "BMTFileManager.closeDocument")
    }
    
    static var saveDocument: Notification.Name {
        return .init(rawValue: "BMTFileManager.saveDocument")
    }
    
    static var saveDocumentAs: Notification.Name {
        return .init(rawValue: "BMTFileManager.saveDocumentAs")
    }
    
    static var closeAllFiles: Notification.Name {
        return .init(rawValue: "BMTFileManager.closeAllFiles")
    }
    
    static var revertToSaved: Notification.Name {
        return .init(rawValue: "BMTFileManager.revertToSaved")
    }
    
    static var createNewDocument: Notification.Name {
        return .init(rawValue: "BMTFileManager.createNewDocument")
    }
}

/**
 Responses to requests to open a file.
 - Returns: Int
 - invalidNotBMT:   File is not a BMT file
 - invalidNotThere: File does not exist
 - validDir:        File is a directory
 - validFile:       File is a valid BMT file
 */
enum OpenFileResponse : Int {
    case invalidNotBMT
    case invalidNotThere
    case validDir
    case validFile
}

/**
 Responses to requests to close a file.
 - Returns: Int
 - cancelled:   User clicked Cancel
 - saved:       User clicked Save
 - notSaved:    User clicked Do Not Save
 - noneNeeded:  File ws closed without warning
 - unknown:     Unknown response (just in case)
 */

enum CloseResponse : Int {
    case cancelled
    case saved
    case notSaved
    case noneNeeded
    case unknown
}

// MARK: Protocol Conformance

extension BMTFileManager: BMTFileCloser {
    
    func saveDataSource(_ dataSource: TableViewDataSource)->CloseResponse {
        //var closeResponse: CloseResponse = .noneNeeded
        let alert = Alerts().saveAlert
        if let filetoSave = dataSource.sourceFile?.path.lastPathComponent {
            alert.messageText = "Do you want to save the changes to \(filetoSave)?"
        }
        else {
            alert.messageText = "Do you want to save the new file?"
        }
        let alertResult = alert.runModal()
        switch alertResult {
        case NSApplication.ModalResponse.alertFirstButtonReturn:
            print("Saved")
            if let sourceFile = dataSource.sourceFile {
                _ = self.saveWordsToFile(sourceFile)
                return .saved
            }
            else {
                // File has never been saved
                _ = self.saveDocumentAs(Notification(name: .saveDocumentAs))
                if dataSource.needsSaving {
                    return .notSaved
                }
            }
        case NSApplication.ModalResponse.alertSecondButtonReturn:
            print("Cancelled")
            return .cancelled
        case NSApplication.ModalResponse.alertThirdButtonReturn:
            print("Not saved")
            return .notSaved
        default:
            print("Unhandled alert response \(alertResult)")
            return .unknown
        }
        return .noneNeeded
    }
    
    fileprivate func cleanUpAfterClose(_ dataSource: TableViewDataSource) {
        if  let controller = self.controller,
            let wordsTabVC = controller.wordsTabViewController,
            let currentTabItem = wordsTabVC.tabView.selectedTabViewItem {
            let index = wordsTabVC.tabView.indexOfTabViewItem(currentTabItem)
            
            // Remove the openFiles entry
            
            var foundAt = -1
            for openFileNum in 0..<controller.wordsTabViewModel.openFiles.count {
                if let sourceFile = dataSource.sourceFile {
                    if controller.wordsTabViewModel.openFiles[openFileNum] == sourceFile {
                        foundAt = openFileNum
                    }
                }
            }
            if foundAt != -1 {
                controller.wordsTabViewModel.removeOpenFile(at: foundAt)
            }
            
            // Remove the datasource and tabVC or create an empty datasource if it's the last open file
            
            /*if wordsTabVC.dataSources.count != 1
            {
                wordsTabVC.tabViewControllersList.remove(at: index)
                wordsTabVC.dataSources.remove(at: index)
            }
            else
            {
                if let tableView = wordsTabVC.tabViewControllersList[0].tableView {
                    tableView.dataSource = nil
                    tableView.delegate = nil
                }
                wordsTabVC.dataSources.remove(at: 0)
                wordsTabVC.dataSources.append(TableViewDataSource())
                //wordsTabViewController.tabViewControllersList[0].tableView = nil
                wordsTabVC.tabViewItems[0].label = "Nothing Loaded"
                
            }*/
            
            // Remove the selected tab and then select the next available tab.
            // Select the previous tab if we removed the last tab or the next tab if not
            
            let tabViewItem = wordsTabVC.tabViewItems[index]
            var nextTab = -1
            
            if  tabViewItem == wordsTabVC.tabViewItems.last && tabViewItem != wordsTabVC.tabViewItems.first {
                nextTab = index-1
            }
            else {
                nextTab = index
            }
            if wordsTabVC.tabViewItems.count != 1 {
                wordsTabVC.tabViewItems.remove(at: index)
                
            }
            else {
                wordsTabVC.tabViewItems[0].label = "Nothing Loaded"
            }
            
            if nextTab != -1 {
                wordsTabVC.tabView.selectTabViewItem(at: nextTab)
            }
            
            // Set the empty label and hide the tableView if the last file was closed.
            // Otherwise
            
            //if wordsTabVC.dataSources.count == 1 && wordsTabVC.dataSources[0].sourceFile == nil {
            if let currentTabItem = wordsTabVC.tabView.selectedTabViewItem {
                if wordsTabVC.tabView.tabViewItems.count == 1 && currentTabItem.label == "Nothing Loaded" {// && wordsTabVC.tableView.dataSource
                    if let first = wordsTabVC.tabViewItems.first,
                        let view = first.view {
                        view.isHidden = true
                        first.label = "Nothing Loaded"
                        if let bmtVC = first.viewController as? BMTViewController {
                            bmtVC.bmtViewModel.dataSource = nil
                            bmtVC.bmtViewModel.dataSource = TableViewDataSource()
                            bmtVC.tableView.reloadData()
                        }
                    }
                    NotificationCenter.default.post(name: .disableFileMenuItems, object: nil)
                    }
                    else {
                        if index == 0 {
                            controller.wordsTabViewModel.removingFirstItem = true
                        }
                        else {
                            controller.wordsTabViewModel.removingFirstItem = false
                        }
                        // FIXME: Not sure if this bit is needed now
                        
                        /*let wordsTabViewController = appDelegate.viewControllers.wordsTabViewController
                         //wordsTabView.removeTabViewItem(wordsTabView.tabViewItem(at: index))
                         wordsTabViewController?.tabViewItems.remove(at: index)
                         appDelegate.viewControllers.wordsTabViewController.wordsTabViewControllers.remove(at:index)*/
                        //controller.removingFirstItem = false
                }
            }
        }
    }
    
    func closeDocumentNonObjc(_ sender: Any?)->CloseResponse {
        infoPrint("",#function,self.className)
        var closeResponse : CloseResponse = .noneNeeded
        if  let controller = self.controller,
            let wordsTabVC = controller.wordsTabViewController,
            let currentTabItem = wordsTabVC.tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource {
            if dataSource.needsSaving {
                closeResponse = saveDataSource(dataSource)
                if closeResponse == .cancelled {
                    return .cancelled
                }
                cleanUpAfterClose(dataSource)
            }
            else {
                cleanUpAfterClose(dataSource)
            }
            NotificationCenter.default.post(name: .startBuildWordTypeMenu, object:nil)
            
            /*if let menuController = getWordTypeMenuController() {
                menuController.buildWordTypeMenu()
            }*/
            if let currentTabItem = wordsTabVC.tabView.selectedTabViewItem {
                if currentTabItem.label == "Nothing Loaded" {
                    NotificationCenter.default.post(name: .disableFileMenuItems, object: nil)
                }
            }
            return closeResponse
        }
        return closeResponse
    }
    
    @objc func closeDocument(_ sender: Any?) {
        infoPrint("",#function,self.className)
        let _ = closeDocumentNonObjc(sender)
    }

    @objc func closeAllFiles(_ aNotification: Notification) {
        if let controller = self.controller {
            for tabNum in (0..<controller.wordsTabViewController.tabViewItems.count).reversed() {
                controller.wordsTabViewController.tabView.selectTabViewItem(at:tabNum)
                let response = closeDocumentNonObjc(self)
                if response == .cancelled {
                    return
                }
            }
            NotificationCenter.default.post(name: .closeMainWindow, object:nil)
        }
    }
}

extension BMTFileManager: BMTFileCreator {
    
    fileprivate func fileIsLoaded()->Bool {
        if  let controller = controller,
            let wordsTabVC = controller.wordsTabViewController,
            let currentTabItem = wordsTabVC.tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource,
            let _ = dataSource.sourceFile {
            return true
        }
        return false
    }
    
    @objc func createNewDocument(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if  let controller = self.controller,
            let wordsTabVC = controller.wordsTabViewController {
            if !fileIsLoaded() {
                // Add a new tab and use that
                let BMTvc = BMTViewController()
                //wordsTabVC.tabViewControllersList.append(BMTvc)
                wordsTabVC.tabViewItems.append(wordsTabVC.createEmptyBMT(named: "Untitled", controlledBy: BMTvc))
                wordsTabVC.tabView.selectTabViewItem(wordsTabVC.tabViewItems.last)
                wordsTabVC.editFirstColumnOf(BMTvc.tableView)
            }
            else {
                // Use the existing tab
                if  let currentTabItem = wordsTabVC.tabView.selectedTabViewItem,
                    let bmtVC = currentTabItem.viewController as? BMTViewController {
                    bmtVC.view.isHidden = false
                    currentTabItem.label = "Untitled"
                    if let tableView = bmtVC.tableView {
                        tableView.reloadData()
                        wordsTabVC.editFirstColumnOf(tableView)
                    }
                    NotificationCenter.default.post(name: .dataSourceNeedsSaving, object: nil)
                    getMainMenuController().closeWordsFileMenuItem.isEnabled = true
                    getMainMenuController().saveFileMenuItem.isEnabled = true
                    getMainMenuController().saveAsFileMenuItem.isEnabled = true
                }
            }
        }
    }
}

extension BMTFileManager: BMTFileSaver {
    
    func saveWordsToFile(_ fileURL: URL)->String {
        infoPrint("", #function, self.className)
        
        if  let controller = controller,
            let wordsTabVC = controller.wordsTabViewController,
            let currentTabItem = wordsTabVC.tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource {
            let pListToSave : [Dictionary<NSString, NSString>] = self.convertToPlist(dataSource.lessonEntries)
            _ = PropertyListSerialization.propertyList(pListToSave, isValidFor: PropertyListSerialization.PropertyListFormat.binary)
            
            let plistData : Data?
            do {
                plistData = try PropertyListSerialization.data(fromPropertyList: pListToSave, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
                do {
                    if let plistData = plistData {
                        try plistData.write(to: fileURL, options: NSData.WritingOptions.atomicWrite)
                        currentTabItem.label = fileURL.path.lastPathComponent
                    }
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
    
    func saveFileForDataSource(_ dataSource : TableViewDataSource, tableView : NSTableView) {
        infoPrint("", #function, self.className)
        
        if let url = dataSource.sourceFile {
            let alertResponse = requestToRevertDataSource(dataSource: dataSource)
            switch alertResponse {
            case .alertFirstButtonReturn:
                self.loadFileAtURL(url, reverting: true )
                dataSource.needsSaving = false
                tableView.reloadData()
            case .alertSecondButtonReturn:
                print("Cancelled")
            default:
                print("Unhandled alert response \(alertResponse)")
            }
        }
    }
    
    @IBAction func saveDocument(_ sender: Any?) {
        infoPrint("", #function, self.className)
        if  let controller = controller,
            let wordsTabVC = controller.wordsTabViewController,
            let currentTabItem = wordsTabVC.tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource,
            let url = dataSource.sourceFile {
            let saveResult = self.saveWordsToFile(url)
            switch saveResult.left(5) {
            case "Saved":
                break
            default:
                let alert = Alerts().warningAlert
                alert.messageText = saveResult
                alert.runModal()
                return
            }
            dataSource.needsSaving = false
            getMainMenuController().updateRecentsMenu(with: url)
            getMainWindowController().window?.title = url.lastPathComponent
            getMainWindowController().window?.representedURL = url
        }
        else {
            _ = self.saveDocumentAs(Notification(name: .saveDocumentAs))
        }
    }
    
    @objc func saveDocumentAs(_ aNotification: Notification)->Bool {
        infoPrint("", #function, self.className)
        
        if  let controller = controller,
            let wordsTabVC = controller.wordsTabViewController,
            let currentTabItem = wordsTabVC.tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource {
            let savePanel = Panels().saveDocumentPanel
            let fileNameToSave = currentTabItem.label
            if fileNameToSave.left(1) != "*" {
                savePanel.nameFieldStringValue = fileNameToSave
            }
            else {
                let fileNameToSave = fileNameToSave.minus(-2)
                savePanel.nameFieldStringValue = fileNameToSave
            }
            savePanel.directoryURL = dataSource.sourceFile?.deletingLastPathComponent()
            let saveDocumentResult = savePanel.runModal()
            
            switch saveDocumentResult {
            case NSApplication.ModalResponse.OK:
                // try to save the file
                if let url = savePanel.url {
                    let saveResult = self.saveWordsToFile(url)
                    switch saveResult.left(5) {
                    case "Saved":
                        break
                    default:
                        let alert = Alerts().warningAlert
                        alert.messageText = saveResult
                        alert.runModal()
                        return false
                    }
                    dataSource.sourceFile = url
                    dataSource.needsSaving = false
                    getMainMenuController().updateRecentsMenu(with: url)
                    getMainWindowController().window?.title = url.lastPathComponent
                    getMainWindowController().window?.representedURL = url
                }
            default:
                print("Cancelled save as")
                NotificationCenter.default.post(name: .dataSourceNeedsSaving, object: nil)
                return false
            }
        }
        return true
    }
}

extension BMTFileManager: BMTFileLoader {
    
    @objc func revertToSaved(_ aNotification : Notification) {
        if  let controller = self.controller,
            let currentTabItem = controller.wordsTabViewController.tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource {
            if let url = dataSource.sourceFile {
                self.loadFileAtURL(url, reverting: true )
                NotificationCenter.default.post(name: .disableRevert, object: nil)
            }
        }
    }
    
    func askToRevert(fileAtUrl: URL)->NSApplication.ModalResponse {
        infoPrint("", #function, self.className)
        
        let alert = Alerts().revertFileAlert
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
    
    func tabOfFileWithURL(_ url: URL)->NSTabViewItem? {
        infoPrint("", #function, self.className)
        if  let controller = self.controller,
            let wordsTabVC = controller.wordsTabViewController {
            for tabItem in wordsTabVC.tabViewItems {
                if  let bmtVC = tabItem.viewController as? BMTViewController,
                    let dataSource = bmtVC.dataSource {
                    if dataSource.sourceFile == url {
                        return tabItem
                    }
                }
            }
        }
        return nil
    }
    
    func loadFileAtURL(_ url: URL, reverting: Bool) {
        infoPrint("", #function, self.className)
        
        // Check each tab to see if datasource with the same url exists already loads it if not
        
        var invalidFile = false
        let tabItem = tabOfFileWithURL(url)
        let fileAlreadyLoaded = tabItem !=  nil
        
        // Check if the first dataSource has no valid url
        
        if  let controller = self.controller,
            let firstTabItem = getWordsTabViewDelegate().tabViewItems.first,
            let bmtVC = firstTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource {
            
            // Check if it's the first time to load a dataSource and load it into the existing tab.
            if dataSource.sourceFile == nil {
                if let newDataSource = self.loadWordsFromFile(url, into: dataSource) {
                    loadDataSource(newDataSource, into: firstTabItem)
                    selectWordsTab()
                    NotificationCenter.default.post(name: .enableFileMenuItems, object: nil)
                }
                else {
                    // TODO: Something went wrong so we should report what it was
                    invalidFile = true
                }
            }
            else {
                // If the file is already loaded and we aren't reverting then no need to do anything else.
                
                if fileAlreadyLoaded && reverting == false {
                    return
                }
                else {
                    // Not the first time to load a dataSource so load the dataSource into the existing tabItem or create a new tab for the datasource
                    let wordsTabView = controller.wordsTabViewController.tabView
                    if let newDataSource = self.loadWordsFromFile(url, into: TableViewDataSource()) {
                        switch reverting {
                        case true:
                            //Revert the file
                            if let tabItem = tabItem {
                                loadDataSource(newDataSource, into: tabItem)
                                selectTabForExistingFile(tabItem: tabItem)
                            }
                        case false:
                            //Create a new tab, BMTView and dataSource
                            
                            controller.setUpNewBMTFor(newDataSource, with: url)
                            wordsTabView.selectLastTabViewItem(self)
                            controller.view.wantsLayer = true
                            selectWordsTab()
                            NotificationCenter.default.post(name: .enableFileMenuItems, object: nil)
                        }
                    }
                }
            }
            // Add the new url to the open files list and update the window to show the name with file location and icon
            if !controller.wordsTabViewModel.openFiles.contains(url) && invalidFile == false
            {
                controller.wordsTabViewModel.addOpenFile(url)
                getMainMenuController().updateRecentsMenu(with: url)
                
                if let mainWindow = getMainWindowController().window {
                    mainWindow.title = url.lastPathComponent
                    mainWindow.representedURL = url
                    return
                }
            }
        }
    }
    
    /**
     Checks if the dataSource for the provided tab needs saving and prompts to save if so.
     Then selects the existing tab if the file requested was loaded already.
    */
    func checkIfFileNeedsSaving(in tabItem: NSTabViewItem?) {
        if  let bmtVC = tabItem?.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource {
            switch dataSource.needsSaving {
            case true:
                saveFileForDataSource(dataSource, tableView: bmtVC.tableView)
            case false:
                break
            }
            if let tabItem = tabItem {
                selectTabForExistingFile(tabItem: tabItem)
            }
        }
    }
    
    /**
     Loads a valid BMT file from a URL
     */
    @objc func loadBMTFromURL(_ url: URL)
    {
        infoPrint("", #function, self.className)
        let tabItem = tabOfFileWithURL(url)
        let fileIsLoaded = tabItem != nil
        if !fileIsLoaded {
            loadFileAtURL(url, reverting: false)
        }
        else {
            checkIfFileNeedsSaving(in: tabItem)
        }
        if  let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController {
            let view = bmtVC.view
            view.isHidden = false
        }
    }
    
    /**
     If url is a file, calls the loadBMTFromURL function to load it.
     If url is a directory it recurses through each file in it calling itself to load it or continue into the directory and repeat.
     - Parameter url: URL of a file or directory
     */
    func loadRequestedUrl(_ url: URL) {
        infoPrint(nil,#function, self.className)
        
        let fileManager = PJFileManager()
        switch fileManager.checkFileValidity(at: url) {
        case .validDir:
            do {
                let fileList = try fileManager.contentsOfDirectory(atPath: url.path)
                for file in fileList {
                    let subUrl = URL(fileURLWithPath: "\(url.path)/\(file)")
                    loadRequestedUrl(subUrl)
                }
            } catch let error {
                print(error)
            }
        case .validFile:
            loadBMTFromURL(url)
        default:
            break
        }
    }
    
    @objc func openRecentFile(url: URL) {
        infoPrint(nil,#function, self.className)
        loadRequestedUrl(url)
        NotificationCenter.default.post(name: .startBuildWordTypeMenu, object:nil)
        
        /*if let menuController = getWordTypeMenuController() {
            menuController.buildWordTypeMenu()
        }*/
        //NotificationCenter.default.post(name: .startPopulateLessonsPopup, object: nil)
    }
    
    @objc func openRecentFiles() {
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            if let url = appDelegate.autoOpenUrl {
                loadRequestedUrl(url)
                NotificationCenter.default.post(name: .buildWordTypeMenu, object:nil)
                
                /*if let menuController = getWordTypeMenuController() {
                    menuController.buildWordTypeMenu()
                }*/
                NotificationCenter.default.post(name: .populateLessonsPopup, object: nil)
                return
            }
        }
        let userDefaults = UserDefaults.standard
        let openMostRecent = userDefaults.bool(forKey: UserDefaults.Keys.OpenMostRecentAtStart)
        if openMostRecent {
            // Open the most recent file in the recent files menu
            let fileToOpen = getMainWindowController().mainMenuController.recentFiles[0]
            loadRequestedUrl(fileToOpen)
            print ("posting buildwtm")
            NotificationCenter.default.post(name: .startBuildWordTypeMenu, object:nil)
            
            /*if let menuController = getWordTypeMenuController() {
                menuController.buildWordTypeMenu()
            }*/
            NotificationCenter.default.post(name: .populateLessonsPopup, object: nil)
            
        }
    }
    
    /*func loadedIndexForUrl(_ url: URL)->Int {
        infoPrint("", #function, self.className)
        if let controller = self.controller {
            var dataSourceIndex = -1
            var foundFile = false
            for dataSource in controller.wordsTabViewController.dataSources {
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
        return -1
    }*/
    
    func loadDataSource(_ dataSource: TableViewDataSource, into tabItem: NSTabViewItem)
    {
        infoPrint("", #function, self.className)
        
        if let name = dataSource.sourceFile?.path.lastPathComponent {
            tabItem.label = name
        }
        if  let bmtVC = tabItem.viewController as? BMTViewController,
            let tableView = bmtVC.tableView as? PJTableView {
            bmtVC.bmtViewModel.dataSource = dataSource
            tableView.dataSource = dataSource
            tableView.delegate = dataSource
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
    
    @objc func loadWordsFromFile(_ fileURL: URL, into dataSource: TableViewDataSource)->TableViewDataSource?
    {
        // Load the words file from the URL into the designated dataSource
        infoPrint("", #function, self.className)
        switch PJFileManager().checkFileValidity(at: fileURL) {
        case .validFile:
            if let lessonEntryDictionariesNSA  = NSArray(contentsOf: fileURL) {
                _ = dataSource.dataSourceViewModel.removeAllLessonEntries()
                dataSource.sourceFile = URL(fileURLWithPath: fileURL.path)
                for lessonEntryDictionary : Any in lessonEntryDictionariesNSA {
                    if let lessonEntryDict = lessonEntryDictionary as? Dictionary<String,String> {
                        let lessonEntry = LessonEntry(lessonEntryDictionary:lessonEntryDict)
                        dataSource.dataSourceViewModel.appendLessonEntry(lessonEntry)
                    }
                }
            }
        default:
            let warningAlert = Alerts().warningAlert
            warningAlert.messageText = "Unable to load file at: \(fileURL)."
            warningAlert.runModal()
        }
        return dataSource
    }
    
    @objc func openDocument(_ aNotification: Notification) {
        
        infoPrint(nil,#function, self.className)
        
        let openDocumentPanel = Panels().openBMTDocPanel
        let openDocumentResult = openDocumentPanel.runModal()
        
        switch openDocumentResult {
        case NSApplication.ModalResponse.OK:
            // Try to load the file into a new tab
            for url in openDocumentPanel.urls {
                loadRequestedUrl(url)
            }
            //case NSApplication.ModalResponse.cancel:
        //    break
        default:
            return
        }
        NotificationCenter.default.post(name: .startBuildWordTypeMenu, object:nil)
        
        /*if let menuController = getWordTypeMenuController() {
            menuController.buildWordTypeMenu()
        }*/
        // Populate the lessons popup menu
        NotificationCenter.default.post(name: .populateLessonsPopup, object:nil)
        
        if  let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController {
            let view = bmtVC.view
            view.isHidden = false
        }
    }
}

class BMTFileManager: PJFileManager {

    weak var controller : WordsViewController?
    
    fileprivate func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.openRecentFiles), name: .loadRecentFiles, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openDocument(_:)), name: .openDocument, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeDocument(_:)), name: .closeDocument, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveDocument(_:)), name: .saveDocument, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveDocumentAs(_:)), name: .saveDocumentAs, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeAllFiles(_:)), name: .closeAllFiles, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.revertToSaved(_:)), name: .revertToSaved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createNewDocument(_:)), name: .createNewDocument, object: nil)
    }
    
    init(controller: WordsViewController) {
        self.controller = controller
        super.init()
        createObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
