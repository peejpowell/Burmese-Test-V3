//
//  WordTypeMenuControllerObservers.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 04/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

// MARK: Notification Names

extension Notification.Name {
    
    static var buildWordTypeMenuForTab: Notification.Name {
        return .init(rawValue: "WordTypeMenuController.buildWordTypeMenuForTab")
    }
    
    static var startBuildWordTypeMenu: Notification.Name {
        return .init(rawValue: "WordTypeMenuController.startBuildWordTypeMenu")
    }
}

// MARK: Notification Observers

extension WordTypeMenuController {
    
    @objc func startBuildWordTypeMenu(_ notification: Notification) {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .buildWordTypeMenu, object:nil, userInfo: [UserInfo.Keys.menu : self.wordTypeMenu])
    }
    
    @objc func buildWordTypeMenuForTab(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if  let userInfo = notification.userInfo,
            let tabItem = userInfo[UserInfo.Keys.tabItem] as? NSTabViewItem,
            let bmtVC = tabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource,
            let sourceFile = dataSource.sourceFile {
            
            let title = sourceFile.lastPathComponent
            for item in wordTypeMenu.items {
                if item.title == title {
                    wordTypeMenu.removeItem(item)
                    break
                }
            }
            let newMenuItem = NSMenuItem()
            newMenuItem.title = sourceFile.lastPathComponent
            newMenuItem.action = #selector(self.toggleCurrent(_:))
            newMenuItem.target = self
            wordTypeMenu.insertItem(newMenuItem, at: wordTypeMenu.items.count-3)
            newMenuItem.submenu = self.populateWordTypes(dataSource)
            
            // Set the words by the list of selectedWords
            
            for item in self.wordTypeMenu.items {
                // Find the item in the list of selectedWords
                for selectedWordType in self.selectedLessonTypes {
                    if selectedWordType.lessonName == item.title {
                        for item in item.submenu!.items {
                            for word in selectedWordType.selectedLessons {
                                if word == item.title {
                                    item.state = .on
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(buildWordTypeMenuForTab(_:)), name: .buildWordTypeMenuForTab, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startBuildWordTypeMenu(_:)), name: .startBuildWordTypeMenu, object: nil)
    }
    
}
