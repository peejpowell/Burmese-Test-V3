//
//  TableViewDataSource.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class TableViewDataSource: NSObject, NSTableViewDataSource {

    //@IBOutlet var tableView : NSTableView!
    var fieldDelegate = TextFieldDelegate()
    var fieldEditor : NSTextView = NSTextView()
    
    var insertableVerbs  : Dictionary<String,Words> = Dictionary<String,Words>()
    var insertableNouns  : Dictionary<String,Words> = Dictionary<String,Words>()
    var insertablePeople : Dictionary<String,Words> = Dictionary<String,Words>()
    
    var sortAscending = true
    var sortBy: String = "KLesson"
    {
        didSet(oldValue)
        {
            if oldValue != sortBy
            {
                self.sortAscending = false
            }
        }
    }
    
    var words: [Words] = []
    var unfilteredWords: [Words]?
    var lessons: Dictionary<String,Int> = [:]
    var sourceFile : URL?
    var needsSaving : Bool = false
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let index = getCurrentIndex()
        if index != -1 {
            return getWordsTabViewDelegate().dataSources[index].words.count
        }
        return 0
    }
    
    override init() {
        super.init()
        infoPrint("new Datasource created",#function,self.className)
    }
    
    deinit {
        infoPrint("Datasource removed",#function,self.className)
        
    }
}

extension TableViewDataSource: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        
    }
    
    func tableViewColumnDidResize(_ notification: Notification) {
        
    }
    
    func tableViewColumnDidMove(_ notification: Notification) {
        
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        //infoPrint("", #function, self.className)
        
        let index = getCurrentIndex()
        
        if index != -1
        {
            let delegate = getWordsTabViewDelegate()
            if row >= delegate.dataSources[index].words.count {
                return NSTableCellView()
            }
            if delegate.dataSources[index].words.count == 0 {
                return NSTableCellView()
            }
            if delegate.dataSources[index].words[row].istitle || delegate.dataSources[index].words[row].wordindex == "#"
            {
                if let groupTitle = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "groupRow"), owner: delegate.dataSources[index]) as? NSTableCellView
                {
                    if let lesson = delegate.dataSources[index].words[row].lesson
                    {
                        groupTitle.textField?.stringValue = lesson.uppercased()
                    }
                    else
                    {
                        groupTitle.textField?.stringValue = ""
                    }
                    return groupTitle
                }
            }
            
            if let identifier = tableColumn?.identifier
            {
                if let colId = identifier.rawValue.left(identifier.rawValue.length() - 3)
                {
                    if let field = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: colId), owner: delegate.dataSources[index]) as? NSTableCellView
                    {
                        if let value = delegate.dataSources[index].words[row].wordKeys[colId]
                        {
                            field.textField?.textColor = NSColor.textColor
                            switch colId
                            {
                            case "KFilterType":
                                if let intValue = value as? Int
                                {
                                    if let filterType = Words.PJFilterType(rawValue: intValue)
                                    {
                                        switch filterType
                                        {
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
                            case "KBurmese":
                                field.textField?.font = NSFont(name: "Myanmar Census", size: 13)
                                field.textField?.stringValue = value as! String
                                field.textField?.delegate = self.fieldDelegate
                                field.textField?.isEditable = true
                                field.textField?.isEnabled = true
                                //return field
                                
                                
                            default:
                                if let stringValue = value as? String
                                {
                                    field.textField?.stringValue = stringValue
                                }
                                if let intValue = value as? Int
                                {
                                    field.textField?.stringValue = "\(intValue)"
                                }
                            }
                            if field.identifier?.rawValue != "avalaser"
                            {
                                field.textField?.delegate = self.fieldDelegate
                            }
                            field.textField?.target = self
                            field.textField?.isHighlighted = false
                            
                            if let _ = delegate.dataSources[index].unfilteredWords
                            {
                                field.textField?.isHighlighted = false
                                field.textField?.textColor = NSColor.textColor
                            }
                            else
                            {
// FIXME: Fix the following

/*                              if delegate.searchFieldDelegate.foundItems.count > 0
                                {
                                    for foundItem in delegate.searchFieldDelegate.foundItems
                                    {
                                        if foundItem.foundOnRow == row && foundItem.foundInField == identifier.rawValue
                                        {
                                            field.textField?.isHighlighted = true
                                            field.textField?.textColor = NSColor.blue
                                            break
                                        }
                                        else
                                        {
                                            field.textField?.isHighlighted = false
                                            field.textField?.textColor = NSColor.textColor
                                        }
                                    }
                                }*/
                            }
                        }
                        else
                        {
                            if colId == "KRowNumber"
                            {
                                field.textField?.stringValue = "\(row)"
                            }
                            if colId == "KAvalaser"
                            {
                                var oldStringToCheck : AnyObject?
                                
                                oldStringToCheck = delegate.dataSources[index].words[row].wordKeys["KBurmese"]
                                
                                field.textField?.font = NSFont(name: "AvalaserT1A", size: 20)
                                if let oldString = oldStringToCheck as? String
                                {
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
                                    for key in burmeseDict.keys
                                    {
                                        //let burmChar = burmeseChars[characterNum]
                                        //let avaChar = avalaserChars[characterNum]
                                        
                                        newString.replaceString(key, withString: burmeseDict[key]!)
                                        /*if newString.containsString(burmeseChars[characterNum])
                                         {
                                         //print("Word \(row), Found: \(burmChar), replaced: \(avaChar)")
                                         newString =
                                         newString.stringByReplacingOccurrencesOfString(burmChar, withString: avaChar)
                                         }*/
                                    }
                                    field.textField?.stringValue = newString as String
                                }
                                field.textField?.delegate = self.fieldDelegate
                                field.textField?.target = self
                            }
                            
                            //print("Couldn't get value \(appDelegate.dataSources![index].words[row].wordKeys[identifier])")
                        }
                        return field
                    }
                }
            }
        }
        let tableCellView = NSTableCellView()
        tableCellView.textField?.textColor = NSColor.red
        tableCellView.textField?.isHighlighted = false
        return tableCellView
    }
    
    
}

extension TableViewDataSource {
    
    func sortTable(_ tableView: NSTableView, sortBy: String)
    {
        infoPrint(nil, #function, self.className)
    }
}

