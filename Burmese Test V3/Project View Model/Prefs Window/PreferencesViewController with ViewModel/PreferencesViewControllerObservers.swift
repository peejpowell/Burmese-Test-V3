//
//  PreferencesViewControllerObservers.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 08/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

extension Notification.Name {
    static var selectPrefsGeneralTab: Notification.Name {
        return .init(rawValue: "PreferencesViewController.selectGeneralTab")
    }
    
    static var selectPrefsTableTab: Notification.Name {
        return .init(rawValue: "PreferencesViewController.selectTableTab")
    }
}

// MARK: Notification Functions

extension PreferencesViewController {
    
    func createObservers() {
        infoPrint("Creating Observers", #function, self.className)
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectGeneralTab(_:)),
                                               name: .selectPrefsGeneralTab, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectTableTab(_:)),
                                               name: .selectPrefsTableTab, object: nil)
    }
    
    // MARK: Prefs Tabs
    
    @objc func selectGeneralTab(_ sender: NSToolbarItem) {
        infoPrint("", #function, self.className)
        self.prefsTabView.selectTabViewItem(at: 0)
        self.view.window?.title = "General"
    }
    
    @objc func selectTableTab(_ sender: NSToolbarItem) {
        infoPrint("", #function, self.className)
        self.prefsTabView.selectTabViewItem(at: 1)
        self.view.window?.title = "Table"
    }
}
