//
//  GlassyButtons.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 21/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

/// Glassy Buttons Extension - .glassy = 0

extension PJPAutoWrapButtonCell {
   
    enum GlassyElement : Int {
        typealias RawValue = Int
        case shadow
        case topHilight
        case middle
        case front
        case frontHilight
        case colorOverlay
    }

    // MARK: Rects
    
    func drawGlassyBezelRectFor(element: GlassyElement, using config: GlassyButtonConfig, offset: CGFloat = 0, down: Bool = false)->NSRect {
        
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
    
    // MARK: Bezier Paths
    
    func drawGlassyBezelElementFor(_ element: GlassyElement, using config: GlassyButtonConfig, offset: CGFloat = 0, down: Bool = false)->NSBezierPath {
        return NSBezierPath(roundedRect: drawGlassyBezelRectFor(element: element, using: config, offset: offset, down: down), xRadius: config.rad, yRadius: config.rad)
    }
    
    // MARK: Gradients
    
    @objc func glassyButtonMiddleGradient(hover: Bool = false)->NSGradient? {
        var gradMiddleColors = [NSColor(deviceWhite: 0.95, alpha: 1),
                               NSColor(deviceWhite: 0.6, alpha: 1)]
        switch hover {
        case true:
            gradMiddleColors = [NSColor(deviceRed: 0.38, green: 0.84, blue: 1, alpha: 1),
                                NSColor(deviceWhite: 0.6, alpha: 1)
            ]
        default:
            break
        }
        let gradMiddleLocations : [CGFloat] = [0,1]
        return NSGradient(colorsAndLocations: (gradMiddleColors[0],gradMiddleLocations[0]),(gradMiddleColors[1],gradMiddleLocations[1]))
    }
    
    func glassyButtonFrontGradient(hover: Bool = false)->NSGradient? {
        var gradFrontColors : [NSColor] = [NSColor(deviceWhite: 0.95, alpha: 1),
                               NSColor(deviceWhite: 0.95, alpha: 1),
                               NSColor(deviceWhite: 0.90, alpha: 1),
                               NSColor(deviceWhite: 0.99, alpha: 1)
        ]
        switch hover {
        case true:
            gradFrontColors = [NSColor(deviceRed: 0.38, green: 0.84, blue: 1, alpha: 1),
                          NSColor(deviceRed: 0.24, green: 0.65, blue: 0.91, alpha: 1),
                          NSColor(deviceRed: 0.24, green: 0.65, blue: 0.91, alpha: 1),
                          NSColor(deviceRed: 0.38, green: 0.84, blue: 1, alpha: 1)
            ]
        default:
            break
        }
        let gradFrontLocations : [CGFloat] = [0,0.3,0.4,1]
        return NSGradient(colorsAndLocations: (gradFrontColors[0], gradFrontLocations[0]),
                                              (gradFrontColors[1], gradFrontLocations[1]),
                                              (gradFrontColors[2], gradFrontLocations[2]),
                                              (gradFrontColors[3], gradFrontLocations[3])
        )
    }
    
    func glassyButtonFrontHilightGradient(hover: Bool = false, down: Bool = false)->NSGradient? {
        var gradFrontColors : [NSColor] = [NSColor(deviceWhite: 1, alpha: 1),
                                           NSColor(deviceWhite: 0.96, alpha: 1)
        ]
        if let buttonColor = self.buttonColor?.usingColorSpace(NSColorSpace.genericRGB) {
            switch hover {
            case true:
                gradFrontColors = [NSColor.white,
                                   NSColor(deviceRed: buttonColor.redComponent, green: buttonColor.greenComponent, blue: buttonColor.blueComponent, alpha: 0.75)
            ]
            case false:
                break
            }
        }
        switch down {
        case true:
            gradFrontColors = [NSColor(deviceWhite: 1, alpha: 0.9),
                               NSColor(deviceWhite: 1, alpha: 0.5)
            ]
        case false:
            break
        }
        let gradFrontLocations : [CGFloat] = [0,1]
        return NSGradient(colorsAndLocations: (gradFrontColors[0], gradFrontLocations[0]),
                          (gradFrontColors[1], gradFrontLocations[1])
        )
    }
    
    func glassyButtonColorOverlayGradient()->NSGradient? {
        var gradFrontColors : [NSColor] = [NSColor(deviceWhite: 1, alpha: 1),
                                           NSColor(deviceWhite: 1, alpha: 1),
                                           NSColor(deviceWhite: 0.8, alpha: 1)
        ]
        let gradFrontLocations : [CGFloat] = [0,0.5,1]
        if let buttonColor = self.buttonColor?.usingColorSpace(NSColorSpace.genericRGB) {
            gradFrontColors = [NSColor(deviceRed: buttonColor.redComponent, green: buttonColor.greenComponent, blue: buttonColor.blueComponent, alpha: 0.01),
                               NSColor(deviceRed: buttonColor.redComponent, green: buttonColor.greenComponent, blue: buttonColor.blueComponent, alpha: 0.25),
                               buttonColor
            ]
        }
        return NSGradient(colorsAndLocations: (gradFrontColors[0], gradFrontLocations[0]),
                          (gradFrontColors[1], gradFrontLocations[1]),
                          (gradFrontColors[2], gradFrontLocations[2])
        )
    }
    
    // MARK: Button Elements
    
    @objc func drawGlassyShadow(using config: GlassyButtonConfig) {
        NSColor.gray.setFill()
        drawGlassyBezelElementFor(.shadow, using: config).setClip()
        drawGlassyBezelElementFor(.shadow, using: config).fill()
    }
    
    @objc func drawGlassyTopHilight(using config: GlassyButtonConfig, hover: Bool = false) {
        drawGlassyBezelElementFor(.topHilight, using: config).setClip()
        switch hover {
        case false:
            NSColor.white.setFill()
        case true:
            NSColor(deviceRed: 0.69, green: 0.91, blue: 0.99, alpha: 1).setFill()
        }
        drawGlassyBezelElementFor(.topHilight, using: config).fill()
    }
    
    @objc func drawGlassyMiddle(using config: GlassyButtonConfig, hover: Bool = false) {
        NSColor(deviceWhite: 0.5, alpha: 1).setFill()
        if let middleGradient = glassyButtonMiddleGradient(hover: hover) {
            middleGradient.draw(in: drawGlassyBezelElementFor(.middle, using: config), angle: 90)
        }
    }
    
    @objc func drawGlassyFront(using config: GlassyButtonConfig, hover: Bool = false) {
        drawGlassyBezelElementFor(.front, using: config).setClip()
        if let frontGradient = glassyButtonFrontGradient(hover: hover) {
            frontGradient.draw(in: drawGlassyBezelElementFor(.front, using: config), angle: 90)
        }
    }
    
    @objc func drawGlassyFrontHilight(using config: GlassyButtonConfig, hover: Bool = false, down: Bool = false) {
        if let frontHilightGradient = glassyButtonFrontHilightGradient(hover: hover, down: down) {
            frontHilightGradient.draw(in: drawGlassyBezelRectFor(element: .frontHilight, using: config, down: down), angle: 90)
        }
    }
    
    @objc func drawGlassyColorOverlay(using config: GlassyButtonConfig) {
        drawGlassyBezelElementFor(.colorOverlay, using: config).setClip()
        if let frontHilightGradient = glassyButtonColorOverlayGradient() {
            frontHilightGradient.draw(in: drawGlassyBezelElementFor(.colorOverlay, using: config), angle: 90)
        }
    }
    
    @objc func drawGlassyTopShadow(using config: GlassyButtonConfig) {
        var ceiling : Int = 15
        var alphaInc : CGFloat = 0.02
        if config.height < 50 {
            ceiling = 10
            alphaInc = 0.05
        }
        for bezNum in 0 ..< ceiling {
            let num = CGFloat(bezNum)
            let bezier = drawGlassyBezelElementFor(.shadow, using: config)
            bezier.setClip()
            bezier.append(drawGlassyBezelElementFor(.shadow, using: config, offset: num))
            bezier.windingRule = .evenOdd
            NSColor(deviceWhite:0, alpha: alphaInc).setFill()
            bezier.fill()
        }
    }
    
    // MARK: Glassy Button States
    
    @objc func drawGlassyUpButton(using config: GlassyButtonConfig) {
        drawGlassyShadow(using: config)
        drawGlassyTopHilight(using: config)
        drawGlassyMiddle(using: config)
        drawGlassyFront(using: config)
        drawGlassyFrontHilight(using: config)
    }
    
    @objc func drawGlassyDownButton(using config: GlassyButtonConfig) {
        drawGlassyShadow(using: config)
        drawGlassyTopHilight(using: config)
        drawGlassyMiddle(using: config)
        drawGlassyFrontHilight(using: config, down: true)
        drawGlassyColorOverlay(using: config)
        drawGlassyTopShadow(using: config)
    }
    
    func drawGlassyHoverButton(using config: GlassyButtonConfig) {
        drawGlassyShadow(using: config)
        drawGlassyTopHilight(using: config, hover: true)
        drawGlassyMiddle(using: config, hover: true)
        drawGlassyFront(using: config, hover: true)
        drawGlassyColorOverlay(using: config)
        drawGlassyFrontHilight(using: config, hover: true)
    }
    
    func drawGlassyDisabledButton(using config: GlassyButtonConfig) {
        drawGlassyShadow(using: config)
        drawGlassyTopHilight(using: config)
        drawGlassyMiddle(using: config)
        drawGlassyFront(using: config)
        drawGlassyFrontHilight(using: config)
    }
    
    @objc func glassyButtons(using config: GlassyButtonConfig) {
        if let buttonState = buttonState {
            Swift.print("Glassy buttons")
            switch buttonState {
            case .up:
                drawGlassyUpButton(using: config)
            case .down:
                drawGlassyDownButton(using:config)
            case .hover:
                drawGlassyHoverButton(using: config)
            case .disabled:
                drawGlassyDisabledButton(using: config)
            default:
                drawGlassyUpButton(using: config)
            }
        }
    }
}
