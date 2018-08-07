//
//  TextFieldDelegate.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 27/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa
import Carbon

class TextFieldDelegate: NSObject, NSTextFieldDelegate {
    
    enum Direction: Int
    {
        case backwards
        case forwards
        case unknown
    }
    
    func findTableView(for view: NSView)->NSTableView? {
        var viewToCheck = view
        
        while viewToCheck.superview != nil {
            if let tableView = viewToCheck as? PJTableView {
                return tableView
            }
            if let superview = viewToCheck.superview {
                viewToCheck = superview
            }
            else {
                return nil
            }
        }
        return nil
    }
    
    override func controlTextDidEndEditing(_ obj: Notification)
    {
        infoPrint("", #function, self.className)
        
        if  let textField = obj.object as? NSTextField,
            let tableView = findTableView(for: textField),
            let dataSource = tableView.dataSource as? TableViewDataSource {
            var oldValue : String?
            
            let row = tableView.row(for: textField)
            if row == -1 {
                //print("No row found")
                return
            }
            let column = tableView.column(for: textField)
            if column == -1 && !dataSource.lessonEntries[row].istitle &&
                dataSource.lessonEntries[row].lessonEntryIndex != "#" {
                return
            }
            else if column == -1 {
                oldValue = dataSource.lessonEntries[row].lesson
                dataSource.lessonEntries[row].lesson = textField.stringValue
            }
            else {
                //print("Editing word in tab \(index), row: \(row), column: \(column)")
                if dataSource.lessonEntries.count != 0 {
                    let id = tableView.tableColumns[column].identifier.rawValue
                    
                    switch id {
                    case "\(LessonEntryType.burmese.rawValue)Col":
                        oldValue = dataSource.lessonEntries[row].burmese
                        dataSource.lessonEntries[row].burmese = textField.stringValue
                    case "\(LessonEntryType.roman.rawValue)Col":
                        oldValue = dataSource.lessonEntries[row].roman
                        dataSource.lessonEntries[row].roman = textField.stringValue
                    case "\(LessonEntryType.english.rawValue)Col":
                        oldValue = dataSource.lessonEntries[row].english
                        dataSource.lessonEntries[row].english = textField.stringValue
                    case "\(LessonEntryType.lesson.rawValue)Col":
                        oldValue = dataSource.lessonEntries[row].lesson
                        dataSource.lessonEntries[row].lesson = textField.stringValue
                    case "\(LessonEntryType.category.rawValue)Col":
                        oldValue = dataSource.lessonEntries[row].category
                        dataSource.lessonEntries[row].category = textField.stringValue
                    case "\(LessonEntryType.lessonEntryCategory.rawValue)Col":
                        oldValue = dataSource.lessonEntries[row].lessonEntryCategory
                        dataSource.lessonEntries[row].lessonEntryCategory = textField.stringValue
                    default:
                        //print("Unhandled column: \(tableView.tableColumns[column].identifier.rawValue)")
                        break
                    }
                }
                else {
                    return
                }
            }
            if let _ = dataSource.dataSourceViewModel.unfilteredLessonEntries {
                if let value = oldValue {
                    if value != textField.stringValue {
                        if dataSource.lessonEntries[row].filtertype != .add {
                            dataSource.lessonEntries[row].filtertype = .change
                        }
                    }
                }
            }
            switch tableView.tableColumns[column].identifier.rawValue {
            case "\(LessonEntryType.lesson.rawValue)Col", "\(LessonEntryType.category.rawValue)Col", "\(LessonEntryType.lessonEntryCategory.rawValue)Col":
                // Check if the value changed
                if let oldValue = oldValue {
                    if textField.stringValue != oldValue {
                        //let bmtController = bmtVC
                        //bmtController.indexAll(nil)
                        
                        //bmtController.indexLessonForRow(row: row)
                        //bmtController.indexLessonForRow(row: row + 1)
                        
                        // FIXME: Write reindexLesson function
                        //delegate.menuController.reindexLesson(row)
                        //delegate.menuController.reindexLesson(row+1)
                    }
                    else {
                        //Swift.print("No need to reindex as no change in value of \(tableView.tableColumns[column].identifier.rawValue).")
                    }
                }
                
            default:
                break
            }
            //tableView.reloadData()
            tableView.reloadData(forRowIndexes: IndexSet(integer:tableView.row(for: textField)), columnIndexes: IndexSet(integersIn: NSRange(location:0,length:tableView.numberOfColumns).toRange() ?? 0..<0))
            //NotificationCenter.default.post(name: .tableNeedsReloading, object: nil)
        }
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool
    {
        infoPrint("", #function, self.className)
        
        let index = getCurrentIndex()
        var insertRowAt: Int?
        var returnValue = false
        
        var direction : Direction = .unknown
        
        var row = -1
        var column = -1
        var editColumn = column {
            didSet(oldValue) {
                //print("editColumn = \(editColumn)")
            }
        }
        var editRow = row {
            didSet(oldValue) {
                //print("editRow = \(editRow)")
            }
        }
        if  let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource,
            let tableView = bmtVC.tableView {
            let row = tableView.row(for: control)
            let column = tableView.column(for: control)
            
            var editColumn = column {
                didSet(oldValue) {
                    //print("editColumn = \(editColumn)")
                }
            }
            
            var editRow = row {
                didSet(oldValue) {
                    //print("editRow = \(editRow)")
                }
            }
            
            let lastEditableColumn : Int = {
                // Find the last column that is both visible and editable
                let numberOfColumns = tableView.tableColumns.count-1
                
                for columnNum in 0 ..< tableView.tableColumns.count {
                    let columnToCheck = tableView.tableColumns[numberOfColumns - columnNum]
                    if !columnToCheck.isHidden && columnToCheck.isEditable {
                        //print("lastEditableColumn: \(tableView.tableColumns.count-1-columnNum)")
                        return numberOfColumns-columnNum
                    }
                }
                return -1
            }()
            
            let firstEditableColumn : Int = {
                // Find the first column that is both visible and editable
                
                for columnNum in 0 ..< tableView.tableColumns.count {
                    let columnToCheck = tableView.tableColumns[columnNum]
                    if !columnToCheck.isHidden && columnToCheck.isEditable {
                        //print("firstEditableColumn: \(columnNum)")
                        return columnNum
                    }
                }
                return -1
            }()
            
            switch commandSelector
            {
            case #selector(NSResponder.insertNewline(_:)):
                // MARK: insertNewline:
                editRow += 1
                direction = .forwards
                returnValue = true
            case #selector(NSResponder.cancelOperation(_:)):
                // MARK: cancelOperation:
                
                let myObject = dataSource.lessonEntries[row]
                
                if let controlId = control.identifier?.rawValue {
                    //print("control ID: \(controlId)")
                    if controlId != "avalaser" {
                        if let lowerCaseId = myObject.value(forKey: controlId.lowercased()) as? String {
                            control.stringValue = lowerCaseId
                        }
                    }
                }
                returnValue = true
            case #selector(NSResponder.moveDown(_:)):
                // MARK: moveDown:
                // Move to the next row and the same column and start editing
                editRow += 1
                direction = .forwards
                returnValue = true
            case #selector(NSResponder.moveUp(_:)):
                // MARK: moveUp:
                // Move to the previous row and the same column and start editing
                editRow -= 1
                direction = .backwards
                returnValue = true
            case #selector(NSResponder.insertTab(_:)):
                // MARK: insertTab:
                editColumn += 1
                direction = .forwards
                returnValue = true
            case #selector(NSResponder.insertBacktab(_:)):
                // MARK: insertBackTab:
                editColumn -= 1
                direction = .backwards
                returnValue = true
            default:
                //print("Unhandled commandSelector: \(commandSelector)")
                return false
            }
            
            // Check if the column to edit is greater than lastEditableColumn
            
            if editColumn < column {
                //print("backwards")
                if editColumn != -1 {
                    while tableView.tableColumns[editColumn].isHidden || !tableView.tableColumns[editColumn].isEditable && editColumn > -1 {
                        editColumn -= 1
                        if editColumn < 0 {
                            break
                        }
                    }
                }
            }
            
            if editColumn > firstEditableColumn && editColumn < lastEditableColumn {
                // Check the new column is visible and editable.  If not continue to the next one
                
                var editable = false
                while editable == false {
                    if tableView.tableColumns[editColumn].isHidden || !tableView.tableColumns[editColumn].isEditable {
                        editColumn += 1
                    }
                    else {
                        editable = true
                    }
                }
            }
            
            if editColumn > lastEditableColumn {
                editRow += 1
                editColumn = firstEditableColumn
            }
            else if editColumn < firstEditableColumn {
                editRow -= 1
                editColumn = lastEditableColumn
            }
            
            if editRow > 0 && editRow < dataSource.lessonEntries.count {
                while dataSource.lessonEntries[editRow].istitle || dataSource.lessonEntries[editRow].lessonEntryIndex == "#" {
                    if editRow == dataSource.lessonEntries.count {
                        break
                    }
                    if direction == .backwards {
                        editRow -= 1
                    }
                    else {
                        editRow += 1
                    }
                    if editRow == dataSource.lessonEntries.count || editRow == 0 {
                        break
                    }
                }
            }
            
            if editRow == 0 && (dataSource.lessonEntries[editRow].istitle || dataSource.lessonEntries[editRow].lessonEntryIndex == "#") && direction == .backwards {
                while dataSource.lessonEntries[editRow].istitle || dataSource.lessonEntries[editRow].lessonEntryIndex == "#" {
                    editRow += 1
                }
                editColumn = firstEditableColumn
            }
            
            if editRow < 0 {
                editRow = 0
                editColumn = firstEditableColumn
            }
            else if editRow == dataSource.lessonEntries.count {
                if let copyOfRow = dataSource.lessonEntries[editRow-1].copy() as? LessonEntry {
                    copyOfRow.filtertype = .add
                    copyOfRow.istitle = false
                    if let _ = copyOfRow.lessonEntryIndex {
                        copyOfRow.lessonEntryIndex!.increment()
                        copyOfRow.lessonEntryIndex = copyOfRow.lessonEntryIndex?.padBefore("0", desiredLength: 4)
                    }
                    
                    dataSource.dataSourceViewModel.lessonEntries.append(copyOfRow)
                    
                    tableView.insertRows(at: IndexSet(integer:editRow), withAnimation: NSTableView.AnimationOptions.effectGap)
                    tableView.reloadData(forRowIndexes: IndexSet(integer:editRow), columnIndexes: IndexSet(integersIn: 0..<tableView.numberOfColumns))
                }
            }
            //print("Editing column: \(tableView.tableColumns[editColumn].identifier)")
            let id = tableView.tableColumns[editColumn].identifier.rawValue
            
            switch id {
            case "KBurmeseCol":
                setKeyboardByName("Myanmar", type: .all)
            case "KAvalaserCol":
                setKeyboardByName("British", type: .ascii)
            default:
                TISSelectInputSource(getWordsTabViewDelegate().originalInputLanguage)
            }
            
            // Scroll to the newly created row
            
            if editRow == tableView.numberOfRows-1
            {
                // Create a new row as a copy of the last one
                
                let rowRect = tableView.rect(ofRow: editRow)
                let viewRect = tableView.superview!.frame
                var scrollOrigin = rowRect.origin
                scrollOrigin.y = scrollOrigin.y + (rowRect.height - viewRect.height) / 2
                if scrollOrigin.y < 0
                {
                    scrollOrigin.y = 0
                }
                tableView.superview?.animator().setBoundsOrigin(scrollOrigin)
            }
            
            //print("Editing column: \(editColumn), row: \(editRow)")
            tableView.selectRowIndexes(IndexSet(integer:editRow), byExtendingSelection: false)
            tableView.editColumn(editColumn, row: editRow, with: nil, select: true)
        }
        return returnValue
    }
}
