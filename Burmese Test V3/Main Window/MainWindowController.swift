//
//  MainWindowController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    @IBOutlet var toolbarController : ToolbarController!
    @IBOutlet var findBarViewController : FindBarViewController!
    @IBOutlet var mainTabViewController : MainTabViewController!
    @IBOutlet var mainMenuController : MainMenuController!
    @IBOutlet var mainFileManager : PJFileManager!
    @IBOutlet var mainClipboardController : ClipboardController!
    
    override func windowDidLoad() {
        
        infoPrint("",#function,self.className)
        
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override func awakeFromNib() {
        infoPrint("",#function,self.className)
        
        self.window?.minSize = NSSize(width: 800, height: 500)
        self.mainMenuController.closeWordsFileMenuItem.isEnabled = false
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
