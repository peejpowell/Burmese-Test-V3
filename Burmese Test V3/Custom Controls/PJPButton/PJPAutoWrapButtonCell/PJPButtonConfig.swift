//
//  PJPButtonConfig.swift
//  Burmese Test V2
//
//  Created by Philip Powell on 17/06/2018.
//  Copyright © 2018 Phil. All rights reserved.
//

import Cocoa

class PJPButtonConfig: NSObject {
    
    var buttonFrame : NSRect
    var buttonX : CGFloat
    var buttonY : CGFloat
    var buttonWidth : CGFloat
    var buttonHeight : CGFloat
    var buttonCornerRadius : CGFloat = 0
    //var buttonDivider : CGFloat = 2
    var buttonColor : NSColor?
    
    init(frame: NSRect) {
        self.buttonFrame = frame
        self.buttonX = frame.origin.x
        self.buttonY = frame.origin.y
        self.buttonWidth = frame.width
        self.buttonHeight = frame.height
    }
    
    deinit {
        infoPrint("\(self)", #function, self.className)
    }
}
