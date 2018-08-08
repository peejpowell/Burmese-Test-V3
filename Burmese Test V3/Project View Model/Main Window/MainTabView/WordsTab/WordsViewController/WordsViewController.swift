//
//  WordsTabController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class WordsViewController: NSViewController {
    
    // MARK: Properties
    var wordsTabViewModel : WordsTabViewModel = WordsTabViewModel()
    
    // MARK: Outlets
    @IBOutlet var wordsTabViewController : WordsTabViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        wordsTabViewModel.fileManager = BMTFileManager(controller: self)
        createObservers()
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
            tabVC.tabViewItems.insert(setupTabViewItem(named: url.path.lastPathComponent, controlledBy: bmtVC), at: 0)
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


