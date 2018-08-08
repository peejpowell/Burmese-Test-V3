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

enum tabNames {
    static let test     = "Test"
    static let results  = "Results"
    static let lessons  = "Lessons"
    static let export   = "Export"
}

class MainTabViewController: NSTabViewController {
    
    @IBOutlet var testViewController : TestViewController!
    @IBOutlet var resultsViewController : ResultsViewController!
    @IBOutlet var wordsViewController : WordsViewController!
    @IBOutlet var exportViewController : ExportViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        infoPrint("",#function,self.className)
        configureTabView(with: [[tabNames.test       : testViewController],
                                [tabNames.results    : resultsViewController],
                                [tabNames.lessons    : wordsViewController],
                                [tabNames.export     : exportViewController]])
    }
}

// Initial Setup

extension MainTabViewController {
    
    func setUpInitalTabItems(_ items: [[String:NSViewController]]) {
        for item in items {
            for key in item.keys {
                if let viewController = item[key] {
                    self.tabViewItems.append(setupTabViewItem(named: key, controlledBy: viewController))
                }
            }
        }
    }
    
    func configureTabView(with items: [[String : NSViewController]]) {
        setUpInitalTabItems(items)
        self.tabView.wantsLayer = true
        self.tabView.selectTabViewItem(at: 2)
        self.tabView.selectTabViewItem(at: 0)
    }
}

extension MainTabViewController {
    
    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        infoPrint(tabViewItem?.label, #function,self.className)
        super .tabView(tabView, willSelect: tabViewItem)
    }
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        infoPrint(tabViewItem?.label, #function,self.className)
        
        if tabViewItem?.label != tabNames.lessons {
            setTitleToDefault()
        }
        else {
            setTitleToSourceUrl()
        }
        super .tabView(tabView, didSelect: tabViewItem)
    }
    
}
