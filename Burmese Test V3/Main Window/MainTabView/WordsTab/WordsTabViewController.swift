//
//  WordsTabViewController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa
import Carbon

extension Notification.Name {
    static var dataSourceNeedsSaving: Notification.Name {
        return .init(rawValue: "WordsTabViewController.dataSourceNeedsSaving")
    }
    static var newDocument: Notification.Name {
        return .init(rawValue: "WordsTabViewController.newDocument")
    }
}

extension WordsTabViewController {
    
    fileprivate func createDataSourceObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.setDataSourceNeedsSaving(_:)), name: .dataSourceNeedsSaving, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createNewDocument(_:)), name: .newDocument, object: nil)
    }
    
    fileprivate func createEmptyBMT(named name: String, controlledBy viewController: BMTViewController) -> NSTabViewItem {
        let dataSource = TableViewDataSource()
        dataSource.words.append(Words())
        self.dataSources.append(dataSource)
        let newTabItem = setupTabViewItem(named: "Untitled", controlledBy: viewController)
        getMainWindowController().window?.title = "Untitled"
        return newTabItem
    }
    
    fileprivate func editFirstColumnOf(_ tableView: NSTableView) {
        for columnNum in 0..<tableView.tableColumns.count {
            let column = tableView.tableColumns[columnNum]
            if column.isEditable && !column.isHidden {
                tableView.editColumn(columnNum, row: 0, with: nil, select: false)
                break
            }
        }
    }
    
    fileprivate func fileIsLoaded()->Bool {
        if let _ = self.dataSources[0].sourceFile {
            return true
        }
        return false
    }
    
    @objc func createNewDocument(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if !fileIsLoaded() {
            // Add a new tab and use that
            let BMTvc = BMTViewController()
            self.tabViewControllersList.append(BMTvc)
            self.tabViewItems.append(createEmptyBMT(named: "Untitled", controlledBy: BMTvc))
            self.tabView.selectTabViewItem(self.tabViewItems.last)
            editFirstColumnOf(BMTvc.tableView)
        }
        else {
            // Use the existing tab
            let BMTvc = self.tabViewControllersList[0]
            BMTvc.view.isHidden = false
            self.tabViewItems.removeAll()
            self.dataSources.removeAll()
            self.tabViewItems.append(createEmptyBMT(named: "Untitled", controlledBy: BMTvc))
            if let tableView = BMTvc.tableView {
                tableView.dataSource = dataSources[0]
                tableView.delegate = dataSources[0]
                tableView.reloadData()
                editFirstColumnOf(tableView)
            }
            NotificationCenter.default.post(name: .dataSourceNeedsSaving, object: nil)
            getMainMenuController().closeWordsFileMenuItem.isEnabled = true
            getMainMenuController().saveFileMenuItem.isEnabled = true
            getMainMenuController().saveAsFileMenuItem.isEnabled = true
        }
    }
    
    @objc func setDataSourceNeedsSaving(_ notification: Notification) {
        infoPrint("", #function, self.className)
        let index = getCurrentIndex()
        if dataSources[index].needsSaving {
            return
        }
        self.dataSources[index].needsSaving = true
        let item = self.tabViewItems[index]
        if item.label.left(1) != "*" {
            item.label = "* \(self.tabViewItems[index].label)"
        }
    }
}

class WordsTabViewController: NSTabViewController {

    // This holds all the information about the datasources for the tables
    // inside the tabs.
    
    var tabViewControllersList  : [BMTViewController] = []
    var dataSources             : [TableViewDataSource] = []
    var removingFirstItem       : Bool  = false
    var originalInputLanguage = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
    var draggingRows = false
    var indexedRows : IndexSet = IndexSet()
    
    @IBOutlet weak var searchFieldDelegate : SearchDelegate!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.createDataSourceObservers()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var tableView : NSTableView!
    //@IBOutlet weak var textFinderClient: TextFinderClient!
    
    fileprivate func performInitialSetup() {
        infoPrint("", #function, self.className)
        let BMTvc = BMTViewController()
        self.tabViewControllersList.append(BMTvc)
        self.tabViewItems.removeAll()
        self.tabViewItems.append(setupTabViewItem(named:"Nothing Loaded", controlledBy: BMTvc))

        if self.dataSources.count == 0 {
            if  let tableView = BMTvc.tableView,
                let dataSource = tableView.dataSource as? TableViewDataSource{
                self.dataSources.append(dataSource)
            }
            else
            {
                self.dataSources.append(TableViewDataSource())
            }
        }
        let view = BMTvc.view
        let tableView = view.viewWithTag(100)
        if let tableView = tableView as? PJTableView {
            tableView.dataSource = self.dataSources[0]
            tableView.delegate = self.dataSources[0]
            tableView.registerTableForDrag()
            view.isHidden = true
        }
        NotificationCenter.default.post(name: .loadRecentFiles, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        infoPrint("Words Tab",#function,self.className)
        if tabViewControllersList.count > 0 {
            return
        }
        performInitialSetup()
    }
    
    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        infoPrint(tabViewItem?.label, #function,self.className)
        super .tabView(tabView, willSelect: tabViewItem)
    }
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        infoPrint(tabViewItem?.label, #function,self.className)
        
        if let currentTabItem = self.tabView.selectedTabViewItem {
            let index = self.tabView.indexOfTabViewItem(currentTabItem)
            if index != -1 {
                let currentBMT = self.tabViewControllersList[index]
                let view = currentBMT.view
                if dataSources.count > 0 {
                    let dataSource = self.dataSources[index]
                    if let tableView = view.viewWithTag(100) as? NSTableView {
                        currentBMT.tableView = tableView
                        tableView.dataSource = dataSource
                        tableView.delegate = dataSource
                    }
                    
                    switch dataSource.needsSaving {
                    case true:
                        NotificationCenter.default.post(name: .enableRevert, object: nil)
                    case false:
                        NotificationCenter.default.post(name: .disableRevert, object: nil)
                    }
                    
                    if let mainWindow = getMainWindowController().window
                    {
                        if let url = self.dataSources[getCurrentIndex()].sourceFile {
                            mainWindow.title = url.lastPathComponent
                            mainWindow.representedURL = self.dataSources[index].sourceFile
                        }
                    }
                }
            }
        }
        super .tabView(tabView, didSelect: tabViewItem)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
