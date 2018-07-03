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
    
    override func controlTextDidEndEditing(_ obj: Notification)
    {
        infoPrint("", #function, self.className)
        
        let wordsTabController = getWordsTabViewDelegate()
        if let textField = obj.object as? NSTextField {
            let index = getCurrentIndex()
            var oldValue : String?
            let dataSource = wordsTabController.dataSources[index]
            if let tableView = wordsTabController.tabViewControllersList[index].tableView {
                let row = tableView.row(for: textField)
                if row == -1 {
                    //print("No row found")
                    return
                }
                let column = tableView.column(for: textField)
                if column == -1 && !dataSource.words[row].istitle &&
                    dataSource.words[row].wordindex != "#" {
                    return
                }
                else if column == -1 {
                    oldValue = dataSource.words[row].lesson
                    dataSource.words[row].lesson = textField.stringValue
                }
                else {
                    //print("Editing word in tab \(index), row: \(row), column: \(column)")
                    if dataSource.words.count != 0 {
                        let id = tableView.tableColumns[column].identifier.rawValue
                        
                        switch id {
                        case "KBurmeseCol":
                            oldValue = dataSource.words[row].burmese
                            dataSource.words[row].burmese = textField.stringValue
                        case "KRomanCol":
                            oldValue = dataSource.words[row].roman
                            dataSource.words[row].roman = textField.stringValue
                        case "KEnglishCol":
                            oldValue = dataSource.words[row].english
                            dataSource.words[row].english = textField.stringValue
                        case "KLessonCol":
                            oldValue = dataSource.words[row].lesson
                            dataSource.words[row].lesson = textField.stringValue
                        case "KCategoryCol":
                            oldValue = dataSource.words[row].category
                            dataSource.words[row].category = textField.stringValue
                        case "KWordCategoryCol":
                            oldValue = dataSource.words[row].wordcategory
                            dataSource.words[row].wordcategory = textField.stringValue
                        default:
                            //print("Unhandled column: \(tableView.tableColumns[column].identifier.rawValue)")
                            break
                        }
                    }
                    else {
                        return
                    }
                }
                if let _ = dataSource.unfilteredWords {
                    if let value = oldValue {
                        if value != textField.stringValue {
                            if dataSource.words[row].filtertype != .add {
                                dataSource.words[row].filtertype = .change
                            }
                        }
                    }
                }
                switch tableView.tableColumns[column].identifier.rawValue {
                case "KLessonCol", "KCategoryCol", "KWordCategoryCol":
                    // Check if the value changed
                    if let oldValue = oldValue {
                        if textField.stringValue != oldValue {
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
                //tableView.reloadData(forRowIndexes: IndexSet(integer:tableView.row(for: textField)), columnIndexes: IndexSet(integersIn: NSRange(location:0,length:tableView.numberOfColumns).toRange() ?? 0..<0))
                tableView.reloadData()
            }
        }
        
        //Swift.print(#function)
        /*let delegate = getWordsTabViewDelegate()
        
        if let textField = obj.object as? NSTextField
        {
            let index = getCurrentIndex()
            var oldValue : String?
            let row = tableView.row(for: textField)
            if row == -1
            {
                //print("No row found")
                return
            }
            let column = tableView.column(for: textField)
            if column == -1 && !dataSource.words[row].istitle &&
                dataSource.words[row].wordindex != "#"
            {
                return
            }
            else if column == -1
            {
                oldValue = dataSource.words[row].lesson
                dataSource.words[row].lesson = textField.stringValue
            }
            else
            {
                //print("Editing word in tab \(index), row: \(row), column: \(column)")
                switch tableView.tableColumns[column].identifier.rawValue
                {
                case "KBurmeseCol":
                    oldValue = dataSource.words[row].burmese
                    dataSource.words[row].burmese = textField.stringValue
                case "KRomanCol":
                    oldValue = dataSource.words[row].roman
                    dataSource.words[row].roman = textField.stringValue
                case "KEnglishCol":
                    oldValue = dataSource.words[row].english
                    dataSource.words[row].english = textField.stringValue
                case "KLessonCol":
                    oldValue = dataSource.words[row].lesson
                    dataSource.words[row].lesson = textField.stringValue
                case "KCategoryCol":
                    oldValue = dataSource.words[row].category
                    dataSource.words[row].category = textField.stringValue
                case "KWordCategoryCol":
                    oldValue = dataSource.words[row].wordcategory
                    dataSource.words[row].wordcategory = textField.stringValue
                default:
                    //print("Unhandled column: \(tableView.tableColumns[column].identifier.rawValue)")
                    break
                }
            }
            if let _ = dataSource.unfilteredWords
            {
                if let value = oldValue
                {
                    if value != textField.stringValue
                    {
                        if dataSource.words[row].filtertype != .add
                        {
                            dataSource.words[row].filtertype = .change
                        }
                    }
                }
            }
            switch tableView.tableColumns[column].identifier.rawValue
            {
            case "KLessonCol", "KCategoryCol", "KWordCategoryCol":
                // Check if the value changed
                if let oldValue = oldValue
                {
                    if textField.stringValue != oldValue
                    {
                        delegate.menuController.reindexLesson(row)
                        delegate.menuController.reindexLesson(row+1)
                    }
                    else
                    {
                        //Swift.print("No need to reindex as no change in value of \(tableView.tableColumns[column].identifier.rawValue).")
                    }
                }
                
            default:
                break
            }
            //tableView.reloadData(forRowIndexes: IndexSet(integer:tableView.row(for: textField)), columnIndexes: IndexSet(integersIn: NSRange(location:0,length:tableView.numberOfColumns).toRange() ?? 0..<0))
            tableView.reloadData()
            
        }*/
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
        switch index
        {
        case -1:
            break
        default:
            let dataSource = getWordsTabViewDelegate().dataSources[index]
            if let tableView = getWordsTabViewDelegate().tabViewControllersList[index].tableView
            {
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
                    
                    let myObject = dataSource.words[row]
                    
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
                
                if editRow > 0 && editRow < dataSource.words.count {
                    while dataSource.words[editRow].istitle || dataSource.words[editRow].wordindex == "#" {
                        if editRow == dataSource.words.count {
                            break
                        }
                        if direction == .backwards {
                            editRow -= 1
                        }
                        else {
                            editRow += 1
                        }
                        if editRow == dataSource.words.count || editRow == 0 {
                            break
                        }
                    }
                }
                
                if editRow == 0 && (dataSource.words[editRow].istitle || dataSource.words[editRow].wordindex == "#") && direction == .backwards {
                    while dataSource.words[editRow].istitle || dataSource.words[editRow].wordindex == "#" {
                        editRow += 1
                    }
                    editColumn = firstEditableColumn
                }
                
                if editRow < 0 {
                    editRow = 0
                    editColumn = firstEditableColumn
                }
                else if editRow == dataSource.words.count {
                    if let copyOfRow = dataSource.words[editRow-1].copy() as? Words {
                        copyOfRow.filtertype = .add
                        copyOfRow.istitle = false
                        if let _ = copyOfRow.wordindex {
                            copyOfRow.wordindex!.increment()
                            copyOfRow.wordindex = copyOfRow.wordindex?.padBefore("0", desiredLength: 4)
                        }
                        
                        dataSource.words.append(copyOfRow)
                        
                        tableView.insertRows(at: IndexSet(integer:editRow), withAnimation: NSTableView.AnimationOptions.effectGap)
                        tableView.reloadData(forRowIndexes: IndexSet(integer:editRow), columnIndexes: IndexSet(integersIn: NSRange(location: 0, length: tableView.numberOfColumns).toRange() ?? 0..<0))
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
            
        }
        return returnValue
    }
}