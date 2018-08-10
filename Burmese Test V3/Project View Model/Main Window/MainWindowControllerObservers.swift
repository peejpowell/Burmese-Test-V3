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
    static var newUrlAdded: Notification.Name {
        return .init(rawValue: "MainWindowController.newUrlAdded")
    }
    static var selectAllLanguages: Notification.Name {
        return .init(rawValue: "MainWindowController.selectAllLanguages")
    }
}

// MARK: Notification Observers
extension MainWindowController {
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.openPrefsWindow), name: .openPrefsWindow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeMainWindow(_:)), name: .closeMainWindow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeKeyboard(_:)), name: .changeKeyboard, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.newUrlAdded(_:)), name: .newUrlAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.selectAllLanguages(_:)), name: .selectAllLanguages, object: nil)
    }
}

extension MainWindowController {
    
    @objc func selectAllLanguages(_ notification: Notification) {
        mainWindowViewModel.selectAllLanguages(notification)
    }
    
    @objc func newUrlAdded(_ notification : Notification) {
        guard let url = notification.userInfo?[UserInfo.Keys.url] as? URL else { return }
        mainWindowViewModel.addUrlToRecentsMenu(url)
        mainWindowViewModel.windowTitleUrl = url
        mainWindowViewModel.windowUrl = url
    }
    
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
            let id = userInfo[UserInfo.Keys.id] as? String {
            switch id {
            case NSTextField.IdentifierKeys.burmese:
                setKeyboardByName(TISInputSource.KeyboardName.myanmar, type: .all)
            case NSTextField.IdentifierKeys.avalaser:
                setKeyboardByName(TISInputSource.KeyboardName.british, type: .ascii)
            default:
                guard let lessonTabViewController = mainTabViewController.wordsViewController.wordsTabViewController else { break }
                TISSelectInputSource(lessonTabViewController.originalInputLanguage)
            }
        }
    }
}
