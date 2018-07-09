//
//  PrefsToolbarDelegate.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 08/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class PrefsToolbarController: NSObject, NSToolbarDelegate {
    
    @IBOutlet weak var prefsToolbar : NSToolbar!
    
    @IBAction func selectGeneralTab(_ sender : NSToolbarItem)
    {
        // Post General tab selected
        
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .selectPrefsGeneralTab, object: nil)
        
        prefsToolbar.selectedItemIdentifier = NSToolbarItem.Identifier(rawValue: "PrefsGeneral")
    }
    
    @IBAction func selectTableTab(_ sender : NSToolbarItem)
    {
        // Post Table Tab Selected

        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .selectPrefsTableTab, object: nil)
        
        prefsToolbar.selectedItemIdentifier = NSToolbarItem.Identifier(rawValue: "PrefsTable")
    }

}
