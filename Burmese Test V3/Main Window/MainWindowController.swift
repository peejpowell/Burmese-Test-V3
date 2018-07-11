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
    
    var fieldEditor = PJTextView()
    
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
    
    @IBAction func newDocument(_ sender: Any?) {
        infoPrint("",#function,self.className)
        self.mainTabViewController.tabView.selectTabViewItem(at: 2)
        selectTabForExistingFile(at: 0)
        self.mainMenuController.newDocument(sender)
    }
    
    @IBAction func openDocument(_ sender: Any?) {
        infoPrint("",#function,self.className)
        
        self.mainMenuController.openDocument(sender)
    }
    
    func performClose(_ sender: Any?) {
        infoPrint("",#function,self.className)
        
        self.mainMenuController.performClose(sender)
    }
    
    @IBAction func saveDocument(_ sender: Any?) {
        infoPrint("",#function,self.className)
        
        self.mainMenuController.saveDocument(sender)
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

        self.mainMenuController.cut(sender)
    }
    
    @IBAction func copy(_ sender: Any?)
    {
        infoPrint("", #function, self.className)
        
        self.mainMenuController.copy(sender)
    }
    
    @IBAction func paste(_ sender: Any?)
    {
        infoPrint("", #function, self.className)

        self.mainMenuController.paste(sender)
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

extension MainWindowController: NSWindowDelegate {
    
    func windowWillReturnFieldEditor(_ sender: NSWindow, to client: Any?) -> Any?
    {
        //Swift.print(__FUNCTION__)
        
        if (client as AnyObject).identifier == "english"
        {
            return nil
        }
        if (client as AnyObject).identifier == "avalaser"
        {
            //Swift.print("Field editor: \((client as! NSTextField).identifier)")
            
            return nil
        }
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        
        var fieldEditor = self.fieldEditor
        fieldEditor.identifier = NSUserInterfaceItemIdentifier(rawValue: "test")
        
        if let id: String = (fieldEditor.identifier).map({ $0.rawValue })
        {
            if id == "new"
            {
                fieldEditor = PJTextView()
                fieldEditor.isFieldEditor = true
                fieldEditor.identifier = NSUserInterfaceItemIdentifier(rawValue: "configured")
            }
            return fieldEditor
        }
        return nil
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        infoPrint("", #function, self.className)
        for tabNum in (0..<getWordsTabViewDelegate().tabViewItems.count).reversed()
        {
            getWordsTabViewDelegate().tabView.selectTabViewItem(at:tabNum)
            if !self.mainMenuController.performCloseWordsFile(self) {
                return false
            }
        }
        return true
    }
}
