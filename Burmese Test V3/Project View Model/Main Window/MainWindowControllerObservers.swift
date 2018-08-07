//
//  MainWindowControllerObservers.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 04/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa
import Carbon

extension Notification.Name {
    static var openPrefsWindow: Notification.Name {
        return .init(rawValue: "MainWindowController.openPrefsWindow")
    }
    static var closeMainWindow: Notification.Name {
        return .init(rawValue: "MainWindowController.closeMainWindow")
    }
    static var changeKeyboard: Notification.Name {
        return .init(rawValue: "MainWindowController.changeKeyboard")
    }
}

// MARK: Notification Observers
extension MainWindowController {
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.openPrefsWindow), name: .openPrefsWindow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeMainWindow(_:)), name: .closeMainWindow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeKeyboard(_:)), name: .changeKeyboard, object: nil)
    }
}

extension MainWindowController {
    
    @objc func openPrefsWindow() {
        if let prefsWindow = self.prefsWindowController.window {
            NSApplication.shared.runModal(for: prefsWindow)
        }
    }

    @objc func closeMainWindow(_ notification: Notification) {
        getMainWindowController().close()
        
    }
    
    @objc func changeKeyboard(_ notification: Notification) {
        if  let userInfo = notification.userInfo,
            let id = userInfo["id"] as? String {
            switch id {
            case "burmese":
                setKeyboardByName("Myanmar", type: .all)
            case "avalaser":
                setKeyboardByName("British", type: .ascii)
            default:
                TISSelectInputSource(getWordsTabViewDelegate().originalInputLanguage)
            }
        }
    }
}
