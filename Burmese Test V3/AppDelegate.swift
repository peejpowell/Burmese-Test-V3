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

    // MARK: Properties
    var autoOpenUrl             : URL?
    var autoOpenUrls            : [URL]?
    var currentInputSource      : TISInputSource?    = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
    var originalInputLanguage   : TISInputSource? = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
    
    // MARK: Outlets
    @IBOutlet weak var mainWindowController : MainWindowController!
    
    // MARK: Application Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoPrint("", #function, self.className)
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        infoPrint("", #function, self.className)
        let fileUrl = URL(fileURLWithPath: filename)
        self.autoOpenUrl = fileUrl
        return true
    }
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        infoPrint("", #function, self.className)
        for fileName in filenames {
            let fileUrl = URL(fileURLWithPath: fileName)
            self.autoOpenUrls?.append(fileUrl)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        infoPrint("", #function, self.className)
        guard let mainMenuController = mainWindowController.mainMenuController else { return }
        mainMenuController.loadRecentFiles(UserDefaults.standard)
        openFirstUrl()
        openAutoOpenUrl()
        openAutoOpenUrls()
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
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        infoPrint("", #function, self.className)
        return true
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        infoPrint("", #function, self.className)
        guard let firstTabItem = lessonTabView().selectedTabViewItem else { return .terminateNow }
        if firstTabItem.label != "Nothing Loaded" {
            NotificationCenter.default.post(name: .closeAllFiles, object: nil)
            return .terminateCancel
        }
        return .terminateNow
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        infoPrint("Tearing Down Application Before Quit", #function, self.className)
        if  let firstTabItem = lessonTabView().selectedTabViewItem,
            let bmtVC = firstTabItem.viewController as? BMTViewController {
            bmtVC.bmtViewModel.dataSource = nil
            bmtVC.bmtViewModel.tableView = nil
            bmtVC.tableView = nil
            bmtVC.scrollView = nil
        }
        
        mainWindowController.mainTabViewController.wordsViewController?.wordsTabViewController.tabViewItems.removeAll()
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
    
}

// MARK: -- Recent Files

extension AppDelegate {
    func openUrl(_ url: URL) {
        if let wordsVC = mainWindowController.mainTabViewController.wordsViewController {
            wordsVC.wordsTabViewModel.fileManager?.loadRequestedUrl(url)
        }
    }
    
    func openFirstUrl() {
        // Check if openMostRecent is enabled
        if  let prefsViewModel = mainWindowController.prefsWindowController.preferencesViewController?.preferencesViewModel {
            if !prefsViewModel.mostRecentIsEnabled {
                return
            }
        }
        if let firstUrl = mainWindowController.mainMenuController.recentFiles.first {
            openUrl(firstUrl)
        }
    }
    
    func openAutoOpenUrl() {
        if let autoOpenUrl = self.autoOpenUrl {
            openUrl(autoOpenUrl)
        }
    }
    
    func openAutoOpenUrls() {
        if let autoOpenUrls = self.autoOpenUrls {
            for autoOpenUrl in autoOpenUrls {
                openUrl(autoOpenUrl)
            }
        }
    }
}

// MARK: Responders
extension AppDelegate {
    
    @IBAction func performClose(_ sender: Any?) {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .closeDocument, object: nil)
    }
    
}

// MARK: Helper Functions
extension AppDelegate {
    
    func lessonTabView()->NSTabView {
        return mainWindowController.mainTabViewController.wordsViewController.wordsTabViewController.tabView
    }
}
