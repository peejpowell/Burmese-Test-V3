//
//  MainTabViewControllerObservers.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 10/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation

// MARK: Notification Names

extension Notification.Name {
    
    static var selectLessonsTab: Notification.Name {
        return .init(rawValue: "mainTabViewController.selectLessonsTab")
    }
    
}

extension MainTabViewController {
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(selectLessonsTab(_:)), name: .selectLessonsTab, object: nil)
    }
    
    @objc func selectLessonsTab(_ notification: Notification) {
        self.tabView.selectTabViewItem(at: 2)
        let mainQueue = DispatchQueue.main
        mainQueue.asyncAfter(deadline: DispatchTime.now()+1, execute: {
            if let sender = notification.userInfo?[UserInfo.Keys.any] {
            NotificationCenter.default.post(name: .findClicked, object:nil, userInfo: [UserInfo.Keys.any:sender as Any])
            }}
        )
        
    }
}
