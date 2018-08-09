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
    //var topLevelObjects : NSArray? = NSArray()
    override init(window: NSWindow?) {
        super.init(window: nil)
            
        /* Load window from xib file */
        Bundle.main.loadNibNamed("PrefsWindowController", owner: self, topLevelObjects: nil) //&topLevelObjects)
        //print("top level: \(topLevelObjects)")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension PrefsWindowController : NSWindowDelegate {
    
    func windowShouldClose(_ sender: NSWindow) -> Bool
    {
        NSApplication.shared.stopModal()
        return true
    }
    
}
