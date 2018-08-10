//
//  FindMenuDelegate.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 03/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class FindMenuDelegate: NSObject, NSMenuDelegate {

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.title == "Ignore Diacritic" {
            infoPrint("", #function, self.className)
        }
        return super .validateMenuItem(menuItem)
    }
}
