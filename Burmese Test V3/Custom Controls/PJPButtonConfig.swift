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
    var buttonX : CGFloat?
    var buttonY : CGFloat?
    var buttonWidth : CGFloat?
    var buttonHeight : CGFloat?
    var buttonCornerRadius : CGFloat?
    var buttonDivider : CGFloat?
    var buttonColor : NSColor?
    
    init(frame: NSRect) {
        self.buttonFrame = frame
    }
    
    deinit {
        infoPrint("\(self)", #function, self.className)
    }
}
