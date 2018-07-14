//
//  BMTTabViewController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa
import Carbon

extension Notification.Name {
    static var tableNeedsReloading: Notification.Name {
        return .init(rawValue: "BMTTabViewController.tableNeedsReloading")
    }
    static var tableRowsNeedReloading: Notification.Name {
        return .init(rawValue: "BMTTabViewController.tableRowsNeedReloading")
    }
    static var removeTableRow: Notification.Name {
        return .init(rawValue: "BMTTabViewController.removeTableRow")
    }
    static var columnVisibilityChanged: Notification.Name {
        return .init(rawValue: "BMTTabViewController.columnsVisibilityChanged")
    }
    static var toggleColumn: Notification.Name {
        return .init(rawValue: "BMTTabViewController.toggleColumn")
    }
    static var putTableRowOnPasteboard : Notification.Name {
        return .init(rawValue: "BMTTabViewController.putTableRowOnPasteboard")
    }
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

class BMTTabViewController: NSViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var testSearchButton: NSButton!
    @IBOutlet weak var tableView : NSTableView!
    @IBOutlet var textFinderClient: TextFinderClient!
    @IBOutlet weak var scrollView: PJScrollView!
    
    // MARK: Vars
    
    //var textFinderController: NSTextFinder = NSTextFinder()
    
    // MARK: View Controller Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        infoPrint("New BMT Tab",#function,self.className)
        
        let view = self.view
        if let tableView = view.viewWithTag(100) as? NSTableView {
            tableView.wantsLayer = true
            self.tableView = tableView
            self.textFinderClient.tableView = self.tableView
        }
        // Set up the textfinder
        
        self.textFinderClient.findBarContainer = self.scrollView
        self.textFinderClient.client = textFinderClient
        //self.textFinderController.client = self.textFinderClient
        //self.textFinderController.findBarContainer = self.scrollView
        //self.textFinderController.isIncrementalSearchingEnabled = true
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        infoPrint("", #function, self.className)
        self.createTableViewObservers()
        /*self.textFinderClient = TextFinderClient()
        self.textFinderClient.client = textFinderClient
        self.textFinderClient.tableView = self.tableView*/
        func getArrayPref(for key: Preferences)->[String] {
            let userDefaults = UserDefaults.standard
            if let array = userDefaults.array(forKey: key.rawValue) as? [String] {
                return array
            }
            return []
        }
        
        let hiddenColumns = getArrayPref(for: Preferences.HiddenColumns)
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
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            dataSource.populateLessons()
        }
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        infoPrint("", #function, self.className)
        //self.textFinderClient = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        // Make sure all searchbars are closed
        if let scrollView = self.tableView.superview?.superview as? PJScrollView {
            infoPrint("Closing visible searchBar.", #function, self.className)
            if scrollView.isFindBarVisible {
                self.textFinderClient.performAction(1)
            }
        }
        infoPrint("removed BMT",#function, self.className)
    }
}

// MARK: Clipboard Functions
private extension BMTTabViewController {
    
    func updateFilteredRowsToDelete(rowIndexes: IndexSet) {
        infoPrint("", #function, self.className)
        if  let dataSource = tableView.dataSource as? TableViewDataSource,
            let _ = dataSource.unfilteredWords {
            for rowIndex in rowIndexes {
                let word = dataSource.words[rowIndex]
                if let filterIndex = word.filterindex {
                    if word.filtertype == .change {
                        dataSource.filterRowsToDelete.insert(filterIndex)
                    }
                }
            }
        }
    }
        
    @IBAction func tableViewDoubleClick(_ sender: PJTableView)
    {
        infoPrint("", #function, self.className)
        
        let row = sender.clickedRow
        let column = sender.clickedColumn
        
        if column != -1 && row != -1 {
            if !tableView.tableColumns[column].isEditable {
                __NSBeep()
                return
            }
            sender.editColumn(column, row: row, with: nil, select: true)
            
            if sender.tableColumns[column].identifier.rawValue == "KBurmese" {
                setKeyboardByName("Myanmar", type: .all)
            }
            else if sender.tableColumns[column].identifier.rawValue == "KAvalaser" {
                setKeyboardByName("British", type: .ascii)
            }
            else {
                TISSelectInputSource(getAppDelegate().originalInputLanguage)
            }
        }
    }
    
    func removeSelectedRowsFromDataSource(rowIndexes: IndexSet) {
        infoPrint("", #function, self.className)
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            
            for rowIndex in rowIndexes.reversed() {
                if let filterIndex = dataSource.words[rowIndex].filterindex {
                    dataSource.filterRowsToDelete.insert(filterIndex)
                }
                dataSource.words.remove(at: rowIndex)
            }
            var row = -1
            if let firstRow = rowIndexes.first {
                row = firstRow
                if row == tableView.numberOfRows {
                    row -= 1
                }
                if row != tableView.numberOfRows-1 {
                    tableView.selectRowIndexes(IndexSet(integer: firstRow), byExtendingSelection: false)
                }
                else {
                    tableView.selectRowIndexes(IndexSet(integer: tableView.numberOfRows-1), byExtendingSelection: false)
                }
            }
        }
    }
    
    @objc func cutRows(_ notification: Notification) {
        infoPrint("", #function, self.className)
        let selectedRowIndexes = tableView.selectedRowIndexes
        // First put the relevant data on the pasteboard
        self.putTableRowsOnPasteboard(rowIndexes: selectedRowIndexes)
        // Update any filtered rows to remove them
        //self.updateFilteredRowsToDelete(rowIndexes: selectedRowIndexes)
        // Remove the table rows
        tableView.removeRows(at: selectedRowIndexes, withAnimation: .slideUp)
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

extension BMTTabViewController {
    
    // MARK: TableView Functions

    enum TableIndex : Int {
        case rows
        case columns
    }
    
    func createTableViewObservers() {
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
    
    @objc func jumpToLesson(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if let userInfo = notification.userInfo {
            if let senderTag = userInfo["senderTag"] as? Int {
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
    }
    
    @objc func populateLessonsPopup(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if let dataSource = self.tableView.dataSource as? TableViewDataSource {
            dataSource.populateLessons()
        }
    }
    
    @objc func putTableRowsOnPasteboard(rowIndexes: IndexSet) {
        infoPrint("", #function, self.className)
        
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            if !tableView.selectedRowIndexes.isEmpty {
                let pBoard = NSPasteboard.general
                var myPasteArray = [Words]()
                for rowIndex in rowIndexes {
                    myPasteArray.append(dataSource.words[rowIndex])
                }
                let data: Data = NSKeyedArchiver.archivedData(withRootObject: myPasteArray)
                pBoard.declareTypes([NSPasteboard.PasteboardType(rawValue: NSPasteboard.Name.general.rawValue)], owner: self)
                pBoard.setData(data, forType: NSPasteboard.PasteboardType(rawValue: "Words"))
                infoPrint("data copied", #function, self.className)
            }
        }
    }
    
    func pasteFromPasteboard() {
        let pBoard = NSPasteboard.general
        var pasteRow = tableView.selectedRow
        if pasteRow == -1 && tableView.numberOfRows > 0 {
            // Paste at the end of the table
            pasteRow = tableView.numberOfRows-1
        }
        else if pasteRow == -1 && tableView.numberOfRows == 0 {
            pasteRow = 0
        }
        
        if let rowData = pBoard.data(forType: NSPasteboard.PasteboardType(rawValue: "Words")) {
            if let pastedWords = NSKeyedUnarchiver.unarchiveObject(with: rowData) as? [Words] {
                for word in pastedWords.reversed() {
                    if let dataSource = tableView.dataSource as? TableViewDataSource {
                        if let _ = dataSource.unfilteredWords {
                            word.filtertype = .add
                            if pasteRow - 1 > -1 {
                                word.filterindex = dataSource.words[pasteRow-1].filterindex
                            }
                            else {
                                word.filterindex = 0
                            }
                        }
                        dataSource.words.insert(word, at: pasteRow)
                    }
                }
                self.tableView.insertRows(at: IndexSet(integersIn: pasteRow..<pasteRow+pastedWords.count), withAnimation: .slideDown)
                NotificationCenter.default.post(name: .dataSourceNeedsSaving, object: nil)
            }
        }
        else {
            __NSBeep()
            return
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
    
    func resizeAllColumns() {
        infoPrint("", #function, self.className)
        
        // Get the width of the tableview
        // Divide by the number of columns
        // Set each column width to the new width
        
        var numberOfVisibleColumns = 0
        if let tableViewWidth = self.tableView.superview?.frame.width {
            for column in tableView.tableColumns {
                if !column.isHidden {
                    numberOfVisibleColumns += 1
                }
            }
            let newColumnWidth = tableViewWidth / CGFloat(numberOfVisibleColumns)
            for column in tableView.tableColumns {
                if !column.isHidden {
                    column.width = newColumnWidth
                }
            }
        }
    }
    
    @objc func refreshTable(_ notification: Notification) {
        infoPrint("", #function, self.className)
        self.tableView.reloadData()
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
                if rowIndex! < dataSource.words.count {
                    // Check if there are no more lessons with the same name as the removed row
                    if let lesson = dataSource.words[rowIndex!].lesson {
                        decreaseLessonCount(lesson)
                    }
                
                    if let _ = dataSource.unfilteredWords {
                        let word = dataSource.words[rowIndex!]
                        if word.filtertype != .add && word.filtertype != .change && word.filtertype != .delete {
                            if let filterRowIndex = word.filterindex {
                                dataSource.filterRowsToDelete.insert(filterRowIndex)
                            }
                        }
                    }
                }
                dataSource.words.remove(at: rowIndex!)
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
    
    func changed(previous: String?, current: String?)->Bool {
        if previous != current {
            return true
        }
        return false
    }
    
    func findFirstLessonRowFor(lesson: String?, at row: Int)->Int {
        infoPrint("", #function, self.className)
        // Find the start of this lesson block
        // -- Go backwards from the current lesson row looking for previous lessons
        // -- If we find a previous lesson set the startRow to the row after it and return
        // -- If we reach -1 return 0
        
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            var currentRow = row
            let lessonForSection = dataSource.words[currentRow].lesson
            while lessonForSection == dataSource.words[currentRow].lesson && currentRow > -1 {
                currentRow -= 1
                if currentRow == -1 {
                    break
                }
            }
            return currentRow + 1
        }
        return row
    }
    
    func indexLessonForRow(row: Int) {
        infoPrint("", #function, self.className)
        // Reindex the lesson block
        if let dataSource = tableView.dataSource as? TableViewDataSource {
            if row >= dataSource.words.count {
                return
            }
            
            let startRow = findFirstLessonRowFor(lesson: dataSource.words[row].lesson, at: row)
            let lessonForSection = dataSource.words[startRow].lesson
            var currentRow = startRow
            while dataSource.words[currentRow].lesson == lessonForSection {
                currentRow += 1
                if currentRow > dataSource.words.count - 1 {
                    currentRow = dataSource.words.count - 1
                    break
                }
            }
            self.reindexInRange(startRow..<currentRow)
        }
    }
    
    @IBAction func reindexLesson(_ sender: NSMenuItem) {
        infoPrint("", #function, self.className)
        if tableView.selectedRow != -1 {
            self.indexLessonForRow(row: tableView.selectedRow)
        }
    }
    
    func reindexInRange(_ range: Range<Int>) {
        infoPrint("", #function, self.className)
        if let dataSource = self.tableView.dataSource as? TableViewDataSource {
            var wordIndex = 0
            var categoryIndex = 0
            var prevLesson : String?
            var prevCategory : String?
            DispatchQueue.global(qos: .background).async {
                infoPrint("started Indexing", #function, self.className)
                for wordNum in range {
                    let word = dataSource.words[wordNum]
                    if self.changed(previous: prevLesson, current: word.lesson) {
                        categoryIndex = 0
                        wordIndex = 0
                    }
                    else {
                        if self.changed(previous: prevCategory, current: word.category) {
                            categoryIndex += 1
                            wordIndex = 0
                        }
                        else {
                            wordIndex += 1
                        }
                    }
                    prevLesson = word.lesson
                    prevCategory = word.category
                    if word.wordindex == "#" {
                        word.istitle = true
                    }
                    else {
                        word.istitle = false
                    }
                    word.categoryindex = "\(categoryIndex)".padBefore("0", desiredLength: 4)
                    word.wordindex = "\(wordIndex)".padBefore("0", desiredLength: 4)
                }
                infoPrint("finished Indexing", #function, self.className)
            }
        }
    }
    
    @IBAction func indexAll(_ sender: NSMenuItem?) {
        infoPrint("", #function, self.className)
        // Index all the rows in the current dataSource
        // Make sure the table is sorted by Lesson first
        
        if let dataSource = self.tableView.dataSource as? TableViewDataSource {
            let oldSortBy = dataSource.sortBy
            dataSource.sortBy = "KLesson"
            dataSource.sortTable(tableView, sortBy: dataSource.sortBy)
            let reindexRange = 0..<dataSource.words.count
            self.reindexInRange(reindexRange)
            dataSource.sortBy = oldSortBy
            dataSource.sortTable(tableView, sortBy: dataSource.sortBy)
            
        }
        //NotificationCenter.default.post(name: .tableNeedsReloading, object: nil)
    }
}


