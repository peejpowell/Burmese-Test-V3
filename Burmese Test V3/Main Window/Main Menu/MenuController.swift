//
//  PJMenuController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 28/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class MenuController: NSObject, NSMenuDelegate {
    
    @IBAction func toggleCurrent(_ sender: NSMenuItem) {
        switch sender.state {
        case .on:
            sender.state = .off
        case .off:
            sender.state = .on
        default:
            break
        }
    }
    
    /**
     Changes state for all menu items except number of items specified.
     - Parameter state:     the state to change to
     - Parameter in:        the menu to change
     - Parameter except:    the number of items at the end to ignore
    */
    func setMenuItemStateForAll(_ state: NSControl.StateValue, in menu: NSMenu, except numToIgnore: Int) {
        for menuItemNum in 0 ..< menu.items.count-numToIgnore {
            menu.items[menuItemNum].state = state
        }
    }
    
    /**
     Checks all menu items except the last 3
     (Select All, Select None and Seperator)
    */
    @IBAction func selectAll(_ sender: NSMenuItem) {
        if let menu = sender.menu {
            setMenuItemStateForAll(.on, in: menu, except: 3)
        }
    }
    
    /**
     Unchecks all menu items except the last 3
     (Select All, Select None and Seperator)
    */
    @IBAction func selectNone(_ sender: NSMenuItem) {
        if let menu = sender.menu {
            setMenuItemStateForAll(.off, in: menu, except: 3)
        }
    }
    
    override init() {
        super.init()
        infoPrint("", #function, self.className)
    }
}
