//
//  PJWindow.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 01/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class PJWindow: NSWindow {

    @IBAction override func performClose(_ sender: Any?) {
        infoPrint("", #function, self.className)
        getMainMenuController().performCloseWordsFile(sender)
        //super.performClose(sender)
    }
}
