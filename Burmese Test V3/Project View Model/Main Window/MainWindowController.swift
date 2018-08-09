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
    @IBOutlet weak var mainTabViewController : MainTabViewController!
    @IBOutlet weak var mainFileManager : PJFileManager!
    @IBOutlet weak var mainClipboardController : ClipboardController!
    @IBOutlet weak var prefsWindowController : PrefsWindowController!
    
    @IBOutlet var mainWindowViewModel : MainWindowViewModel!
    
    // MARK: Properties
    let fieldEditor = FieldEditorTextView()
    
    override func windowDidLoad() {
        infoPrint("",#function,self.className)
        super.windowDidLoad()
    }
    
    override func awakeFromNib() {
        infoPrint("",#function,self.className)
        mainWindowViewModel.controller = self
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
        mainWindowViewModel.createNewDocument(sender)
    }
    
    @IBAction func openDocument(_ sender: Any?) {
        mainWindowViewModel.openDocument(sender)
    }
    
    func performClose(_ sender: Any?) {
        mainWindowViewModel.closeDocument(sender)
    }
    
    @IBAction func saveDocument(_ sender: Any?) {
        mainWindowViewModel.saveDocument(sender)
    }
    
    @IBAction func saveDocumentAs(_ sender: Any?) {
        mainWindowViewModel.saveDocumentAs(sender)
    }
    
    @IBAction func revertDocumentToSaved(_ sender: Any?) {
        mainWindowViewModel.revertDocumentToSaved(sender)
    }
}

//MARK: Edit Menu

extension MainWindowController {
    
    @IBAction func cut(_ sender: Any?) {
        infoPrint("", #function, self.className)
        mainWindowViewModel.cut(sender)
    }
    
    @IBAction func copy(_ sender: Any?) {
        infoPrint("", #function, self.className)
        mainWindowViewModel.copy(sender)
    }
    
    @IBAction func paste(_ sender: Any?) {
        infoPrint("", #function, self.className)
        mainWindowViewModel.paste(sender)
    }
    
}

// MARK: NSWindowDelegate Protocol
extension MainWindowController: NSWindowDelegate {
    
    func windowWillReturnFieldEditor(_ sender: NSWindow, to client: Any?) -> Any? {
        
        if let textField = client as? PJTextField {
            switch textField.identifier?.rawValue {
            case NSTextField.IdentifierKeys.english,
                 NSTextField.IdentifierKeys.avalaser:
                return nil
            default:
                break
            }
        }
        
        let fieldEditor = self.fieldEditor
        fieldEditor.identifier = NSUserInterfaceItemIdentifier(rawValue: "test")
        
        if let id: String = (fieldEditor.identifier).map({ $0.rawValue }) {
            if id == NSTextField.IdentifierKeys.new {
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
        if  let firstTabItem = mainTabViewController.wordsViewController.wordsTabViewController.tabView.selectedTabViewItem,
            let bmtVC = firstTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource,
            let _ = dataSource.sourceFile {
            NotificationCenter.default.post(name: .closeAllFiles, object: nil)
            return false
        }
        
        return true
    }
}
