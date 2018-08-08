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
    
    override func keyDown(with theEvent: NSEvent) {
        if theEvent.keyCode == 51 {
            NotificationCenter.default.post(name: .removeTableRow, object: nil)
        }
        super.keyDown(with: theEvent)
    }
    
    override func mouseDown(with event: NSEvent) {
    
        //infoPrint("", #function, self.className)
        super.mouseDown(with: event)
        
        let localLocation = self.convert(event.locationInWindow, from: nil)
        if let view = self.hitTest(localLocation) as? PJTextField {
            if let id = view.identifier?.rawValue {
                NotificationCenter.default.post(name: .changeKeyboard, object:nil, userInfo: ["id" : id])
            }
        }
        else if let view = self.hitTest(localLocation) as? NSTextField {
            if let id = view.identifier?.rawValue {
                NotificationCenter.default.post(name: .changeKeyboard, object:nil, userInfo: ["id" : id])
            }
        }
    }

    override func awakeFromNib() {
        registerTableForDrag()
        //registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
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

// MARK: DragOperation Functions

extension PJTableView {
    
    func registerTableForDrag()
    {
        infoPrint("", #function, self.className)
        
        self.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: NSPasteboard.Name.drag.rawValue)])
    }
}
