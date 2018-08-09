//
//  PrefsToolbarDelegate.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 08/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class PrefsToolbarController: NSObject {
    
    @IBOutlet weak var prefsToolbar : NSToolbar!

}

extension PrefsToolbarController: NSToolbarDelegate {
    
    @IBAction func selectGeneralTab(_ sender : NSToolbarItem) {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .selectPrefsGeneralTab, object: nil)
        prefsToolbar.selectedItemIdentifier = NSToolbarItem.Identifier(rawValue: NSToolbar.IdentifierKeys.general)
    }
    
    @IBAction func selectTableTab(_ sender : NSToolbarItem)
    {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .selectPrefsTableTab, object: nil)
        prefsToolbar.selectedItemIdentifier = NSToolbarItem.Identifier(rawValue: NSToolbar.IdentifierKeys.table)
    }

}
