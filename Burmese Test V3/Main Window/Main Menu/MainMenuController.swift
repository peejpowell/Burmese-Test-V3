//
//  MainMenuController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 27/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static var enableFileMenuItems: Notification.Name {
        return .init(rawValue: "MainMenuController.enableFileMenuItems")
    }
    
    static var disableFileMenuItems: Notification.Name {
        return .init(rawValue: "MainMenuController.disableFileMenuItems")
    }
    
    static var enableRevert: Notification.Name {
        return .init(rawValue: "ManMenuController.enableRevert")
    }
    
    static var disableRevert: Notification.Name {
        return .init(rawValue: "ManMenuController.disableRevert")
    }
}

class MainMenuController: MenuController {
    
    var recentFiles: [URL] = []
    
    @IBOutlet var mainMenu : NSMenu!
    @IBOutlet var recentFilesMenu : NSMenu!
    @IBOutlet var closeWordsFileMenuItem : NSMenuItem!
    @IBOutlet var saveFileMenuItem : NSMenuItem!
    @IBOutlet var saveAsFileMenuItem : NSMenuItem!
    @IBOutlet var revertMenuItem : NSMenuItem!
    
    var removingFirstItem = false
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.enableFileMenuItems(_:)), name: .enableFileMenuItems, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.disableFileMenuItems(_:)), name: .disableFileMenuItems, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.enableRevert(_:)), name: .enableRevert, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.disableRevert(_:)), name: .disableRevert, object: nil)
    }
    
    @objc func enableRevert(_ notification: Notification) {
        self.revertMenuItem.isEnabled = true
    }
    
    @objc func disableRevert(_ notification: Notification) {
        self.revertMenuItem.isEnabled = false
    }
    
    @objc func enableFileMenuItems(_ notification: Notification) {
        self.closeWordsFileMenuItem.isEnabled = true
        self.saveFileMenuItem.isEnabled = true
        self.saveAsFileMenuItem.isEnabled = true
    }
    
    @objc func disableFileMenuItems(_ notification: Notification) {
        self.closeWordsFileMenuItem.isEnabled = false
        self.saveFileMenuItem.isEnabled = false
        self.saveAsFileMenuItem.isEnabled = false
        self.revertMenuItem.isEnabled = false
    }
    
    
    
    @objc func openRecentFile(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .openRecentFile, object: nil, userInfo: ["sender":sender])
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
            let newMenuItem = NSMenuItem(title: "\(url.lastPathComponent)", action: #selector(self.openRecentFile(_:)), keyEquivalent: "")
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
        NotificationCenter.default.post(name: .loadRecentFiles, object: nil)
        self.createObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainMenuController {
    // MARK: First Responder Actions
    // MARK: -- File Menu
    
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
    
    func buildRecentFilesMenu() {
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
    
    @IBAction func performFindPanelAction(_ sender: Any?){
        infoPrint("", #function, self.className)
       
        let index = getCurrentIndex()
        getWordsTabViewDelegate().tabViewControllersList[index].textFinderClient.performTextFinderAction(sender)
    }
    
    @IBAction func openPreferences(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .openPrefsWindow, object: nil)
    }
    
}
