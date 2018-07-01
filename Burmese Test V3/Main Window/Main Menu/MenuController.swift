//
//  PJMenuController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 28/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class MenuController: NSObject, NSMenuDelegate {
    
    @IBAction func toggleCurrent(_ sender: NSMenuItem) {
        switch sender.state {
        case .on:
            sender.state = .off
        case .off:
            sender.state = .on
        default:
            break
        }
    }
    
    @IBAction func selectAll(_ sender: NSMenuItem) {
        
        // Get the menu for the item and loop through checking all but the last three
        
        let menu = sender.menu
        if let menu = menu
        {
            for menuItemNum in 0 ..< menu.items.count-3
            {
                menu.items[menuItemNum].state = .on
                //self.toggleCurrent(menu.items[menuItemNum])
            }
        }
        
    }
    
    @IBAction func selectNone(_ sender: NSMenuItem) {
        
        // Get the menu for the item and loop through unchecking all but the last three
        
        let menu = sender.menu
        if let menu = menu
        {
            for menuItemNum in 0 ..< menu.items.count-3
            {
                menu.items[menuItemNum].state = .off
                //self.toggleCurrent(menu.items[menuItemNum])
            }
        }
    }
    
    /*
        if let newLesson = sender.menu?.title
        {
            switch sender.state
            {
            case .off:
                sender.state = .on
                switch sender.parent?.title {
                case "Word Types":
                    var lessonExists = false
                    for wordType in self.selectedWordTypes {
                        if wordType.lessonName == newLesson {
                            lessonExists = true
                            // Now add the new word type to the list
                            
                            var foundWord = false
                            for word in wordType.selectedWords
                            {
                                if word == sender.title
                                {
                                    foundWord = true
                                    break
                                }
                            }
                            if foundWord == false
                            {
                                wordType.selectedWords.append(sender.title)
                            }
                        }
                    }
                default:
                }
            case .on:
                sender.state = .off
            default:
                break
            }
            if sender.state == .off
            {
                sender.state = .on
                
                Swift.print(sender.parent!.title)
                if sender.parent!.title != "Word Types"
                {               // Check if the lesson already exists in the list of lessons
                    var lessonExists = false
                    for wordType in self.selectedWordTypes
                    {
                        if wordType.lessonName == newLesson
                        {
                            lessonExists = true
                            // Now add the new word type to the list
                            
                            var foundWord = false
                            for word in wordType.selectedWords
                            {
                                if word == sender.title
                                {
                                    foundWord = true
                                    break
                                }
                            }
                            if foundWord == false
                            {
                                wordType.selectedWords.append(sender.title)
                            }
                        }
                    }
                    if lessonExists
                    {
                        
                    }
                    else
                    {
                        let newSelectedWordType = PJSelectedWordTypes()
                        newSelectedWordType.lessonName = newLesson
                        newSelectedWordType.selectedWords.append(sender.title)
                        self.selectedWordTypes.append(newSelectedWordType)
                    }
                }
                
                
            }
            else
            {
                sender.state = .off
                if sender.parent!.title != "Word Types"
                {
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
                    }
                }
            }
        }
        if sender.parent!.title == "Word Types"
        {
            
            //return
        }
        // Save the preference of what selected words there are
        let myData = NSKeyedArchiver.archivedData(withRootObject: self.selectedWordTypes)
        UserDefaults.standard.set(myData, forKey: "SelectedWordTypes")
        /*for wordType in self.selectedWordTypes
         {
         print("file: \(wordType.lessonName)\n")
         for lessonName in wordType.selectedWords
         {
         print("lesson: \(lessonName)")
         }
         }*/
    }
*/
    
    override init() {
        super.init()
        infoPrint("", #function, self.className)
        
        // Load Recent files from UserDefaults
        
        
        
    }
}
