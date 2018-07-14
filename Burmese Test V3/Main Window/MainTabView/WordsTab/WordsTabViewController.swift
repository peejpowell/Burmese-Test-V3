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
    
    static var loadRecentFiles: Notification.Name {
        return .init(rawValue: "WordsTabViewController.loadRecentFiles")
    }
}

extension WordsTabViewController {
    
    @objc func openRecentFiles() {
        let userDefaults = UserDefaults.standard
        let openMostRecent = userDefaults.bool(forKey: "OpenMostRecentAtStart")
        if openMostRecent {
            // Open the most recent file in the recent files menu
            if let mainFileManager = getMainWindowController().mainFileManager {
                let fileToOpen = getMainWindowController().mainMenuController.recentFiles[0]
                if mainFileManager.fileExists(atPath: fileToOpen.path) {
                    mainFileManager.loadOrWarn(fileToOpen)
                    if let menuController = getWordTypeMenuController() {
                        menuController.buildWordTypeMenu()
                    }
                    NotificationCenter.default.post(name: .populateLessonsPopup, object: nil)
                }
            }
        }
    }
    
    func createDataSourceObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.setDataSourceNeedsSaving(_:)), name: .dataSourceNeedsSaving, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createNewDocument(_:)), name: .newDocument, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openRecentFiles), name: .loadRecentFiles, object: nil)
    }
    
    @objc func createNewDocument(_ notification: Notification) {
        infoPrint("", #function, self.className)
        
        if let _ = self.dataSources[0].sourceFile {
            // Add a new tab and use that
        }
        else {
            // Use the existing tab and populate the dataSource
            let viewController = self.tabViewControllersList[0]
            viewController.view.isHidden = false
            self.tabViewItems[0].label = "Untitled"
            dataSources[0].words.append(Words())
            if let tableView = self.tabViewControllersList[0].tableView {
                tableView.dataSource = dataSources[0]
                tableView.delegate = dataSources[0]
                tableView.reloadData()
                // Find the first editable column
                for columnNum in 0..<tableView.tableColumns.count {
                    let column = tableView.tableColumns[columnNum]
                    if column.isEditable && !column.isHidden {
                        tableView.editColumn(columnNum, row: 0, with: nil, select: false)
                        break
                    }
                }
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
        /*else {
            if item.label.left(1) == "*" {
                let newLabel = item.label.minus(-2)
                item.label = newLabel
            }
        }*/
    }
}

class WordsTabViewController: NSTabViewController {

    // This holds all the information about the datasources for the tables
    // inside the tabs.
    
    var tabViewControllersList  : [BMTTabViewController] = []
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        infoPrint("Words Tab",#function,self.className)
        
        printResponderChain(getWordsTabViewDelegate())
        
        if tabViewControllersList.count > 0 {
            return
        }
        tabViewControllersList.append(BMTTabViewController())
        //tabViewControllersList.append(BMTTabViewController())
        if let tableView = tabViewControllersList[0].tableView
        {
            tableView.dataSource = nil
            tableView.delegate = nil
        }
        self.tabViewItems.removeAll()
        
        let tabViewControllerItem = self.tabViewControllersList[0]
        let newTabViewItem = setupTabViewItem(named:"Nothing Loaded", controlledBy: tabViewControllerItem)
        self.tabViewItems.append(newTabViewItem)
        
        if self.dataSources.count == 0 {
            if let tableView = self.tabViewControllersList[0].tableView,
            let dataSource = tableView.dataSource as? TableViewDataSource{
                self.dataSources.append(dataSource)
            }
            else
            {
                self.dataSources.append(TableViewDataSource())
            }
        }
        
        /*newDataSource.words.append(Words(burmese: "ကောင်းတယ်", english: "kaundeh", roman: "good"))
        let newDataSource2 = self.dataSources[1]
        newDataSource2.words.append(Words(burmese: "မကောင်းဘူး", english: "måkaunbè", roman: "bad"))
        */
        let currentBMT = self.tabViewControllersList[0]
        let view = currentBMT.view
        let tableView = view.viewWithTag(100)
        if let tableView = tableView as? PJTableView
        {
            //self.dataSources[0].tableView = tableView
            tableView.dataSource = self.dataSources[0]
            tableView.delegate = self.dataSources[0]
            tableView.registerTableForDrag()
            view.isHidden = true
        }
        self.openRecentFiles()
    }
    
    
    
    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        infoPrint(tabViewItem?.label, #function,self.className)
        super .tabView(tabView, willSelect: tabViewItem)
    }
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        infoPrint(tabViewItem?.label, #function,self.className)
        if getCurrentIndex() != -1 {
            let currentBMT = self.tabViewControllersList[getCurrentIndex()]
            let view = currentBMT.view
            if let tableView = view.viewWithTag(100) as? NSTableView {
                tableView.dataSource = self.dataSources[getCurrentIndex()]
                tableView.delegate = self.dataSources[getCurrentIndex()]
                //self.dataSources[getCurrentIndex()].tableView = tableView
                //self.dataSources[getCurrentIndex()].tableView.dataSource = dataSource
                //self.dataSources[getCurrentIndex()].tableView.delegate = dataSource
            }
        }
        
        if let mainWindow = getMainWindowController().window
        {
            let index = getCurrentIndex()
            if index != -1 {
                if let url = self.dataSources[getCurrentIndex()].sourceFile {
                    mainWindow.title = url.lastPathComponent
                    mainWindow.representedURL = self.dataSources[index].sourceFile
                }
            }
        }
        
        super .tabView(tabView, didSelect: tabViewItem)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
