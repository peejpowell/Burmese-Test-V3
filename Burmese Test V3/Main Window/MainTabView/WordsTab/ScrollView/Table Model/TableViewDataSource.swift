//
//  TableViewDataSource.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class TableViewDataSource: NSObject {

    //@IBOutlet var tableView : NSTableView!
    var fieldDelegate = TextFieldDelegate()
    var fieldEditor : NSTextView = NSTextView()
    
    var insertableVerbs  : Dictionary<String,Words> = Dictionary<String,Words>()
    var insertableNouns  : Dictionary<String,Words> = Dictionary<String,Words>()
    var insertablePeople : Dictionary<String,Words> = Dictionary<String,Words>()
    
    var sortAscending = true
    var sortBy: String = "KLesson" {
        didSet(oldValue) {
            if oldValue != sortBy {
                self.sortAscending = false
            }
        }
    }
    
    var words: [Words] = []
    var unfilteredWords: [Words]?
    var filterRowsToDelete : IndexSet = IndexSet()
    var lessons: Dictionary<String,Int> = [:]
    var sourceFile : URL?
    var needsSaving : Bool = false
    
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
        infoPrint("new Datasource created",#function,self.className)
    }
    
    deinit {
        infoPrint("Datasource removed",#function,self.className)
        self.sourceFile = nil
    }
}

//MARK: Delegate Functions

extension TableViewDataSource: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, didDrag tableColumn: NSTableColumn) {
        let index = getCurrentIndex()
        let textFinderClient = getWordsTabViewDelegate().tabViewControllersList[index].textFinderClient
        textFinderClient?.resetSearch()
    }
    
    func canDragRowsWithIndexes(_ rowIndexes: IndexSet, atPoint mouseDownPoint: NSPoint) -> Bool
    {
        infoPrint("", #function, self.className)
        
        return false
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        if self.words[row].wordindex == "#" {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        
    }
    
    func tableViewColumnDidResize(_ notification: Notification) {
        
    }
    
    func tableViewColumnDidMove(_ notification: Notification) {
        
    }
    
    @objc @IBAction func SearchTest(_ sender: Any) {
        let myTextFinder = TextFinderClient()
        myTextFinder.tabIndex = 0
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
        
        let index = getCurrentIndex()
        
        if index != -1
        {
            let dataSource = getWordsTabViewDelegate().dataSources[index]
            let delegate = getWordsTabViewDelegate()
            if row >= dataSource.words.count {
                return NSTableCellView()
            }
            if dataSource.words.count == 0 {
                return NSTableCellView()
            }
            if  dataSource.words[row].istitle ||
                dataSource.words[row].wordindex == "#" {
                if let groupTitle = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "groupRow"),
                                                       owner: dataSource) as? NSTableCellView {
                    if let lesson = dataSource.words[row].lesson {
                        groupTitle.textField?.stringValue = lesson.uppercased()
                    }
                    else {
                        groupTitle.textField?.stringValue = ""
                    }
                    groupTitle.textField?.textColor = NSColor.white
                    return groupTitle
                }
            }
            
            if let identifier = tableColumn?.identifier {
                if let colId = identifier.rawValue.left(identifier.rawValue.length() - 3) {
                    if let field = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: colId),
                                                      owner: dataSource) as? NSTableCellView {
                        if let value = dataSource.words[row].wordForKey(colId) {
                            field.textField?.textColor = NSColor.textColor
                            switch colId {
                            case "KFilterType":
                                if let intValue = Int(value) {
                                    if let filterType = Words.PJFilterType(rawValue: intValue) {
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
                                if let value = dataSource.words[row].wordKeys[colId] {
                                    if let stringValue = value as? String {
                                        field.textField?.stringValue = stringValue
                                    }
                                    if let intValue = value as? Int
                                    {
                                        field.textField?.stringValue = "\(intValue)"
                                    }
                                }
                            }
                            if field.identifier?.rawValue != "avalaser" {
                                field.textField?.delegate = self.fieldDelegate
                            }
                            field.textField?.target = self
                            field.textField?.isHighlighted = false
                            
                            if let _ = dataSource.unfilteredWords {
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
                                
                                oldStringToCheck = dataSource.words[row].burmese as AnyObject
                                
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
                            }
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

//MARK: DataSource Functions Extension

extension TableViewDataSource: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let index = getCurrentIndex()
        if index != -1 {
            return getWordsTabViewDelegate().dataSources[index].words.count
        }
        return 0
    }
    
    func sortTable(_ tableView: NSTableView, sortBy: String)
    {
        infoPrint(nil, #function, self.className)
    }
    
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet)
    {
        infoPrint("", #function, self.className)
        
        getWordsTabViewDelegate().draggingRows = true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation
    {
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
    
    func reindexRows(_ rowIndexes: IndexSet, dropOnRow: Int)
    {
        infoPrint("", #function, self.className)
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
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
                for rowNum in firstDropRow ... lastDropRow
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
        
        let wordsTabController = getWordsTabViewDelegate()
        let index = getCurrentIndex()
        let pasteBoard = info.draggingPasteboard
        let dataSource = wordsTabController.dataSources[index]
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
                
                var wordsToInsert = [Words]()
                for rowIndex in rowIndexes.reversed() {
                    if let _ = dataSource.unfilteredWords {
                        let word = dataSource.words[rowIndex]
                        if word.filtertype != .add {
                            if let filterIndex = word.filterindex {
                                dataSource.filterRowsToDelete.insert(filterIndex)
                            }
                        }
                    }
                    if info.draggingSourceOperationMask.rawValue & NSDragOperation.move.rawValue == NSDragOperation.move.rawValue {
                        wordsToInsert.append(dataSource.words.remove(at: rowIndex) as Words)
                    }
                    else {
                        wordsToInsert.append(dataSource.words[rowIndex])
                    }
                }
                /*var rowToCopy = rowIndexes.last
                if rowToCopy != nil {
                    repeat {
                        // FIXME: Add unfiltered words functionality
                        if let _ = dataSource.unfilteredWords
                        {
                            let word = dataSource.words[rowToCopy!]
                            if word.filtertype != .add
                            {
                                if let filterIndex = word.filterindex {
                                    dataSource.filterRowsToDelete.insert(filterIndex)
                                }
                            }
                        }
                        if info.draggingSourceOperationMask.rawValue & NSDragOperation.move.rawValue == NSDragOperation.move.rawValue {
                            wordsToInsert.append(dataSource.words.remove(at: rowToCopy!) as Words)
                        }
                        else {
                            wordsToInsert.append(dataSource.words[rowToCopy!])
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
                        let prevWord = dataSource.words[insertAtRow-1]
                        if let _ = dataSource.unfilteredWords {
                            wordtoInsert.filtertype = .add
                            wordtoInsert.filterindex = prevWord.filterindex
                        }
                    }
                    else {
                        let nextWord = dataSource.words[insertAtRow]
                        if let _ = dataSource.unfilteredWords {
                            wordtoInsert.filtertype = .add
                            wordtoInsert.filterindex = nextWord.filterindex
                        }
                    }
                    dataSource.words.insert(wordtoInsert, at: insertAtRow)
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
                if let rowCount = Range(rowRange)?.count {
                    // FIXME: Implement reindex
                    //appDelegate.menuController.reindexLesson(insertAtRow + rowCount)
                }
                tableView.endUpdates()
                
                NotificationCenter.default.post(name: .dataSourceNeedsSaving, object:nil)
            }
            wordsTabController.draggingRows = false
            return true
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
                pboard.declareTypes([NSPasteboard.PasteboardType(rawValue: NSPasteboard.Name.dragPboard.rawValue)], owner: self)
                pboard.setData(data, forType:NSPasteboard.PasteboardType(rawValue: "Words"))
                
                return true
            }
        }
        return false
    }
    
}

