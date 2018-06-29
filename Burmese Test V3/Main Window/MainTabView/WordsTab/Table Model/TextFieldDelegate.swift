//
//  TextFieldDelegate.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 27/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class TextFieldDelegate: NSObject, NSTextFieldDelegate {
    
    override func controlTextDidEndEditing(_ obj: Notification)
    {
        //Swift.print(#function)
        /*let delegate = getWordsTabViewDelegate()
        
        if let textField = obj.object as? NSTextField
        {
            let index = getCurrentIndex()
            var oldValue : String?
            let row = delegate.tableTemplate.row(for: textField)
            if row == -1
            {
                //print("No row found")
                return
            }
            let column = delegate.tableTemplate.column(for: textField)
            if column == -1 && !delegate.dataSources![index].words[row].istitle &&
                delegate.dataSources![index].words[row].wordindex != "#"
            {
                return
            }
            else if column == -1
            {
                oldValue = delegate.dataSources![index].words[row].lesson
                delegate.dataSources![index].words[row].lesson = textField.stringValue
            }
            else
            {
                //print("Editing word in tab \(index), row: \(row), column: \(column)")
                switch delegate.tableTemplate.tableColumns[column].identifier.rawValue
                {
                case "KBurmeseCol":
                    oldValue = delegate.dataSources![index].words[row].burmese
                    delegate.dataSources![index].words[row].burmese = textField.stringValue
                case "KRomanCol":
                    oldValue = delegate.dataSources![index].words[row].roman
                    delegate.dataSources![index].words[row].roman = textField.stringValue
                case "KEnglishCol":
                    oldValue = delegate.dataSources![index].words[row].english
                    delegate.dataSources![index].words[row].english = textField.stringValue
                case "KLessonCol":
                    oldValue = delegate.dataSources![index].words[row].lesson
                    delegate.dataSources![index].words[row].lesson = textField.stringValue
                case "KCategoryCol":
                    oldValue = delegate.dataSources![index].words[row].category
                    delegate.dataSources![index].words[row].category = textField.stringValue
                case "KWordCategoryCol":
                    oldValue = delegate.dataSources![index].words[row].wordcategory
                    delegate.dataSources![index].words[row].wordcategory = textField.stringValue
                default:
                    //print("Unhandled column: \(delegate.tableTemplate.tableColumns[column].identifier.rawValue)")
                    break
                }
            }
            if let _ = delegate.dataSources![index].unfilteredWords
            {
                if let value = oldValue
                {
                    if value != textField.stringValue
                    {
                        if delegate.dataSources![index].words[row].filtertype != .add
                        {
                            delegate.dataSources![index].words[row].filtertype = .change
                        }
                    }
                }
            }
            switch delegate.tableTemplate.tableColumns[column].identifier.rawValue
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
                        //Swift.print("No need to reindex as no change in value of \(delegate.tableTemplate.tableColumns[column].identifier.rawValue).")
                    }
                }
                
            default:
                break
            }
            //delegate.tableTemplate.reloadData(forRowIndexes: IndexSet(integer:delegate.tableTemplate.row(for: textField)), columnIndexes: IndexSet(integersIn: NSRange(location:0,length:delegate.tableTemplate.numberOfColumns).toRange() ?? 0..<0))
            delegate.tableTemplate.reloadData()
            
        }*/
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool
    {
        return true
        /*
        //Swift.print(#function)
        let delegate = NSApplication.shared.delegate as! delegate
        let index = getCurrentIndex()
        var insertRowAt: Int?
        var returnValue = false
        enum PJDirection: Int
        {
            case backwards
            case forwards
            case unknown
        }
        
        var direction : PJDirection = .unknown
        
        if index != -1
        {
            let row = delegate.tableTemplate.row(for: control)
            let column = delegate.tableTemplate.column(for: control)
            
            var editColumn = column
            {
                didSet(oldValue)
                {
                    //print("editColumn = \(editColumn)")
                }
            }
            
            var editRow = row
            {
                didSet(oldValue)
                {
                    //print("editRow = \(editRow)")
                }
            }
            
            let lastEditableColumn : Int =
            {
                // Find the last column that is both visible and editable
                let numberOfColumns = delegate.tableTemplate.tableColumns.count-1
                
                for columnNum in 0 ..< delegate.tableTemplate.tableColumns.count
                {
                    let columnToCheck = delegate.tableTemplate.tableColumns[numberOfColumns - columnNum]
                    if !columnToCheck.isHidden && columnToCheck.isEditable
                    {
                        //print("lastEditableColumn: \(delegate.tableTemplate.tableColumns.count-1-columnNum)")
                        return numberOfColumns-columnNum
                    }
                }
                return -1
            }()
            
            let firstEditableColumn : Int =
            {
                // Find the first column that is both visible and editable
                
                for columnNum in 0 ..< delegate.tableTemplate.tableColumns.count
                {
                    let columnToCheck = delegate.tableTemplate.tableColumns[columnNum]
                    if !columnToCheck.isHidden && columnToCheck.isEditable
                    {
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
                
                let myObject = delegate.dataSources![index].words[row]
                
                if let controlId = control.identifier?.rawValue
                {
                    //print("control ID: \(controlId)")
                    if controlId != "avalaser"
                    {
                        control.stringValue = myObject.value(forKey: controlId.lowercased()) as! String
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
            
            if editColumn < column
            {
                //print("backwards")
                if editColumn != -1
                {
                    while delegate.tableTemplate.tableColumns[editColumn].isHidden || !delegate.tableTemplate.tableColumns[editColumn].isEditable && editColumn > -1
                    {
                        editColumn -= 1
                        if editColumn < 0
                        {
                            break
                        }
                    }
                }
            }
            else
            {
                //print("forwards")
            }
            
            if editColumn > firstEditableColumn && editColumn < lastEditableColumn
            {
                // Check the new column is visible and editable.  If not continue to the next one
                
                var editable = false
                while editable == false
                {
                    if delegate.tableTemplate.tableColumns[editColumn].isHidden || !delegate.tableTemplate.tableColumns[editColumn].isEditable
                    {
                        editColumn += 1
                    }
                    else
                    {
                        editable = true
                    }
                }
            }
            
            if editColumn > lastEditableColumn
            {
                editRow += 1
                editColumn = firstEditableColumn
            }
            else if editColumn < firstEditableColumn
            {
                editRow -= 1
                editColumn = lastEditableColumn
            }
            
            if editRow > 0 && editRow < delegate.dataSources![index].words.count
            {
                while delegate.dataSources![index].words[editRow].istitle || delegate.dataSources![index].words[editRow].wordindex == "#"
                {
                    if editRow == delegate.dataSources![index].words.count
                    {
                        break
                    }
                    if direction == .backwards
                    {
                        editRow -= 1
                    }
                    else
                    {
                        editRow += 1
                    }
                    if editRow == delegate.dataSources![index].words.count || editRow == 0
                    {
                        break
                    }
                }
            }
            
            if editRow == 0 && (delegate.dataSources![index].words[editRow].istitle || delegate.dataSources![index].words[editRow].wordindex == "#") && direction == .backwards
            {
                while delegate.dataSources![index].words[editRow].istitle || delegate.dataSources![index].words[editRow].wordindex == "#"
                {
                    editRow += 1
                }
                editColumn = firstEditableColumn
            }
            
            if editRow < 0
            {
                editRow = 0
                editColumn = firstEditableColumn
            }
            else if editRow == delegate.dataSources![index].words.count
            {
                if let copyOfRow = delegate.dataSources![index].words[editRow-1].copy() as? PJWords
                {
                    copyOfRow.filtertype = .add
                    copyOfRow.istitle = false
                    if let _ = copyOfRow.wordindex
                    {
                        copyOfRow.wordindex!.increment()
                        copyOfRow.wordindex = copyOfRow.wordindex?.padBefore("0", desiredLength: 4)
                    }
                    
                    delegate.dataSources![index].words.append(copyOfRow)
                    
                    delegate.tableTemplate.insertRows(at: IndexSet(integer:editRow), withAnimation: NSTableView.AnimationOptions.effectGap)
                    delegate.tableTemplate.reloadData(forRowIndexes: IndexSet(integer:editRow), columnIndexes: IndexSet(integersIn: NSRange(location: 0, length: delegate.tableTemplate.numberOfColumns).toRange() ?? 0..<0))
                }
            }
            //print("Editing column: \(delegate.tableTemplate.tableColumns[editColumn].identifier)")
            if delegate.tableTemplate.tableColumns[editColumn].identifier.rawValue == "KBurmeseCol"
            {
                //print("BURMESE COLUMN")
                //delegate.originalInputLanguage = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
                setKeyboardByName("Myanmar", type: .all)
                
                //changeInputLanguage("my", originalLang: delegate.originalInputLanguage)
                //delegate.currentInputSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
            }
            else if delegate.tableTemplate.tableColumns[editColumn].identifier.rawValue == "KAvalaserCol"
            {
                setKeyboardByName("British", type: .ascii)
            }
            else
            {
                //print("ENGLISH COLUMN")
                TISSelectInputSource(delegate.originalInputLanguage)
            }
            
            // Scroll to the newly created row
            
            if editRow == delegate.tableTemplate.numberOfRows-1
            {
                // Create a new row as a copy of the last one
                
                let rowRect = delegate.tableTemplate.rect(ofRow: editRow)
                let viewRect = delegate.tableTemplate.superview!.frame
                var scrollOrigin = rowRect.origin
                scrollOrigin.y = scrollOrigin.y + (rowRect.height - viewRect.height) / 2
                if scrollOrigin.y < 0
                {
                    scrollOrigin.y = 0
                }
                delegate.tableTemplate.superview?.animator().setBoundsOrigin(scrollOrigin)
            }
            
            //print("Editing column: \(editColumn), row: \(editRow)")
            delegate.tableTemplate.selectRowIndexes(IndexSet(integer:editRow), byExtendingSelection: false)
            delegate.tableTemplate.editColumn(editColumn, row: editRow, with: nil, select: true)
            
        }
        return returnValue*/
    }
}
