//
//  MainMenuController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 27/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

extension NSOpenPanel {
    
    func openBMTDocPanel()-> NSOpenPanel {
        let newOpenPanel = NSOpenPanel()
        newOpenPanel.canChooseFiles = true
        newOpenPanel.canChooseDirectories = true
        newOpenPanel.canCreateDirectories = true
        newOpenPanel.allowsMultipleSelection = true
        newOpenPanel.prompt = "Select"
        return newOpenPanel
    }
}

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
    
    @IBAction func openDocument(sender: NSMenuItem) {
        Swift.print(#function)
        
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
            }
            
        case NSApplication.ModalResponse.cancel:
            break
        default:
            break
        }
        
        if let menuController = getWordTypeMenuController() {
            menuController.buildWordTypeMenu()
        }
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
        }
        
        let url = self.recentFiles[count]
        
        let fileManager = PJFileManager()
        
        if fileManager.fileExists(atPath: url.path) {
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
            let newMenuItem = NSMenuItem(title: "\(url.lastPathComponent)", action: "openRecentFile:", keyEquivalent: "")
            newMenuItem.target = self
            let iconPath = url.path
            
            newMenuItem.image = loadIconFrom(iconPath)
            if let image = newMenuItem.image
            {
                image.size = NSSize(width: 16,height: 16)
            }
        
            self.recentFilesMenu.insertItem(newMenuItem, at: 0)
            if self.recentFilesMenu.items.count > 12
            {
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
    
}
