//
//  FieldEditorTextView.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 11/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class FieldEditorTextView: NSTextView {
    
    override func keyDown(with event: NSEvent) {
        var myEvent = event
    
        switch event.keyCode {
        case 0:
            if event.modifierFlags.contains(NSEvent.ModifierFlags.option) {
                if let event = NSEvent.keyEvent(with: event.type, location: event.locationInWindow, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, characters: "ă", charactersIgnoringModifiers: "a", isARepeat: event.isARepeat, keyCode: event.keyCode) {
                    myEvent = event
                }
            }
        case 3:
            if myEvent.modifierFlags.contains(NSEvent.ModifierFlags.command) {
                self.performFindPanelAction(self)
                myEvent = event
            }
        default:
            break
        }
        super.keyDown(with: myEvent)
    }
    
    deinit {
        infoPrint("\(self)", #function, self.className)
    }
}
