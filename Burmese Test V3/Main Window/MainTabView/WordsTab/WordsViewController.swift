//
//  WordsTabController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static var openRecentFile: Notification.Name {
        return .init(rawValue: "WordsViewController.openRecentFile")
    }
}

// MARK: Observation functions

extension WordsViewController {
    
    @objc func openRecentFile(_ notification: Notification) {
        infoPrint("", #function, self.className)
        if  let userInfo = notification.userInfo,
            let url = userInfo[userInfoUrl] as? URL {
            //if let currentTabItem = wordsTabViewController.tabView.selectedTabViewItem {
                wordsTabViewModel.fileManager?.openRecentFile(url: url )
            //}
        }
    }
}

extension WordsViewController {
    
    /**
     Loads a BMT file into a datasource
     - Parameter fileURL    : URL for the file to load
     - Parameter dataSource : The datasource to load it into.
     - Returns: A datasource with the file contents loaded into it.
     */
    
    func setUpNewBMTFor(_ dataSource : TableViewDataSource, with url: URL) {
        infoPrint("", #function, self.className)
        if let tabVC = self.wordsTabViewController {
            let bmtVC = BMTViewController(nibName: "BMTViewController", bundle: Bundle.main)
            tabVC.tabViewItems.append(setupTabViewItem(named: url.path.lastPathComponent, controlledBy: bmtVC))
            let view = bmtVC.view
            view.superview?.wantsLayer = true
            bmtVC.bmtViewModel.dataSource = dataSource
            //bmtVC.dataSource.words = dataSource.words
            //bmtVC.dataSource.sourceFile = dataSource.sourceFile
            if let tableView = view.viewWithTag(100) as? NSTableView {
                bmtVC.tableView = tableView
                bmtVC.tableView.dataSource = bmtVC.dataSource
                bmtVC.tableView.delegate = bmtVC.dataSource
            }
            selectWordsTab()
            /*tabVC.dataSources.append(dataSource)
            let bmtVC = BMTViewController()
            let view = bmtVC.view
            if let tableView = view.viewWithTag(100) as? NSTableView {
                if let dataSource = tabVC.dataSources.last {
                    tableView.dataSource = dataSource
                    tableView.delegate = dataSource
                }
            }
            tabVC.tabViewControllersList.append(bmtVC)
            let newTabViewItem = NSTabViewItem()
            newTabViewItem.label = url.path.lastPathComponent
            newTabViewItem.viewController = bmtVC
            tabVC.tabViewItems.append(newTabViewItem)
            selectWordsTab()*/
        }
    }
}

class WordsViewController: NSViewController {

    enum UserInfoKey : String {
        case url = "url"
    }
    
    let userInfoUrl     = UserInfoKey.url.rawValue
    
    var wordsTabViewModel : WordsTabViewModel = WordsTabViewModel()
    
    @IBOutlet var wordsTabViewController : WordsTabViewController!
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.openRecentFile(_:)), name: .openRecentFile, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        wordsTabViewModel.fileManager = BMTFileManager(controller: self)
        NotificationCenter.default.post(name: .loadRecentFiles, object: nil)
        createObservers()
    }
    
    override func viewWillAppear() {
    }
    
    override func viewWillDisappear() {
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        infoPrint("", #function, self.className)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        infoPrint("", #function, self.className)
    }
    
    deinit {
        infoPrint("", #function, self.className)
        wordsTabViewModel.fileManager?.controller = nil
        wordsTabViewModel.fileManager = nil
    }
    
}
