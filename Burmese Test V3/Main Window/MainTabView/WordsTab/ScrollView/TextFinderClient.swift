//
//  TextFinderClient.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 02/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class TextFinderClient: PJScrollView, NSTextFinderClient {

    var searchMenuTemplate : NSMenu = NSMenu()
    var searchFieldDelegate = FindMenuDelegate()
    var tabIndex : Int = -1
    var finderIndexM = [Words]()
    var finderIndexA = Array<Array<Int>>()
    var finderIndex : [Dictionary<String,Int>] = [Dictionary<String,Int>]()
    
    var string: String { return "This is a test" }
    var foundWord = false
    var foundWordLocation = Dictionary<String,Int>()
    
    var firstSelectedRange : NSRange = NSRange()
    
    var precountedStringLength = -1
    var foundFrame = NSRect(x: 0,y: 0,width: 10,height: 10)
    var diacriticInsensitive = false
    {
        didSet(oldValue) {
            print("Changed value of diacriticInsensitive from \(oldValue)")
        }
        
    }
    let wordsKeys = ["KBurmeseCol","KEnglishCol","KRomanCol","KLessonCol","KCategoryCol","KWordCategoryCol"]
    
    var visibleCharacterRanges: [NSValue] = []
    
    override func performTextFinderAction(_ sender: Any?) {
        
        infoPrint("", #function, self.className)
        
        self.tabIndex = getCurrentIndex()
        
        if let sender = sender as? NSMenuItem {
            self.performAction(sender.tag)
        }
    }
    
    @IBAction override func performFindPanelAction(_ sender: NSMenuItem)
    {
        self.performAction(sender.tag)
    }
    
    func validateAction(_ op: NSTextFinder.Action) -> Bool
    {
        infoPrint("", #function, self.className)
        
        return true
    }
    
    @objc func filterItems(_ sender: NSMenuItem) {
        infoPrint("", #function, self.className)
    }
    
    func toggleIgnoreDiactric(state: NSControl.StateValue) {
        let index = self.tabIndex
        let textFinderController = getWordsTabViewDelegate().tabViewControllersList[index].textFinderController
        if let findBarContainer = textFinderController.findBarContainer {
            if let findBarView = findBarContainer.findBarView {
                let topOfStack = findBarView.subviews[0]
                let findSearchField = topOfStack.subviews[0]
                if let searchField = findSearchField as? NSSearchField {
                    if let findMenuTemplate = searchField.searchMenuTemplate {
                        if let lastItem = findMenuTemplate.items.last {
                            if lastItem.title == "Ignore Diacritics" {
                                lastItem.state = state
                                textFinderController.noteClientStringWillChange()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func isIgnoreDiacriticChecked()->Bool {
        if let lastItem = self.searchMenuTemplate.items.last {
            if lastItem.title == "Ignore Diacritics" {
                switch lastItem.state {
                case .on:
                    if self.diacriticInsensitive != true {
                        self.diacriticInsensitive = true
                    }
                    return true
                case .off:
                    if self.diacriticInsensitive != false {
                        self.diacriticInsensitive = false
                    }
                    return false
                default:
                    break
                }
            }
        }
        return false
    }
    
    @objc func ignoreDiacritic(_ sender: NSMenuItem) {
        infoPrint("", #function, self.className)
        
        switch sender.state {
        case .on:
            
        //getWordsTabViewDelegate().tabViewControllersList[tabIndex].textFinderController.cancelFindIndicator()
        _ = self.calculateIndex()
        self.precountedStringLength = -1
        _ = self.stringLength()
            // Get the searchmenutemplate and change the state there
            sender.state = .off
            self.toggleIgnoreDiactric(state: .off)
            self.diacriticInsensitive = false
        case .off:
            sender.state = .on
            self.toggleIgnoreDiactric(state: .on)
            self.diacriticInsensitive = true
            //getWordsTabViewDelegate().tabViewControllersList[tabIndex].textFinderController.cancelFindIndicator()
            _ = self.calculateIndex()
            self.precountedStringLength = -1
            _ = self.stringLength()
            
        default:
            break
        }
    }
    
    func performAction(_ tag: Int)
    {
        infoPrint("", #function, self.className)
        
        let index = self.tabIndex
        let wordsTabController = getWordsTabViewDelegate()
        let textFinderController = wordsTabController.tabViewControllersList[index].textFinderController
        
        if let scrollView = wordsTabController.tabViewControllersList[index].tableView.superview?.superview as? PJScrollView {
            self.foundWord = false
            self.foundWordLocation["row"] = -1
            self.foundWordLocation["col"] = -1
            
            switch tag {
            case  1:
                // Show find interface
                if scrollView.isFindBarVisible {
                    scrollView.isFindBarVisible = false
                    break
                }
                scrollView.findBarPosition = NSScrollView.FindBarPosition.aboveContent
                _ = self.calculateIndex()
                textFinderController.performAction(NSTextFinder.Action(rawValue:tag)!)
                
                if let findBarContainer = textFinderController.findBarContainer {
                    if let findBarView = findBarContainer.findBarView {
                        let topOfStack = findBarView.subviews[0]
                        let findSearchField = topOfStack.subviews[0]
                        let topSegmentedControl = topOfStack.subviews[1]
                        let topButton1 = topOfStack.subviews[2]
                        let topButton2 = topOfStack.subviews[3]
                        if let searchField = findSearchField as? NSSearchField {
                            // Change the action for the searchField
                            
                            
                            
                            if let findMenu = searchField.searchMenuTemplate as? NSMenu {
                                let newMenuTemplate = findMenu
                                self.searchMenuTemplate = newMenuTemplate
                                if let lastItem = newMenuTemplate.items.last {
                                    if lastItem.title != "Ignore Diacritics" {
                                        let filterItem = NSMenuItem(title: "Filter", action: #selector(self.filterItems(_:)), keyEquivalent: "")
                                        filterItem.target = self
                                        let ignoreDiacriticItem = NSMenuItem(title: "Ignore Diacritics", action: #selector(self.ignoreDiacritic(_:)), keyEquivalent: "")
                                        ignoreDiacriticItem.target = self
                                        switch self.diacriticInsensitive {
                                        case true:
                                            ignoreDiacriticItem.state = .on
                                        case false:
                                            ignoreDiacriticItem.state = .off
                                        }
                                        newMenuTemplate.addItem(NSMenuItem.separator())
                                        newMenuTemplate.addItem(filterItem)
                                        newMenuTemplate.addItem(ignoreDiacriticItem)
                                        //newMenuTemplate.delegate = self.searchFieldDelegate
                                    }
                                    else
                                    {
                                        switch self.diacriticInsensitive {
                                        case true:
                                            lastItem.state = .on
                                        case false:
                                            lastItem.state = .off
                                        }
                                    }
                                    searchField.searchMenuTemplate = newMenuTemplate
                                }
                            }
                            
                        }
                        let bottomOfStack = findBarView.subviews[1]
                        let replaceSearchField = bottomOfStack.subviews[0]
                        let segmentedControl = bottomOfStack.subviews[1]
                        let view1 = bottomOfStack.subviews[2]
                        
                    
                    }
                }
                print(textFinderController.findBarContainer)

            case  2:
                Swift.print(tag) // Find Next
                _ = self.calculateIndex()
            textFinderController.performAction(NSTextFinder.Action(rawValue:tag)!)
                
            case 12:
                Swift.print(tag) //Find and Replace Text
                _ = self.calculateIndex()
                scrollView.findBarPosition = NSScrollView.FindBarPosition.aboveContent
                textFinderController.performAction(NSTextFinder.Action(rawValue:tag)!)
                
            default:
                Swift.print(tag)
            }
        }
        //calulateIndex()
    }
    
    func replaceCharacters(in range: NSRange, with string: String) {
        
        // Get the array for the relevant location
        
        let arrayForLocation = self.arrayForLocation(range.location)
        let idx = arrayForLocation[0]
        
        let actualRange = NSRange(location: range.location - idx, length: range.length)
        
        // Swift.print(getWordAtRowCol(arrayForLocation[1], col: arrayForLocation[2]))
        
        // Double check the word is correct
        let wordAtArray = getWordAtRowCol(arrayForLocation[1], col: arrayForLocation[2])
        
        //let wordToMatch = wordAtArray.substringWithRange(actualRange)
        
        //Swift.print(wordToMatch)
        
        let newString = wordAtArray.replacingCharacters(in: actualRange, with: string)
        
        let row = arrayForLocation[1]
        let col = arrayForLocation[2]
        
        setWordAtRowCol(newString, row, col: col)
        /*if let dataSource = tableView.dataSource as? TableViewDataSource
        {
            let keyName = dataSource.words[row].entity.attributeKeys[col]
            
            dataSource.pjWords[row].setValue(newString, forKey: keyName)
        }*/
        
    }
    
    func shouldReplaceCharacters(inRanges ranges: [NSValue], with strings: [String]) -> Bool
    {
        Swift.print("Ranges: \(ranges)")
        Swift.print("Strings: \(strings)")
        
        // If there are more that one replacement (replacing all) then prompt to comfirm this is really wanted
        
        if ranges.count == 1
        {
            return true
        }
        
        let replacementConfirmationAlert = NSAlert()
        
        replacementConfirmationAlert.messageText = "This will replace \(ranges.count) items. Do you wish to continue?"
        replacementConfirmationAlert.alertStyle = NSAlert.Style.informational
        replacementConfirmationAlert.addButton(withTitle: "Continue")
        replacementConfirmationAlert.addButton(withTitle: "Cancel")
        
        let result = replacementConfirmationAlert.runModal()
        
        
        switch result
        {
        case NSApplication.ModalResponse.alertFirstButtonReturn:
            return true
        case NSApplication.ModalResponse.alertSecondButtonReturn:
            return false
        default:
            return false
        }
        
        /*
         // Get the array for the relevant location
         
         let range = ranges.first as! NSRange
         
         let arrayForLocation = self.arrayForLocation(range.location)
         let idx = arrayForLocation[0]
         
         let difference = range.location - idx
         
         let actualRange = NSRange(location: difference, length: range.length)
         
         Swift.print(getWordAtRowCol(arrayForLocation[1], col: arrayForLocation[2]))
         
         // Double check the word is correct
         let wordAtArray = getWordAtRowCol(arrayForLocation[1], col: arrayForLocation[2])
         
         let wordToMatch = wordAtArray.substringWithRange(actualRange)
         
         Swift.print(wordToMatch)
         
         return true
         */
    }
    
    func didReplaceCharacters() {
        infoPrint("", #function, self.className)
        
        _ = self.calculateIndex()
        
        getCurrentTableView().reloadData()
        //appDelegate.viewController.lessonsTableView.reloadData()
        
    }
    
    /*func contentViewAtIndex(index: Int, effectiveCharacterRange outRange: NSRangePointer) -> NSView
     {
     Swift.print(index)
     let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
     
     return appDelegate.viewController.PJTableView
     
     }*/
    
    /*func matchColumn(_ index:Int)->Int
    {
        // Search the attributeKeys to get an index to the one that matches the tablecolumn
        
        let dataSourceIndex = self.tabIndex
        let wordTabController = getWordsTabViewDelegate()
        
        let dataSource = wordTabController.dataSources[dataSourceIndex] as? TableViewDataSource
        var count = 0
        
        if let tableView = wordsTabController.tabViewControllersList[index].tableView
        {
            let id = tableView.tableColumns[col].identifier.rawValue
            let keyName = Words().wordKeys[id.left(id.length()-3)]
            
        //let keyName = dataSource.pjWords[0].entity.attributeKeys[index]
            for column in appDelegate.viewController.tableView.tableColumns
            {
                if column.identifier.rawValue == keyName
                {
                    return count
                }
                count = count + 1
            }
        }
        return -1
    }*/
    
    func getTableColumnForCol(_ colIndex: Int, table: NSTableView) -> Int
    {
        var index = -1
        
        let dataSourceIndex = self.tabIndex
        let wordsTabController = getWordsTabViewDelegate()
        let dataSource = wordsTabController.dataSources[dataSourceIndex]
        if let tableView = wordsTabController.tabViewControllersList[dataSourceIndex].tableView {
        
            let keyWord = self.wordsKeys[colIndex]
            index = 0
            for column in table.tableColumns {
                if column.identifier.rawValue == keyWord {
                    return index
                }
                if !column.isHidden {
                    index = index + 1
                }
            }
        }
        return index
    }
    
    func contentView(at index: Int, effectiveCharacterRange outRange: NSRangePointer) -> NSView {
        infoPrint("", #function, self.className)
        
        let dataSourceIndex = self.tabIndex
        let wordsTabController = getWordsTabViewDelegate()
        if let tableView = wordsTabController.tabViewControllersList[dataSourceIndex].tableView {
        
            let arrayForLocation = self.arrayForLocation(index)
            let row = arrayForLocation[1]
            let col = arrayForLocation[2]
            let tableCol = getTableColumnForCol(col, table: tableView)
        
            let str = getWordAtRowCol(row, col: col)
            //self.foundWord = true
            //self.foundWordLocation["row"] = row!
            //self.foundWordLocation["col"] = col!
            tableView.reloadData()
            tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
            tableView.scrollRowToVisible(row)
        
            outRange.pointee = NSRange(location: arrayForLocation[0], length: str.length)
        
            if let viewToReturn = tableView.view(atColumn: tableCol, row: row, makeIfNecessary: true)
            {
                Swift.print("row: \(row), col: \(col), tableCol:\(tableCol)")
                let subViews = viewToReturn.subviews
                for subView in subViews
                {
                    if let textField = subView as? NSTextField
                    {
                        Swift.print(textField.frame)
                        self.foundFrame = textField.frame
                        return textField
                    }
                }
                //return viewToReturn
            }
        }
        //appDelegate.viewController.PJTableView.editColumn(self.matchColumn(col), row: row, withEvent: nil, select: true)
        //appDelegate.viewController.PJTableView.reloadDataForRowIndexes(NSIndexSet(index: row!), columnIndexes: NSIndexSet(index: self.matchColumn(col!)))
        return NSView()
    }
    
    func drawCharacters(in range: NSRange, forContentView view: NSView) {
        if let view = view as? NSTextField
        {
            view.draw(view.frame)
        }
    }
    
    func rects(forCharacterRange range: NSRange) -> [NSValue]? {
        Swift.print("Range: \(range)")
        var values = [NSValue]()
        values.append(NSValue(rect: self.foundFrame))
        return values
    }
    
    func scrollRangeToVisible(_ range: NSRange)
    {
        //Swift.print("firstSelectedRange: \(range)")
        self.firstSelectedRange = range
        
    }
    
    func setWordAtRowCol(_ word: String, _ row: Int, col: Int)
    {
        let index = self.tabIndex
        let wordsTabController = getWordsTabViewDelegate()
        let dataSource = wordsTabController.dataSources[index]
        switch col
        {
        case 0: // burmese
            dataSource.words[row].burmese = word
        case 1: // english
            dataSource.words[row].english = word
        case 2: // roman
            dataSource.words[row].roman = word
        default:
            break
        }
        /*if let tableView = wordsTabController.tabViewControllersList[index].tableView
        {
            let id = tableView.tableColumns[col].identifier.rawValue
            switch id {
            case "KBurmeseCol":
                dataSource.words[row].burmese = word
            case "KEnglishCol":
                dataSource.words[row].english = word
            case "KRomanCol":
                dataSource.words[row].roman = word
            case "KLessonCol":
                dataSource.words[row].lesson = word
            case "KCategoryCol":
                dataSource.words[row].category = word
            case "KWordCategoryCol":
                dataSource.words[row].wordcategory = word
            default:
                break
            }
        }*/
    }
    
    func getWordAtRowCol(_ row: Int, col: Int)->NSString
    {
        let index = self.tabIndex
        let wordsTabController = getWordsTabViewDelegate()
        let dataSource = wordsTabController.dataSources[index]
        
        switch col
        {
        case 0: // burmese
            let word = dataSource.words[row].burmese
            if let word = word as NSString? {
                return word
            }
            else {
                print("PROBLEM with \(word)!")
            }
        case 1: // english
            let word = dataSource.words[row].english
            switch isIgnoreDiacriticChecked() {
            case true:
                var diacriticInsensitiveWord = word
                diacriticInsensitiveWord?.foldString()
                if let newWord = diacriticInsensitiveWord as NSString? {
                    return newWord
                }
            case false:
                if let word = word as NSString? {
                    return word
                }
                else {
                    print("PROBLEM with \(word)!")
                }
            }
        case 2: // roman
            let word = dataSource.words[row].roman
            switch isIgnoreDiacriticChecked() {
            case true:
                var diacriticInsensitiveWord = word
                diacriticInsensitiveWord?.foldString()
                if let newWord = diacriticInsensitiveWord as NSString? {
                    return newWord
                }
            case false:
                if let word = word as NSString? {
                    return word
                }
                else {
                    print("PROBLEM with \(word)!")
                }
            }
        default:
            break
        }
        /*let keyWord = dataSource.words[row].entity.attributeKeys[col]
            if let string = dataSource.pjWords[row].value(forKey: keyWord) as? String
            {
                //appDelegate.viewController.PJTableView.
                
                return string as NSString
            }
        }*/
        return ""
    }
    
    func string(at characterIndex: Int, effectiveRange outRange: NSRangePointer, endsWithSearchBoundary outFlag: UnsafeMutablePointer<ObjCBool>) -> String {
        
        infoPrint("\(characterIndex)", #function, self.className)
        let arrayForLocation = self.arrayForLocation(characterIndex)
        //let MOForLocation = self.MOForLocation(characterIndex)
        //let dictForLocation = self.dictForLocation(characterIndex)
        
        //let row = dictForLocation["row"]
        //let col = dictForLocation["col"]
        //let idx = dictForLocation["idx"]
        
        let row = arrayForLocation[1]
        let col = arrayForLocation[2]
        let idx = arrayForLocation[0]
        
        //let row = MOForLocation.valueForKey("row") as! Int
        //let col = MOForLocation.valueForKey("col") as! Int
        //let idx = MOForLocation.valueForKey("idx") as! Int
        
        let str = getWordAtRowCol(row, col: col)
        
        var myRange = NSRange()
        
        myRange.location = idx
        myRange.length = str.length
        //Swift.print("charIdx: \(characterIndex)")
        
        if characterIndex == self.stringLength()
        {
            self.firstSelectedRange = NSRange(location: 0,length: 0)
        }
        outRange.pointee = myRange
        outFlag.pointee = true
        //Swift.print("string: \(str)")
        return str as String
    }
    
    func arrayForLocation(_ location: Int)->Array<Int>
    {
        var pos = finderIndexA.count
        
        var currentIdx : Int = 0
        
        repeat
        {
            pos = pos - 1
            currentIdx = finderIndexA[pos][0]
            
        } while pos > 0 && currentIdx > location
        return finderIndexA[pos]
    }

    func stringLength() -> Int {
        infoPrint("", #function, self.className)
        
        if precountedStringLength != -1
        {
            return precountedStringLength
        }
        let index = self.tabIndex
        let wordsTabController = getWordsTabViewDelegate()
        let dataSource = wordsTabController.dataSources[index]
        if let tableView = wordsTabController.tabViewControllersList[index].tableView {
            var totalLength : Int = 0   // The total Length of all strings in the search concatenated together
            for word in dataSource.words {
                for column in tableView.tableColumns {
                    let key = column.identifier.rawValue
                    if key.contains("index") {
                        continue
                    }
                    
                    //Find the appropriate string and use it
                    switch key {
                    case "KBurmeseCol":
                        if let word = word.burmese as NSString? {
                            totalLength = totalLength + word.length
                        }
                        else {
                            print("PROBLEM with \(word.burmese)!")
                        }
                    case "KEnglishCol":
                        switch isIgnoreDiacriticChecked() {
                        case true:
                            var diacriticInsensitiveWord = word.english
                            diacriticInsensitiveWord?.foldString()
                            if let newWord = diacriticInsensitiveWord {
                                totalLength = totalLength + newWord.length()
                            }
                        case false:
                            if let word = word.english as NSString? {
                                totalLength = totalLength + word.length
                            }
                            else {
                                print("PROBLEM with \(word.english)!")
                            }
                        }
                    case "KRomanCol":
                        switch isIgnoreDiacriticChecked() {
                        case true:
                            var diacriticInsensitiveWord = word.roman
                            diacriticInsensitiveWord?.foldString()
                            if let newWord = diacriticInsensitiveWord {
                                totalLength = totalLength + newWord.length()
                            }
                        case false:
                            if let word = word.roman as NSString? {
                                totalLength = totalLength + word.length
                            }
                            else {
                                print("PROBLEM with \(word.roman)!")
                            }
                        }
                    default:
                        break
                    }
                }
            }
            precountedStringLength = totalLength
            return totalLength
        }
        return precountedStringLength
    }
    
    func calculateIndex()->Int {
        // Make an index of all strings such that we can find any string via that index
        
        // Store index in a special table
        
        let index = self.tabIndex
        let wordsTabController = getWordsTabViewDelegate()
        
        var count = 0
        
        if let tableView = wordsTabController.tabViewControllersList[index].tableView
        {
            self.finderIndexA.removeAll()
            
            // create a new index
            
            var row = 0
            
            if let dataSource = tableView.dataSource as? TableViewDataSource {
                for word in dataSource.words {
                    for column in tableView.tableColumns {
                        let key = column.identifier.rawValue
                        
                        if key.containsString("index")
                        {}
                        
                        //Find the appropriate string and use it
                        switch key
                        {
                        case "KBurmeseCol":
                            let idx = count
                            if let word = word.burmese as? NSString {
                                count = count + word.length
                                finderIndexA.append([idx,row,0])
                            }
                            else {
                                print("PROBLEM with \(word.burmese)!")
                                count = count + 0
                            }
                            
                        case "KEnglishCol":
                            let idx = count
                            switch isIgnoreDiacriticChecked() {
                            case true:
                                var diacriticInsensitiveWord = word.english
                                diacriticInsensitiveWord?.foldString()
                                if let newWord = diacriticInsensitiveWord as NSString? {
                                    count = count + newWord.length
                                    finderIndexA.append([idx,row,1])
                                }
                            case false:
                                if let word = word.english as NSString? {
                                    count = count + word.length
                                    finderIndexA.append([idx,row,1])
                                }
                                else {
                                    print("PROBLEM with \(word.english)!")
                                    count = count + 0
                                }
                            }
                            
                        case "KRomanCol":
                            let idx = count
                            switch isIgnoreDiacriticChecked() {
                            case true:
                                var diacriticInsensitiveWord = word.roman
                                diacriticInsensitiveWord?.foldString()
                                if let newWord = diacriticInsensitiveWord as NSString? {
                                    count = count + newWord.length
                                    finderIndexA.append([idx,row,2])
                                }
                            case false:
                                if let word = word.roman as NSString? {
                                    count = count + word.length
                                    finderIndexA.append([idx,row,2])
                                    
                                }
                                else {
                                    print("PROBLEM with \(word.roman)!")
                                    count = count + 0
                                }
                            }
                            
                        default:
                            break
                        }
                    }
                    row = row + 1
                }
            }
            return count
        }
        return count
    }
}
