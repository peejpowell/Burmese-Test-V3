//
//  MainWindowController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static var openPrefsWindow: Notification.Name {
        return .init(rawValue: "MainWindowController.openPrefsWindow")
    }
}

class MainWindowController: NSWindowController {
    
    @IBOutlet var toolbarController : ToolbarController!
    @IBOutlet var mainTabViewController : MainTabViewController!
    @IBOutlet var mainMenuController : MainMenuController!
    @IBOutlet var mainFileManager : PJFileManager!
    @IBOutlet var mainClipboardController : ClipboardController!
    @IBOutlet var prefsWindowController : PrefsWindowController!
    
    override func windowDidLoad() {
        
        infoPrint("",#function,self.className)
        
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override func awakeFromNib() {
        infoPrint("",#function,self.className)
        
        self.window?.minSize = NSSize(width: 800, height: 500)
        self.mainMenuController.closeWordsFileMenuItem.isEnabled = false
        createObservers()
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.openPrefsWindow), name: .openPrefsWindow, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainWindowController {
    
    @IBAction func openDocument(_ sender: Any?) {
        infoPrint("",#function,self.className)
        
        self.mainMenuController.openDocument(sender)
    }
    
    func performClose(_ sender: Any?) {
        infoPrint("",#function,self.className)
        
        self.mainMenuController.performClose(sender)
    }
    
    @IBAction func saveDocumentAs(_ sender: Any?) {
        infoPrint("",#function,self.className)
        
        self.mainMenuController.saveDocumentAs(sender)
    }
}
//MARK: Edit Menu First Responder Items

extension MainWindowController {
    
    @IBAction func cut(_ sender: Any?)
    {
        infoPrint("", #function, self.className)
        
        //PJLog("Cutting...",1)
        self.mainMenuController.cut(sender)
        //PJLog("Cut finished",1)
    }
}

//MARK : Application Menu
extension MainWindowController {
    
    @objc func openPrefsWindow() {
        if let prefsWindow = self.prefsWindowController.window {
            NSApplication.shared.runModal(for: prefsWindow)
        }
    }
}
