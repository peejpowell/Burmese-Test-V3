//
//  ClipboardController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 01/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static var cutRows: Notification.Name {
        return .init(rawValue: "ClipboardController.cutRows")
    }
    static var copyRows: Notification.Name {
        return .init(rawValue: "ClipboardController.copyRows")
    }
    static var pasteRows: Notification.Name {
        return .init(rawValue: "ClipboardController.pasteRows")
    }
}
class ClipboardController: NSObject {

    func moveToPasteBoard()
    {
        infoPrint("", #function, self.className)
        
        if  let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let tableView = bmtVC.tableView,
            let dataSource = bmtVC.dataSource {
            
            if let initialRowIndex = tableView.selectedRowIndexes.first {
                var rowIndex = initialRowIndex
                if let lesson = dataSource.words[rowIndex].lesson {
                    decreaseLessonCount(lesson)
                }
                if let last = tableView.selectedRowIndexes.last {
                    while rowIndex < last {
                        if let next = tableView.selectedRowIndexes.integerGreaterThan(rowIndex) {
                            rowIndex = next
                        }
                        if let lesson = dataSource.words[rowIndex].lesson {
                            decreaseLessonCount(lesson)
                        }
                    }
                }
            }
            dataSource.needsSaving = true
        }
        //self.putDataOnPasteboard()
        //FIXME: Enable the following later
        //self.putDataOnPasteboard(index, dragOperation: "move", filteredItems: getMainWindowController().findBarViewController.findMenuController.filterItems.state.rawValue == 1, searchResult: appDelegate.toolbarDelegate.searchResult)
    }
}
