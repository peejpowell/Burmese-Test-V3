//
//  MainMenuControllerObservers.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 04/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var enableFileMenuItems: Notification.Name {
        return .init(rawValue: "MainMenuController.enableFileMenuItems")
    }
    
    static var disableFileMenuItems: Notification.Name {
        return .init(rawValue: "MainMenuController.disableFileMenuItems")
    }
    
    static var enableRevert: Notification.Name {
        return .init(rawValue: "ManMenuController.enableRevert")
    }
    
    static var disableRevert: Notification.Name {
        return .init(rawValue: "ManMenuController.disableRevert")
    }
}

// MARK: Notification Observers

extension MainMenuController {
    
    @objc private func enableRevert(_ notification: Notification) {
        self.revertMenuItem.isEnabled = true
    }
    
    @objc func disableRevert(_ notification: Notification) {
        self.revertMenuItem.isEnabled = false
    }
    
    @objc func enableFileMenuItems(_ notification: Notification) {
        self.closeWordsFileMenuItem.isEnabled = true
        self.saveFileMenuItem.isEnabled = true
        self.saveAsFileMenuItem.isEnabled = true
    }
    
    @objc func disableFileMenuItems(_ notification: Notification) {
        self.closeWordsFileMenuItem.isEnabled = false
        self.saveFileMenuItem.isEnabled = false
        self.saveAsFileMenuItem.isEnabled = false
        self.revertMenuItem.isEnabled = false
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.enableFileMenuItems(_:)), name: .enableFileMenuItems, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.disableFileMenuItems(_:)), name: .disableFileMenuItems, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.enableRevert(_:)), name: .enableRevert, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.disableRevert(_:)), name: .disableRevert, object: nil)
    }
}
