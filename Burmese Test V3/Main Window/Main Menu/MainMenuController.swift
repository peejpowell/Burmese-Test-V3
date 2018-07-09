//
//  MainMenuController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 27/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class MainMenuController: MenuController {
    
    var recentFiles: [URL] = []
    var openBMTDocPanel : NSOpenPanel {
        let newOpenPanel = NSOpenPanel()
        newOpenPanel.canChooseFiles = true
        newOpenPanel.canChooseDirectories = true
        newOpenPanel.canCreateDirectories = true
        newOpenPanel.allowsMultipleSelection = true
        newOpenPanel.prompt = "Select"
        return newOpenPanel
    }
    
    @IBOutlet var mainMenu : NSMenu!
    @IBOutlet var recentFilesMenu : NSMenu!
    @IBOutlet var closeWordsFileMenuItem : NSMenuItem!
    
    var removingFirstItem = false
    
    func loadRequestedUrl(_ url: URL)
    {
        infoPrint(nil,#function, self.className)
        
        let fileManager = PJFileManager()
        
        if fileManager.isDir(url) {
            do {
                let fileList = try fileManager.contentsOfDirectory(atPath: url.path)
                for file in fileList {
                    let subUrl = URL(fileURLWithPath: "\(url.path)/\(file)")
                    
                    fileManager.loadOrWarn(subUrl)
                }
            } catch let error {
                print(error)
            }
        }
        else {
            fileManager.loadOrWarn(url)
        }
    }
    
    @objc func openRecentFile(_ sender: NSMenuItem) {
        
        infoPrint(nil,#function, self.className)
        
        var count = 0
        if let menu = sender.menu {
            for menuItem in menu.items {
                if menuItem == sender {
                    break
                }
                count = count + 1
            }
        }
        
        let url = self.recentFiles[count]
        
        if let fileManager = getMainWindowController().mainFileManager
        {
            if fileManager.fileExists(atPath: url.path) {
                fileManager.loadOrWarn(url)
            }
        }
    }
    
    func updateRecentsMenu(with url: URL)
    {
        infoPrint(nil,#function, self.className)
        
        let userDefaults = UserDefaults.standard
        
        // Is the url already in recents?
        
        var foundUrl = false
        var foundAt = 0
        for recentUrl in self.recentFiles {
            if recentUrl == url {
                foundUrl = true
                break
            }
            foundAt = foundAt + 1
        }
        if !foundUrl {
            self.recentFiles.insert(url, at: 0)
            let newMenuItem = NSMenuItem(title: "\(url.lastPathComponent)", action: #selector(openRecentFile(_:)), keyEquivalent: "")
            newMenuItem.target = self
            let iconPath = url.path
            
            newMenuItem.image = loadIconFrom(iconPath)
            if let image = newMenuItem.image {
                image.size = NSSize(width: 16,height: 16)
            }
        
            self.recentFilesMenu.insertItem(newMenuItem, at: 0)
            if self.recentFilesMenu.items.count > 12 {
                self.recentFilesMenu.removeItem(at: self.recentFilesMenu.items.count-3)
                self.recentFiles.remove(at: self.recentFiles.count-1)
            //print("\(self.recentFiles)")
            }
        }
        else
        {
            // move the found url to the top
            let url = self.recentFiles.remove(at: foundAt)
            self.recentFiles.insert(url, at: 0)
            let menuItem = self.recentFilesMenu.items[foundAt]
            
            let iconPath = url.path
            
            menuItem.image = loadIconFrom(iconPath)
            if let image = menuItem.image
            {
                image.size = NSSize(width: 16,height: 16)
            }
            
            self.recentFilesMenu.removeItem(at: foundAt)
            self.recentFilesMenu.insertItem(menuItem, at:0)
        }
        
        let recentData = NSKeyedArchiver.archivedData(withRootObject: self.recentFiles)
        userDefaults.set(recentData, forKey: "RecentFiles")
        //userDefaults.set((appDelegate.prefsWindow.delegate as! PJPrefsWindowDelegate).openMostRecent.state, forKey: "OpenMostRecent")
    }

    override func awakeFromNib() {
        
        infoPrint("", #function, self.className)
        super.awakeFromNib()
        loadRecentFiles(UserDefaults.standard)
    }
}

extension MainMenuController {
    // MARK: First Responder Actions
    // MARK: -- File Menu
    
    @IBAction func openDocument(_ sender: Any?) {
        
        infoPrint(nil,#function, self.className)
        
        let openDocumentPanel = openBMTDocPanel
        let openDocumentResult = openDocumentPanel.runModal()
        
        switch openDocumentResult {
        case NSApplication.ModalResponse.OK:
            // Try to load the file into a new tab
            let fileManager = PJFileManager()
            
            for url in openDocumentPanel.urls {
                if fileManager.fileExists(atPath: url.path) {
                    if fileManager.isDir(url) {
                        do {
                            let fileList = try fileManager.contentsOfDirectory(atPath: url.path)
                            for file in fileList {
                                let subUrl = URL(fileURLWithPath: "\(url.path)/\(file)")
                                if !fileManager.fileIsInvalid(at: url) {
                                    fileManager.loadOrWarn(subUrl)
                                }
                                else {
                                    return
                                }
                            }
                        } catch let error {
                            print(error)
                        }
                    }
                    else {
                        if !fileManager.fileIsInvalid(at: url) {
                            fileManager.loadOrWarn(url)
                        }
                        else {
                            return
                        }
                    }
                }
            }
            
        case NSApplication.ModalResponse.cancel:
            break
        default:
            break
        }
        
        if let menuController = getWordTypeMenuController() {
            menuController.buildWordTypeMenu()
        }
        let view = getWordsTabViewDelegate().tabViewControllersList[getCurrentIndex()].view
        view.isHidden = false
    }
    
    var saveAlert : NSAlert {
        let alert = NSAlert()
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Don't Save")
        return alert
    }
    
    var saveDocumentPanel : NSSavePanel {
        let saveDocumentPanel = NSSavePanel()
        saveDocumentPanel.canCreateDirectories = true
        //saveDlg.setDirectory(self.prefs.filePath)
        saveDocumentPanel.allowedFileTypes = ["bmt"]
        saveDocumentPanel.allowsOtherFileTypes = false
        return saveDocumentPanel
    }
    
    @IBAction func saveDocumentAs(_ sender: Any?) {
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
            
            let savePanel = saveDocumentPanel
            savePanel.nameFieldStringValue = wordsTabController.tabViewItems[index].label
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
                            let alert = fileManager.warningAlert
                            alert.messageText = saveResult
                            alert.runModal()
                        return
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
            }
        }
    }
    
    @IBAction func performClose(_ sender: Any?) {
        infoPrint("", #function, self.className)
        _ = self.performCloseWordsFile(sender)
    }
    
    func performCloseWordsFile(_ sender: Any?)->Bool {
        infoPrint("",#function,self.className)
        
        let index = getCurrentIndex()
        let wordsTabViewController = getWordsTabViewDelegate()
        
        if index != -1 {
            let dataSource = wordsTabViewController.dataSources[index]
            
            if wordsTabViewController.dataSources.count != 0 {
                // Check if the file needs saving first
                
                if dataSource.needsSaving {
                    let alert = saveAlert
                    if let filetoSave = dataSource.sourceFile?.path.lastPathComponent {
                        alert.messageText = "Do you want to save the changes to \(filetoSave)?"
                    }
                    let alertResult = alert.runModal()
                    switch alertResult {
                    case NSApplication.ModalResponse.alertFirstButtonReturn:
                        print("Saved")
                        if let sourceFile = dataSource.sourceFile {
                            getMainWindowController().mainFileManager.saveWordsToFile(sourceFile)
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
                if let fileManager = getMainWindowController().mainFileManager {
                    for openFileNum in 0..<fileManager.openFiles.count {
                        
                        if let sourceFile = dataSource.sourceFile {
                            if fileManager.openFiles[openFileNum] == sourceFile {
                                foundAt = openFileNum
                            }
                        }
                    }
                    if foundAt != -1 {
                        fileManager.openFiles.remove(at: foundAt)
                    }
                    if wordsTabViewController.dataSources.count != 1
                    {
                        wordsTabViewController.tabViewControllersList.remove(at: index)
                        wordsTabViewController.dataSources.remove(at: index)
                    }
                    else
                    {
                        if let tableView = wordsTabViewController.tabViewControllersList[0].tableView {
                            tableView.dataSource = nil
                            tableView.delegate = nil
                        }
                        wordsTabViewController.dataSources.remove(at: 0)
                        wordsTabViewController.dataSources.append(TableViewDataSource())
                        //wordsTabViewController.tabViewControllersList[0].tableView = nil
                        wordsTabViewController.tabViewItems[0].label = "Nothing Loaded"
                        
                    }
                    let tabViewItem = wordsTabViewController.tabViewItems[index]
                    var nextTab = -1
                    
                    if  tabViewItem == wordsTabViewController.tabViewItems.last && tabViewItem != wordsTabViewController.tabViewItems.first {
                        nextTab = index-1
                    }
                    else {
                        nextTab = index
                    }
                    if wordsTabViewController.tabViewItems.count != 1 {
                        wordsTabViewController.tabViewItems.remove(at: index)
                    }
                    if nextTab != -1 {
                        wordsTabViewController.tabView.selectTabViewItem(at: nextTab)
                    }
                }
                
                if wordsTabViewController.dataSources.count == 1 && wordsTabViewController.dataSources[0].sourceFile == nil {
                    if let first = wordsTabViewController.tabViewItems.first,
                       let view = first.view {
                        view.isHidden = true
                        first.label = "Nothing Loaded"
                    }
                    
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
        if getWordsTabViewDelegate().dataSources[0].sourceFile == nil {
            getMainMenuController().closeWordsFileMenuItem.isEnabled = false
        }
        return true
    }
    
    func buildRecentFilesMenu()
    {
        infoPrint("", #function, self.className)
        
        for url in self.recentFiles{
            let newMenuItem = NSMenuItem(title: "\(url.lastPathComponent)", action: #selector(MainMenuController.openRecentFile(_:)), keyEquivalent: "")
            newMenuItem.target = self
            let iconPath = url.path
            
            newMenuItem.image = loadIconFrom(iconPath)
            if let image = newMenuItem.image
            {
                image.size = NSSize(width: 16, height: 16)
            }
            
            self.recentFilesMenu.insertItem(newMenuItem, at: self.recentFilesMenu.items.count-2)
        }
        
    }
    
    func loadRecentFiles(_ userDefaults: UserDefaults)
    {
        infoPrint("", #function, self.className)
        
        if let savedRecentFiles = userDefaults.value(forKey: "RecentFiles") as? Data {
            let recentFiles = NSKeyedUnarchiver.unarchiveObject(with: savedRecentFiles)
            
            if let recentFiles = recentFiles as? [URL] {
                self.recentFiles = recentFiles
            }
            buildRecentFilesMenu()
        }
    }
    
    func cut(_ sender: Any?)
    {
        infoPrint("", #function, self.className)
        
        getMainWindowController().mainClipboardController.moveToPasteBoard()
        
    }
    
    @IBAction func performFindPanelAction(_ sender: Any?){
        infoPrint("", #function, self.className)
       
        let index = getCurrentIndex()
        getWordsTabViewDelegate().tabViewControllersList[index].textFinderClient.performTextFinderAction(sender)
    }
    
    @IBAction func openPreferences(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .openPrefsWindow, object: nil)
    }
}
