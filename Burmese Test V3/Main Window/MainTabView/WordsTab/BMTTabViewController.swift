//
//  BMTTabViewController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class BMTTabViewController: NSViewController {

    @IBOutlet weak var tableView : NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        infoPrint("New BMT Tab",#function,self.className)
        
        let view = self.view
        if let tableView = view.viewWithTag(100) as? NSTableView {
            tableView.wantsLayer = true
            self.tableView = tableView
        }
    }
    
    deinit {
        infoPrint("removed BMT",#function, self.className)
    }
}
