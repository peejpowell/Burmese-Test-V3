//
//  ToolbarController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static var startPopulateLessonsPopup: Notification.Name {
        return .init(rawValue: "ToolbarController.startPopulateLessonsPopup")
    }
}

class ToolbarController: NSObject, NSToolbarDelegate {
    
    @IBOutlet weak var mainToolbar : NSToolbar!
    @IBOutlet weak var lessonsPopup : NSPopUpButton!
    @IBOutlet weak var searchSlider : NSSlider!
    
    @objc func startPopulateLessonsPopup(_ notification: Notification) {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .populateLessonsPopup, object: nil, userInfo: ["lessonsPopup" : lessonsPopup])
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(startPopulateLessonsPopup(_:)), name: .startPopulateLessonsPopup, object: nil)
    }
    
    override init() {
        super.init()
        createObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
