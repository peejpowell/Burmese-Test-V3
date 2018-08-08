//
//  BMTViewController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa
import Carbon

class BMTViewController: NSViewController {
    
    // MARK: Outlets
    @IBOutlet weak var testSearchButton: NSButton!
    @IBOutlet weak var tableView : NSTableView!
    @IBOutlet var textFinderClient: TextFinderClient!
    @IBOutlet weak var scrollView: PJScrollView!
    
    // MARK: Properties
    var bmtViewModel : BMTViewModel = BMTViewModel()
    var dataSource : TableViewDataSource? {
        return bmtViewModel.dataSource
    }
    
    // MARK: View Controller Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        performInitialSetup()
        infoPrint("New BMT Tab",#function,self.className)
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        infoPrint("\(self)", #function, self.className)
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
        NotificationCenter.default.post(name: .startPopulateLessonsPopup, object: nil, userInfo:[UserInfo.Keys.datasource : self.dataSource as Any])
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

// MARK: General Functions

extension BMTViewController {
    
    func updateFilteredRowsToDelete(rowIndexes: IndexSet) {
        infoPrint("", #function, self.className)
        if  let dataSource = tableView.dataSource as? TableViewDataSource,
            let _ = dataSource.dataSourceViewModel.unfilteredLessonEntries {
            for rowIndex in rowIndexes {
                let word = dataSource.lessonEntries[rowIndex]
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
                if let filterIndex = dataSource.lessonEntries[rowIndex].filterindex {
                    dataSource.filterRowsToDelete.insert(filterIndex)
                }
                dataSource.dataSourceViewModel.removeLessonEntry(at: rowIndex)
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
    
    func performInitialSetup() {
        let view = self.view
        if let tableView = view.viewWithTag(100) as? NSTableView {
            tableView.wantsLayer = true
            //self.tableView = tableView
            //self.dataSource = TableViewDataSource()
            self.bmtViewModel.dataSource = TableViewDataSource()
            
            tableView.dataSource = self.bmtViewModel.dataSource
            tableView.delegate = self.bmtViewModel.dataSource
            view.isHidden = true
            
            // Set up the textfinder
            
            self.textFinderClient.tableView = self.tableView
            self.textFinderClient.findBarContainer = self.scrollView
            self.textFinderClient.client = textFinderClient
        }
    }
    
}



extension BMTViewController {
    
    // MARK: TableView Functions

    enum TableIndex : Int {
        case rows
        case columns
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
            if let pastedLessonEntries = NSKeyedUnarchiver.unarchiveObject(with: rowData) as? [LessonEntry] {
                for lessonEntry in pastedLessonEntries.reversed() {
                    if let dataSource = tableView.dataSource as? TableViewDataSource {
                        if let _ = dataSource.dataSourceViewModel.unfilteredLessonEntries {
                            lessonEntry.filtertype = .add
                            if pasteRow - 1 > -1 {
                                lessonEntry.filterindex = dataSource.lessonEntries[pasteRow-1].filterindex
                            }
                            else {
                                lessonEntry.filterindex = 0
                            }
                        }
                        dataSource.dataSourceViewModel.insertLessonEntry(lessonEntry, at: pasteRow)
                    }
                }
                self.tableView.insertRows(at: IndexSet(integersIn: pasteRow..<pasteRow+pastedLessonEntries.count), withAnimation: .slideDown)
                NotificationCenter.default.post(name: .dataSourceNeedsSaving, object: nil)
            }
        }
        else {
            __NSBeep()
            return
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
            let lessonForSection = dataSource.lessonEntries[currentRow].lesson
            while lessonForSection == dataSource.lessonEntries[currentRow].lesson && currentRow > -1 {
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
            if row >= dataSource.lessonEntries.count {
                return
            }
            
            let startRow = findFirstLessonRowFor(lesson: dataSource.lessonEntries[row].lesson, at: row)
            let lessonForSection = dataSource.lessonEntries[startRow].lesson
            var currentRow = startRow
            while dataSource.lessonEntries[currentRow].lesson == lessonForSection {
                currentRow += 1
                if currentRow > dataSource.lessonEntries.count - 1 {
                    currentRow = dataSource.lessonEntries.count - 1
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
            var lessonEntryIndex = 0
            var categoryIndex = 0
            var prevLesson : String?
            var prevCategory : String?
            DispatchQueue.global(qos: .background).async {
                infoPrint("started Indexing", #function, self.className)
                for wordNum in range {
                    let lessonEntry = dataSource.lessonEntries[wordNum]
                    if self.changed(previous: prevLesson, current: lessonEntry.lesson) {
                        categoryIndex = 0
                        lessonEntryIndex = 0
                    }
                    else {
                        if self.changed(previous: prevCategory, current: lessonEntry.category) {
                            categoryIndex += 1
                            lessonEntryIndex = 0
                        }
                        else {
                            lessonEntryIndex += 1
                        }
                    }
                    prevLesson = lessonEntry.lesson
                    prevCategory = lessonEntry.category
                    if lessonEntry.lessonEntryIndex == "#" {
                        lessonEntry.istitle = true
                    }
                    else {
                        lessonEntry.istitle = false
                    }
                    lessonEntry.categoryindex = "\(categoryIndex)".padBefore("0", desiredLength: 4)
                    lessonEntry.lessonEntryIndex = "\(lessonEntryIndex)".padBefore("0", desiredLength: 4)
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
            let reindexRange = 0..<dataSource.lessonEntries.count
            self.reindexInRange(reindexRange)
            dataSource.sortBy = oldSortBy
            dataSource.sortTable(tableView, sortBy: dataSource.sortBy)
            
        }
        //NotificationCenter.default.post(name: .tableNeedsReloading, object: nil)
    }
}


