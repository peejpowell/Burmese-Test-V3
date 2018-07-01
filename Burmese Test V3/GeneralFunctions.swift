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
    if let mainWindow = getMainWindowController().window {
        let index = getCurrentIndex()
        let tabViewController = getWordsTabViewDelegate()
        if index != -1 {
            if let url = tabViewController.dataSources[index].sourceFile {
                mainWindow.title = url.lastPathComponent
                mainWindow.representedURL = url
            }
        }
    }
}

func selectWordsTab()
{
    let mainTabView = getMainWindowController().mainTabViewController.tabView
    if mainTabView.selectedTabViewItem?.label != "Words" {
        mainTabView.selectTabViewItem(at: 2)
    }
}

func selectTabForExistingFile(at index: Int) {
    
    if let wordsTabView = getWordsTabViewDelegate().tabViewItems[index].tabView {
        wordsTabView.selectTabViewItem(at: index)
    }
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
        if let className = className?.stringAfter(".")
        {
            // Find the first . and then extract the remainder
            print(className)
        }
        if let funcName = funcName {
            if let info = info {
                if info != "" {
                    print("-->\(funcName) -> \(info)")
                }
                else {
                    print("-->\(funcName)")
                }
            }
            else {
                print("-->\(funcName)")
            }
        }
    default:
        return
    }
}
