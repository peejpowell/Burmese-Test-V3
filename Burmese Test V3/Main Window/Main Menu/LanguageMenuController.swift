//
//  LanguageMenuController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 28/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class LanguageMenuController: MenuController {

    //FIXME: Enable this function later
    
    func cancelTest()
    {
        if let testTabController =  getMainWindowController().mainTabViewController.tabViewItems[0].viewController as? TestTabController
        {
            testTabController.multipleChoiceTest.testStarted = false
        }
    }
    
    @IBAction func languageChosen(sender:NSMenuItem)
    {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        
        let menuItemClicked = sender
        let menuClicked = menuItemClicked.menu
        
        switch menuItemClicked.title {
        case "Select All", "Select None":
            if let menuClickedItems = menuClicked?.items {
                for item in menuClickedItems {
                    switch item.title {
                    case "Select All", "Select None", "Seperator", "":
                        break
                    default:
                        switch menuItemClicked.title {
                        case "Select All":
                            switch item.title {
                            case "Reload Words", "Burmese Only", "Roman Only", "English Only":
                                break
                            default:
                                item.state = .on
                            }
                        case "Select None":
                            item.state = .off
                        default:
                            break
                        }
                    }
                }
            }
        case "Burmese Only":
            if let menuClickedItems = menuClicked?.items {
                for item in menuClickedItems {
                    if item.title.containsString("Burmese") && item.title != "Burmese Only" {
                        item.state = .on
                    }
                    else {
                        item.state = .off
                    }
                }
            }
        case "Roman Only":
            if let menuClickedItems = menuClicked?.items {
                for item in menuClickedItems {
                    if item.title.containsString("Roman") && item.title != "Roman Only" {
                        item.state = .on
                    }
                    else {
                        item.state = .off
                    }
                }
            }
        case "English Only":
            if let menuClickedItems = menuClicked?.items {
                for item in menuClickedItems {
                    if item.title.containsString("English") && item.title != "English Only" {
                        item.state = .on
                    }
                    else {
                        item.state = .off
                    }
                }
            }
        case "":
            // Seperator Item so ignore
            break
        default:
            if menuItemClicked.state == .on {
                menuItemClicked.state = .off
            }
            else {
                menuItemClicked.state = .on
            }
        }
        
        if let parentMenu = sender.menu {
            switch parentMenu.title {
            case "Word Type", "Language":
                cancelTest()
            default:
                break
            }
        }
        
        if let parent = sender.parent {
            switch parent.title {
            case "Word Type", "Language":
                cancelTest()
            default:
                break
            }
        }
        
        switch menuClicked?.title
        {
        case "Language":
            var langArray: NSMutableArray = NSMutableArray()
            if let items = menuClicked?.items {
                for item in items {
                    let state = item.state.rawValue
                    langArray.add(NSNumber(value: state))
                }
                UserDefaults.standard.set(langArray, forKey: "LanguageMenuItems")
            }
        case "WordTypes":
            break
        default:
            break
        }
    }
    
    override func selectAll(_ sender: NSMenuItem) {
        let menu = sender.menu
        if let menu = menu {
            for menuItemNum in 6 ..< menu.items.count-3 {
                menu.items[menuItemNum].state = .on
                //self.toggleCurrent(menu.items[menuItemNum])
            }
        }
        
        if let newLesson = sender.menu?.title,
           let wordTypeMenuController = getWordTypeMenuController() {
            switch sender.state {
            case .on:
                var lessonExists = false
                if let wordTypeMenuController = getWordTypeMenuController() {
                    for wordType in wordTypeMenuController.selectedWordTypes {
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
                    if !lessonExists {
                        let newSelectedWordType = SelectedWordTypes()
                        newSelectedWordType.lessonName = newLesson
                        newSelectedWordType.selectedWords.append(sender.title)
                        wordTypeMenuController.selectedWordTypes.append(newSelectedWordType)
                    }
                }
            case .off:
                // Check if the lesson already exists in the list of lessons
                //var lessonExists = false
                for wordType in wordTypeMenuController.selectedWordTypes {
                    if wordType.lessonName == newLesson {
                        //lessonExists = true
                        // Now remove the word type from the list
                        
                        //var foundWord = false
                        var wordCount = 0
                        for word in wordType.selectedWords {
                            if word == sender.title {
                                //foundWord = true
                                wordType.selectedWords.remove(at: wordCount)
                                break
                            }
                            wordCount = wordCount + 1
                        }
                    }
                }
            default:
                break
            }
        }
    }
    
    override func selectNone(_ sender: NSMenuItem) {
        super.selectNone(sender)
    }
}
