//
//  ToggleButtonConfig.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 22/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

class ToggleButtonConfig : PJPButtonConfig {
    var frame: NSRect
    var x: CGFloat
    var y: CGFloat
    var rad: CGFloat
    var width: CGFloat
    var height: CGFloat
    var recessWidth: CGFloat
    var showBorder: Bool?
    var alphaVal: CGFloat = 1
    var alphaInc: CGFloat = 0.05
    var cornerRad: CGFloat
    var horOffset: CGFloat
    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 2
    var widthOffset: CGFloat = 0
    var heightOffset: CGFloat = 0
    
    convenience init(using config: PJPButtonConfig) {
        self.init(frame: config.buttonFrame, rad: config.buttonCornerRadius/2, cornerRad: config.buttonCornerRadius)
    }
    
    override init(frame: NSRect) {
        self.frame = frame
        self.x = frame.origin.x + (frame.height / 2)
        self.y = frame.origin.y + (frame.height / 4)
        self.width = frame.width
        self.height = frame.height / 2
        self.rad = 0
        self.recessWidth = (self.height * 2) - (self.height / 4)
        self.cornerRad = 0
        self.horOffset = self.height / 4
        super.init(frame: frame)
    }
    
    init(frame: NSRect, rad: CGFloat, cornerRad: CGFloat) {
        self.frame = frame
        self.x = frame.origin.x + (frame.height / 2)
        self.y = frame.origin.y + (frame.height / 4)
        self.width = frame.width
        self.height = frame.height / 2
        self.rad = rad
        self.recessWidth = (self.height * 2) - (self.height / 4)
        self.cornerRad = cornerRad
        self.horOffset = self.height / 4
        super.init(frame: frame)
    }
}
