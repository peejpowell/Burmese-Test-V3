//
//  WordsViewControllerObservers.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 07/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var openRecentFile: Notification.Name {
        return .init(rawValue: "WordsViewController.openRecentFile")
    }
}

// MARK: Observation functions

extension WordsViewController {
    
    @objc func openRecentFile(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if  let userInfo = notification.userInfo,
            let url = userInfo[UserInfo.Keys.url] as? URL {
            //if let currentTabItem = wordsTabViewController.tabView.selectedTabViewItem {
            wordsTabViewModel.fileManager?.openRecentFile(url: url )
            //}
        }
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.openRecentFile(_:)), name: .openRecentFile, object: nil)
    }
}
