//
//  MainTabViewController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

extension MainTabViewController {
 
    func selectTab(at index: Int) {
        self.tabView.selectTabViewItem(at: index)
    }
}

class MainTabViewController: NSTabViewController {

    @IBOutlet var testTabController : TestTabController!
    @IBOutlet var resultsTabController : ResultsTabController!
    @IBOutlet var wordsTabController : WordsViewController!
    @IBOutlet var exportTabController : ExportTabController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        infoPrint("",#function,self.className)
        
        let testTabItem = setupTabViewItem(named: "Test",
                                                    controlledBy: self.testTabController)
        let resultsTabItem = setupTabViewItem(named: "Results",
                                              controlledBy: self.resultsTabController)
        let wordsTabItem = setupTabViewItem(named: "Words",
                                            controlledBy: self.wordsTabController)
        let exportTabItem = setupTabViewItem(named: "Export",
                                             controlledBy: self.exportTabController)
        self.tabViewItems = [testTabItem, resultsTabItem, wordsTabItem, exportTabItem]
        self.tabView.wantsLayer = true
        self.tabView.selectTabViewItem(at: 2)
        self.tabView.selectTabViewItem(at: 0)
        
    }
    
    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        
        infoPrint(tabViewItem?.label, #function,self.className)
        
        super .tabView(tabView, willSelect: tabViewItem)
    }
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        infoPrint(tabViewItem?.label, #function,self.className)
        
        if tabViewItem?.label != "Words" {
            setTitleToDefault()
        }
        else {
            setTitleToSourceUrl()
        }
        super .tabView(tabView, didSelect: tabViewItem)
    }
    
}
