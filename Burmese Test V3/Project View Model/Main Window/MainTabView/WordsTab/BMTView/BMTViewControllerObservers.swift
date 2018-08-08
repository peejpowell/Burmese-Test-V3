//
//  BMTViewControllerObservers.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 04/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

// MARK: TableView Notifications

extension Notification.Name {
    
    static var tableRowsNeedReloading: Notification.Name {
        return .init(rawValue: "BMTViewController.tableRowsNeedReloading")
    }
    static var tableNeedsReloading: Notification.Name {
        return .init(rawValue: "BMTViewController.tableNeedsReloading")
    }
    static var removeTableRow: Notification.Name {
        return .init(rawValue: "BMTViewController.removeTableRow")
    }
    static var columnVisibilityChanged: Notification.Name {
        return .init(rawValue: "BMTViewController.columnsVisibilityChanged")
    }
    static var toggleColumn: Notification.Name {
        return .init(rawValue: "BMTViewController.toggleColumn")
    }
    static var putTableRowOnPasteboard : Notification.Name {
        return .init(rawValue: "BMTViewController.putTableRowOnPasteboard")
    }
}

// MARK: Lessons Notifications

extension Notification.Name {
    
static var populateLessonsPopup: Notification.Name {
        return .init(rawValue: "WordsTabViewController.populateLessonsPopup")
    }
    static var jumpToLesson: Notification.Name {
        return .init(rawValue: "WordsTabViewController.jumpToLesson")
    }
    static var jumpToFirstRow: Notification.Name {
        return .init(rawValue: "WordsTabViewController.jumpToFirstRow")
    }
    static var jumpToLastRow: Notification.Name {
        return .init(rawValue: "WordsTabViewController.jumpToLastRow")
    }
}

// MARK: Clipboard Notifications

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

// MARK: Observer Setup

extension BMTViewController {
    
    func createTableViewObservers() {
        // Check if the observers already exist
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable(_:)), name: .tableNeedsReloading, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTableRows(_:)), name: .tableRowsNeedReloading, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeTableRow), name: .removeTableRow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleColumnWithId(_:)),name: .toggleColumn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.cutRows(_:)),name: .cutRows, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.copyRows(_:)),name: .copyRows, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.pasteRows(_:)),name: .pasteRows, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.populateLessonsPopup),name: .populateLessonsPopup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.jumpToLesson(_:)),name: .jumpToLesson, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.jumpToFirst(_:)),name: .jumpToFirstRow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.jumpToLast(_:)),name: .jumpToLastRow, object: nil)
        
    }
}

// MARK: TableView Notification Functions

extension BMTViewController {
    
    @objc func refreshTableRows(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if  let object = notification.userInfo as? [String: [IndexSet]],
            let indexes = object["indexes"] {
            // Unpack the dictionary
            var rowIndexes      : IndexSet = IndexSet()
            var columnIndexes   : IndexSet = IndexSet()
            rowIndexes = indexes[0]
            if indexes.count == 1 {
                columnIndexes = IndexSet(integersIn: 0..<tableView.tableColumns.count)
            }
            else {
                columnIndexes = indexes[1]
            }
            self.tableView.reloadData(forRowIndexes: rowIndexes, columnIndexes: columnIndexes)
        }
    }
    
    @objc func refreshTable(_ notification: Notification) {
        infoPrint("", #function, self.className)
        self.tableView.reloadData()
    }
    
    @objc func removeTableRow() {
        infoPrint("", #function, self.className)
        
        let rowIndexes = self.tableView.selectedRowIndexes
        
        var rowIndex = rowIndexes.last
        
        if rowIndex == nil {
            return
        }
        
        var counter = 0
        repeat {
            counter += 1
            //PJLog("deleting row \(rowIndex) - \(counter)")
            if let dataSource = self.tableView.dataSource as? TableViewDataSource {
                if rowIndex! < dataSource.lessonEntries.count {
                    // Check if there are no more lessons with the same name as the removed row
                    if let lesson = dataSource.lessonEntries[rowIndex!].lesson {
                        decreaseLessonCount(lesson)
                    }
                    
                    if let _ = dataSource.dataSourceViewModel.unfilteredLessonEntries {
                        let word = dataSource.lessonEntries[rowIndex!]
                        if word.filtertype != .add && word.filtertype != .change && word.filtertype != .delete {
                            if let filterRowIndex = word.filterindex {
                                dataSource.filterRowsToDelete.insert(filterRowIndex)
                            }
                        }
                    }
                }
                dataSource.dataSourceViewModel.removeLessonEntry(at: rowIndex!)
            }
            else {
                break
            }
            rowIndex = rowIndexes.integerLessThan(rowIndex!)
            if rowIndex == nil { break }
        } while rowIndex! >= rowIndexes.first!
        
        self.tableView.removeRows(at: rowIndexes, withAnimation: NSTableView.AnimationOptions.slideUp)
        //appDelegate.menuController.reIndexAllClick(NSMenuItem())
        
        tableView.selectRowIndexes(IndexSet(integer: rowIndexes.first!), byExtendingSelection: false)
        
        NotificationCenter.default.post(name: .dataSourceNeedsSaving, object: nil)
    }
    
    @objc func columnVisibilityChanged(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if  let hiddenColumnsDict = notification.userInfo as? [String:[String]],
            let hiddenColumns = hiddenColumnsDict["columnVisibilityChanged"] {
            for column in self.tableView.tableColumns {
                let id = column.identifier.rawValue
                let colId = id.minus(3)
                if hiddenColumns.contains(colId) {
                    column.isHidden = true
                }
                else {
                    column.isHidden = false
                }
            }
        }
    }
    
    @objc func toggleColumnWithId(_ notification: Notification) {
        infoPrint("", #function, self.className)
        
        var colToChange = ""
        var hideColumn = false
        if let tableView = self.tableView,
            let dict = notification.userInfo as? [String:String] {
            if let colToHide = dict["HideColumn"] {
                colToChange = colToHide
                hideColumn = true
            }
            if let colToShow = dict["ShowColumn"] {
                colToChange = colToShow
                hideColumn = false
            }
            for tableColumn in tableView.tableColumns {
                let id = tableColumn.identifier.rawValue
                let colName = id.minus(3)
                if colName == colToChange {
                    tableColumn.isHidden = hideColumn
                    resizeAllColumns()
                    break
                }
            }
        }
    }
    
    @objc func putTableRowsOnPasteboard(rowIndexes: IndexSet) {
        infoPrint("", #function, self.className)
        
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            if !tableView.selectedRowIndexes.isEmpty {
                let pBoard = NSPasteboard.general
                var myPasteArray = [LessonEntry]()
                for rowIndex in rowIndexes {
                    myPasteArray.append(dataSource.lessonEntries[rowIndex])
                }
                let data: Data = NSKeyedArchiver.archivedData(withRootObject: myPasteArray)
                pBoard.declareTypes([NSPasteboard.PasteboardType(rawValue: NSPasteboard.Name.general.rawValue)], owner: self)
                pBoard.setData(data, forType: NSPasteboard.PasteboardType(rawValue: "Words"))
                infoPrint("data copied", #function, self.className)
            }
        }
    }
}

// MARK: Lesson Notification Functions
extension BMTViewController {
    
    @objc func populateLessonsPopup(_ notification: Notification) {
        infoPrint("", #function, self.className)
        
        if  let currenTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
            let bmtVC = currenTabItem.viewController as? BMTViewController {
            if bmtVC != self {
                print("Wrong viewcontroller observing!")
                return
            }
        }
        // Make sure we are populating the lessonspopup with the right information
        if  let userInfo = notification.userInfo,
            let lessonsPopup = userInfo[UserInfo.Keys.lessonPopup] as? NSPopUpButton {
            if let dataSource = self.dataSource {
                dataSource.populateLessons(in: lessonsPopup)
            }
        }
    }
    
    @objc func jumpToLesson(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if  let userInfo = notification.userInfo,
            let senderTag = userInfo[UserInfo.Keys.tag] as? Int {
            self.tableView.selectRowIndexes(IndexSet(integer: senderTag), byExtendingSelection: false)
            let visibleRowRange = tableView.rows(in: tableView.visibleRect)
            let topRow = visibleRowRange.location
            let numberOfVisibleRows = visibleRowRange.length - 2
            if senderTag > topRow {
                self.tableView.scrollRowToVisible(senderTag + numberOfVisibleRows)
            }
            else {
                self.tableView.scrollRowToVisible(senderTag)
            }
            getMainWindowController().window?.makeFirstResponder(tableView)
        }
    }
    
    @objc func jumpToFirst(_ notification: Notification) {
        infoPrint("", #function, self.className)
        self.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        self.tableView.scrollRowToVisible(0)
        getMainWindowController().window?.makeFirstResponder(tableView)
    }
    
    @objc func jumpToLast(_ notification: Notification) {
        infoPrint("", #function, self.className)
        self.tableView.selectRowIndexes(IndexSet(integer: self.tableView.numberOfRows - 1), byExtendingSelection: false)
        self.tableView.scrollRowToVisible(self.tableView.numberOfRows - 1)
        
        getMainWindowController().window?.makeFirstResponder(tableView)
    }
}

// MARK: Clipboard Notifications
private extension BMTViewController {
    
    @objc func cutRows(_ notification: Notification) {
        infoPrint("", #function, self.className)
        let selectedRowIndexes = tableView.selectedRowIndexes
        // First put the relevant data on the pasteboard
        self.putTableRowsOnPasteboard(rowIndexes: selectedRowIndexes)
        // Update any filtered rows to remove them
        //self.updateFilteredRowsToDelete(rowIndexes: selectedRowIndexes)
        // Remove the table rows
        self.tableView.removeRows(at: selectedRowIndexes, withAnimation: .slideUp)
        // Remove the underlying data
        self.removeSelectedRowsFromDataSource(rowIndexes: selectedRowIndexes)
        NotificationCenter.default.post(name: .dataSourceNeedsSaving, object:nil)
    }
    
    @objc func copyRows(_ notification: Notification) {
        infoPrint("", #function, self.className)
        
        // First put the relevant data on the pasteboard
        self.putTableRowsOnPasteboard(rowIndexes: tableView.selectedRowIndexes)
    }
    
    @objc func pasteRows(_ notification: Notification) {
        self.pasteFromPasteboard()
    }
}

