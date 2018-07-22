//
//  SimpleButtons.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 19/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

/// Simple Buttons Extension - .simple = 2

extension PJPAutoWrapButtonCell {
    
    enum SimpleElement : Int {
        case shadow
        case back
        case middle
        case front
        case clipFront
        case offsetFront
    }
    
    // MARK: Simple Button Rects
    
    func drawSimpleBezelRectFor(element: SimpleElement,using config: SimpleButtonConfig, offset: CGFloat = 0)->NSRect {
        switch element {
        case .shadow:
            return config.frame
        case .back:
            return NSRect(x: config.x+2, y: config.y+2, width: config.width - 4, height: config.frame.size.height - 4)
        case .front:
            return NSRect(x: config.x+6, y: config.y+6, width: config.width - 12, height: config.height - 12)
        case .offsetFront:
            return NSRect(x: config.x+6, y: config.y+6+offset, width: config.width-6, height: config.height - 12)
        case .middle:
            return NSRect(x: config.x+4, y: config.y+4, width: config.width - 8, height: config.height - 8)
        case .clipFront:
            return NSRect(x: config.x+7, y: config.y+7, width: config.width-12, height: config.height - 12)
        }
    }
    
    // MARK: Bezier Paths
    
    func drawSimpleBezelElementFor(_ element: SimpleElement, using config: SimpleButtonConfig, offset: CGFloat = 0)->NSBezierPath {
        return NSBezierPath(roundedRect: drawSimpleBezelRectFor(element: element, using: config, offset: offset), xRadius: config.rad, yRadius: config.rad)
    }
    
    // MARK: Gradients
    
    func simpleButtonFrontGradient()->NSGradient? {
        
        var gradFrontColors = [NSColor(deviceWhite: 1, alpha: 1), NSColor(deviceWhite: 1, alpha: 1),NSColor(deviceWhite: 0.8, alpha: 1)]
        if let buttonState = self.buttonState {
            switch buttonState {
            case .hover:
                gradFrontColors[2] = NSColor(deviceWhite: 1, alpha: 0.25)
            case .disabled:
                gradFrontColors = [NSColor(deviceWhite: 1, alpha: 0.5), NSColor(deviceWhite: 1, alpha: 0.5),NSColor(deviceWhite: 0.8, alpha: 0.5)]
            default:
                break
            }
        }
        
        let gradFrontLocations : [CGFloat] = [0,0.5,1]
        if let buttonColor = self.buttonColor {
            if self.buttonColor != NSColor.white {
                gradFrontColors[2] = buttonColor
            }
        }
        
        return NSGradient(colorsAndLocations: (gradFrontColors[0],gradFrontLocations[0]),(gradFrontColors[1],gradFrontLocations[1]),(gradFrontColors[2],gradFrontLocations[2]))
    }
    
    // MARK: Button Elements
    
    func simpleShadow(using config: SimpleButtonConfig) {
        drawSimpleBezelElementFor(.shadow, using: config).setClip()
        if let buttonState = self.buttonState {
            switch buttonState {
            case .hover:
                NSColor(deviceRed: 0, green: 1, blue: 0, alpha: 0.75).setFill()
            default:
                NSColor(deviceWhite: 0.8, alpha: 1).setFill()
            }
        }
        drawSimpleBezelElementFor(.shadow, using: config).fill()
    }
    
    func simpleBezelBack(using config: SimpleButtonConfig) {
        NSColor.white.setFill()
        drawSimpleBezelElementFor(.back, using: config).fill()
    }
    
    func simpleBezelMiddle(using config: SimpleButtonConfig, clip: Bool = false) {
        if let buttonState = self.buttonState {
            switch buttonState {
            case .disabled:
                NSColor(deviceWhite: 0.6, alpha: 0.5).setFill()
            case .hover:
                NSColor.green.setFill()
            default:
                switch clip {
                case true:
                    let gradBackColors = [NSColor(deviceWhite: 0.3, alpha: 1), NSColor(deviceWhite: 0.7, alpha: 1)]
                    let gradBackLocations : [CGFloat] = [0,1]
                    
                    let buttonBackGradient = NSGradient(colorsAndLocations: (gradBackColors[0],gradBackLocations[0]),(gradBackColors[1],gradBackLocations[1]))
                    
                    drawSimpleBezelElementFor(.middle, using: config).setClip()
                    if let buttonBackGradient = buttonBackGradient {
                        buttonBackGradient.draw(in:drawSimpleBezelRectFor(element: .middle, using: config), angle: 90)
                    }
                    return
                default:
                    NSColor(deviceWhite: 0.6, alpha: 1).setFill()
                }
            }
        }
        drawSimpleBezelElementFor(.middle, using: config).fill()
    }
    
    func simpleBezelFront(using config: SimpleButtonConfig, disabled: Bool = false) {
        switch disabled {
        case true:
            NSColor(deviceWhite: 0.9, alpha: 0.5).setFill()
        case false:
            NSColor(deviceWhite: 0.9, alpha: 1).setFill()
        }
        drawSimpleBezelElementFor(.front, using: config).fill()
    }
    
    // MARK: Button States
    
    func drawSimpleUpButton(using config: SimpleButtonConfig)
    {
        Swift.print("Drawing Simple Up")
        simpleShadow(using: config)
        simpleBezelBack(using: config)
        simpleBezelMiddle(using: config)
        simpleBezelFront(using: config)
        drawSimpleBezelElementFor(.front, using: config).setClip()
        if let buttonFrontGradient = simpleButtonFrontGradient() {
            buttonFrontGradient.draw(in:drawSimpleBezelRectFor(element: .front, using: config), angle: 90)
        }
    }
    
    func drawSimpleDownButton(using config: SimpleButtonConfig)
    {
        Swift.print("Drawing Simple Down")
        simpleShadow(using: config)
        simpleBezelBack(using: config)
        simpleBezelMiddle(using: config, clip: true)
        drawSimpleBezelElementFor(.offsetFront, using: config, offset: config.height/20).setClip()
        drawSimpleBezelElementFor(.middle, using: config).addClip()
        drawSimpleBezelElementFor(.clipFront, using: config).addClip()
        drawSimpleBezelElementFor(.front, using: config).addClip()
        if let buttonFrontGradient = simpleButtonFrontGradient() {
            buttonFrontGradient.draw(in:drawSimpleBezelRectFor(element: .front, using: config), angle: 90)
        }
    }
    
    func drawSimpleHoverButton(using config: SimpleButtonConfig)
    {
        Swift.print("Drawing Simple Hover")
        simpleShadow(using: config)
        simpleBezelBack(using: config)
        simpleBezelMiddle(using: config)
        simpleBezelFront(using: config)
        drawSimpleBezelElementFor(.front, using: config).setClip()
        if let buttonFrontGradient = simpleButtonFrontGradient() {
            buttonFrontGradient.draw(in:drawSimpleBezelRectFor(element: .front, using: config), angle: 90)
        }
    }
    
    func drawSimpleDisabledButton(using config: SimpleButtonConfig) {
        Swift.print("Drawing Simple Disabled")
        simpleShadow(using: config)
        simpleBezelBack(using: config)
        simpleBezelMiddle(using: config, clip: false)
        simpleBezelFront(using: config)
        drawSimpleBezelElementFor(.front, using: config).setClip()
        if let buttonFrontGradient = simpleButtonFrontGradient() {
            buttonFrontGradient.draw(in:drawSimpleBezelRectFor(element: .front, using: config), angle: 90)
        }
    }
    
    func simpleButtons(using config: SimpleButtonConfig) {
        
        if let buttonState = buttonState {
            Swift.print("Simple buttons")
            switch buttonState {
            case .up:
                drawSimpleUpButton(using: config)
            case .down:
                drawSimpleDownButton(using:config)
            case .hover:
                drawSimpleHoverButton(using: config)
            case .disabled:
                drawSimpleDisabledButton(using: config)
            default:
                drawSimpleUpButton(using: config)
            }
        }
    }
}
