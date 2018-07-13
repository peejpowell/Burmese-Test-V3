//
//  PJGlobalFunctions.swift
//  Burmese Test V2
//
//  Created by Phil on 03/07/2015.
//  Copyright © 2015 Phil. All rights reserved.
//

import Cocoa
import Carbon

// Global Enums

// MARK: Global Functions

extension String
{
    // MARK: Fixes for String functions/variables
    
    func padBefore(_ padWith: String,desiredLength:Int)->String
    {
        var stringToPad = self
        while stringToPad.distance(from: stringToPad.startIndex, to: stringToPad.endIndex) < desiredLength
        {
            stringToPad = "\(padWith)\(stringToPad)"
        }
        return stringToPad
    }
    
    /*func length()->Int
    {
        return self.distance(from: self.startIndex, to: self.endIndex)
    }*/
    
    func left(_ length:Int)->String?
    {
        let lengthOfString = self.distance(from: self.startIndex, to: self.endIndex)
        
        if length > lengthOfString
        {
            return nil
        }
        
        var myEndIndex : String.Index = self.startIndex
        
        for _ in 0 ..< length
        {
            myEndIndex = self.index(after: myEndIndex)
        }
        
        return "\(self[..<myEndIndex])"
        //return substring(to: myEndIndex)
    }
    
    func right(_ length:Int)->String?
    {
        let lengthOfString = self.distance(from: self.startIndex, to: self.endIndex)
        
        if length > lengthOfString
        {
            return nil
        }
        
        var myStartIndex : String.Index = self.endIndex
        
        for _ in 0 ..< length
        {
            myStartIndex = self.index(before: myStartIndex)
        }
        
        return "\(self[myStartIndex...])"
        //return substring(from: myStartIndex)
    }
    
    func mid(_ loc: Int,length: Int)->String?
    {
        
        let lengthOfString = self.distance(from: self.startIndex, to: self.endIndex)
        let totalRequestedString = lengthOfString - loc
        if length > totalRequestedString
        {
            return nil
        }
        
        var myStartIndex : String.Index = self.startIndex
        
        for _ in 0 ..< loc
        {
            myStartIndex = self.index(after: myStartIndex)
        }
        
        var myEndIndex : String.Index = myStartIndex
        
        for _ in 0 ..< length
        {
            myEndIndex = self.index(after: myEndIndex)
        }
        
        //let myRange : Range = (myStartIndex ..< myEndIndex)
        
        return "\(self[myStartIndex..<myEndIndex])"
        //return self.substring(with: myRange)
    }
    
    func sentenceCase()->String
    {   let initial = self.left(1)!.uppercased()
        let theRest = self.right(self.count-1)!
        return "\(initial)\(theRest)"
    }
    
    func removeLastLine()->String
    {
        // Find the last \r in the text
        let string = self
        var progressText = ""
        var index = string.endIndex
        
        while index != string.startIndex
        {
            index = self.index(before: index)
            //let myoldChar = string.substring(with: (index ..< self.index(after: index)))
            let myChar = "\(string[index..<self.index(after: index)])"
            if myChar == "\r" || myChar == "\n"
            {
                // Check if the following characters are blank
                //let lastLine = string.substring(with: (index ..< string.endIndex)).trimAll()
                let lastLine = "\(string[index ..< string.endIndex])"
                if lastLine == ""
                {
                    index = self.index(before: index)
                }
                else
                {
                    break
                }
            }
        }
        //progressText = string.substring(with: (string.startIndex ..< index))
        progressText = "\(string[string.startIndex..<index])"
        return progressText
    }
    
    func lastLine()->String
    {
        // Find the last \r in the text
        let string = self
        var progressText = ""
        var index = string.endIndex
        
        while index != string.startIndex
        {
            index = self.index(before: index)
            //let myChar = string.substring(with: (index ..< self.index(after: index)))
            let myChar = "\(string[index ..< self.index(after:index)])"
            if myChar == "\r" || myChar == "\n"
            {
                // Check if the following characters are blank
                let lastLine = "\(string[index..<string.endIndex])".trimAll()
                //let lastLine = string.substring(with: (index ..< string.endIndex)).trimAll()
                if lastLine == ""
                {
                    index = self.index(before: index)
                }
                else
                {
                    break
                }
            }
        }
        progressText = "\(string[index..<string.endIndex])"
        //progressText = string.substring(with: (index ..< string.endIndex))
        return progressText
    }
    
    func trimAll()->String
    {
        var string = self
        string = string.replacingOccurrences(of: "\r", with: "", options: NSString.CompareOptions.literal, range: string.stringRange())
        string = string.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: string.stringRange())
        
        return string
    }
    
    func removeString(_ stringToRemove: String)->String
    {
        return self.replacingOccurrences(of: stringToRemove, with: "", options: NSString.CompareOptions.literal, range: self.range(of: self))
    }
    
    func stringRange()->Range<String.Index>
    {
        let myRange = (self.startIndex ..< self.endIndex)
        return myRange
    }
    
    func containsString(_ stringToFind: String)->Bool
    {
        if (self.range(of: stringToFind, options: NSString.CompareOptions.literal, range: self.stringRange(), locale: nil) != nil)
        {
            return true
        }
        else
        {
            return false
        }
    }
}

enum SortKeys: String
{
    case Burmese = "KBurmese"
    case Roman = "KRoman"
    case English = "KEnglish"
    case Lesson = "KLesson"
    case Category = "KCategory"
}

func getLowerOrBlank(_ string: String?)->String
{
    switch string
    {
    case nil:
        return ""
    default:
        return string!.lowercased()
    }
}

func loadIconFrom(_ fullPath: String)->NSImage?
{
    let url = URL(fileURLWithPath: fullPath)
    
    let resourceValues: URLResourceValues?
    do {
        resourceValues = try url.resourceValues(forKeys: [URLResourceKey.effectiveIconKey])
    } catch _ {
        resourceValues = nil
    }
    if resourceValues != nil
    {
        return resourceValues?.effectiveIcon as? NSImage
    }
    else
    {
        return NSImage()
    }
}

enum keyboardType
{
    case ascii
    case all
}

func randomNumber(total: Int)->Int
{
    return Int(arc4random_uniform(uint32(total)))
}

func setKeyboardByName(_ name: String, type: keyboardType)
{
    var languageList : NSArray = []
    switch type
    {
    case .ascii:
        languageList = TISCreateASCIICapableInputSourceList().takeRetainedValue()
    default:
        languageList = TISCreateInputSourceList(CFDictionaryCreate(kCFAllocatorDefault,nil,nil,0,nil,nil), false).takeRetainedValue()
    }
    
    for source in languageList as! [TISInputSource]
    {
        if source.id.uppercased().containsString(name.uppercased())
        //if "\(source)".containsText(name, isBurmese: false, fullWord: false, ignoreDiacritics: true)
        {
            TISSelectInputSource(source)
            break
        }
    }
}

func changeInputLanguage(_ inputLanguage: NSString, originalLang: TISInputSource)
{
    Swift.print(#function)
    if ["en", "my"].contains(inputLanguage)
    {
        TISSelectInputSource(TISCopyInputSourceForLanguage(inputLanguage).takeRetainedValue())
    }
    else
    {
        TISSelectInputSource(originalLang)
    }
}

func getAppDelegate() -> AppDelegate
{
    return NSApplication.shared.delegate as! AppDelegate
}

func getCurrentTableView()->NSTableView
{
    let currentBMTView = getWordsTabViewDelegate().tabViewControllersList[getCurrentIndex()].view
    return currentBMTView.viewWithTag(100) as! NSTableView
}

func getWordTypeMenuController()->WordTypeMenuController?
{
    if let wordTypeMenu = getMainMenuController().mainMenu.item(withTitle: "Word Type")?.submenu {
        if let delegate = wordTypeMenu.delegate as? WordTypeMenuController {
        return delegate
        }
    }
    return nil
}

func getWordsTabViewDelegate()->WordsTabViewController
{
    return getMainWindowController().mainTabViewController.wordsTabController.wordsTabViewController
}

func getMainMenuController()->MainMenuController
{
    return getMainWindowController().mainMenuController
}

func getMainWindowController()->MainWindowController
{
    return getAppDelegate().mainWindowController
}

func getCurrentIndex()->Int
{
    let wordTabController = getWordsTabViewDelegate()
    if wordTabController.dataSources.count != 0
    {
        if wordTabController.removingFirstItem
        {
            return 0
        }
        if let selectedItem = wordTabController.tabView.selectedTabViewItem
        {
            return wordTabController.tabView.indexOfTabViewItem(selectedItem)
        }
    }
    return -1
}

func increaseLessonCount(_ lessonName: String) {
    
    infoPrint("", #function, nil)
    
    let index = getCurrentIndex()
    if index == -1 {return}
    
    if let value = getWordsTabViewDelegate().dataSources[index].lessons[lessonName] {
        getWordsTabViewDelegate().dataSources[index].lessons[lessonName] = value + 1
    }
    else {
        getWordsTabViewDelegate().dataSources[index].lessons[lessonName] = 1
    }
}

func decreaseLessonCount(_ lessonName: String)
{
    infoPrint("", #function, nil)
    
    let index = getCurrentIndex()
    if index == -1 {return}
    
    if let value = getWordsTabViewDelegate().dataSources[index].lessons[lessonName] {
        getWordsTabViewDelegate().dataSources[index].lessons[lessonName] = value - 1
        if value == 1
        {
            getWordsTabViewDelegate().dataSources[index].lessons[lessonName] = nil
        }
    }
}

func padString(_ stringToPad: String, usingString: String, toLength: Int, afterString: Bool) -> String
{
    var resultString = stringToPad
    var newString = stringToPad as NSString
    
    while (newString.length<toLength){
        if (!afterString){
            newString = "\(usingString)\(newString)" as NSString
        }
        else
        {
            newString = "\(stringToPad)\(usingString)" as NSString
        }
        resultString = newString as String
    }
    return resultString
}

func chooseDispatch(_ block: ()->Void)
{
    if !Thread.current.isMainThread
    {
        DispatchQueue.main.sync
            {
                block()
        }
    }
    else
    {
        block()
    }
}

class PJGlobalFunctions
{
   
}
