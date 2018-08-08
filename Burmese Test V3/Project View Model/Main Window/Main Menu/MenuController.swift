//
//  PJMenuController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 28/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class MenuController: NSObject, NSMenuDelegate {
    
    override init() {
        super.init()
        infoPrint("", #function, self.className)
    }
}
enum MenuTitle {
    static let wordType = "Word Type"
}

extension MenuController {
    
    /**
     Checks the state of all menu items in the specified menu.
     - Parameter menu: the menu to check
     - Returns:         true if all are off
                        false if any are on.
     */
    func allMenuItemsAreOff(in menu: NSMenu)->Bool {
        for item in menu.items {
            if item.state == .on {
                return false
            }
        }
        return true
    }
    
    /**
     Toggles between on and off for the sender
     - Parameter sender: the menu item to toggle
     */
    @IBAction func toggleCurrent(_ sender: NSMenuItem) {
        switch sender.state {
        case .on:
            sender.state = .off
            guard let menu = sender.menu else { return }
            if allMenuItemsAreOff(in: menu) {
                let menuItem = menu.supermenu?.item(withTitle: menu.title)
                menuItem?.state = .off
            }
        case .off:
            sender.state = .on
            guard let menu = sender.menu else { return }
            if menu.supermenu?.title == MenuTitle.wordType {
                let menuItem = menu.supermenu?.item(withTitle: menu.title)
                menuItem?.state = .on
            }
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
        guard let menu = sender.menu  else { return }
        setMenuItemStateForAll(.on, in: menu, except: 3)
        if menu.supermenu?.title == MenuTitle.wordType {
            let menuItem = menu.supermenu?.item(withTitle: menu.title)
            menuItem?.state = .on
        }
    }
    
    /**
     Unchecks all menu items except the last 3
     (Select All, Select None and Seperator)
     */
    @IBAction func selectNone(_ sender: NSMenuItem) {
        guard let menu = sender.menu  else { return }
        
        setMenuItemStateForAll(.off, in: menu, except: 3)
        if menu.supermenu?.title == MenuTitle.wordType {
            let menuItem = menu.supermenu?.item(withTitle: menu.title)
            menuItem?.state = .off
        }
    
    }
}
