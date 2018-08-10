//
//  LessonsTabViewControllerObservers.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 10/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

extension Notification.Name {
    
    static var dataSourceNeedsSaving: Notification.Name {
        return .init(rawValue: "LessonsTabViewController.dataSourceNeedsSaving")
    }
    static var increaseLessonCount: Notification.Name {
        return .init(rawValue: "LessonsTabViewController.increaseLessonCount")
    }
    static var decreaseLessonCount: Notification.Name {
        return .init(rawValue: "LessonsTabViewController.decreaseLessonCount")
    }
    static var buildWordTypeMenu: Notification.Name {
        return .init(rawValue: "LessonsTabViewController.buildWordTypeMenu")
    }
}

// MARK: Observation Functions

extension LessonsTabViewController {
    
    func createDataSourceObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.setDataSourceNeedsSaving(_:)), name: .dataSourceNeedsSaving, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.increaseLessonCount(_:)), name: .increaseLessonCount, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.decreaseLessonCount(_:)), name: .decreaseLessonCount, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.buildWordTypeMenu(_:)), name: .buildWordTypeMenu, object: nil)
        //NotificationCenter.default.post(name: .startBuildWordTypeMenu, object:nil)
    }
    
    @objc func setDataSourceNeedsSaving(_ notification: Notification) {
        infoPrint("", #function, self.className)
        guard let dataSource = (self.tabView.selectedTabViewItem?.viewController as? BMTViewController)?.dataSource else { return }
        guard let currentTabItem = self.tabView.selectedTabViewItem else { return }
        if dataSource.needsSaving {
            return
        }
        dataSource.needsSaving = true
        if currentTabItem.label.left(1) != "*" {
            currentTabItem.label = "* \(currentTabItem.label)"
        }
    }
    
    @objc func increaseLessonCount(_ notification: Notification) {
        infoPrint("", #function, self.className)
        guard let lessonName = notification.userInfo?[UserInfo.Keys.lesson] as? String else { return }
        guard let dataSource = (self.tabView.selectedTabViewItem?.viewController as? BMTViewController)?.dataSource else { return }
        if let value = dataSource.lessons[lessonName] {
            dataSource.lessons[lessonName] = value + 1
        }
        else {
            dataSource.lessons[lessonName] = 1
        }
    }
    
    @objc func decreaseLessonCount(_ notification: Notification) {
        infoPrint("", #function, self.className)
        guard let lessonName = notification.userInfo?[UserInfo.Keys.lesson] as? String else { return }
        guard let dataSource = (self.tabView.selectedTabViewItem?.viewController as? BMTViewController)?.dataSource else { return }
        if let value = dataSource.lessons[lessonName] {
            dataSource.lessons[lessonName] = value - 1
            if value == 1 {
                dataSource.lessons[lessonName] = nil
            }
        }
    }
    
    @objc func buildWordTypeMenu(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if  let wordTypeMenu = notification.userInfo?[UserInfo.Keys.menu] as? NSMenu {
            
            while wordTypeMenu.items.count>3 {
                wordTypeMenu.removeItem(at: 0)
            }
            
            for tabItem in getWordsTabViewDelegate().tabViewItems {
                print("tabItem: \(tabItem)")
                NotificationCenter.default.post(name: .buildWordTypeMenuForTab, object: nil, userInfo: [UserInfo.Keys.tabItem : tabItem])
            }
        }
    }
}
