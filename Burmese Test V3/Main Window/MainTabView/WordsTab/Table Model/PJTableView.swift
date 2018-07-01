//
//  PJTableView.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 27/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa
import Carbon

class PJTableView: NSTableView {

    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func mouseDown(with event: NSEvent) {
    
        infoPrint("", #function, self.className)
        super.mouseDown(with: event)
        
        let localLocation = self.convert(event.locationInWindow, from: nil)
        if let view = self.hitTest(localLocation) as? PJTextField {
            if let id = view.identifier?.rawValue {
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
        else if let view = self.hitTest(localLocation) as? NSTextField {
            if let id = view.identifier?.rawValue {
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

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        infoPrint("TableView Created", #function, self.className)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        infoPrint("TableView Created", #function, self.className)
    }
    
    deinit {
        infoPrint("TableView Removed", #function, self.className)
    }
}

extension PJTableView {
    
    func registerTableForDrag()
    {
        infoPrint("", #function, self.className)
        
        self.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: NSPasteboard.Name.drag.rawValue)])
        
    }
    
}
