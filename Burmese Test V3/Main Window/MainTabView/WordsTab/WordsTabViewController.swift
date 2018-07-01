//
//  WordsTabViewController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa
import Carbon

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
    @IBOutlet weak var tableView : NSTableView!
    
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
        
        // Set up an observer to check if the file needs saving because it was modified
        self.createObservers()
        
        // Add some sample data to a dataSource to show
        
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
    
    func createObservers()
    {
        let needsSaving = Notification.Name(rawValue: needsSavingNotificationKey)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateNeedsSaving), name: needsSaving, object: nil)
    }
    
    @objc func updateNeedsSaving()
    {
        infoPrint(nil,#function, self.className)
        self.dataSources[getCurrentIndex()].needsSaving = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
