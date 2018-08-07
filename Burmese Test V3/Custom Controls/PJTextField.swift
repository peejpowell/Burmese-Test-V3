//
//  PJTextField.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 27/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class PJTextField: NSTextField {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    override func mouseDown(with theEvent: NSEvent)
    {
        //infoPrint("", #function, self.className)
        
        super.mouseDown(with: theEvent)
        if let id = self.identifier?.rawValue {
            NotificationCenter.default.post(name: .changeKeyboard, object:nil, userInfo: ["id" : id])
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        //infoPrint("\(self)", #function, self.className)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //infoPrint("\(self)", #function, self.className)
    }
    
    deinit {
        //infoPrint("\(self)", #function, self.className)
    }
}
