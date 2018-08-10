//
//  TableViewDataSourceViewModel.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 05/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

class TableViewDataSourceViewModel {
    
    var unfilteredLessonEntries: [LessonEntry]?
    var fieldDelegate = TextFieldDelegate()
    var lessonEntries: [LessonEntry] = []
    // Map table columns to field names
    var lessonColumnMap : [String] = ["RowNum",
                                 LessonEntryType.burmese.rawValue,
                                 "avalaser",
                                 LessonEntryType.roman.rawValue,
                                 LessonEntryType.english.rawValue,
                                 LessonEntryType.lesson.rawValue,
                                 LessonEntryType.filtertype.rawValue,
                                 LessonEntryType.categoryindex.rawValue,
                                 LessonEntryType.lessonEntryIndex.rawValue,
                                 LessonEntryType.category.rawValue,
                                 LessonEntryType.filterindex.rawValue,
                                 LessonEntryType.lessonEntryCategory.rawValue,
                                 LessonEntryType.insertion.rawValue
    ]
}

// MARK: Words Data Manipulation

extension TableViewDataSourceViewModel {
    
    public func appendLessonEntry(_ lessonEntry: LessonEntry) {
       lessonEntries.append(lessonEntry)
    }
    
    public func insertLessonEntry(_ lessonEntry: LessonEntry, at index: Int) {
        lessonEntries.insert(lessonEntry, at: index)
    }
    
    public func removeLessonEntry(at index: Int) {
        lessonEntries.remove(at: index)
    }
    
    public func updateLessonEntry(_ lessonEntry: LessonEntry, at index: Int)->LessonEntry {
        let oldLessonEntry = lessonEntries[index]
        lessonEntries[index] = lessonEntry
        return oldLessonEntry
    }
 
    public func removeAllLessonEntries()->Int {
        let numberOfEntries = lessonEntries.count
        lessonEntries.removeAll()
        return numberOfEntries
    }
    
    public func makeGroupTableCellView(for row: Int, in tableView: NSTableView, column: NSTableColumn?)->NSTableCellView? {
        if let groupTitle = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue:"groupRow"), owner: self) as? NSTableCellView {
            if let lesson = lessonEntries[row].lesson {
                groupTitle.textField?.stringValue = lesson.uppercased()
            }
            else {
                groupTitle.textField?.stringValue = ""
            }
            groupTitle.textField?.textColor = NSColor.white
            return groupTitle
        }
        return nil
    }
    
    func findColumnNumber(for identifier: NSUserInterfaceItemIdentifier, in tableView: NSTableView)->Int {
        for columnNum in 0..<tableView.tableColumns.count {
            if tableView.tableColumns[columnNum].identifier == identifier {
                return columnNum
            }
        }
        return -1
    }
    
    public func makeLessonEntryTableCellView(for row: Int, in tableView: NSTableView, column: NSTableColumn?)->NSTableCellView? {
        if  let column = column,
            let dataSource = tableView.dataSource {
            let colId = column.identifier.rawValue.minus(3)
            if let field = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: colId),
                                              owner: dataSource) as? NSTableCellView {
                if let value = lessonEntries[row].lessonEntryForKey(colId) {
                    field.textField?.textColor = NSColor.textColor
                    if let lessonType = LessonEntryType(rawValue: colId) {
                        switch lessonType {
                        case .filtertype:
                            if let intValue = Int(value) {
                                if let filterType = LessonEntry.LessonEntryFilterType(rawValue: intValue) {
                                    switch filterType {
                                    case .add:
                                    field.textField?.stringValue = "A"
                                    case .change:
                                    field.textField?.stringValue = "C"
                                    case .delete:
                                    field.textField?.stringValue = "D"
                                    case .none:
                                    field.textField?.stringValue = ""
                                    }
                                }
                            }
                            else {
                                field.textField?.stringValue = ""
                            }
                        case .burmese:
                            field.textField?.font = NSFont(name: "Myanmar Census", size: 13)
                            field.textField?.stringValue = value
                            field.textField?.delegate = fieldDelegate
                            field.textField?.isEditable = true
                            field.textField?.isEnabled = true
                        default:
                            if let value = lessonEntries[row].lessonEntryForKey(colId) {
                                field.textField?.stringValue = value
                                if let intValue = Int(value) {
                                    field.textField?.stringValue = "\(intValue)".padBefore("0", desiredLength: 4)
                                }
                            }
                        }
                        if field.identifier?.rawValue != "avalaser" {
                            field.textField?.delegate = self.fieldDelegate
                        }
                        field.textField?.target = self
                        field.textField?.isHighlighted = false
                        
                        if let _ = unfilteredLessonEntries {
                            field.textField?.isHighlighted = false
                            field.textField?.textColor = NSColor.textColor
                        }
                        else {
                            // Hilight the cells where a word has been found
                        }
                    }
                }
                else {
                    if colId == "KRowNumber" {
                        field.textField?.stringValue = "\(row)"
                    }
                    else if colId == "KAvalaser" {
                        var oldStringToCheck : AnyObject?
                        
                        oldStringToCheck = lessonEntries[row].burmese as AnyObject
                        
                        field.textField?.font = NSFont(name: "AvalaserT1A", size: 20)
                        if let oldString = oldStringToCheck as? String {
                            var newString: String = oldString
                            var burmeseDict : Dictionary<String,String> = [:]
                            burmeseDict["ခြေ"] = "e®K"
                            burmeseDict["ချ"] = "K¥"
                            burmeseDict["င်"] = "c\\"
                            burmeseDict["း"] = ";"
                            burmeseDict["ဝ"] = "w"
                            burmeseDict["တ်"] = "t\\"
                            burmeseDict["ထေ"] = "eT"
                            burmeseDict["ာ"] = "a"
                            burmeseDict["ါ"] = "å"
                            burmeseDict["က်"] = "k\\"
                            burmeseDict["ဗို"] = "biu"
                            burmeseDict["မျ"] = "m¥"
                            burmeseDict["ခုံ"] = "KuM"
                            burmeseDict["တေ"] = "et"
                            burmeseDict["ရ"] = "r"
                            burmeseDict["ည်"] = "v\\"
                            burmeseDict["ခေ"]="Ke"
                            burmeseDict["နှ"] = "n˙"
                            burmeseDict["နှု"] = "n˙u"
                            burmeseDict["ခ"] = "K"
                            burmeseDict["မ်"] = "m\\"
                            burmeseDict["ပ"] = "p"
                            burmeseDict["စ"] = "s"
                            burmeseDict["ပ်"] = "p\\"
                            burmeseDict["သွ"] = "q∑"
                            burmeseDict["လျှ"] = "lY"
                            burmeseDict["တ"] = "t"
                            burmeseDict["စ်"] = "s\\"
                            burmeseDict["ကို"] = "kiu"
                            burmeseDict["ယ်"] = "y\\"
                            burmeseDict["လုံ"] = "luM"
                            burmeseDict["မေ"] = "em"
                            burmeseDict["န"] = "n"
                            burmeseDict["ထ"] = "t"
                            burmeseDict["ဖ"] = "P"
                            burmeseDict["ပ"] = "p"
                            burmeseDict["ရွ"] = "r∑"
                            burmeseDict["လ"] = "l"
                            burmeseDict["ကေ"] = "ek"
                            burmeseDict["တံ"] = "tM"
                            burmeseDict["ဆ"] = "S"
                            burmeseDict["ချေ"] = "eK¥"
                            burmeseDict["ဖ"] = "P"
                            burmeseDict["နေ"] = "en"
                            burmeseDict["င့်"] = "c\\."
                            burmeseDict["သ"] = "q"
                            burmeseDict["ဦ"] = "√^"
                            burmeseDict["နှေ"] = "en˙"
                            burmeseDict["အ"] = "A"
                            burmeseDict["ရို"] = "Rui"
                            burmeseDict["ကြ"] = "Âk"
                            burmeseDict["ခြ"] = "®K"
                            burmeseDict["ကြေ"] = "eÂk"
                            burmeseDict["ကျ"] = "k¥"
                            burmeseDict["ကု"] = "ku"
                            burmeseDict["န်"] = "n\\"
                            burmeseDict["ကျေ"] = "ek¥"
                            burmeseDict["ဘ"] = "B"
                            burmeseDict["ပေ"] = "ep"
                            burmeseDict["ဒူ"] = "d¨"
                            burmeseDict["ညို့"] = "Viu>"
                            burmeseDict["ဆံ"] = "SM"
                            burmeseDict["ဖီ"] = "P^"
                            burmeseDict["စေ့"] = "es."
                            burmeseDict["စိ"] = "si"
                            burmeseDict["ဥ်"] = "√\\"
                            burmeseDict["ည့်"] = "v\\."
                            burmeseDict["မြ"] = "®m"
                            burmeseDict["တွေ့"] = "et∑>"
                            burmeseDict["ငို"] = "ciu"
                            burmeseDict["သေ"] = "eq"
                            burmeseDict["ပြုံ"] = "®pMo"
                            burmeseDict["ရီ"] = "r^"
                            burmeseDict["က"] = "k"
                            burmeseDict["ပြေ"] = "e®p"
                            burmeseDict["အေ"] = "eA"
                            burmeseDict["ာ်"] = "a\\"
                            burmeseDict["ညွှ"] = "VW"
                            burmeseDict["ပြ"] = "®p"
                            burmeseDict["ရေ"] = "er"
                            burmeseDict["လျှေ"] = "elYH"
                            burmeseDict["ထို"] = "Tiu"
                            burmeseDict["မ"] = "m"
                            burmeseDict["အိ"] = "Ai"
                            burmeseDict["ချီ"] = "K¥^"
                            burmeseDict["လွ"] = "l∑"
                            burmeseDict["ရေ"] = "er"
                            burmeseDict["ထူ"] = "T¨"
                            burmeseDict["လို့"] = "liu≥"
                            burmeseDict["ဘူ"] = "B¨"
                            burmeseDict["မှ"] = "m˙"
                            burmeseDict["ဖု"] = "Pu"
                            burmeseDict["လို"] = "liu"
                            burmeseDict["ဖို"] = "Piu"
                            burmeseDict["တို"] = "tiu"
                            burmeseDict["ပီ"] = "pˆ"
                            burmeseDict["ကူ"] = "k¨"
                            burmeseDict["တွေ"] = "et∑"
                            burmeseDict["ခို"] = "Kiu"
                            burmeseDict["ခု"] = "Ku"
                            burmeseDict["ပဲ"] = "p´"
                            burmeseDict["ဓ"] = "m"
                            burmeseDict["ပုံ"] = "pMu"
                            burmeseDict["ဖြေ"] = "e®P"
                            burmeseDict["နို"] = "niu"
                            burmeseDict["ငံ"] = "cM"
                            burmeseDict["ဟ"] = "h"
                            burmeseDict["တီ"] = "t^"
                            burmeseDict["လု"] = "lu"
                            burmeseDict["ဒီ"] = "d^"
                            burmeseDict["ာ့"] = "a."
                            burmeseDict["သီ"] = "q^"
                            burmeseDict["ဆို"] = "Siu"
                            burmeseDict["ဗ"] = "b"
                            burmeseDict["သူ"] = "q¨"
                            burmeseDict["လှ"] = "l˙"
                            burmeseDict["မေ့"] = "em."
                            burmeseDict["န့"] = "n."
                            
                            for key in burmeseDict.keys {
                                newString.replaceString(key, withString: burmeseDict[key]!)
                            }
                            field.textField?.stringValue = newString as String
                        }
                        field.textField?.delegate = self.fieldDelegate
                        field.textField?.target = self
                    }
                    else {
                        field.textField?.stringValue = ""
                        field.textField?.delegate = self.fieldDelegate
                        field.textField?.isEditable = true
                        field.textField?.isEnabled = true
                    }
                }
                return field
            }
        }
        return nil
    }
}
