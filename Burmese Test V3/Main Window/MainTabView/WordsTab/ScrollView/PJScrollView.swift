//
//  PJScrollView.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 02/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class PJScrollView: NSScrollView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        infoPrint("", #function, self.className)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.isFindBarVisible = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isFindBarVisible = false
    }
}

extension PJScrollView {
    
    @IBAction override func performTextFinderAction(_ sender: Any?) {
        infoPrint("", #function, self.className)
        let index = getCurrentIndex()
        let wordsTabController = getWordsTabViewDelegate()
        if let textFinderClient = wordsTabController.tabViewControllersList[index].textFinderClient {
            textFinderClient.client = textFinderClient
            textFinderClient.findBarContainer = wordsTabController.tabViewControllersList[index].scrollView
            textFinderClient.isIncrementalSearchingEnabled = false
            textFinderClient.incrementalSearchingShouldDimContentView = true
            textFinderClient.allowsMultipleSelection = true
            //textFinderClient.tabIndex = index
            if let sender = sender as? NSMenuItem {
                textFinderClient.performTextFinderAction(sender)
            }
        }
    }
    
    @IBAction func performFindPanelAction(_ sender: NSMenuItem){
        infoPrint("", #function, self.className)
        
        let index = getCurrentIndex()
        
        getWordsTabViewDelegate().tabViewControllersList[index].textFinderClient.performTextFinderAction(sender)
    }
}

// MARK: NSTextFinderBarContainer Protocol Functions
extension PJScrollView {
    
    override func findBarViewDidChangeHeight() {
        infoPrint("", #function, self.className)
    }
}

// MARK: First Responder functions
extension PJScrollView {
    
    func cut(_ sender: Any?) {
        infoPrint("", #function, self.className)
    }
}
