//
//  FindBarViewController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class FindBarViewController: NSViewController {

    @IBOutlet var findBar : NSBox!
    @IBOutlet var filterItems : NSMenuItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        infoPrint("",#function,self.className)
    }
}
