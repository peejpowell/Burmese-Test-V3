//
//  GeneralFunctions.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

let needsSavingNotificationKey          = "PJNeedsSaving"


func printResponderChain(_ responder: NSResponder?) {
    guard let responder = responder else { return; }
    
    print(responder)
    printResponderChain(responder.nextResponder)
}

func setTitleToDefault()
{
    if let mainWindow = getMainWindowController().window
    {
        mainWindow.title = "Burmese Test V3"
        mainWindow.representedURL = nil
    }
}

func setTitleToSourceUrl() {
    if  let mainWindow = getMainWindowController().window,
        let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
        let bmtVC = currentTabItem.viewController as? BMTViewController,
        let dataSource = bmtVC.dataSource,
        let url = dataSource.sourceFile {
        mainWindow.title = url.lastPathComponent
        mainWindow.representedURL = url
    }
}

func selectWordsTab()
{
    let mainTabView = getMainWindowController().mainTabViewController.tabView
    if mainTabView.selectedTabViewItem?.label != "Words" {
        mainTabView.selectTabViewItem(at: 2)
    }
}

func selectTabForExistingFile(tabItem: NSTabViewItem) {
    
    let wordsTabView = getWordsTabViewDelegate().tabView
    wordsTabView.selectTabViewItem(tabItem)
}

func setupTabViewItem(named label: String, controlledBy viewController: NSViewController)->NSTabViewItem
{
    let newTabViewItem = NSTabViewItem()
    newTabViewItem.viewController = viewController
    newTabViewItem.label = label
    return newTabViewItem
}

extension String {
    
    func stringAfter(_ stringToFind: String)->String
    {
        if let range = self.range(of: stringToFind) {
            let newString = self[range.upperBound..<self.endIndex]
            return "\(newString)"
        }
        return ""
    }
    
    func stringBefore(_ stringToFind: String)->String
    {
        if let range = self.range(of: stringToFind) {
            let newString = self[self.startIndex..<range.lowerBound]
            return "\(newString)"
        }
        return ""
    }
}

func infoPrint(_ info: String?, _ funcName: String?, _ className: String? )
{
    switch logLevel {
    case 1:
        // Find the first . and then extract the remainder
        if let className = className?.stringAfter(".") {
            if let funcName = funcName {
                if let info = info {
                    if info != "" {
                        print("\(className) -->\(funcName) -> \(info)")
                    }
                    else {
                        print("\(className) -->\(funcName)")
                    }
                }
                else {
                    print("\(className) -->\(funcName)")
                }
            }
        }
        
    default:
        return
    }
}
