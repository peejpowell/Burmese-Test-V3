//
//  GlassyButtonConfig.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 22/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

class GlassyButtonConfig : PJPButtonConfig {
    var frame: NSRect
    var x: CGFloat
    var y: CGFloat
    var rad: CGFloat
    var width: CGFloat
    var height: CGFloat
    var recessWidth: CGFloat
    var originalFrame: NSRect
    var alphaVal: CGFloat = 1
    var alphaInc: CGFloat = 0.05
    var cornerRad: CGFloat
    var horOffset: CGFloat
    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 2
    var widthOffset: CGFloat = 0
    var heightOffset: CGFloat = 0
    
    convenience init(using config: PJPButtonConfig) {
        self.init(frame: config.buttonFrame, rad: config.buttonCornerRadius, cornerRad: config.buttonCornerRadius * 2)
    }
    
    init(frame: NSRect, rad: CGFloat, cornerRad: CGFloat) {
        self.frame = frame
        self.x = frame.origin.x
        self.y = frame.origin.y
        self.rad = rad
        self.width = frame.width
        self.height = frame.height
        self.recessWidth = (frame.height * 2) - (frame.height / 4)
        self.originalFrame = frame
        self.cornerRad = cornerRad
        self.horOffset = frame.height / 4
        super.init(frame: frame)
    }
}

