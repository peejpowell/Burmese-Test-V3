//
//  BMTTabViewController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

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
}

private extension BMTTabViewController {
    
    enum TableIndex : Int {
        case rows
        case columns
    }
    
    func createTableViewObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable(_:)), name: .tableNeedsReloading, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTableRows(_:)), name: .tableRowsNeedReloading, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeTableRow), name: .removeTableRow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleColumnWithId(_:)),name: .toggleColumn, object: nil)
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
                if let colName = id.left(id.length()-3) {
                    if colName == colToChange {
                        tableColumn.isHidden = hideColumn
                        resizeAllColumns()
                        break
                    }
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
        if let hiddenColumnsDict = notification.userInfo as? [String:[String]] {
            if let hiddenColumns = hiddenColumnsDict["columnVisibilityChanged"] {
                for column in self.tableView.tableColumns {
                    let id = column.identifier.rawValue
                    if let colId = id.left(id.length()-3) {
                        if hiddenColumns.contains(colId) {
                            column.isHidden = true
                        }
                        else {
                            column.isHidden = false
                        }
                    }
                }
            }
        }
    }
    
    @objc func refreshTableRows(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if let object = notification.userInfo as? [String: [IndexSet]] {
            // Unpack the dictionary
            if let indexes = object["indexes"] {
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
    }
    
    @objc func removeTableRow() {
        infoPrint("", #function, self.className)
        let index = getCurrentIndex()
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
}

class BMTTabViewController: NSViewController {

    @IBOutlet weak var testSearchButton: NSButton!
    
    @IBOutlet weak var tableView : NSTableView!
    
    @IBOutlet var textFinderClient: TextFinderClient!
    
    @IBOutlet weak var scrollView: PJScrollView!
    
    var textFinderController: NSTextFinder = NSTextFinder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        infoPrint("New BMT Tab",#function,self.className)
        
        let view = self.view
        if let tableView = view.viewWithTag(100) as? NSTableView {
            tableView.wantsLayer = true
            self.tableView = tableView
        }
        // Set up the textfinder
       
        self.textFinderController.client = self.textFinderClient
        self.textFinderController.findBarContainer = self.scrollView
        self.textFinderController.isIncrementalSearchingEnabled = true
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        infoPrint("", #function, self.className)
        self.createTableViewObservers()
        
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
            if let colId = id.left(id.length()-3) {
                if hiddenColumns.contains(colId) {
                    column.isHidden = true
                }
                else {
                    column.isHidden = false
                }
            }
        }
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        infoPrint("", #function, self.className)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        infoPrint("removed BMT",#function, self.className)
    }
}
