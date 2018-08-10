//
//  MetallicButtons.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 21/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

class MetallicButtonConfig {
    var frame: NSRect
    var x: CGFloat
    var y: CGFloat
    var rad: CGFloat
    var width: CGFloat
    var height: CGFloat
    var recessWidth: CGFloat
    var showBorder: Bool?
    var originalFrame: NSRect
    var alphaVal: CGFloat
    var alphaInc: CGFloat
    var cornerRad: CGFloat
    var horOffset: CGFloat
    var xOffset: CGFloat
    var yOffset: CGFloat
    var widthOffset: CGFloat
    var heightOffset: CGFloat
    
    
    init(frame: NSRect, x: CGFloat, y: CGFloat, rad: CGFloat, width: CGFloat, height: CGFloat, recessWidth: CGFloat, showBorder: Bool?, originalFrame: NSRect, alphaVal: CGFloat, alphaInc: CGFloat, cornerRad: CGFloat, horOffset: CGFloat, xOffset: CGFloat, yOffset: CGFloat, widthOffset: CGFloat, heightOffset: CGFloat) {
        self.frame = frame
        self.x = x
        self.y = y
        self.rad = rad
        self.width = width
        self.height = height
        self.recessWidth = recessWidth
        self.showBorder = showBorder
        self.originalFrame = originalFrame
        self.alphaVal = alphaVal
        self.alphaInc = alphaInc
        self.cornerRad = cornerRad
        self.horOffset = horOffset
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.widthOffset = widthOffset
        self.heightOffset = heightOffset
        print("Created MetallicButtonConfig: \(self)")
    }
    
    deinit {
        print("Removed MetallicButtonConfig : \(self)")
    }
}

/// Metallic Buttons Extension - .metallic = 3

extension PJPAutoWrapButtonCell {
    
    enum MetallicElement : Int {
        case shadow
        case topHilight
        case middle
        case front
        case frontHilight
        case colorOverlay
    }
    
    // MARK: Rects
    
    func drawMetallicBezelRectFor(element: MetallicElement, using config: MetallicButtonConfig, offset: CGFloat = 0, down: Bool = false)->NSRect {
        
        let x = config.x
        let y = config.y
        let width = config.width
        let height = config.height
        let xOffset = config.xOffset
        let yOffset = config.yOffset
        let widthOffset = config.widthOffset
        let heightOffset = config.heightOffset
        
        switch element {
        case .shadow:
            switch offset > 0 {
            case false:
                return NSRect(x: x,
                              y: y,
                              width: width,
                              height: height
                )
            case true:
                return NSRect(x: x + offset,
                              y: y + offset,
                              width: width - offset,
                              height: height - offset
                )
            }
        case .topHilight, .colorOverlay:
            return NSRect(x: x + 1,
                          y: y + 1,
                          width: width - 2,
                          height: height - 2
            )
        case .middle:
            return NSRect(x: x + 1,
                          y: y + 3,
                          width: width - 2,
                          height: height - 2
            )
        case .front:
            return NSRect(x: x + 2,
                          y: y + 4,
                          width: width - 4,
                          height: height - 6
            )
        case .frontHilight:
            switch down {
            case false:
                return NSRect(x: x + xOffset,
                              y: y + yOffset,
                              width: width - widthOffset,
                              height: height / 2 - heightOffset
                )
            case true:
                return NSRect(x: x + xOffset,
                              y: y + yOffset,
                              width: width - widthOffset,
                              height: height / 2 - heightOffset + (height / 10)
                )
            }
        }
    }
}

