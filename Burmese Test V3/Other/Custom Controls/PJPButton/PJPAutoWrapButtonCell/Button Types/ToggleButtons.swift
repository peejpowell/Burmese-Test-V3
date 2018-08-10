//
//  ToggleButtons.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 19/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

/// Toggle Buttons Extension - .toggle = 1

extension PJPAutoWrapButtonCell {
    
    enum ToggleElement : Int {
        case shadowOn
        case shadowOff
        case shadowHoverOn
        case shadowHoverOff
        case topShadowFrame1
        case topShadowFrame2
        case back
        case backInterior
        case onMiddle
        case offMiddle
        case onMiddleHover
        case offMiddleHover
        case onFront
        case onFrontHover
        case offFront
        case offFrontHover
        case offIndicatorBack
        case offIndicatorFront
        case onIndicator
        case onTopHilight
        case onTopHilightHover
        case offTopHilight
        case offTopHilightHover
        case onFrontHilight
        case onFrontHilightHover
        case offFrontHilight
        case offFrontHilightHover
    }
    
    // MARK: Toggle Button Rects
    
    func drawToggleBezelRectFor(element: ToggleElement,using config: ToggleButtonConfig, offset: CGFloat = 0)->NSRect {
        
        let x = config.x
        let y = config.y
        let height = config.height
        let heightOffset = config.height
        let horOffset = config.horOffset
        let xOffset = config.xOffset
        let yOffset = config.yOffset
        let recessWidth = config.recessWidth
        
        switch element {
        case .topShadowFrame1:
            return NSRect(x:        x,
                          y:        y,
                          width:    height + horOffset + (height / 2),
                          height:   height
            )
        case .topShadowFrame2:
            return NSRect(x:        x + offset,
                          y:        y + offset,
                          width:    height + horOffset + (height / 2) - offset,
                          height:   height - offset
            )
        case .onIndicator:
            return NSRect(x:        (x + height / 2) - height / 16,
                          y:        y + (height / 2) - ( height / 6),
                          width:    height / 16,
                          height:   height / 3
            )
        case .offIndicatorBack:
            return NSRect(x:        x + (height) + horOffset,
                          y:        y + (height / 2) - (height / 6),
                          width:    height / 3,
                          height:   height / 3)
        case .offIndicatorFront:
            return NSRect(x:        x + (height) + horOffset + (height / 16) - 1,
                          y:        y + (height / 2) - (height / 8),
                          width:    height / 4,
                          height:   height / 4
            )
        case .shadowOn:
            return NSRect(x:        x + (height/2) + horOffset + 5,
                          y:        y + 5,
                          width:    height,
                          height:   height
            )
        case .shadowOff:
            return NSRect(x:        x + (height/8),
                          y:        y + (height/8),
                          width:    height,
                          height:   height
            )
        case .shadowHoverOn:
            return NSRect(x:        x + (height/2) + 5,
                          y:        y + 5,
                          width:    (height + (height/4)),
                          height:   height
            )
        case .shadowHoverOff:
            return NSRect(x:        x + 5, y:       y + 5,
                          width:    (height + (height/4)),
                          height:   height
            )
        case .onMiddle:
            return NSRect(x:        x + (height/2) + horOffset + 1,
                          y:        y + 3,
                          width:    height-2,
                          height:   height-2
            )
        case .offMiddle:
            return NSRect(x:        x + 1,
                          y:        y + 1,
                          width:    height-2,
                          height:   height-2)
        case .onMiddleHover:
            return NSRect(x:        (x + height/2) + 1,
                          y:        y + 3,
                          width:    (height + (height/4))-2,
                          height:   height-2)
        case .offMiddleHover:
            return NSRect(x:        x + 1,
                          y:        y + 3,
                          width:    (height + (height/4))-2,
                          height:   height-2
            )
        case .offFront:
            return NSRect(x:        x + 2,
                          y:        y + 4,
                          width:    height-4,
                          height:   height-6
            )
        case .offFrontHover:
            return NSRect(x:        x + 2,
                          y:        y + 4,
                          width:    (height + (height/4))-4,
                          height:   height-6
            )
        case .onFront:
            return NSRect(x:        x + (height/2) + horOffset + 2,
                          y:        y + 4,
                          width:    height-4,
                          height:   height-6
            )
        case .onFrontHover:
            return NSRect(x:        (x + height/2) + 2,
                          y:        y + 4,
                          width:    (height + (height/4))-4,
                          height:   height-6
            )
        case .onTopHilight:
            return NSRect(x:        x + (height/2) + horOffset + 1,
                          y:        y + 1,
                          width:    height-2,
                          height:   height-2
            )
        case .onTopHilightHover:
            return NSRect(x:        (x + (height/2)) + 1,
                          y:        y + 1,
                          width:    (height + (height/4))-2,
                          height:   height-2
            )
        case .offTopHilight:
            return NSRect(x:        x + 1,
                          y:        y + 1,
                          width:    height-2,
                          height:   height-2
            )
        case .offTopHilightHover:
            return NSRect(x:        x + 1,
                          y:        y + 1,
                          width:    (height + (height/4))-2,
                          height:   height-2
            )
        case .onFrontHilight:
            return NSRect(x:        x + (height/2) + horOffset + xOffset,
                          y:        y + yOffset,
                          width:    height-heightOffset,
                          height:   height/2-heightOffset
            )
        case .onFrontHilightHover:
            return NSRect(x:        x + 5,
                          y:        y + 5,
                          width:    (height + (height/4)),
                          height:   height
            )
        case .offFrontHilight:
            return NSRect(x:        x + xOffset + 2,
                          y:        y + yOffset + 2,
                          width:    height-heightOffset-4,
                          height:   height/2-heightOffset-4
            )
        case .offFrontHilightHover:
            return NSRect(x:        x + xOffset,
                          y:        y + yOffset,
                          width:    (height + (height/4))-heightOffset,
                          height:   height/2-heightOffset
            )
        case .back:
            return NSRect(x:        x,
                          y:        y,
                          width:    recessWidth,
                          height:   height
            )
        case .backInterior:
            return NSRect(x:        x + 1,
                          y:        y + 1,
                          width:    recessWidth-2,
                          height:   height-2
            )
        }
    }
    
    // MARK: Bezier Paths
    
    func drawToggleBezelElementFor(_ element: ToggleElement, using config: ToggleButtonConfig, offset: CGFloat = 0)->NSBezierPath {
        
        let height = config.height
        let rad = config.rad
        
        switch element {
        case .onFront:
            return NSBezierPath(roundedRect: drawToggleBezelRectFor(element: .onFront, using: config), xRadius: rad, yRadius: rad)
        case .topShadowFrame2:
            return NSBezierPath(roundedRect: drawToggleBezelRectFor(element: element, using: config, offset: offset), xRadius: rad, yRadius: rad)
        case .offIndicatorBack:
            return NSBezierPath(roundedRect: drawToggleBezelRectFor(element: element, using: config, offset: offset), xRadius: height/3, yRadius: height/3)
        case .offIndicatorFront:
            return NSBezierPath(roundedRect: drawToggleBezelRectFor(element: element, using: config, offset: offset), xRadius: height/4, yRadius: height/4)
        case .onIndicator:
            return NSBezierPath(rect: drawToggleBezelRectFor(element: element, using: config))
        default:
            return NSBezierPath(roundedRect: drawToggleBezelRectFor(element: element, using: config, offset: offset), xRadius: rad, yRadius: rad)
        }
        
    }
    
    // MARK: Gradients
    
    func toggleButtonMiddleGradient()->NSGradient? {
        let gradFrontColors = [NSColor(deviceWhite: 0.95, alpha: 1),
                               NSColor(deviceWhite: 0.6, alpha: 1)]
        let gradFrontLocations : [CGFloat] = [0,1]
        return NSGradient(colorsAndLocations: (gradFrontColors[0],gradFrontLocations[0]),(gradFrontColors[1],gradFrontLocations[1]))
    }
    
    func toggleButtonFrontGradient()->NSGradient? {
        let gradFrontColors = [NSColor(deviceWhite: 0.95, alpha: 1),
                               NSColor(deviceWhite: 0.95, alpha: 1),
                               NSColor(deviceWhite: 0.90, alpha: 1),
                               NSColor(deviceWhite: 0.99, alpha: 1)]
        let gradFrontLocations : [CGFloat] = [0,0.3,0.4,1]
        return NSGradient(colorsAndLocations: (gradFrontColors[0],gradFrontLocations[0]),(gradFrontColors[1],gradFrontLocations[1]),(gradFrontColors[2],gradFrontLocations[2]),(gradFrontColors[3],gradFrontLocations[3]))
    }
    
    func toggleButtonFrontHilightGradient()->NSGradient? {
        let gradFrontColors = [NSColor(deviceWhite: 1, alpha: 1), NSColor(deviceWhite: 0.96, alpha: 1)]
        let gradFrontLocations : [CGFloat] = [0,1]
        return NSGradient(colorsAndLocations: (gradFrontColors[0],gradFrontLocations[0]),(gradFrontColors[1],gradFrontLocations[1]))
    }
    
    // MARK: Button Elements
    
    func toggleOnTopHilight(using config: ToggleButtonConfig) {
        drawToggleBezelElementFor(.onTopHilight, using: config).setClip()
        NSColor.white.setFill()
        drawToggleBezelElementFor(.onTopHilight, using: config).fill()
    }
    
    func toggleOnTopHilightHover(using config: ToggleButtonConfig) {
        drawToggleBezelElementFor(.onTopHilightHover, using: config).setClip()
        NSColor.white.setFill()
        drawToggleBezelElementFor(.onTopHilightHover, using: config).fill()
    }
    
    func toggleOffTopHilightHover(using config: ToggleButtonConfig) {
        drawToggleBezelElementFor(.offTopHilightHover, using: config).setClip()
        NSColor.white.setFill()
        drawToggleBezelElementFor(.offTopHilightHover, using: config).fill()
    }
    
    func toggleOffTopHilight(using config: ToggleButtonConfig) {
        drawToggleBezelElementFor(.offTopHilight, using: config).setClip()
        NSColor.white.setFill()
        drawToggleBezelElementFor(.offTopHilight, using: config).fill()
    }
    
    func toggleShadowOn(using config: ToggleButtonConfig) {
        drawToggleBezelElementFor(.shadowOn, using: config).setClip()
        NSColor(deviceWhite: 0, alpha:0.3).setFill()
        drawToggleBezelElementFor(.shadowOn, using: config).fill()
    }
    
    func toggleShadowOff(using config: ToggleButtonConfig) {
        drawToggleBezelElementFor(.shadowOff, using: config).setClip()
        NSColor(deviceWhite: 0, alpha:0.3).setFill()
        drawToggleBezelElementFor(.shadowOff, using: config).fill()
    }
    
    func toggleShadowHoverOn(using config: ToggleButtonConfig) {
        drawToggleBezelElementFor(.shadowHoverOn, using: config).setClip()
        NSColor(deviceWhite: 0, alpha:0.3).setFill()
        drawToggleBezelElementFor(.shadowHoverOn, using: config).fill()
    }
    
    func toggleShadowHoverOff(using config: ToggleButtonConfig) {
        drawToggleBezelElementFor(.shadowHoverOff, using: config).setClip()
        NSColor(deviceWhite: 0, alpha:0.3).setFill()
        drawToggleBezelElementFor(.shadowHoverOff, using: config).fill()
    }
    
    func toggleOnMiddle(using config: ToggleButtonConfig) {
        NSColor(deviceWhite: 1, alpha: 1).setFill()
        if let middleGradient = toggleButtonMiddleGradient() {
            middleGradient.draw(in: drawToggleBezelElementFor(.onMiddle, using: config), angle: 90)
        }
    }
    
    func toggleOffMiddle(using config: ToggleButtonConfig) {
        NSColor(deviceWhite: 1, alpha: 1).setFill()
        if let middleGradient = toggleButtonMiddleGradient() {
            middleGradient.draw(in: drawToggleBezelElementFor(.offMiddle, using: config), angle: 90)
        }
    }
    
    func toggleOnMiddleHover(using config: ToggleButtonConfig) {
        NSColor(deviceWhite: 1, alpha: 1).setFill()
        if let middleGradient = toggleButtonMiddleGradient() {
            middleGradient.draw(in: drawToggleBezelElementFor(.onMiddleHover, using: config), angle: 90)
        }
    }
    
    func toggleOffMiddleHover(using config: ToggleButtonConfig) {
        NSColor(deviceWhite: 1, alpha: 1).setFill()
        if let middleGradient = toggleButtonMiddleGradient() {
            middleGradient.draw(in: drawToggleBezelElementFor(.offMiddleHover, using: config), angle: 90)
        }
    }
    
    func toggleOnFront(using config: ToggleButtonConfig) {
        drawToggleBezelElementFor(.onFront, using: config).setClip()
        if let frontGradient = toggleButtonFrontGradient() {
            frontGradient.draw(in: drawToggleBezelElementFor(.onFront, using: config), angle: 90)
        }
    }
    
    func toggleOnFrontHover(using config: ToggleButtonConfig) {
        drawToggleBezelElementFor(.onFrontHover, using: config).setClip()
        if let frontGradient = toggleButtonFrontGradient() {
            frontGradient.draw(in: drawToggleBezelElementFor(.onFrontHover, using: config), angle: 90)
        }
    }
    
    func toggleOffFront(using config: ToggleButtonConfig) {
        drawToggleBezelElementFor(.offFront, using: config).setClip()
        if let frontGradient = toggleButtonFrontGradient() {
            frontGradient.draw(in: drawToggleBezelElementFor(.offFront, using: config), angle: 90)
        }
    }
    
    func toggleOffFrontHover(using config: ToggleButtonConfig) {
        drawToggleBezelElementFor(.offFrontHover, using: config).setClip()
        if let frontGradient = toggleButtonFrontGradient() {
            frontGradient.draw(in: drawToggleBezelElementFor(.offFrontHover, using: config), angle: 90)
        }
    }
    
    func toggleOnFrontHilight(using config: ToggleButtonConfig) {
        //let frontHilight = drawToggleBezelElementFor(.frontHilight, using: config)
            //frontHilight.setClip()
        if let frontHilightGradient = toggleButtonFrontHilightGradient() {
            frontHilightGradient.draw(in: drawToggleBezelRectFor(element: .onFrontHilight, using: config), angle: 90)
        }
    }
    
    func toggleOffFrontHilight(using config: ToggleButtonConfig) {
        //let frontHilight = drawToggleBezelElementFor(.frontHilight, using: config)
        //frontHilight.setClip()
        if let frontHilightGradient = toggleButtonFrontHilightGradient() {
            frontHilightGradient.draw(in: drawToggleBezelRectFor(element: .offFrontHilight, using: config), angle: 90)
        }
    }
    
    func toggleOnFrontHilightHover(using config: ToggleButtonConfig) {
        //let frontHilight = drawToggleBezelElementFor(.frontHilight, using: config)
        //frontHilight.setClip()
        if let frontHilightGradient = toggleButtonFrontHilightGradient() {
            frontHilightGradient.draw(in: drawToggleBezelRectFor(element: .onFrontHilightHover, using: config), angle: 90)
        }
    }
    
    func toggleOffFrontHilightHover(using config: ToggleButtonConfig) {
        //let frontHilight = drawToggleBezelElementFor(.frontHilight, using: config)
        //frontHilight.setClip()
        if let frontHilightGradient = toggleButtonFrontHilightGradient() {
            frontHilightGradient.draw(in: drawToggleBezelRectFor(element: .offFrontHilightHover, using: config), angle: 90)
        }
    }
    func toggleOnOffIndicators(using config: ToggleButtonConfig) {
        let offIndicatorBack = drawToggleBezelElementFor(.offIndicatorBack, using: config)
        offIndicatorBack.append(drawToggleBezelElementFor(.offIndicatorFront, using: config))
        offIndicatorBack.windingRule = .evenOdd
        NSColor(deviceWhite:0, alpha: 0.5).setFill()
        offIndicatorBack.setClip()
        offIndicatorBack.fill()
        NSColor(deviceWhite:1, alpha: 1).setFill()
        drawToggleBezelElementFor(.onIndicator, using: config).setClip()
        drawToggleBezelElementFor(.onIndicator, using: config).fill()
    }
    
    func toggleTopShadow(using config: ToggleButtonConfig) {
        var newAlphaInc = config.alphaInc
        var ceiling : Int = 15
        
        if config.height < 50 {
            ceiling = 15
            newAlphaInc = 0.02
        }
        for bezNum in 0..<ceiling {
            let num = CGFloat(bezNum)
            let bezier = drawToggleBezelElementFor(.topShadowFrame1, using: config)
            bezier.setClip()
            bezier.append(drawToggleBezelElementFor(.topShadowFrame2, using: config, offset: num))
            bezier.windingRule = .evenOdd
            NSColor(deviceWhite:0, alpha: newAlphaInc).setFill()
            bezier.fill()
        }
    }
    
    func toggleBack(using config: ToggleButtonConfig, disabled: Bool = false) {
        if let bordered = self.showBorder {
            switch bordered {
            case true:
                let buttonAreaRect = NSRect(x: config.frame.origin.x+1, y: config.frame.origin.y+1, width: config.frame.width-2, height: config.frame.height-2)
                let buttonArea = NSBezierPath(roundedRect: buttonAreaRect, xRadius: config.cornerRad, yRadius: config.cornerRad)
                NSColor(deviceWhite: 0, alpha: 0.5).setStroke()
                switch disabled {
                case false:
                    NSColor(deviceWhite: 0, alpha: config.alphaInc).setFill()
                case true:
                    NSColor(deviceWhite: 0, alpha: 0.025).setFill()
                }
                buttonArea.fill()
                buttonArea.stroke()
            case false:
                break
            }
        }
        switch disabled {
        case false:
            NSColor(deviceWhite:0.7, alpha: config.alphaVal).setFill()
        case true:
            NSColor(deviceWhite:0.7, alpha: 0.75).setFill()
        }
            drawToggleBezelElementFor(.back, using: config).fill()
        switch disabled {
        case false:
            if let buttonColor = self.buttonColor {
                buttonColor.setFill()
                drawToggleBezelElementFor(.backInterior, using: config).fill()
            }
        case true:
            NSColor(deviceWhite: 1, alpha: 0.75).setFill()
            drawToggleBezelElementFor(.backInterior, using: config).fill()
        }
        
    }
    
    // MARK: Toggle Button States
    
    func drawToggleOnButton(using config: ToggleButtonConfig)
    {
        toggleBack(using: config)
        toggleShadowOn(using: config)
        toggleOnOffIndicators(using: config)
        toggleTopShadow(using:config)
        toggleOnTopHilight(using: config)
        toggleOnMiddle(using: config)
        toggleOnFront(using: config)
        toggleOnFrontHilight(using: config)
        
    }
    
    func drawToggleOffButton(using config: ToggleButtonConfig)
    {
        toggleBack(using: config)
        toggleOnOffIndicators(using: config)
        toggleShadowOff(using: config)
        toggleTopShadow(using: config)
        toggleOffTopHilight(using: config)
        toggleOffMiddle(using: config)
        toggleOffFront(using: config)
        toggleOffFrontHilight(using: config)
    }
    
    func drawToggleHoverOnButton(using config: ToggleButtonConfig)
    {
        toggleBack(using: config)
        toggleShadowHoverOn(using: config)
        toggleOnOffIndicators(using: config)
        toggleTopShadow(using:config)
        toggleOnTopHilightHover(using: config)
        toggleOnMiddleHover(using: config)
        toggleOnFrontHover(using: config)
        toggleOnFrontHilightHover(using: config)
    }
    
    func drawToggleHoverOffButton(using config: ToggleButtonConfig)
    {
        toggleBack(using: config)
        toggleShadowHoverOff(using: config)
        toggleOnOffIndicators(using: config)
        toggleTopShadow(using:config)
        toggleOffTopHilightHover(using: config)
        toggleOffMiddleHover(using: config)
        toggleOffFrontHover(using: config)
        toggleOffFrontHilightHover(using: config)
    }
    
    func drawToggleDisabledButton(using config: ToggleButtonConfig)
    {
        toggleBack(using: config, disabled: true)
    }
    
    func toggleButtons(using config: ToggleButtonConfig) {
        if let buttonState = buttonState {
            Swift.print("Toggle buttons")
            switch buttonState {
            case .on:
                drawToggleOnButton(using: config)
            case .off:
                drawToggleOffButton(using: config)
            case .up:
                drawToggleOffButton(using: config)
            case .down:
                drawToggleOffButton(using:config)
            case .hoverOn:
                drawToggleHoverOnButton(using: config)
            case .hoverOff:
                drawToggleHoverOffButton(using: config)
            case .disabled:
                drawToggleDisabledButton(using: config)
            default:
                drawToggleOffButton(using: config)
            }
        }
    }
}
