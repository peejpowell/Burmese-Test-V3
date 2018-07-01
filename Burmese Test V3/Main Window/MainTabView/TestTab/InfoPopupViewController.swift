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
        
        let index = getCurrentIndex()
        let tableView = getWordsTabViewDelegate().tabViewControllersList[index].tableView
        if let row = tableView?.selectedRow {
            if let burmeseWord = getWordsTabViewDelegate().dataSources[index].words[row].burmese {
                self.burmeseWord.stringValue = burmeseWord
            }
            if let romanWord = getWordsTabViewDelegate().dataSources[index].words[row].roman {
                self.romanWord.stringValue = romanWord
            }
            if let englishWord = getWordsTabViewDelegate().dataSources[index].words[row].english {
                self.romanWord.stringValue = englishWord
            }
        }
    }
    
}
