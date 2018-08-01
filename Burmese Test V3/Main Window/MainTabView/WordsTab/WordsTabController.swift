//
//  WordsTabController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static var loadRecentFiles: Notification.Name {
        return .init(rawValue: "WordsTabController.loadRecentFiles")
    }
    
    static var openRecentFile: Notification.Name {
        return .init(rawValue: "WordsTabController.openRecentFile")
    }
    
    static var openDocument: Notification.Name {
        return .init(rawValue: "WordsTabController.openDocument")
    }
    
    static var closeDocument: Notification.Name {
        return .init(rawValue: "WordsTabController.closeDocument")
    }
    
    static var saveDocumentAs: Notification.Name {
        return .init(rawValue: "WordsTabController.saveDocumentAs")
    }
    
    static var closeAllFiles: Notification.Name {
        return .init(rawValue: "WordsTabController.closeAllFiles")
    }
    
}

extension WordsTabController {
    
    fileprivate func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.openRecentFiles), name: .loadRecentFiles, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openRecentFile(_:)), name: .openRecentFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openDocument(_:)), name: .openDocument, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeDocument(_:)), name: .closeDocument, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveDocumentAs(_:)), name: .saveDocumentAs, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeAllFiles(_:)), name: .closeAllFiles, object: nil)
    }
    
    @objc func closeAllFiles(_ aNotification: Notification) {
        for tabNum in (0..<self.wordsTabViewController.tabViewItems.count).reversed()
        {
            self.wordsTabViewController.tabView.selectTabViewItem(at:tabNum)
            _ = self.closeDocument(self)
        }
        getMainWindowController().close()
    }
    
    @objc func closeDocument(_ sender: Any?)->Bool {
        infoPrint("",#function,self.className)
        if  let wordsTabVC = self.wordsTabViewController,
            let currentTabItem = wordsTabVC.tabView.selectedTabViewItem {
            let index = wordsTabVC.tabView.indexOfTabViewItem(currentTabItem)
        
            if index != -1 {
                let dataSource = wordsTabVC.dataSources[index]
                
                if wordsTabVC.dataSources.count != 0 {
                    // Check if the file needs saving first
                    
                    if dataSource.needsSaving {
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
                                _ = getMainWindowController().mainFileManager.saveWordsToFile(sourceFile)
                            }
                            else {
                                // File has never been saved
                                self.saveDocumentAs(Notification(name: .saveDocumentAs))
                                if dataSource.needsSaving {
                                    return false
                                }
                            }
                        case NSApplication.ModalResponse.alertSecondButtonReturn:
                            print("Cancelled")
                            return false
                        case NSApplication.ModalResponse.alertThirdButtonReturn:
                            print("Not saved")
                        default:
                            print("Unhandled alert response \(alertResult)")
                            return false
                        }
                    }
                    var foundAt = -1
                    for openFileNum in 0..<self.openFiles.count {
                            
                        if let sourceFile = dataSource.sourceFile {
                            if self.openFiles[openFileNum] == sourceFile {
                                foundAt = openFileNum
                            }
                        }
                    }
                    if foundAt != -1 {
                        self.openFiles.remove(at: foundAt)
                    }
                    if wordsTabVC.dataSources.count != 1
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
                        
                    }
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
                    if nextTab != -1 {
                        wordsTabVC.tabView.selectTabViewItem(at: nextTab)
                    }
                    
                    if wordsTabVC.dataSources.count == 1 {// && wordsTabViewController.dataSources[0].sourceFile == nil {
                        wordsTabVC.dataSources[0].sourceFile = nil
                        if let first = wordsTabVC.tabViewItems.first,
                            let view = first.view {
                            view.isHidden = true
                            first.label = "Nothing Loaded"
                        }
                        NotificationCenter.default.post(name: .disableFileMenuItems, object: nil)
                    }
                    else {
                        if index == 0 {
                            self.removingFirstItem = true
                        }
                        else {
                            self.removingFirstItem = false
                        }
                        // FIXME: Not sure if this bit is needed now
                        
                        /*let wordsTabViewController = appDelegate.viewControllers.wordsTabViewController
                         //wordsTabView.removeTabViewItem(wordsTabView.tabViewItem(at: index))
                         wordsTabViewController?.tabViewItems.remove(at: index)
                         appDelegate.viewControllers.wordsTabViewController.wordsTabViewControllers.remove(at:index)*/
                        self.removingFirstItem = false
                    }
                }
            }
            // FIXME: needs enabling once function exists
            //self.buildWordTypeMenu()
            if wordsTabVC.dataSources[0].sourceFile == nil {
                NotificationCenter.default.post(name: .disableFileMenuItems, object: nil)
            }
            return true
        }
        return false
    }
    
    @objc func openDocument(_ aNotification: Notification) {
        
        infoPrint(nil,#function, self.className)
        
        let openDocumentPanel = openBMTDocPanel
        let openDocumentResult = openDocumentPanel.runModal()
        
        switch openDocumentResult {
        case NSApplication.ModalResponse.OK:
            // Try to load the file into a new tab
            for url in openDocumentPanel.urls {
                if PJFileManager().fileExists(atPath: url.path) {
                    loadRequestedUrl(url)
                }
            }
            //case NSApplication.ModalResponse.cancel:
        //    break
        default:
            return
        }
        if let menuController = getWordTypeMenuController() {
            menuController.buildWordTypeMenu()
        }
        // Populate the lessons popup menu
        NotificationCenter.default.post(name: .populateLessonsPopup, object:nil)
        
        let view = getWordsTabViewDelegate().tabViewControllersList[getCurrentIndex()].view
        view.isHidden = false
    }
    
    @objc func openRecentFiles() {
        let userDefaults = UserDefaults.standard
        let openMostRecent = userDefaults.bool(forKey: "OpenMostRecentAtStart")
        if openMostRecent {
            // Open the most recent file in the recent files menu
            let fileToOpen = getMainWindowController().mainMenuController.recentFiles[0]
            loadRequestedUrl(fileToOpen)
            if let menuController = getWordTypeMenuController() {
                menuController.buildWordTypeMenu()
            }
            NotificationCenter.default.post(name: .populateLessonsPopup, object: nil)
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
}

// MARK: File Saving

extension WordsTabController {
    
    func saveFileForDataSource(_ dataSource : TableViewDataSource, at index: Int) {
        infoPrint("", #function, self.className)
        
        if let url = dataSource.sourceFile {
            let alertResponse = requestToRevertDataSource(dataSource: dataSource)
            switch alertResponse {
            case .alertFirstButtonReturn:
                self.loadFileAtURL(url, reverting: true )
                dataSource.needsSaving = false
                getWordsTabViewDelegate().tabViewControllersList[index].tableView.reloadData()
            case .alertSecondButtonReturn:
                print("Cancelled")
            default:
                print("Unhandled alert response \(alertResponse)")
            }
        }
    }
    
    @objc func saveDocumentAs(_ aNotification: Notification)->Bool {
        infoPrint("", #function, self.className)
        
        let index = getCurrentIndex()
        let wordsTabController = getWordsTabViewDelegate()
        let dataSource = wordsTabController.dataSources[index]
        
        switch index {
        case -1:
            break
        default:
            //  FIXME: Stuff about searchfielddelegate
            /*if let _ = appDelegate.dataSources![index].unfilteredWords
             {
             appDelegate.searchFieldDelegate.searchField.stringValue = ""
             appDelegate.searchFieldDelegate.performFind(appDelegate.searchFieldDelegate.searchField)
             }*/
            
            let savePanel = Panels().saveDocumentPanel
            let fileNameToSave = wordsTabController.tabViewItems[index].label
            if fileNameToSave.left(1) != "*" {
                savePanel.nameFieldStringValue = fileNameToSave
            }
            else {
                let fileNameToSave = fileNameToSave.minus(2)
                savePanel.nameFieldStringValue = fileNameToSave
            }
            savePanel.directoryURL = wordsTabController.dataSources[index].sourceFile?.deletingLastPathComponent()
            let saveDocumentResult = savePanel.runModal()
            
            switch saveDocumentResult {
            case NSApplication.ModalResponse.OK:
                // try to save the file
                if let url = savePanel.url
                {
                    if let fileManager = getMainWindowController().mainFileManager {
                        let saveResult = fileManager.saveWordsToFile(url)
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

// MARK: File Loading
extension WordsTabController {
    
    func loadedIndexForUrl(_ url: URL)->Int {
        infoPrint("", #function, self.className)
        
        var dataSourceIndex = -1
        var foundFile = false
        for dataSource in self.wordsTabViewController.dataSources {
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
    
    @objc func loadWordsFromFile(_ fileURL: URL, into dataSource: TableViewDataSource)->TableViewDataSource?
    {
        // Load the words file from the URL into the designated dataSource
        infoPrint("", #function, self.className)
        switch PJFileManager().checkFileValidity(at: fileURL) {
        case .validFile:
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
        default:
            let warningAlert = Alerts().warningAlert
            warningAlert.messageText = "Unable to load file at: \(fileURL)."
            warningAlert.runModal()
        }
        return dataSource
    }
    
    /**
     Loads a BMT file into a datasource
     - Parameter fileURL    : URL for the file to load
     - Parameter dataSource : The datasource to load it into.
     - Returns: A datasource with the file contents loaded into it.
     */
    
    func setUpNewBMTFor(_ dataSource : TableViewDataSource, with url: URL) {
        
        infoPrint("", #function, self.className)
        
        let tabViewController = getWordsTabViewDelegate()
        tabViewController.dataSources.append(dataSource)
        let BMTvc = BMTViewController()
        let view = BMTvc.view
        if let tableView = view.viewWithTag(100) as? NSTableView {
            if let dataSource = tabViewController.dataSources.last {
                tableView.dataSource = dataSource
                tableView.delegate = dataSource
            }
        }
        tabViewController.tabViewControllersList.append(BMTvc)
        let newTabViewItem = NSTabViewItem()
        newTabViewItem.label = url.path.lastPathComponent
        newTabViewItem.viewController = BMTvc
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
        let dataSource = self.wordsTabViewController.dataSources[0]
        if dataSource.sourceFile == nil {
            if let newDataSource = self.loadWordsFromFile(url, into: dataSource) {
                loadDataSource(newDataSource, at: 0)
                selectWordsTab()
                NotificationCenter.default.post(name: .enableFileMenuItems, object: nil)
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
                let wordsTabView = self.wordsTabViewController.tabView
                if let newDataSource = self.loadWordsFromFile(url, into: TableViewDataSource()) {
                    switch reverting {
                    case true:
                        //Revert the file
                        loadDataSource(newDataSource, at: dataSourceIndex)
                        selectTabForExistingFile(at: dataSourceIndex)
                    case false:
                        if self.wordsTabViewController.dataSources.count == 0 {
                            if let tableView = wordsTabViewController.tabViewControllersList[0].tableView {
                                //newDataSource.sortTable(tableView, sortBy: newDataSource.sortBy)
                                tableView.dataSource = nil
                                tableView.delegate = nil
                                wordsTabViewController.dataSources.append(TableViewDataSource())
                                loadDataSource(newDataSource, at: 0)
                                if let BMTvc =  wordsTabViewController.tabViewItems.first?.viewController as? BMTViewController {
                                    wordsTabViewController.tabViewControllersList.append(BMTvc)
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
    
    func fileAlreadyLoaded(_ url: URL)-> (Bool, Int) {
        infoPrint("", #function, self.className)
        var loadedAtIndex = -1
        let tabView = self.wordsTabViewController.tabView
        if let currentTabItem = tabView.selectedTabViewItem {
            let index = tabView.indexOfTabViewItem(currentTabItem)
            if let tabViewDelegate = self.wordsTabViewController {
                for dataSource in tabViewDelegate.dataSources {
                    loadedAtIndex = loadedAtIndex + 1
                    if dataSource.sourceFile == url {
                        return (true, loadedAtIndex)
                    }
                }
            }
        }
        return (false, -1)
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
    
    @objc func loadBMTFromURL(_ url: URL)
    {
        infoPrint("", #function, self.className)
        
        let result = fileAlreadyLoaded(url)
        let loaded = result.0
        let indexOfLoadedFile = result.1
        if !loaded {
            loadFileAtURL(url, reverting: false)
        }
        else {
            // If the file needs saving ask the user to confirm the save before loading the file
            
            let dataSource = wordsTabViewController.dataSources[indexOfLoadedFile]
            switch dataSource.needsSaving {
            case true:
                saveFileForDataSource(dataSource, at: indexOfLoadedFile)
                fallthrough
            case false:
                selectTabForExistingFile(at: indexOfLoadedFile)
            }
        }
        let view = getWordsTabViewDelegate().tabViewControllersList[0].view
        view.isHidden = false
    }
    
    @objc func loadFileFromURL(_ url: URL)
    {
        infoPrint("", #function, self.className)
        // Test to see if it's a valid file
        switch PJFileManager().checkFileValidity(at: url) {
        case .invalidNotBMT,
             .invalidNotThere:
            return
        default:
            break
        }
        let result = fileAlreadyLoaded(url)
        let loaded = result.0
        let loadedAtIndex = result.1
        if !loaded {
            loadFileAtURL(url, reverting: false)
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
    
    @objc func openRecentFile(_ aNotification : Notification) {
        infoPrint(nil,#function, self.className)
        if  let userInfo = aNotification.userInfo,
            let sender = userInfo["sender"] as? NSMenuItem {
            var count = 0
            if let menu = sender.menu {
                for menuItem in menu.items {
                    if menuItem == sender {
                        break
                    }
                    count = count + 1
                }
            }
            
            let url = getMainMenuController().recentFiles[count]
            self.loadRequestedUrl(url)
            if let menuController = getWordTypeMenuController() {
                menuController.buildWordTypeMenu()
            }
            NotificationCenter.default.post(name: .populateLessonsPopup, object: nil)
        }
    }
}

class WordsTabController: NSViewController {

    @IBOutlet var wordsTabViewController : WordsTabViewController!
    
    var removingFirstItem : Bool = false
    
    var openBMTDocPanel : NSOpenPanel {
        let newOpenPanel = NSOpenPanel()
        newOpenPanel.canChooseFiles = true
        newOpenPanel.canChooseDirectories = true
        newOpenPanel.canCreateDirectories = true
        newOpenPanel.allowsMultipleSelection = true
        newOpenPanel.prompt = "Select"
        return newOpenPanel
    }
    
    /**
     Holds the currently open files. When changed saves to userdefaults.
     */
    var openFiles = [URL]() {
        didSet(oldValue) {
            infoPrint("changed from: \(oldValue) to: \(self.openFiles)", #function, self.className)
            let data = NSKeyedArchiver.archivedData(withRootObject: self.openFiles)
            UserDefaults.standard.set(data, forKey: "OpenFiles")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        createObservers()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
