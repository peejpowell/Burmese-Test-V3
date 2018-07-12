//
//  ToolbarController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class ToolbarController: NSObject, NSToolbarDelegate {
    
    @IBOutlet weak var mainToolbar : NSToolbar!
    @IBOutlet weak var lessonsPopup : NSPopUpButton!
    
    @IBAction func selectLessonInPopup(_ sender: NSPopUpButton) {
        infoPrint("", #function, self.className)
    }
}
