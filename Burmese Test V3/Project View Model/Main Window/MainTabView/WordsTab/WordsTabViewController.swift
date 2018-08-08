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
    
    static var increaseLessonCount: Notification.Name {
        return .init(rawValue: "WordsTabViewController.increaseLessonCount")
    }
    
    static var decreaseLessonCount: Notification.Name {
        return .init(rawValue: "WordsTabViewController.decreaseLessonCount")
    }
    
    static var buildWordTypeMenu: Notification.Name {
        return .init(rawValue: "WordsTabViewController.buildWordTypeMenu")
    }
}

// MARK: Observation Functions

extension WordsTabViewController {
    
    @objc func increaseLessonCount(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if  let userInfo = notification.userInfo,
            let lessonName = userInfo[UserInfo.Keys.lesson] as? String,
            let currentTabItem = self.tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource {
            if let value = dataSource.lessons[lessonName] {
                dataSource.lessons[lessonName] = value + 1
            }
            else {
                dataSource.lessons[lessonName] = 1
            }
        }
    }
    
    @objc func decreaseLessonCount(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if  let userInfo = notification.userInfo,
            let lessonName = userInfo[UserInfo.Keys.lesson] as? String,
            let currentTabItem = self.tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource {
            if let value = dataSource.lessons[lessonName] {
                dataSource.lessons[lessonName] = value - 1
                if value == 1 {
                    dataSource.lessons[lessonName] = nil
                }
            }
        }
    }
    
    @objc func buildWordTypeMenu(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if  let userInfo = notification.userInfo,
            let wordTypeMenu = userInfo[UserInfo.Keys.menu] as? NSMenu {
            
            while wordTypeMenu.items.count>3 {
                wordTypeMenu.removeItem(at: 0)
            }
            
            for tabItem in getWordsTabViewDelegate().tabViewItems {
                NotificationCenter.default.post(name: .buildWordTypeMenuForTab, object: nil, userInfo: [UserInfo.Keys.tabItem : tabItem])
            }
        }
    }
}

extension WordsTabViewController {
    
    fileprivate func createDataSourceObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.setDataSourceNeedsSaving(_:)), name: .dataSourceNeedsSaving, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.increaseLessonCount(_:)), name: .increaseLessonCount, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.decreaseLessonCount(_:)), name: .decreaseLessonCount, object: nil)
        
        print ("creating buildwtm observer")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.buildWordTypeMenu(_:)), name: .buildWordTypeMenu, object: nil)
        
        NotificationCenter.default.post(name: .startBuildWordTypeMenu, object:nil)
        
    }
    
    func createEmptyBMT(named name: String, controlledBy bmtVC: BMTViewController) -> NSTabViewItem {
        let dataSource = TableViewDataSource()
        dataSource.dataSourceViewModel.appendLessonEntry(LessonEntry())
        let newTabItem = setupTabViewItem(named: "Untitled", controlledBy: bmtVC)
        getMainWindowController().window?.title = "Untitled"
        if let tableView = bmtVC.tableView {
            tableView.dataSource = dataSource
        }
        return newTabItem
    }
    
    func editFirstColumnOf(_ tableView: NSTableView) {
        for columnNum in 0..<tableView.tableColumns.count {
            let column = tableView.tableColumns[columnNum]
            if column.isEditable && !column.isHidden {
                tableView.editColumn(columnNum, row: 0, with: nil, select: false)
                break
            }
        }
    }
    
    @objc func setDataSourceNeedsSaving(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if  let currentTabItem = tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource {
            if dataSource.needsSaving {
                return
            }
            dataSource.needsSaving = true
            if currentTabItem.label.left(1) != "*" {
                currentTabItem.label = "* \(currentTabItem.label)"
            }
        }
    }
}

class WordsTabViewController: NSTabViewController {
    
    var openedFromCmdLine = false
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
        let bmtVC = BMTViewController(nibName: "BMTViewController", bundle: Bundle.main)
        //self.tabViewControllersList.append(BMTvc)
        self.tabViewItems.removeAll()
        self.tabViewItems.append(setupTabViewItem(named:"Nothing Loaded", controlledBy: bmtVC))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        infoPrint("Words Tab",#function,self.className)
        if self.tabViewItems.count > 0 {
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
        
        if  let currentTabItem = self.tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.dataSource {
            switch dataSource.needsSaving {
            case true:
                NotificationCenter.default.post(name: .enableRevert, object: nil)
            case false:
                NotificationCenter.default.post(name: .disableRevert, object: nil)
            }
            
            if let mainWindow = getMainWindowController().window
            {
                if let url = dataSource.sourceFile {
                    mainWindow.title = url.lastPathComponent
                    mainWindow.representedURL = url
                }
            }
        }
        super .tabView(tabView, didSelect: tabViewItem)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
