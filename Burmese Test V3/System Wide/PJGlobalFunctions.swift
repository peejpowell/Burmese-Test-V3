//
//  PJGlobalFunctions.swift
//  Burmese Test V2
//
//  Created by Phil on 03/07/2015.
//  Copyright © 2015 Phil. All rights reserved.
//

import Cocoa
import Carbon

// MARK: Global Functions

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
    if [TISInputSource.KeyboardLanguage.english, TISInputSource.KeyboardLanguage.myanmar].contains(inputLanguage as String) {
        TISSelectInputSource(TISCopyInputSourceForLanguage(inputLanguage).takeRetainedValue())
    }
    else {
        TISSelectInputSource(originalLang)
    }
}

func getAppDelegate() -> AppDelegate
{
    return NSApplication.shared.delegate as! AppDelegate
}

func getCurrentTableView()->NSTableView
{
    if  let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
        let bmtVC = currentTabItem.viewController as? BMTViewController {
        return bmtVC.tableView
    }
    return NSTableView()
    //let currentBMTView = getWordsTabViewDelegate().tabViewControllersList[getCurrentIndex()].view
    //return currentBMTView.viewWithTag(100) as! NSTableView
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
    return getMainWindowController().mainTabViewController.wordsViewController.wordsTabViewController
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
    if let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem {
        if getWordsTabViewDelegate().removingFirstItem {
            return 0
        }
        return getWordsTabViewDelegate().tabView.indexOfTabViewItem(currentTabItem)
    }
    return -1
}

func increaseLessonCount(_ lessonName: String) {
    
    infoPrint("", #function, nil)
    
    if  let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
        let bmtVC = currentTabItem.viewController as? BMTViewController,
        let dataSource = bmtVC.dataSource {
        if let value = dataSource.lessons[lessonName] {
            dataSource.lessons[lessonName] = value + 1
        }
        else {
            dataSource.lessons[lessonName] = 1
        }
    }
}

func decreaseLessonCount(_ lessonName: String)
{
    infoPrint("", #function, nil)
    if  let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
        let bmtVC = currentTabItem.viewController as? BMTViewController,
        let dataSource = bmtVC.dataSource {
        if let value = dataSource.lessons[lessonName] {
            dataSource.lessons[lessonName] = value - 1
            if value == 1 {
                dataSource.lessons[lessonName] = nil
            }
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
