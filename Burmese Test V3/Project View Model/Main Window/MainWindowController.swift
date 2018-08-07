//
//  MainWindowController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    // MARK: Outlets
    
    @IBOutlet weak var toolbarController : ToolbarController!
    @IBOutlet weak var mainTabViewController : MainTabViewController!
    @IBOutlet weak var mainMenuController : MainMenuController!
    @IBOutlet weak var mainFileManager : PJFileManager!
    @IBOutlet weak var mainClipboardController : ClipboardController!
    @IBOutlet weak var prefsWindowController : PrefsWindowController!
    
    // MARK: Properties
    let fieldEditor = FieldEditorTextView()
    
    override func windowDidLoad() {
        infoPrint("",#function,self.className)
        super.windowDidLoad()
    }
    
    override func awakeFromNib() {
        infoPrint("",#function,self.className)
        self.window?.minSize = NSSize(width: 800, height: 500)
        NotificationCenter.default.post(name: .disableFileMenuItems, object: nil)
        createObservers()
    }
    
    override init(window: NSWindow?) {
        super.init(window: window)
        infoPrint("\(self)", #function, self.className)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        infoPrint("\(self)", #function, self.className)
    }
    
    deinit {
        infoPrint("\(self)", #function, self.className)
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: First Responder Actions

// MARK: -- File Menu
extension MainWindowController {
    
    @IBAction func newDocument(_ sender: Any?) {
        infoPrint("",#function,self.className)
        mainTabViewController.selectTab(at: 2)
        //selectTabForExistingFile(at: 0)
        mainMenuController.newDocument(sender)
    }
    
    @IBAction func openDocument(_ sender: Any?) {
        infoPrint("",#function,self.className)
        mainMenuController.openDocument(sender)
    }
    
    func performClose(_ sender: Any?) {
        infoPrint("",#function,self.className)
        mainMenuController.performClose(sender)
    }
    
    @IBAction func saveDocument(_ sender: Any?) {
        infoPrint("",#function,self.className)
        mainMenuController.saveDocument(sender)
    }
    
    @IBAction func saveDocumentAs(_ sender: Any?) {
        infoPrint("",#function,self.className)
        mainMenuController.saveDocumentAs(sender)
    }
    
    @IBAction func revertDocumentToSaved(_ sender: Any?) {
        infoPrint("",#function,self.className)
        mainMenuController.revertDocumentToSaved(sender)
    }
}

//MARK: Edit Menu

extension MainWindowController {
    
    @IBAction func cut(_ sender: Any?) {
        infoPrint("", #function, self.className)
        mainMenuController.cut(sender)
    }
    
    @IBAction func copy(_ sender: Any?) {
        infoPrint("", #function, self.className)
        mainMenuController.copy(sender)
    }
    
    @IBAction func paste(_ sender: Any?) {
        infoPrint("", #function, self.className)
        mainMenuController.paste(sender)
    }
    
}

// MARK: NSWindowDelegate Protocol
extension MainWindowController: NSWindowDelegate {
    
    func windowWillReturnFieldEditor(_ sender: NSWindow, to client: Any?) -> Any? {
        
        if let textField = client as? PJTextField {
            switch textField.identifier?.rawValue {
            case "english":
                return nil
            case "avalaser":
                return nil
            default:
                break
            }
        }
        
        let fieldEditor = self.fieldEditor
        fieldEditor.identifier = NSUserInterfaceItemIdentifier(rawValue: "test")
        
        if let id: String = (fieldEditor.identifier).map({ $0.rawValue }) {
            if id == "new" {
                fieldEditor.isFieldEditor = true
                fieldEditor.identifier = NSUserInterfaceItemIdentifier(rawValue: "configured")
            }
            return fieldEditor
        }
        return nil
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        infoPrint("", #function, self.className)
        // Make sure all files are closed first
        // Check if the first tab's dataSource is empty
        if  let firstTabItem = mainTabViewController.wordsTabController.wordsTabViewController.tabView.selectedTabViewItem,
            let bmtVC = firstTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource,
            let _ = dataSource.sourceFile {
            NotificationCenter.default.post(name: .closeAllFiles, object: nil)
            return false
        }
        
        return true
    }
}
