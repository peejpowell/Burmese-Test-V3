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
    
    override func windowDidLoad() {
        
        infoPrint("",#function,self.className)
        
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        
    }
    
    override func awakeFromNib() {
        infoPrint("",#function,self.className)
        
        self.window?.minSize = NSSize(width: 800, height: 500)
    }

}
