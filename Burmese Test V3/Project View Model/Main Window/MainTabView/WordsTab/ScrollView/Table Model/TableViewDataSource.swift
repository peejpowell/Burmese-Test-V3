//
//  TableViewDataSource.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class TableViewDataSource: NSObject {

    var dataSourceViewModel = TableViewDataSourceViewModel()
    var lessonEntries : [LessonEntry] {
        return dataSourceViewModel.lessonEntries
    }
    var columnMap : [String] {
        return dataSourceViewModel.lessonColumnMap
    }
    
    //@IBOutlet var tableView : NSTableView!
    var fieldDelegate = TextFieldDelegate()
    var fieldEditor : NSTextView = NSTextView()
    
    var insertableVerbs  : Dictionary<String,LessonEntry> = Dictionary<String,LessonEntry>()
    var insertableNouns  : Dictionary<String,LessonEntry> = Dictionary<String,LessonEntry>()
    var insertablePeople : Dictionary<String,LessonEntry> = Dictionary<String,LessonEntry>()
    
    var sortAscending = true
    var sortBy: String = "KLesson" {
        didSet(oldValue) {
            if oldValue != sortBy {
                self.sortAscending = false
            }
        }
    }
    
    var filterRowsToDelete : IndexSet = IndexSet()
    var lessons: Dictionary<String,Int> = [:]
    var sourceFile : URL?
    var needsSaving : Bool = false {
        didSet(oldValue) {
            if needsSaving == true {
                NotificationCenter.default.post(name: .enableRevert, object: nil)
            }
            else {
                NotificationCenter.default.post(name: .disableRevert, object: nil)
            }
        }
    }
    
    func delOrCut() {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .removeTableRow, object: nil)
        
        /*switch appDelegate.prefsWindow.delegate as! PJPrefsWindowDelegate).useDelForCut.state
        {
        case NSControl.StateValue.on:
            appDelegate.menuController.cut(NSMenuItem())
        default:
            self.removeTableRow()
        }*/
    }
    
    override init() {
        super.init()
        infoPrint("new Datasource created - \(self)",#function,self.className)
    }
    
    deinit {
        infoPrint("Datasource removed - \(self)",#function,self.className)
        self.sourceFile = nil
    }
}

// MARK: Other Functions

extension TableViewDataSource {

    @objc func jumpToFirstRow(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .jumpToFirstRow, object: nil)
    }
    
    @objc func jumpToLastRow(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .jumpToLastRow, object: nil)
    }
    
    @objc func jumpToLesson(_ sender: NSMenuItem) {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .jumpToLesson, object: nil, userInfo:[UserInfo.Keys.tag : sender.tag, UserInfo.Keys.title : sender.title])
    }
    
    func populateLessons(in lessonPopup: NSPopUpButton) {
        infoPrint("", #function, self.className)
        // Populate the Lessons in the list
        // First remove all but the top and bottom items
        for _ in 1 ..< lessonPopup.itemArray.count-1 {
            lessonPopup.removeItem(at: 1)
        }
        
        var rowNum = -1
        var prevLesson = ""
        
        if let menu = lessonPopup.menu,
            let lastMenuItem = menu.items.last,
            let firstMenuItem = menu.items.first
        {
            firstMenuItem.action = #selector(jumpToFirstRow(_:))
            lastMenuItem.action = #selector(jumpToLastRow(_:))
            firstMenuItem.target = self
            lastMenuItem.target = self
            
            menu.removeAllItems()
            menu.addItem(firstMenuItem)
            
            for word in self.lessonEntries {
                rowNum += 1
                
                if let lesson = word.lesson {
                    if lesson != prevLesson {
                        // New Lesson reached, add to the popup menu with the rownum as the tag
                        
                        let newMenuItem = NSMenuItem(title: lesson, action: #selector(self.jumpToLesson(_:)), keyEquivalent: "")
                        newMenuItem.tag = rowNum
                        newMenuItem.target = self
                        menu.addItem(newMenuItem)
                    }
                    prevLesson = lesson
                }
            }
            menu.addItem(lastMenuItem)
        }
    }
}

//MARK: Delegate Functions

extension TableViewDataSource: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, didDrag tableColumn: NSTableColumn) {
        if  let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController {
            bmtVC.textFinderClient.resetSearch()
        }
    }
    
    func canDragRowsWithIndexes(_ rowIndexes: IndexSet, atPoint mouseDownPoint: NSPoint) -> Bool
    {
        infoPrint("", #function, self.className)
        
        return false
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        if self.lessonEntries.count == 0 {
            return false
        }
        if self.lessonEntries[row].lessonEntryIndex == "#" || self.lessonEntries[row].istitle {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn)
    {
        if let dataSource = tableView.dataSource as? TableViewDataSource {

            // Change the sort descriptor
            let columnId = tableColumn.identifier.rawValue.minus(3)
            switch dataSource.sortBy {
            case columnId:
                dataSource.sortAscending = !dataSource.sortAscending
            default:
                dataSource.sortBy = columnId
                dataSource.sortAscending = true
            }
            
            for column in tableView.tableColumns {
                tableView.setIndicatorImage(NSImage(), in: column)
                if column.title.containsString("(") {
                    column.title = column.title.minus(3)
                }
            }
            
            // Sort the relevant column
            dataSource.sortTable(tableView, sortBy: dataSource.sortBy)
            
            tableView.reloadData()
        }
    }
    
    func tableViewColumnDidResize(_ notification: Notification) {
        
    }
    
    func tableViewColumnDidMove(_ notification: Notification) {
        
    }
    
    @objc @IBAction func SearchTest(_ sender: Any) {
        let myTextFinder = TextFinderClient()
        //myTextFinder.tabIndex = 0
        print("Indexed: \(myTextFinder.calculateIndex())")
        print("Total Length: \(myTextFinder.stringLength())")
        var test = NSRange()
        var boundary = ObjCBool(false)
        // Search at each inex looking for the string to search for
        
        print("String at: 0 - \(myTextFinder.string(at: 0, effectiveRange: &test, endsWithSearchBoundary: &boundary))")
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        //infoPrint("", #function, self.className)
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            if row >= dataSource.lessonEntries.count {
                return nil
            }
            if dataSource.lessonEntries.count == 0 {
                return nil
            }
            if  dataSource.lessonEntries[row].istitle ||
                dataSource.lessonEntries[row].lessonEntryIndex == "#" {
                return dataSource.dataSourceViewModel.makeGroupTableCellView(for: row, in: tableView, column: tableColumn)
            }
            else {
                return dataSource.dataSourceViewModel.makeLessonEntryTableCellView(for: row, in: tableView, column: tableColumn)
            }
        }
            /*
            if let identifier = tableColumn?.identifier {
                let colId = identifier.rawValue.minus(3)
                //infoPrint("colid = \(colId)", #function, self.className)
                if let field = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: colId),
                                                  owner: dataSource) as? NSTableCellView {
                    if let value = dataSource.lessonEntries[row].lessonEntryForKey(colId) {
                        field.textField?.textColor = NSColor.textColor
                        switch colId {
                        case "KFilterType":
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
                        case "KBurmese":
                            field.textField?.font = NSFont(name: "Myanmar Census", size: 13)
                            field.textField?.stringValue = value
                            field.textField?.delegate = self.fieldDelegate
                            field.textField?.isEditable = true
                            field.textField?.isEnabled = true
                        default:
                            if let value = dataSource.lessonEntries[row].lessonEntryForKey(colId) {
                                field.textField?.stringValue = value
                                if let intValue = Int(value) {
                                    field.textField?.stringValue = "\(intValue)"
                                }
                            }
                        }
                        if field.identifier?.rawValue != "avalaser" {
                            field.textField?.delegate = self.fieldDelegate
                        }
                        field.textField?.target = self
                        field.textField?.isHighlighted = false
                        
                        if let _ = dataSource.unfilteredLessonEntries {
                            field.textField?.isHighlighted = false
                            field.textField?.textColor = NSColor.textColor
                        }
                        else {
                            // Hilight the cells where a word has been found
                        }
                    }
                    else
                    {
                        if colId == "KRowNumber" {
                            field.textField?.stringValue = "\(row)"
                        }
                        else if colId == "KAvalaser" {
                            var oldStringToCheck : AnyObject?
                            
                            oldStringToCheck = dataSource.lessonEntries[row].burmese as AnyObject
                            
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
                        else {
                            field.textField?.stringValue = ""
                            field.textField?.delegate = self.fieldDelegate
                            field.textField?.isEditable = true
                            field.textField?.isEnabled = true
                        }
                    }
                    return field
                }
            }*/
        let tableCellView = NSTableCellView()
        tableCellView.textField?.textColor = NSColor.red
        tableCellView.textField?.isHighlighted = false
        return tableCellView
    }
    
    
}

//MARK: DataSource Functions Extension

extension TableViewDataSource: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            return dataSource.lessonEntries.count
        }
        return 0
    }
    
    func sortTable(_ tableView: NSTableView, sortBy: String) {
        infoPrint("", #function, self.className)
        
        for tableColumn in tableView.tableColumns {
            tableView.setIndicatorImage(nil, in: tableColumn)
            if tableColumn.title.containsString("(") {
                let trimmedTitle = tableColumn.title.minus(3)
                tableColumn.title = trimmedTitle
            }
        }
        
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            var sortKey : SortKeys = .Lesson
            
            let sortIndicatorImage : NSImage = {
                switch dataSource.sortAscending {
                case true:
                    if let image = NSImage(named: "NSAscendingSortIndicator") {
                        return image
                    }
                case false:
                    if let image = NSImage(named: "NSDescendingSortIndicator") {
                        return image
                    }
                }
                return NSImage()
            }()
            
            switch dataSource.sortBy {
            case "KRoman","KBurmese", "KEnglish", "KCategory":
                if let localSortKey = SortKeys(rawValue: dataSource.sortBy) {
                    sortKey = localSortKey
                    tableView.setIndicatorImage(sortIndicatorImage, in: tableView.tableColumns[tableView.column(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "\(localSortKey.rawValue)Col"))])
                }
            case "KAvalaser":
                if let localSortKey = SortKeys(rawValue: "KBurmese") {
                    sortKey = localSortKey
                    tableView.setIndicatorImage(sortIndicatorImage, in: tableView.tableColumns[tableView.column(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "KBurmeseCol"))])
                }
            default:
                sortKey = .Lesson
                
                let lessonColumn    = tableView.tableColumns[tableView.column(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "KLessonCol"))]
                let categoryColumn  = tableView.tableColumns[tableView.column(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "KCategoryCol"))]
                let lessonEntryIndexColumn  = tableView.tableColumns[tableView.column(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "KLessonEntryIndexCol"))]
                
                tableView.setIndicatorImage(sortIndicatorImage, in: lessonColumn)
                
                if !lessonColumn.title.containsString("(") {
                    lessonColumn.title += " (1)"
                }
                
                tableView.setIndicatorImage(sortIndicatorImage, in: categoryColumn)
                
                if !categoryColumn.title.containsString("(") {
                    categoryColumn.title += " (2)"
                }
                
                tableView.setIndicatorImage(sortIndicatorImage, in: lessonEntryIndexColumn)
                
                if !lessonEntryIndexColumn.title.containsString("(") {
                    lessonEntryIndexColumn.title += " (3)"
                }
            }
            
            infoPrint("Sorting DataSource by \(dataSource.sortBy)...", #function, self.className)
            quicksort_source(&dataSource.dataSourceViewModel.lessonEntries, sortKey: sortKey,  start: 0, end: dataSource.dataSourceViewModel.lessonEntries.count, ascending: dataSource.sortAscending)
            infoPrint("Finished sorting.", #function, self.className)
        }
    }
    
    func quicksort_source(_ source:inout [LessonEntry], sortKey: SortKeys, start:Int, end:Int, ascending: Bool) {
        if (end - start < 2) {
            return
        }
        let p = source[start + (end - start)/2]
        var l = start
        var r = end - 1
        while (l <= r) {
            if ascending {
                switch sortKey {
                case .Burmese:
                    let leftBurmese = getLowerOrBlank(source[l].burmese)
                    let rightBurmese = getLowerOrBlank(source[r].burmese)
                    let pBurmese = getLowerOrBlank(p.burmese)
                    
                    if leftBurmese < pBurmese {
                        l += 1
                        continue
                    }
                    if rightBurmese > pBurmese {
                        r -= 1
                        continue
                    }
                case .Roman:
                    var leftRoman = getLowerOrBlank(source[l].roman)
                    var rightRoman = getLowerOrBlank(source[r].roman)
                    var pRoman = getLowerOrBlank(p.roman)
                    
                    leftRoman.foldString()
                    rightRoman.foldString()
                    pRoman.foldString()
                    
                    if leftRoman < pRoman {
                        l += 1
                        continue
                    }
                    if rightRoman > pRoman {
                        r -= 1
                        continue
                    }
                case .English:
                    let leftEnglish = getLowerOrBlank(source[l].english)
                    let rightEnglish = getLowerOrBlank(source[r].english)
                    let pEnglish = getLowerOrBlank(p.english)
                    
                    if leftEnglish < pEnglish {
                        l += 1
                        continue
                    }
                    if rightEnglish > pEnglish {
                        r -= 1
                        continue
                    }
                case .Lesson:
                    
                    let leftLesson = getLowerOrBlank(source[l].lesson)
                    let rightLesson = getLowerOrBlank(source[r].lesson)
                    let pLesson = getLowerOrBlank(p.lesson)
                    
                    let leftCategory = getLowerOrBlank(source[l].category)
                    let rightCategory = getLowerOrBlank(source[r].category)
                    let pCategory = getLowerOrBlank(p.category)
                    
                    let leftWordIndex = getLowerOrBlank(source[l].lessonEntryIndex)
                    let rightWordIndex = getLowerOrBlank(source[r].lessonEntryIndex)
                    let pWordIndex = getLowerOrBlank(p.lessonEntryIndex)
                    
                    if leftLesson < pLesson {
                        l += 1
                        continue
                    }
                    else if leftLesson == pLesson {
                        if leftCategory < pCategory {
                            l += 1
                            continue
                        }
                        else if leftCategory == pCategory {
                            if leftWordIndex < pWordIndex {
                                l += 1
                                continue
                            }
                        }
                    }
                    if rightLesson > pLesson {
                        r -= 1
                        continue
                    }
                    else if rightLesson == pLesson {
                        if rightCategory > pCategory {
                            r -= 1
                            continue
                        }
                        else if rightCategory == pCategory {
                            if rightWordIndex > pWordIndex {
                                r -= 1
                                continue
                            }
                        }
                    }
                case .Category:
                    
                    let leftCategory = getLowerOrBlank(source[l].category)
                    let rightCategory = getLowerOrBlank(source[r].category)
                    let pCategory = getLowerOrBlank(p.category)
                    
                    if leftCategory < pCategory {
                        l += 1
                        continue
                    }
                    if rightCategory > pCategory {
                        r -= 1
                        continue
                    }
                }
            }
            else {
                switch sortKey {
                case .Burmese:
                    let leftBurmese = getLowerOrBlank(source[l].burmese)
                    let rightBurmese = getLowerOrBlank(source[r].burmese)
                    let pBurmese = getLowerOrBlank(p.burmese)
                    
                    if leftBurmese > pBurmese {
                        l += 1
                        continue
                    }
                    if rightBurmese < pBurmese {
                        r -= 1
                        continue
                    }
                case .Roman:
                    var leftRoman = getLowerOrBlank(source[l].roman)
                    var rightRoman = getLowerOrBlank(source[r].roman)
                    var pRoman = getLowerOrBlank(p.roman)
                    
                    leftRoman.foldString()
                    rightRoman.foldString()
                    pRoman.foldString()
                    
                    if leftRoman > pRoman {
                        l += 1
                        continue
                    }
                    if rightRoman < pRoman {
                        r -= 1
                        continue
                    }
                case .English:
                    let leftEnglish = getLowerOrBlank(source[l].english)
                    let rightEnglish = getLowerOrBlank(source[r].english)
                    let pEnglish = getLowerOrBlank(p.english)
                    
                    if leftEnglish > pEnglish {
                        l += 1
                        continue
                    }
                    if rightEnglish < pEnglish {
                        r -= 1
                        continue
                    }
                case .Lesson:
                    
                    let leftLesson = getLowerOrBlank(source[l].lesson)
                    let rightLesson = getLowerOrBlank(source[r].lesson)
                    let pLesson = getLowerOrBlank(p.lesson)
                    
                    let leftCategory = getLowerOrBlank(source[l].category)
                    let rightCategory = getLowerOrBlank(source[r].category)
                    let pCategory = getLowerOrBlank(p.category)
                    
                    let leftWordIndex = getLowerOrBlank(source[l].lessonEntryIndex)
                    let rightWordIndex = getLowerOrBlank(source[r].lessonEntryIndex)
                    let pWordIndex = getLowerOrBlank(p.lessonEntryIndex)
                    
                    if leftLesson > pLesson {
                        l += 1
                        continue
                    }
                    else if leftLesson == pLesson {
                        if leftCategory > pCategory {
                            l += 1
                            continue
                        }
                        else if leftCategory == pCategory {
                            if leftWordIndex > pWordIndex {
                                l += 1
                                continue
                            }
                        }
                    }
                    if rightLesson < pLesson {
                        r -= 1
                        continue
                    }
                    else if rightLesson == pLesson {
                        if rightCategory < pCategory {
                            r -= 1
                            continue
                        }
                        else if rightCategory == pCategory {
                            if rightWordIndex < pWordIndex {
                                r -= 1
                                continue
                            }
                        }
                    }
                case .Category:
                    
                    let leftCategory = getLowerOrBlank(source[l].category)
                    let rightCategory = getLowerOrBlank(source[r].category)
                    let pCategory = getLowerOrBlank(p.category)
                    
                    if leftCategory > pCategory {
                        l += 1
                        continue
                    }
                    if rightCategory < pCategory {
                        r -= 1
                        continue
                    }
                }
            }
            let t = source[l]
            source[l] = source[r]
            source[r] = t
            l += 1
            r -= 1
        }
        quicksort_source(&source, sortKey: sortKey, start: start, end: r + 1, ascending: ascending)
        quicksort_source(&source, sortKey: sortKey, start: r + 1, end: end, ascending: ascending)
    }
    
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        infoPrint("", #function, self.className)
        if  let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let firstIndex = rowIndexes.first {
            bmtVC.indexLessonForRow(row: firstIndex)
        }
        getWordsTabViewDelegate().draggingRows = true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        infoPrint("", #function, self.className)
        
        if let currentEvent = NSApplication.shared.currentEvent {
            if currentEvent.modifierFlags.rawValue & NSEvent.ModifierFlags.option.rawValue == NSEvent.ModifierFlags.option.rawValue {
                print("Drag Copy row")
                return NSDragOperation.copy
            }
            else {
                print("Drag Move row")
                return NSDragOperation.move
            }
        }
        print("Drag Move row")
        
        return NSDragOperation()
    }
    
    func reindexRows(_ rowIndexes: IndexSet, dropOnRow: Int) {
        infoPrint("", #function, self.className)
        
        //let index = getCurrentIndex()
        
        for rowIndex in rowIndexes
        {
            print("index: \(rowIndex)")
            //dataSource[index].words[rowIndex].burmese = "\(__FUNCTION__)"
            //FIXME: write function to reindex
            //self.reindexLesson(rowIndex)
        }
        print("last index: \(rowIndexes.last! + rowIndexes.count)")
        
        //let firstDropRow = rowIndexes.firstIndex
        let firstDropRow = dropOnRow - (rowIndexes.count-1)
        //let lastDropRow = rowIndexes.lastIndex
        let lastDropRow = dropOnRow - 1
        
        if firstDropRow <= -1 && lastDropRow <= -1
        {
            //FIXME: write function to reindex
            //self.reindexLesson(0)
        }
        else
        {
            if rowIndexes.count == 1
            {
                //FIXME: write function to reindex
                //self.reindexLesson(dropOnRow)
                //dataSource[index].words[dropOnRow].burmese = "DROPPED"
            }
            else
            {
                for _ in firstDropRow ... lastDropRow
                {
                    //FIXME: write function to reindex
                    //appDelegate.menuController.reindexLesson(rowNum)
                    //dataSource[index].words[rowNum].burmese = "DROPPED"
                }
            }
        }
        //FIXME: write function to reindex
        //appDelegate.menuController.reindexLesson(dropOnRow)
        //appDelegate.menuController.reindexLesson(dropOnRow+1)
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        infoPrint("", #function, self.className)
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            let wordsTabController = getWordsTabViewDelegate()
            let pasteBoard = info.draggingPasteboard
            if let rowData = pasteBoard.data(forType: NSPasteboard.PasteboardType(rawValue: "Words")) {
                if let rowIndexes = NSKeyedUnarchiver.unarchiveObject(with: rowData) as? IndexSet {
                    var reIndexRowIndexes = IndexSet(rowIndexes)
                    
                    //var dataSource = appDelegate.mainDataController.data.dataSources[index] as [PJWords]
                    /*_ = dataSource
                     _ = [Int]()
                     _ = [PJWords]()
                     */
                    // Work out how many rows were before the row to insert at
                    
                    var rowCount = 0
                    var rowToCheck = rowIndexes.first
                    
                    while rowToCheck! < row {
                        rowCount = rowCount + 1
                        rowToCheck = rowIndexes.integerGreaterThan(rowToCheck!)
                        if rowToCheck == nil {break}
                    }
                    
                    // Make a new array of the data to copy and remove it from the datasource
                    
                    var wordsToInsert = [LessonEntry]()
                    for rowIndex in rowIndexes.reversed() {
                        if let _ = dataSource.dataSourceViewModel.unfilteredLessonEntries {
                            let word = dataSource.lessonEntries[rowIndex]
                            if word.filtertype != .add {
                                if let filterIndex = word.filterindex {
                                    dataSource.filterRowsToDelete.insert(filterIndex)
                                }
                            }
                        }
                        if info.draggingSourceOperationMask.rawValue & NSDragOperation.move.rawValue == NSDragOperation.move.rawValue {
                            wordsToInsert.append(dataSource.dataSourceViewModel.lessonEntries.remove(at: rowIndex) as LessonEntry)
                        }
                        else {
                            wordsToInsert.append(dataSource.lessonEntries[rowIndex])
                        }
                    }
                    /*var rowToCopy = rowIndexes.last
                     if rowToCopy != nil {
                     repeat {
                     // FIXME: Add unfiltered words functionality
                     if let _ = dataSource.unfilteredWords
                     {
                     let word = dataSource.dataSourceViewModel.lessonEntries[rowToCopy!]
                     if word.filtertype != .add
                     {
                     if let filterIndex = word.filterindex {
                     dataSource.filterRowsToDelete.insert(filterIndex)
                     }
                     }
                     }
                     if info.draggingSourceOperationMask.rawValue & NSDragOperation.move.rawValue == NSDragOperation.move.rawValue {
                     wordsToInsert.append(dataSource.dataSourceViewModel.lessonEntries.remove(at: rowToCopy!) as Words)
                     }
                     else {
                     wordsToInsert.append(dataSource.dataSourceViewModel.lessonEntries[rowToCopy!])
                     }
                     
                     //wordsToInsert.append(dataSource[index].words.removeAtIndex(rowToCopy) as PJWords)
                     rowToCopy = rowIndexes.integerLessThan(rowToCopy!)
                     if rowToCopy == nil { break }
                     } while rowToCopy! >= rowIndexes.first! && rowToCopy! <= rowIndexes.last!
                     }*/
                    // Calculate where we actually will insert the new rows
                    
                    var insertAtRow : Int = -1
                    
                    insertAtRow = row - rowCount
                    
                    for wordNum in 0 ..< wordsToInsert.count {
                        let wordtoInsert = wordsToInsert[wordNum]
                        if insertAtRow - 1 >= 0 {
                            let prevWord = dataSource.lessonEntries[insertAtRow-1]
                            if let _ = dataSource.dataSourceViewModel.unfilteredLessonEntries {
                                wordtoInsert.filtertype = .add
                                wordtoInsert.filterindex = prevWord.filterindex
                            }
                        }
                        else {
                            let nextWord = dataSource.lessonEntries[insertAtRow]
                            if let _ = dataSource.dataSourceViewModel.unfilteredLessonEntries {
                                wordtoInsert.filtertype = .add
                                wordtoInsert.filterindex = nextWord.filterindex
                            }
                        }
                        dataSource.dataSourceViewModel.insertLessonEntry(wordtoInsert, at: insertAtRow)
                    }
                    
                    let rowRange : NSRange = NSRange(location: insertAtRow, length: rowIndexes.count)
                    
                    reIndexRowIndexes.insert(insertAtRow)
                    //self.reindexRows(reIndexRowIndexes, dropOnRow: row)
                    wordsTabController.indexedRows.removeAll()
                    //appDelegate.mainDataController.reindexRows(reIndexRowIndexes, tableView: tableView, inSource: dataSource, deleting: true,reIndexingAll: false, editingText: false)
                    
                    tableView.beginUpdates()
                    if info.draggingSourceOperationMask.rawValue & NSDragOperation.move.rawValue == NSDragOperation.move.rawValue {
                        tableView.removeRows(at: rowIndexes, withAnimation: NSTableView.AnimationOptions.slideUp)
                    }
                    tableView.insertRows(at: IndexSet(integersIn: Range(rowRange)!), withAnimation: .slideDown)
                    tableView.selectRowIndexes(IndexSet(integersIn: Range(rowRange)!), byExtendingSelection: false)
                    // FIXME: Implement reindex
                    //appDelegate.menuController.reindexLesson(insertAtRow)
                    if  let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
                        let bmtVC = currentTabItem.viewController as? BMTViewController,
                        let _ = rowIndexes.first {
                        bmtVC.indexLessonForRow(row: insertAtRow)
                    }
                    if let rowCount = Range(rowRange)?.count {
                        // FIXME: Implement reindex
                        if  let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
                            let bmtVC = currentTabItem.viewController as? BMTViewController,
                            let _ = rowIndexes.first {
                            bmtVC.indexLessonForRow(row: insertAtRow + rowCount)
                        }
                    }
                    tableView.endUpdates()
                    
                    NotificationCenter.default.post(name: .dataSourceNeedsSaving, object:nil)
                }
                wordsTabController.draggingRows = false
                return true
            }
        }
        
        //wordsTabController.draggingRows = false
        return false
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool
    {
        if tableView.numberOfSelectedRows != tableView.numberOfRows {
            if tableView.selectedRow == -1 {
                tableView.selectRowIndexes(rowIndexes, byExtendingSelection: false)
            }
            else {
                let data : Data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
                pboard.declareTypes([NSPasteboard.PasteboardType(rawValue: NSPasteboard.Name.drag.rawValue)], owner: self)
                pboard.setData(data, forType:NSPasteboard.PasteboardType(rawValue: "Words"))
                
                return true
            }
        }
        return false
    }
    
}

