//
//  MainWindowViewModel.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 09/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

protocol ClipboardHandler {
    
    func cut(_ sender: Any?)
    
    func copy(_ sender: Any?)
    
    func paste(_ sender: Any?)
    
}

protocol FileMenuHandler {
    
    func createNewDocument(_ sender: Any?)
    
    func openDocument(_ sender: Any?)
    
    func closeDocument(_ sender: Any?)
    
    func saveDocument(_ sender: Any?)
    
    func saveDocumentAs(_ sender: Any?)
    
    func revertDocumentToSaved(_ sender: Any?)
    
}

protocol LessonTypeMenuHandler {
    
    func selectAllLessons(_ sender : NSMenuItem)
}

protocol LanguageMenuHandler {
    
    func selectAllLanguages(_ notification: Notification)
    
}

extension MainWindowViewModel: LanguageMenuHandler {
    
    func selectAllLanguages(_ notification: Notification) {
        guard let menuItem = notification.userInfo?[UserInfo.Keys.menuItem] as? NSMenuItem else { return }
        
        if  let lessonTypeMenuController = mainMenuController?.lessonTypeMenuController,
            let languageMenuController = mainMenuController?.languageMenuController {
            languageMenuController.selectAllLanguages(menuItem, lessonController: lessonTypeMenuController)
        }
    }
    
}

class MainWindowViewModel: NSObject {
    
    @IBOutlet private weak var toolbarController : ToolbarController!
    @IBOutlet private weak var mainMenuController : MainMenuController!
    
    var windowTitleUrl : URL? {
        didSet {
            guard let url = self.windowTitleUrl else { return }
            updateWindowTitle(from: url)
        }
    }
    
    var windowUrl : URL? {
        didSet {
            guard let url = self.windowUrl else { return }
            updateWindowUrl(from: url)
        }
    }
    
    var firstRecentFile : URL? {
        return mainMenuController.recentFiles.first
    }
    
    var closeWordsIsEnabled : Bool {
        return mainMenuController.closeWordsFileMenuItem.isEnabled
    }
    
    var controller : MainWindowController?
    
    func addUrlToRecentsMenu(_ url: URL) {
        mainMenuController.updateRecentsMenu(with: url)
    }
    
    func updateWindowTitle(from url: URL) {
        controller?.window?.title = url.lastPathComponent
    }
    
    func updateWindowUrl(from url: URL ) {
        controller?.window?.representedURL = url
    }
}

extension MainWindowViewModel {
    
    func loadRecentFiles() {
        mainMenuController.loadRecentFiles(UserDefaults.standard)
    }
    
}

extension MainWindowViewModel: FileMenuHandler {
    
    func createNewDocument(_ sender: Any?) {
        infoPrint("",#function,self.className)
        controller?.mainTabViewController.selectTab(at: 2)
        mainMenuController.newDocument(sender)
    }
    
    func openDocument(_ sender: Any?) {
        mainMenuController.openDocument(sender)
    }
    
    func closeDocument(_ sender: Any?) {
        mainMenuController.performClose(sender)
    }
    
    func saveDocument(_ sender: Any?) {
        mainMenuController.saveDocument(sender)
    }
    
    func saveDocumentAs(_ sender: Any?) {
        mainMenuController.saveDocumentAs(sender)
    }
    
    func revertDocumentToSaved(_ sender: Any?) {
        mainMenuController.revertDocumentToSaved(sender)
    }

}

extension MainWindowViewModel: ClipboardHandler
{

    func cut(_ sender: Any?) {
        mainMenuController.cut(sender)
    }
    
    func copy(_ sender: Any?) {
        mainMenuController.copy(sender)
    }
    
    func paste(_ sender: Any?) {
        mainMenuController.paste(sender)
    }
    
}
