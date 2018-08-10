//
//  MainMenuController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 27/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class MainMenuController: MenuController {
    
    // MARK: Properties
    let totalRecentFiles = 5
    var updatingRecentsMenu = false
    var removingFirstItem = false
    var recentFiles: [URL] = [] {
        didSet(oldValue) {
            cleanupRecentFilesMenu()
        }
    }
 
    // MARK: Outlets
    
    @IBOutlet var mainMenu : NSMenu!
    @IBOutlet var recentFilesMenu : NSMenu!
    @IBOutlet var closeWordsFileMenuItem : NSMenuItem!
    @IBOutlet var saveFileMenuItem : NSMenuItem!
    @IBOutlet var saveAsFileMenuItem : NSMenuItem!
    @IBOutlet var revertMenuItem : NSMenuItem!
    
    @IBOutlet var languageMenuController : LanguageMenuController!
    @IBOutlet var lessonTypeMenuController : WordTypeMenuController!
    
    // MARK: Functions
    
    override func awakeFromNib() {
        infoPrint("", #function, self.className)
        super.awakeFromNib()
        self.createObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Recent Files Menu
extension MainMenuController {
    
    func cleanupRecentFilesMenu() {
        if !updatingRecentsMenu {
            infoPrint("", #function, self.className)
        }
        if updatingRecentsMenu {
           return
        }
        if recentFiles.count > totalRecentFiles {
            trimRecentFiles(to: totalRecentFiles)
        }
        if recentFiles.count > 0 {
            recentFilesMenu.items.last?.isEnabled = true
            recentFilesMenu.items.last?.target = self
            recentFilesMenu.items.last?.action = #selector(clearRecentFiles)
        }
        else {
            recentFilesMenu.items.last?.isEnabled = false
            clearRecentFilesMenu()
        }
    }
    
    @objc func clearRecentFilesMenu() {
        for _ in 0..<recentFilesMenu.items.count-2 {
            recentFilesMenu.removeItem(at: 0)
        }
        recentFilesMenu.items.last?.isEnabled = false
    }
    
    @objc func clearRecentFiles() {
        recentFiles.removeAll()
        saveRecentFiles()
    }
    
    @objc func openRecentFile(_ sender: NSMenuItem) {
        var count = 0
        if let menu = sender.menu {
            for menuItem in menu.items {
                if menuItem == sender {
                    break
                }
                count = count + 1
            }
            let url = recentFiles[count]
            NotificationCenter.default.post(name: .openRecentFile, object: nil, userInfo: ["url" : url])
        }
    }
    
    func recentFilesContainsUrl(_ url: URL)->Int {
        var foundAtIndex = -1
        for recentUrl in self.recentFiles {
            foundAtIndex += 1
            if recentUrl == url {
                return foundAtIndex
            }
        }
        return -1
    }
    
    func moveFoundUrlToTop(at index: Int) {
        let url = self.recentFiles.remove(at: index)
        self.recentFiles.insert(url, at: 0)
        let menuItem = self.recentFilesMenu.items[index]
        menuItem.image = loadIconFrom(url.path)
        if let image = menuItem.image {
            image.size = NSSize(width: 16,height: 16)
        }
        self.recentFilesMenu.removeItem(at: index)
        self.recentFilesMenu.insertItem(menuItem, at:0)
    }
    
    func insertNewUrlAtTop(_ url: URL) {
        self.recentFiles.insert(url, at: 0)
        let newMenuItem = NSMenuItem(title: "\(url.lastPathComponent)", action: #selector(self.openRecentFile(_:)), keyEquivalent: "")
        newMenuItem.target = self
        newMenuItem.image = loadIconFrom(url.path)
        if let image = newMenuItem.image {
            image.size = NSSize(width: 16,height: 16)
        }
        self.recentFilesMenu.insertItem(newMenuItem, at: 0)
    }
    
    func trimRecentFiles(to totalUrls: Int) {
        if self.recentFilesMenu.items.count > totalUrls {
            self.recentFilesMenu.removeItem(at: self.recentFilesMenu.items.count-3)
            self.recentFiles.remove(at: self.recentFiles.count-1)
        }
    }
    
    func saveRecentFiles() {
        let userDefaults = UserDefaults.standard
        let recentData = NSKeyedArchiver.archivedData(withRootObject: self.recentFiles)
        userDefaults.set(recentData, forKey: UserDefaults.Keys.RecentFiles)
    }
    
    func updateRecentsMenu(with url: URL)
    {
        infoPrint(nil,#function, self.className)
        updatingRecentsMenu = true
        let indexOfUrl = recentFilesContainsUrl(url)
        switch indexOfUrl > -1 {
        case true:
            moveFoundUrlToTop(at: indexOfUrl)
        case false:
            insertNewUrlAtTop(url)
        }
        saveRecentFiles()
        updatingRecentsMenu = false
        cleanupRecentFilesMenu()
    }
    
    func rebuildRecentFilesMenu() {
        let numItems = recentFilesMenu.items.count
        var bottomItems : [NSMenuItem] = []
        for itemNum in numItems-2..<numItems {
            bottomItems.append(recentFilesMenu.items[itemNum])
        }
        recentFilesMenu.removeAllItems()
        for item in bottomItems {
            recentFilesMenu.addItem(item)
        }
        buildRecentFilesMenu()
    }
    
    func buildRecentFilesMenu() {
        infoPrint("", #function, self.className)
        for url in self.recentFiles {
            let newMenuItem = NSMenuItem(title: "\(url.lastPathComponent)", action: #selector(MainMenuController.openRecentFile(_:)), keyEquivalent: "")
            newMenuItem.target = self
            let iconPath = url.path
            
            newMenuItem.image = loadIconFrom(iconPath)
            if let image = newMenuItem.image {
                image.size = NSSize(width: 16, height: 16)
            }
            
            self.recentFilesMenu.insertItem(newMenuItem, at: self.recentFilesMenu.items.count-2)
        }
        
    }
    
    func loadRecentFiles(_ userDefaults: UserDefaults) {
        infoPrint("", #function, self.className)
        
        if let savedRecentFiles = userDefaults.value(forKey: UserDefaults.Keys.RecentFiles) as? Data {
            let recentFiles = NSKeyedUnarchiver.unarchiveObject(with: savedRecentFiles)
            
            if let recentFiles = recentFiles as? [URL] {
                self.recentFiles = recentFiles
            }
            buildRecentFilesMenu()
        }
    }
}

// MARK: First Responder Actions

// MARK: -- App Menu
extension MainMenuController {
    
    @IBAction func openPreferences(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .openPrefsWindow, object: nil)
    }
    
}

// MARK: -- File Menu
extension MainMenuController {
    
    @IBAction func newDocument(_ sender: Any?) {
        infoPrint("", #function, self.className)
        // Post a newDocument notification for the WordsTabViewController to respond to
        NotificationCenter.default.post(name: .createNewDocument, object: nil)
    }
    
    @IBAction func openDocument(_ sender: Any?) {
        NotificationCenter.default.post(name: .openDocument, object: nil)
    }
    
    
    @IBAction func saveDocument(_ sender: Any?) {
        NotificationCenter.default.post(name: .saveDocument, object: nil)
    }
    
    @IBAction func revertDocumentToSaved(_ sender: Any?) {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .revertToSaved, object: nil)
    }
    
    @IBAction func saveDocumentAs(_ sender: Any?) {
        NotificationCenter.default.post(name: .saveDocumentAs, object: nil)
    }
    
    @IBAction func performClose(_ sender: Any?) {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .closeDocument, object: nil)
    }
}

// MARK: -- Edit Menu
extension MainMenuController {
    
    func cut(_ sender: Any?)
    {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .cutRows, object: nil)
    }
    
    func copy(_ sender: Any?)
    {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .copyRows, object: nil)
    }
    
    func paste(_ sender: Any?)
    {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .pasteRows, object: nil)
    }
}

// MARK: ---- Find Menu
extension MainMenuController {
    
    @IBAction func performFindPanelAction(_ sender: Any?){
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .findClicked, object:nil, userInfo:[UserInfo.Keys.any:sender as Any])
    }
}
