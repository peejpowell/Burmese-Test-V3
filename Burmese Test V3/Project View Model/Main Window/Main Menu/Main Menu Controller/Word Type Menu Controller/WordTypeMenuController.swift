//
//  WordsTypeMenuController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 28/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class WordTypeMenuController: MenuController {

    // MARK: Outlets
    @IBOutlet var wordTypeMenu : NSMenu!
    var selectedLessonTypes : [SelectedWordTypes] = []
    var buildingWordTypes : Bool = false
    var observersExist : Bool = false
    //MARK: Functions
    override func awakeFromNib() {
        infoPrint("", #function, self.className)
        super.awakeFromNib()
        if !observersExist {
            self.createObservers()
            observersExist = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        observersExist = false
    }
}

extension WordTypeMenuController {
    
    func populateWordTypes(_ dataSource : TableViewDataSource) -> NSMenu {
        infoPrint("", #function, self.className)
        var lastLesson : String = ""
        let newMenu = NSMenu()
        newMenu.title = dataSource.sourceFile!.lastPathComponent
        
        for word in dataSource.lessonEntries {
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
    
    @IBAction func toggleCurrentWordType(_ sender: NSMenuItem) {
        self.toggleCurrent(sender)
        
        if let newLesson = sender.menu?.title {
            switch sender.state {
            case .on:
                
                var lessonExists = false
                for wordType in self.selectedLessonTypes {
                    if wordType.lessonName == newLesson {
                        lessonExists = true
                        // Now add the new word type to the list
                        
                        var foundWord = false
                        for word in wordType.selectedLessons {
                            if word == sender.title {
                                foundWord = true
                                break
                            }
                        }
                        if foundWord == false {
                            wordType.selectedLessons.append(sender.title)
                        }
                    }
                }
                if !lessonExists
                {
                    let newSelectedWordType = SelectedWordTypes()
                    newSelectedWordType.lessonName = newLesson
                    newSelectedWordType.selectedLessons.append(sender.title)
                    self.selectedLessonTypes.append(newSelectedWordType)
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
}
