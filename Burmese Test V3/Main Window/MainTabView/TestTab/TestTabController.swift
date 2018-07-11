//
//  TestTabViewController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class TestTabController: NSViewController {
    
    var multipleChoiceTest : MultipleChoiceTest = MultipleChoiceTest()
    
    @IBOutlet weak var testButton: PJPButton!
    
    @IBAction func showNewVC(_ sender: Any) {
        let index = getCurrentIndex()
        
        self.present(InfoPopupViewController(), asPopoverRelativeTo: self.testButton.frame, of: self.view, preferredEdge: NSRectEdge.minY, behavior: NSPopover.Behavior.transient)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        infoPrint("Test Tab",#function,self.className)
        
    }
    
}
