//
//  InfoPopupViewController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 30/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class InfoPopupViewController: NSViewController {

    @IBOutlet weak var burmeseWord: NSTextField!
    @IBOutlet weak var englishWord: NSTextField!
    @IBOutlet weak var romanWord: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if  let currentTabItem = getWordsTabViewDelegate().tabView.selectedTabViewItem,
            let bmtVC = currentTabItem.viewController as? BMTViewController,
            let dataSource = bmtVC.tableView.dataSource as? TableViewDataSource{
            let tableView = bmtVC.tableView
            if let row = tableView?.selectedRow {
                if row == -1 {return}
                if let burmeseWord = dataSource.words[row].burmese {
                    self.burmeseWord.stringValue = burmeseWord
                }
                if let romanWord = dataSource.words[row].roman {
                    self.romanWord.stringValue = romanWord
                }
                if let englishWord = dataSource.words[row].english {
                    self.romanWord.stringValue = englishWord
                }
            }
        }
    }
    
}
