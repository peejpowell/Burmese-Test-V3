//
//  PrefsWindowController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 08/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class PrefsWindowController: NSWindowController {

    @IBOutlet var preferencesViewController : PreferencesViewController!

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override func awakeFromNib() {
        infoPrint("\(self.window)", #function, self.className)
    }
    
    override init(window: NSWindow?) {
        super.init(window: nil)
            
        /* Load window from xib file */
        Bundle.main.loadNibNamed("PrefsWindowController", owner: self, topLevelObjects: nil)
        print(self.preferencesViewController)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
    }
}

extension PrefsWindowController : NSWindowDelegate {
    
    func windowShouldClose(_ sender: NSWindow) -> Bool
    {
        NSApplication.shared.stopModal()
        return true
    }
    
}
