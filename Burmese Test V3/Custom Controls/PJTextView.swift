//
//  PJTextView.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 11/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class PJTextView: NSTextView
{
    
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
   
    /*func mykeyDown(with theEvent: NSEvent)
    {
        var myEvent = theEvent
        
        switch theEvent.keyCode
        {
        case 0:
            if myEvent.modifierFlags.rawValue & NSEvent.ModifierFlags.option.rawValue == NSEvent.ModifierFlags.option.rawValue
            {
                myEvent1 = NSEvent.keyEvent(with: theEvent.type, location: <#T##NSPoint#>, modifierFlags: <#T##NSEvent.ModifierFlags#>, timestamp: <#T##TimeInterval#>, windowNumber: <#T##Int#>, context: <#T##NSGraphicsContext?#>, characters: <#T##String#>, charactersIgnoringModifiers: <#T##String#>, isARepeat: <#T##Bool#>, keyCode: <#T##UInt16#>)
                myEvent = NSEvent.keyEvent(with: theEvent.type, location: theEvent.locationInWindow, modifierFlags: theEvent.modifierFlags, timestamp: theEvent.timestamp, windowNumber: theEvent.windowNumber, context: theEvent.context, characters: "ă", charactersIgnoringModifiers: "a", isARepeat: theEvent.isARepeat, keyCode: theEvent.keyCode)!
            }
        case 3:
            if myEvent.modifierFlags.rawValue & NSEvent.ModifierFlags.command.rawValue == NSEvent.ModifierFlags.command.rawValue
            {
                self.performFindPanelAction(self)
                myEvent = theEvent
            }
        default:
            //print("Unhandled key code: \(theEvent.keyCode)")
            break
        }
        
        super.keyDown(with: myEvent)
    }*/
    
    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    deinit {
        infoPrint("\(self)", #function, self.className)
    }
}
