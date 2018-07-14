//
//  TextFinderClient.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 02/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

protocol WordsTextFinder : NSTextFinderClient {
    
}

class TextFinderClient: NSObject, WordsTextFinder {

    // Gives nice names for the columns we want to enable for searching
    
    lazy var tableView : NSTableView = NSTableView()
    lazy var textFinderController = NSTextFinder()
    
    enum SearchableColumn : Int {
        typealias RawValue = Int
        case burmese = 0
        case english = 1
        case roman   = 2
        case lesson  = 3
        case category = 4
    }
    
    // Returns the SearchField from the built in text finder view
    // This is so we can alter the menu to add functionality to
    // ignore diacritic marks and filter the results
    
    var searchField : NSSearchField {
        let textFinderController = getWordsTabViewDelegate().tabViewControllersList[self.tabIndex].textFinderController
        if let scrollView = tableView.superview?.superview as? PJScrollView {
            print(scrollView)
        }
        if let findBarContainer = textFinderController.findBarContainer {
            if let findBarView = findBarContainer.findBarView {
                let topOfStack = findBarView.subviews[0]
                if let findSearchField = topOfStack.subviews[0] as? NSSearchField {
                    if let cell = findSearchField.cell as? NSSearchFieldCell {
                        print(cell)
                    }
                    return findSearchField
                }
            }
        }
        return NSSearchField()
    }
    
    // Returns the column names for the associated tableview
    
    var tableColumnNames : [String] {
        var columnNames = [String]()
        for column in tableView.tableColumns {
                columnNames.append(column.identifier.rawValue)
        }
        return columnNames
    }
    
    var incremental = false
    var indexing = false
    var searchMenuTemplate : NSMenu = NSMenu()
    var searchFieldDelegate = FindMenuDelegate()
    var tabIndex : Int = -1
    var finderIndex = Array<Array<Int>>()
    //var foundWord = false
    //var foundWordLocation = Dictionary<String,Int>()
    
    var firstSelectedRange : NSRange = NSRange()
    
    var precountedStringLength = -1
    var foundFrame = NSRect(x: 0,y: 0,width: 10,height: 10)
    var diacriticInsensitive = false
    let wordsKeys = ["KBurmeseCol","KEnglishCol","KRomanCol","KLessonCol","KCategoryCol","KWordCategoryCol"]
    
    var visibleCharacterRanges: [NSValue] {
        // Determine the visible rows in the tableview to work out what ranges to use
        var visibleCharRange : [NSValue] = []
        let rangeOfVisibleRows = tableView.rows(in: tableView.visibleRect)
        for item in self.finderIndex {
            let row = item[1]
            let col = item[2]
            if row >= rangeOfVisibleRows.location && row < rangeOfVisibleRows.length {
                let wordLength = getWordAtRowCol(row, col: col).length
                visibleCharRange.append(NSValue(range:NSRange(location: item[0], length: wordLength)))
            }
        }
        print("Visible range: \(visibleCharRange)")
        NotificationCenter.default.post(name: .showSearchBar, object:nil, userInfo: ["numberOfRanges":visibleCharRange.count])
        return visibleCharRange
    }
    
    var selectedRanges: [NSValue] = []
    
    var allowsMultipleSelection = false
    
    func validateAction(_ op: NSTextFinder.Action) -> Bool
    {
        infoPrint("", #function, self.className)
        
        return true
    }
    
    func performAction(_ tag: Int)
    {
        infoPrint("", #function, self.className)
        
        let index = self.tabIndex
        let wordsTabController = getWordsTabViewDelegate()
        let textFinderController = wordsTabController.tabViewControllersList[index].textFinderController
        
        if let scrollView = tableView.superview?.superview as? PJScrollView {
            //self.foundWord = false
            //self.foundWordLocation["row"] = -1
            //self.foundWordLocation["col"] = -1
            infoPrint("Find tag: \(tag)", #function, self.className)
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
                
                if let findMenu = searchField.searchMenuTemplate {
                    let newMenuTemplate = findMenu
                    self.searchMenuTemplate = newMenuTemplate
                    if let lastItem = newMenuTemplate.items.last {
                        if lastItem.title != "Ignore Diacritics" {
                            let filterItem = NSMenuItem(title: "Filter", action: #selector(self.filterItemsMenuItem(_:)), keyEquivalent: "")
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
    }
    
    override init() {
        super.init()
        infoPrint("Created TextFinderClient", #function, self.className)
    }
    
    deinit {
        infoPrint("Removed TextFinderClient", #function, self.className)
    }
}

// MARK: Indexing Functions
    
extension TextFinderClient {
    
    func getTableColumnForCol(_ colIndex: Int) -> Int
    {
        var index = 0
        let keyWord = self.wordsKeys[colIndex]
        for column in tableView.tableColumns {
            if column.identifier.rawValue == keyWord {
                return index
            }
            if !column.isHidden {
                index = index + 1
            }
        }
        return index
    }
    
    func setWordAtRowCol(_ word: String, _ row: Int, col: Int)
    {
        let index = self.tabIndex
        let wordsTabController = getWordsTabViewDelegate()
        let dataSource = wordsTabController.dataSources[index]
        if dataSource.words[row].filtertype != .add {
            dataSource.words[row].filtertype = .change
        }
        switch col {
        case 0: // burmese
            dataSource.words[row].burmese = word
        case 1: // english
            dataSource.words[row].english = word
        case 2: // roman
            dataSource.words[row].roman = word
        case 3: // lesson
            dataSource.words[row].lesson = word
        case 4: // category
            dataSource.words[row].category = word
        default:
            break
        }
    }
    
    func getRecordAtRowCol(_ row: Int)->Words {
        let index = self.tabIndex
        let wordsTabController = getWordsTabViewDelegate()
        let dataSource = wordsTabController.dataSources[index]
        return dataSource.words[row]
    }
    
    func getWordOrDiacriticWord(_ word: String?, ignoreDiacritic: Bool)->NSString {
        switch ignoreDiacritic {
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
        }
        return ""
    }
    
    func getWordAtRowCol(_ row: Int, col: Int)->NSString
    {
        let index = self.tabIndex
        let wordsTabController = getWordsTabViewDelegate()
        let dataSource = wordsTabController.dataSources[index]
        let ignoreDiacritic = isIgnoreDiacriticChecked()
        switch col
        {
        case 0: // burmese
            let word = dataSource.words[row].burmese
            if let word = word as NSString? {
                return word
            }
        case 1: // english
            return getWordOrDiacriticWord(dataSource.words[row].english, ignoreDiacritic: ignoreDiacritic)
        case 2: // roman
            return getWordOrDiacriticWord(dataSource.words[row].roman, ignoreDiacritic: ignoreDiacritic)
        case 3: // lesson
            return getWordOrDiacriticWord(dataSource.words[row].lesson, ignoreDiacritic: ignoreDiacritic)
        case 4: // category
            return getWordOrDiacriticWord(dataSource.words[row].category, ignoreDiacritic: ignoreDiacritic)
        default:
            break
        }
        return ""
    }
    
    func arrayForLocation(_ location: Int)->Array<Int>
    {
        //infoPrint("", #function, self.className)
        var pos = finderIndex.count
        
        var currentIdx : Int = 0
        
        repeat {
            pos = pos - 1
            currentIdx = finderIndex[pos][0]
            
        } while pos > 0 && currentIdx > location
        return finderIndex[pos]
    }
    
    func checkDiacriticAndIndex(_ word: String, currentIndex: Int, row: Int, col: Int, ignoreDiacritic: Bool)->Int {
        let idx = currentIndex
        switch ignoreDiacritic {
        case true:
            var diacriticInsensitiveWord = word
            diacriticInsensitiveWord.foldString()
            if let newWord = diacriticInsensitiveWord as NSString? {
                finderIndex.append([idx,row,col])
                return idx + newWord.length
            }
        case false:
            if let word = word as NSString? {
                finderIndex.append([idx,row,col])
                return idx + word.length
            }
        }
    }
    
    func calculateIndex()->Int {
        // Make an index of all strings such that we can find any string via that index
        self.indexing = true
        infoPrint("index started...", #function, self.className)
        let index = self.tabIndex
        let wordsTabController = getWordsTabViewDelegate()
        let dataSource = wordsTabController.dataSources[index]
        var count = 0
        // Store index in a special table
        self.finderIndex.removeAll()
        
        var row = 0
        let ignoreDiacritic = isIgnoreDiacriticChecked()
        for word in dataSource.words {
            for columnName in self.tableColumnNames {
                //Find the appropriate string and use it
                switch columnName {
                case "KBurmeseCol":
                    let idx = count
                    if let word = word.burmese as NSString? {
                        count = count + word.length
                        finderIndex.append([idx,row,0])
                    }
                case "KEnglishCol":
                    if let word = word.english {
                        count = checkDiacriticAndIndex(word, currentIndex: count, row: row, col: SearchableColumn.english.rawValue, ignoreDiacritic: ignoreDiacritic)
                    }
                case "KRomanCol":
                    if let word = word.roman {
                        count = checkDiacriticAndIndex(word, currentIndex: count, row: row, col: SearchableColumn.roman.rawValue, ignoreDiacritic: ignoreDiacritic)
                    }
                case "KLessonCol":
                    if let word = word.lesson {
                        count = checkDiacriticAndIndex(word, currentIndex: count, row: row, col: SearchableColumn.lesson.rawValue, ignoreDiacritic: ignoreDiacritic)
                    }
                case "KCategoryCol":
                    if let word = word.category {
                        count = checkDiacriticAndIndex(word, currentIndex: count, row: row, col: SearchableColumn.category.rawValue, ignoreDiacritic: ignoreDiacritic)
                    }
                default:
                    break
                }
            }
            row += 1
        }
        indexing = false
        infoPrint("index ended...", #function, self.className)
        return count
    }
}

// MARK: Diacritic Menu Item Functions

extension TextFinderClient {
    
    func toggleIgnoreDiactric(state: NSControl.StateValue) {
        let index = self.tabIndex
        let textFinderController = getWordsTabViewDelegate().tabViewControllersList[index].textFinderController
        if let findBarContainer = textFinderController.findBarContainer {
            if let findBarView = findBarContainer.findBarView {
                let topOfStack = findBarView.subviews[0]
                let findSearchField = topOfStack.subviews[0]
                if let searchField = findSearchField as? NSSearchField {
                    if let findMenuTemplate = searchField.searchMenuTemplate {
                        if let ignoreDiacritic = findMenuTemplate.items.last {
                            if ignoreDiacritic.title == "Ignore Diacritics" {
                                ignoreDiacritic.state = state
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
            
            getWordsTabViewDelegate().tabViewControllersList[tabIndex].textFinderController.cancelFindIndicator()
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
            getWordsTabViewDelegate().tabViewControllersList[tabIndex].textFinderController.cancelFindIndicator()
            _ = self.calculateIndex()
            self.precountedStringLength = -1
            _ = self.stringLength()
            
        default:
            break
        }
    }
}

// MARK: Filter Menu Item Functions

extension TextFinderClient {
    
    func copyFilteredItems(_ filteredItems :[Words]) {
        let dataSource = getWordsTabViewDelegate().dataSources[self.tabIndex]
        dataSource.words = filteredItems
    }
    
    func copyUnfilteredItems() {
        let dataSource = getWordsTabViewDelegate().dataSources[self.tabIndex]
        dataSource.unfilteredWords = dataSource.words
    }
    
    func updateChangedRows() {
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            if let unfilteredWords = dataSource.unfilteredWords {
                for word in dataSource.words {
                    if word.filtertype == .change {
                        if let filterIndex = word.filterindex {
                            print("Changing row \(filterIndex) from \(unfilteredWords[filterIndex]) to:  \(word)")
                            word.filtertype = nil
                            dataSource.unfilteredWords?[filterIndex] = word
                        }
                    }
                }
            }
        }
    }
    
    func deleteMarkedRows() {
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            for rowIndex in dataSource.filterRowsToDelete.reversed() {
                dataSource.unfilteredWords?.remove(at: rowIndex)
            }
            // Update filterindexes
            self.updateFilterIndexes()
            
            dataSource.filterRowsToDelete.removeAll()
        }
    }
    
    func insertNewRows() {
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            for word in dataSource.words.reversed() {
                if word.filtertype == .add {
                    if let wordCopy = word.copy() as? Words {
                        wordCopy.filtertype = nil
                        if let insertRow = word.filterindex {
                            dataSource.unfilteredWords?.insert(wordCopy, at: insertRow + 1)
                        }
                    }
                }
            }
        }
    }
    
    func updateFilterIndexes() {
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            for indexToDelete in dataSource.filterRowsToDelete {
                for word in dataSource.words {
                    if let filterIndex = word.filterindex {
                        if word.filtertype == .add && filterIndex >= indexToDelete {
                            word.filterindex = filterIndex - 1
                        }
                    }
                }
            }
        }
    }
    
    func resetToUnfiltered() {
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            // Update any changed rows
            self.updateChangedRows()
            // Remove any marked rows
            self.deleteMarkedRows()
            // Add any new rows
            self.insertNewRows()
            if let unfilteredWords = dataSource.unfilteredWords {
                dataSource.words = unfilteredWords
            }
        }
        NotificationCenter.default.post(name: .tableNeedsReloading, object: nil)
    }
    
    @objc func filterItemsMenuItem(_ sender: NSMenuItem) {
        infoPrint("", #function, self.className)
        switch sender.state {
        case .off:
            // Filter the items
            let searchString = self.searchField.stringValue
            if let dataSource = tableView.dataSource as? TableViewDataSource {
                dataSource.unfilteredWords?.removeAll()
            }
            copyUnfilteredItems()
            findMatchingItems(textToFind: searchString)
            self.resetSearch()
            sender.state = .on
            toggleFiltered(state: .on)
        case .on:
            // Unfilter the items
            self.resetToUnfiltered()
            self.resetSearch()
            sender.state = .off
            toggleFiltered(state: .off)
        default:
            break
        }
        
    }
    
    func toggleFiltered(state: NSControl.StateValue) {
        let index = self.tabIndex
        let textFinderController = getWordsTabViewDelegate().tabViewControllersList[index].textFinderController
        if let findBarContainer = textFinderController.findBarContainer {
            if let findBarView = findBarContainer.findBarView {
                let topOfStack = findBarView.subviews[0]
                let findSearchField = topOfStack.subviews[0]
                if let searchField = findSearchField as? NSSearchField {
                    if let findMenuTemplate = searchField.searchMenuTemplate {
                        let filterItem = findMenuTemplate.items[findMenuTemplate.items.count - 2]
                        if filterItem.title == "Filter" {
                            filterItem.state = state
                            textFinderController.noteClientStringWillChange()
                        }
                    }
                }
            }
        }
    }
    
    func matchTextIn(_ word: String, searchFor textToFind: String, ignoreDiacritic: Bool)->Bool {
        switch ignoreDiacritic {
        case true:
            var diacriticInsensitiveWord = word
            diacriticInsensitiveWord.foldString()
            if let newWord = diacriticInsensitiveWord as NSString? {
                if newWord.contains(textToFind) {
                    return true
                }
            }
        case false:
            if word.contains(textToFind) {
                return true
            }
        }
        return false
    }
    
    func findMatchingItems(textToFind: String)
    {
        infoPrint("", #function, self.className)
        
        var filteredList = [Words]()
        for item in finderIndex {
            let characterIndex = item[0]
            let arrayForLocation = self.arrayForLocation(characterIndex)
            let row = arrayForLocation[1]
            let col = arrayForLocation[2]
            let word = getRecordAtRowCol(row)
            let ignoreDiacritic = self.isIgnoreDiacriticChecked()
            switch col {
            case 0:
                if let burmeseWord = word.burmese {
                    if burmeseWord.contains(textToFind) {
                        word.filterindex = row
                        if let wordCopy = word.copy() as? Words {
                            filteredList.append(wordCopy)
                        }
                        continue
                    }
                }
            case 1:
                if let englishWord = word.english {
                    if matchTextIn(englishWord, searchFor: textToFind,
                                   ignoreDiacritic: ignoreDiacritic) {
                        word.filterindex = row
                        if let wordCopy = word.copy() as? Words {
                            filteredList.append(wordCopy)
                        }
                        continue
                    }
                }
            case 2:
                if let romanWord = word.roman {
                    if matchTextIn(romanWord, searchFor: textToFind,
                                   ignoreDiacritic: ignoreDiacritic) {
                        word.filterindex = row
                        if let wordCopy = word.copy() as? Words {
                            filteredList.append(wordCopy)
                        }
                        continue
                    }
                }
            case 3:
                if let lessonWord = word.lesson{
                    if matchTextIn(lessonWord, searchFor: textToFind,
                                   ignoreDiacritic: ignoreDiacritic) {
                        word.filterindex = row
                        if let wordCopy = word.copy() as? Words {
                            filteredList.append(wordCopy)
                        }
                        continue
                    }
                }
            case 4:
                if let categoryWord = word.category{
                    if matchTextIn(categoryWord, searchFor: textToFind,
                                   ignoreDiacritic: ignoreDiacritic) {
                        word.filterindex = row
                        if let wordCopy = word.copy() as? Words {
                            filteredList.append(wordCopy)
                        }
                        continue
                    }
                }
            default:
                break
            }
        }
        copyFilteredItems(filteredList)
        NotificationCenter.default.post(name: .tableNeedsReloading, object:nil)
    }
    
    func performTextFinderAction(_ sender: Any?) {
        infoPrint("", #function, self.className)
        self.tabIndex = getCurrentIndex()
        if let sender = sender as? NSMenuItem {
            self.performAction(sender.tag)
        }
    }
    
    @IBAction func performFindPanelAction(_ sender: NSMenuItem) {
        self.performAction(sender.tag)
    }
}

// MARK: TextFinderClient Protocol Adherence

extension TextFinderClient {
    
    func rects(forCharacterRange range: NSRange) -> [NSValue]? {
        //Swift.print("Range: \(range)")
        var values = [NSValue]()
        values.append(NSValue(rect: self.foundFrame))
        return values
    }
    
    func contentView(at index: Int, effectiveCharacterRange outRange: NSRangePointer) -> NSView {
        //infoPrint("", #function, self.className)
        let arrayForLocation = self.arrayForLocation(index)
        let row = arrayForLocation[1]
        let col = arrayForLocation[2]
        let tableCol = getTableColumnForCol(col)
        let str = getWordAtRowCol(row, col: col)
        
        tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        
        outRange.pointee = NSRange(location: arrayForLocation[0], length: str.length)
        
        if let viewToReturn = tableView.view(atColumn: tableCol, row: row, makeIfNecessary: true) {
            let subViews = viewToReturn.subviews
            for subView in subViews {
                if let textField = subView as? NSTextField {
                    self.foundFrame = textField.frame
                    return textField
                }
            }
            //return viewToReturn
        }
        return NSView()
    }
    
    func string(at characterIndex: Int, effectiveRange outRange: NSRangePointer, endsWithSearchBoundary outFlag: UnsafeMutablePointer<ObjCBool>) -> String {
        //infoPrint("\(characterIndex)", #function, self.className)
        //print("CI = \(characterIndex)")
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
        return str as String
    }
    
    func resetSearch() {
        if self.tabIndex == -1 {
            return
        }
    getWordsTabViewDelegate().tabViewControllersList[tabIndex].textFinderController.cancelFindIndicator()
        self.selectedRanges = []
        self.precountedStringLength = -1
        _ = self.stringLength()
        _ = self.calculateIndex()
        self.firstSelectedRange = NSRange(location: 0, length: 0)
    }
    
    func shouldReplaceCharacters(inRanges ranges: [NSValue], with strings: [String]) -> Bool
    {
        // If there are more that one replacement (replacing all) then prompt to comfirm this is really wanted
        
        if ranges.count == 1 {
            return true
        }
        
        let replacementConfirmationAlert = NSAlert()
        
        replacementConfirmationAlert.messageText = "This will replace \(ranges.count) items. Do you wish to continue?"
        replacementConfirmationAlert.alertStyle = NSAlert.Style.informational
        replacementConfirmationAlert.addButton(withTitle: "Continue")
        replacementConfirmationAlert.addButton(withTitle: "Cancel")
        
        let result = replacementConfirmationAlert.runModal()
        
        
        switch result {
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
         
         return true*/
    }
    
    /*func drawCharacters(in range: NSRange, forContentView view: NSView) {
        if let view = view as? NSTextField {
            view.draw(view.frame)
        }
    }*/
    
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
        
        let indexes = [IndexSet(integer:row)]
        NotificationCenter.default.post(name: .tableRowsNeedReloading, object: nil, userInfo: ["indexes" : indexes])
    }
    
    func didReplaceCharacters() {
        _ = self.calculateIndex()
        tableView.reloadData()
    }
    
    func scrollRangeToVisible(_ range: NSRange)
    {
        // Find where the range is in the list of strings

        let arrayForLocation = self.arrayForLocation(range.location)
        let row = arrayForLocation[1]
        let visibleRowRange = tableView.rows(in: tableView.visibleRect)
        let topRow = visibleRowRange.location
        let numberOfVisibleRows = visibleRowRange.length - 5
        if row > topRow {
            tableView.scrollRowToVisible(row + numberOfVisibleRows)
        }
        else {
            tableView.scrollRowToVisible(row)
        }
        tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        self.firstSelectedRange = range
        self.selectedRanges.append(NSValue(range: range))
    }
    
    func stringLength() -> Int {
        //infoPrint("", #function, self.className)
        
        if precountedStringLength != -1
        {
            return precountedStringLength
        }
        let index = self.tabIndex
        let wordsTabController = getWordsTabViewDelegate()
        let dataSource = wordsTabController.dataSources[index]
        
        var totalLength : Int = 0   // The total Length of all strings in the search concatenated together
        let ignoreDiacritic = isIgnoreDiacriticChecked()
        infoPrint("stringlength started...", #function, self.className)
        
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
                case "KEnglishCol":
                    totalLength = totalLength + getWordOrDiacriticWord(word.english, ignoreDiacritic: ignoreDiacritic).length
                case "KRomanCol":
                    totalLength = totalLength + getWordOrDiacriticWord(word.roman, ignoreDiacritic: ignoreDiacritic).length
                case "KLessonCol":
                    totalLength = totalLength + getWordOrDiacriticWord(word.lesson, ignoreDiacritic: ignoreDiacritic).length
                case "KCategoryCol":
                    totalLength = totalLength + getWordOrDiacriticWord(word.category, ignoreDiacritic: ignoreDiacritic).length
                default:
                    break
                }
            }
        }
        infoPrint("stringlength ended... \(totalLength)", #function, self.className)
        
        precountedStringLength = totalLength
        return precountedStringLength
    }
}
