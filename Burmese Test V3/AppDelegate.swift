//
//  AppDelegate.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa
import Carbon

public var logLevel = 1

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var mainWindowController : MainWindowController!
    
    var currentInputSource : TISInputSource?    = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
    var originalInputLanguage : TISInputSource? = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        infoPrint("", #function, self.className)
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        
        infoPrint("", #function, self.className)
        if let _ = self.mainWindowController.mainTabViewController.wordsTabController.wordsTabViewController.dataSources[0].sourceFile {
            NotificationCenter.default.post(name: .closeAllFiles, object: nil)
            return .terminateCancel
        }
        return .terminateNow
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        infoPrint("", #function, self.className)
        
        // Close all active documents
       
        for controller in getWordsTabViewDelegate().tabViewControllersList {
            controller.tableView = nil
        }
        
        getWordsTabViewDelegate().tabViewControllersList.removeAll()
        getWordsTabViewDelegate().dataSources.removeAll()
        getWordsTabViewDelegate().tabViewItems.removeAll()
        self.currentInputSource = nil
        TISSelectInputSource(self.originalInputLanguage)
        self.originalInputLanguage = nil
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        infoPrint("", #function, self.className)
        
        return true
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        infoPrint("", #function, self.className)
        TISSelectInputSource(self.currentInputSource)
    }
    
    func applicationWillResignActive(_ notification: Notification) {
        infoPrint("", #function, self.className)
        
        self.currentInputSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        TISSelectInputSource(originalInputLanguage)
    }
    
}

extension AppDelegate {
    
    @IBAction func performClose(_ sender: Any?) {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .closeDocument, object: nil)
    }

    /*@IBAction func performFindPanelAction(_ sender: Any?){
        infoPrint("", #function, self.className)
       
        let index = getCurrentIndex()
        _ = getWordsTabViewDelegate().tabViewControllersList[index].textFinderClient.performTextFinderAction(sender)
    }
    */
}
