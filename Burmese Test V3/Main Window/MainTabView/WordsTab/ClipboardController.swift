//
//  ClipboardController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 01/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class ClipboardController: NSObject {

    func moveToPasteBoard()
    {
        infoPrint("", #function, self.className)
        
        let index = getCurrentIndex()
        let tableView = getCurrentTableView()
        let dataSource = getWordsTabViewDelegate().dataSources[index]
        
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
        //FIXME: Enable the following later
        //self.putDataOnPasteboard(index, dragOperation: "move", filteredItems: getMainWindowController().findBarViewController.findMenuController.filterItems.state.rawValue == 1, searchResult: appDelegate.toolbarDelegate.searchResult)
        
        dataSource.needsSaving = true
    }
}
