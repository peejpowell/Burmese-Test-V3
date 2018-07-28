//
//  SimpleButtonConfig.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 22/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

class SimpleButtonConfig : PJPButtonConfig {
    var frame: NSRect
    var x: CGFloat
    var y: CGFloat
    var rad: CGFloat
    var width: CGFloat
    var height: CGFloat
    var showBorder: Bool?
    var originalFrame: NSRect
    
    convenience init(using config: PJPButtonConfig) {
        self.init(frame: config.buttonFrame, x: config.buttonX, y: config.buttonY, rad: config.buttonCornerRadius, width: config.buttonWidth, height: config.buttonHeight, originalFrame: config.buttonFrame)
    }
    
    init(frame: NSRect, x: CGFloat, y: CGFloat, rad: CGFloat, width: CGFloat, height: CGFloat, originalFrame: NSRect) {
        self.frame = frame
        self.x = x
        self.y = y
        self.rad = rad
        self.width = width
        self.height = height
        self.originalFrame = originalFrame
        super.init(frame: frame)
    }
}
