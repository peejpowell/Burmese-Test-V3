//
//  AppDelegate.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

public var logLevel = 1

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var mainWindowController : MainWindowController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        infoPrint("", #function, self.className)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        infoPrint("", #function, self.className)
        
        for controller in getWordsTabViewDelegate().tabViewControllersList
        {
            controller.tableView = nil
        }
        
        getWordsTabViewDelegate().tabViewControllersList.removeAll()
        getWordsTabViewDelegate().dataSources.removeAll()
        getWordsTabViewDelegate().tabViewItems.removeAll()
        
        
        
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        infoPrint("", #function, self.className)
        
        return true
    }
    
    func openDocument(sender: NSMenuItem)
    {
        infoPrint("", #function, self.className)
    }
}

