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

    var autoOpenUrl : URL?
    
    @IBOutlet weak var mainWindowController : MainWindowController!
    
    var currentInputSource : TISInputSource?    = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
    var originalInputLanguage : TISInputSource? = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        infoPrint("", #function, self.className)
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        
        infoPrint("", #function, self.className)
//        if  let firstTabItem = mainWindowController.mainTabViewController.wordsTabController.wordsTabViewController.tabView.selectedTabViewItem,
//            let bmtVC = firstTabItem.viewController as? BMTViewController,
//            let dataSource = bmtVC.dataSource,
//            let _ = dataSource.sourceFile {
//            if firstTabItem.label != "Nothing Loaded" {
//                NotificationCenter.default.post(name: .closeAllFiles, object: nil)
//                return .terminateCancel
//            }
//        }
        if  let firstTabItem = mainWindowController.mainTabViewController.wordsTabController.wordsTabViewController.tabView.selectedTabViewItem {
            if firstTabItem.label != "Nothing Loaded" {
                NotificationCenter.default.post(name: .closeAllFiles, object: nil)
                return .terminateCancel
            }
        }
        return .terminateNow
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        infoPrint("Tearing Down Application Before Quit", #function, self.className)
        if  let firstTabItem = mainWindowController.mainTabViewController.wordsTabController.wordsTabViewController.tabView.selectedTabViewItem {
            if let bmtVC = firstTabItem.viewController as? BMTViewController {
                bmtVC.bmtViewModel.dataSource = nil
                bmtVC.bmtViewModel.tableView = nil
                bmtVC.tableView = nil
                bmtVC.scrollView = nil
            }
        }
        
        mainWindowController.mainTabViewController.wordsTabController?.wordsTabViewController.tabViewItems.removeAll()
        mainWindowController.mainTabViewController.tabViewItems.removeAll()
        mainWindowController.toolbarController = nil
        mainWindowController.mainTabViewController = nil
        mainWindowController.mainMenuController = nil
        mainWindowController.mainFileManager = nil
        mainWindowController.mainClipboardController = nil
        mainWindowController.prefsWindowController = nil
        
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
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        infoPrint("", #function, self.className)
        let fileUrl = URL(fileURLWithPath: filename)
        self.autoOpenUrl = fileUrl
        /*if let wordsTabVC = mainWindowController.mainTabViewController.wordsTabController,
            let fileManager = wordsTabVC.wordsTabViewModel.fileManager {
            mainWindowController.mainTabViewController!.tabView.selectTabViewItem(at:2)
            getWordsTabViewDelegate().tabView.selectTabViewItem(at: 0)
            fileManager.loadRequestedUrl(fileUrl)
        }*/
        return true
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
