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
    
    private var mainWindowViewModel : MainWindowViewModel = MainWindowViewModel()
    
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
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.openPrefsWindow), name: .openPrefsWindow, object: nil)
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

//MARK: Edit Menu First Responder Items

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

//MARK : Application Menu
extension MainWindowController {
    
    @objc func openPrefsWindow() {
        if let prefsWindow = self.prefsWindowController.window {
            NSApplication.shared.runModal(for: prefsWindow)
        }
    }
}

extension MainWindowController: NSWindowDelegate {
    
    func windowWillReturnFieldEditor(_ sender: NSWindow, to client: Any?) -> Any? {
        //Swift.print(__FUNCTION__)
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
        /*
        if (client as AnyObject).identifier == "english" {
            return nil
        }
        if (client as AnyObject).identifier == "avalaser" {
            //Swift.print("Field editor: \((client as! NSTextField).identifier)")
            return nil
        }*/
        
        var fieldEditor = mainWindowViewModel.fieldEditor
        fieldEditor.identifier = NSUserInterfaceItemIdentifier(rawValue: "test")
        
        if let id: String = (fieldEditor.identifier).map({ $0.rawValue }) {
            if id == "new" {
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
