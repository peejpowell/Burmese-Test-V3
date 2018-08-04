//
//  WordsTypeMenuController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 28/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa
extension Notification.Name {

    static var buildWordTypeMenuForTab: Notification.Name {
        return .init(rawValue: "WordTypeMenuController.buildWordTypeMenuForTab")
    }
    
    static var startBuildWordTypeMenu: Notification.Name {
        return .init(rawValue: "WordTypeMenuController.startBuildWordTypeMenu")
    }
}

// MARK: Observation Functions

extension WordTypeMenuController {
    
    func createObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(buildWordTypeMenuForTab(_:)), name: .buildWordTypeMenuForTab, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startBuildWordTypeMenu(_:)), name: .startBuildWordTypeMenu, object: nil)
    }
    
    @objc func startBuildWordTypeMenu(_ notification: Notification) {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .buildWordTypeMenu, object:nil, userInfo: [userInfoMenu : self.wordTypeMenu])
    }
    
    @objc func buildWordTypeMenuForTab(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if  let userInfo = notification.userInfo,
            let tabItem = userInfo[userInfoTab] as? NSTabViewItem,
            let bmtVC = tabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource,
            let sourceFile = dataSource.sourceFile {
            
            let newMenuItem = NSMenuItem()
            newMenuItem.title = sourceFile.lastPathComponent
            newMenuItem.action = #selector(self.toggleCurrent(_:))
            newMenuItem.target = self
            wordTypeMenu.insertItem(newMenuItem, at: wordTypeMenu.items.count-3)
            newMenuItem.submenu = self.populateWordTypes(dataSource)
            
            // Set the words by the list of selectedWords
            
            for item in self.wordTypeMenu.items {
                // Find the item in the list of selectedWords
                for selectedWordType in self.selectedWordTypes {
                    if selectedWordType.lessonName == item.title {
                        for item in item.submenu!.items {
                            for word in selectedWordType.selectedWords {
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
}

class SelectedWordTypes : NSObject, NSCoding {
    var lessonName : String = "" // Lesson name
    var selectedWords : [String] = [String]() // Checked items in the list
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(lessonName, forKey: "KLessonName")
        aCoder.encode(selectedWords, forKey: "KSelectedWords")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.lessonName = aDecoder.decodeObject(forKey: "KLessonName") as! String
        self.selectedWords = aDecoder.decodeObject(forKey: "KSelectedWords") as! [String]
    }
    
    override init() {
        super.init()
    }
}

class WordTypeMenuController: MenuController {

    enum UserInfoKey : String {
        case menu       = "menu"
        case tabItem    = "tabItem"
    }
    
    let userInfoTab = UserInfoKey.tabItem.rawValue
    let userInfoMenu = UserInfoKey.menu.rawValue
    
    @IBOutlet var wordTypeMenu : NSMenu!
    var selectedWordTypes : [SelectedWordTypes] = []
    
    func populateWordTypes(_ dataSource : TableViewDataSource) -> NSMenu
    {
        Swift.print(#function)
        
        var lastLesson : String = ""
        let newMenu = NSMenu()
        newMenu.title = dataSource.sourceFile!.lastPathComponent
        
        for word in dataSource.words {
            if lastLesson != word.lesson {
                if let name = word.lesson {
                    let newMenuItem = NSMenuItem(title: name, action: #selector(self.toggleCurrentWordType(_:)), keyEquivalent: "")
                    newMenuItem.target = self
                    newMenu.addItem(newMenuItem)
                }
            }
            if let name = word.lesson {
                lastLesson = name
            }
            else {
                lastLesson = ""
            }
        }
        newMenu.addItem(NSMenuItem.separator())
        let selectAllItem = NSMenuItem(title: "Select All", action: #selector(self.selectAll(_:)), keyEquivalent: "")
        selectAllItem.target = self
        newMenu.addItem(selectAllItem)
        
        let selectNoneItem = NSMenuItem(title: "Select None", action: #selector(self.selectNone(_:)), keyEquivalent: "")
        selectNoneItem.target = self
        newMenu.addItem(selectNoneItem)
        
        return newMenu
    }
    
    @IBAction func toggleCurrentWordType(_ sender: NSMenuItem)
    {
        self.toggleCurrent(sender)
        
        if let newLesson = sender.menu?.title {
            switch sender.state {
            case .on:
                
                var lessonExists = false
                for wordType in self.selectedWordTypes {
                    if wordType.lessonName == newLesson {
                        lessonExists = true
                        // Now add the new word type to the list
                        
                        var foundWord = false
                        for word in wordType.selectedWords {
                            if word == sender.title {
                                foundWord = true
                                break
                            }
                        }
                        if foundWord == false {
                            wordType.selectedWords.append(sender.title)
                        }
                    }
                }
                if !lessonExists
                {
                    let newSelectedWordType = SelectedWordTypes()
                    newSelectedWordType.lessonName = newLesson
                    newSelectedWordType.selectedWords.append(sender.title)
                    self.selectedWordTypes.append(newSelectedWordType)
                }
            case .off:
                break
                /*
                // Check if the lesson already exists in the list of lessons
                var lessonExists = false
                for wordType in self.selectedWordTypes
                {
                    if wordType.lessonName == newLesson
                    {
                        lessonExists = true
                        // Now remove the word type from the list
                        
                        var foundWord = false
                        var wordCount = 0
                        for word in wordType.selectedWords
                        {
                            if word == sender.title
                            {
                                foundWord = true
                                wordType.selectedWords.remove(at: wordCount)
                                break
                            }
                            wordCount = wordCount + 1
                        }
                    }
                }*/
            default:
                break
            }
        }
    }
    
    override func awakeFromNib() {
        infoPrint("", #function, self.className)
        super.awakeFromNib()
        self.createObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
