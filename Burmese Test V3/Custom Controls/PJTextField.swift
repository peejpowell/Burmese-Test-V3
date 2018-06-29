//
//  PJTextField.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 27/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa
import Carbon

class PJTextField: NSTextField {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    override func mouseDown(with theEvent: NSEvent)
    {
        infoPrint("", #function, self.className)
        
        super.mouseDown(with: theEvent)
        if let id = self.identifier?.rawValue {
            switch id {
            case "burmese":
                setKeyboardByName("Myanmar", type: .all)
            case "avalaser":
                setKeyboardByName("British", type: .ascii)
            default:
                TISSelectInputSource(getWordsTabViewDelegate().originalInputLanguage)
            }
        }
    }
    
}
