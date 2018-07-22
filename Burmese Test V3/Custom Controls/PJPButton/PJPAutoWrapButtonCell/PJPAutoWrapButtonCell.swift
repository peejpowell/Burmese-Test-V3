//
//  PJPAutoWrapButtonCell.swift
//  testButtonWrap
//
//  Created by Phil on 28/08/2014.
//  Copyright (c) 2014 Phil. All rights reserved.
//

import Cocoa

@IBDesignable class PJPAutoWrapButtonCell: NSButtonCell
{
    @IBInspectable var oldStyle: Bool = false
    var lastFont : NSFont?
    var lastTitle : String?
    var lastRect : NSRect?
    var lastBounds : NSRect?
    
    @IBInspectable var styleAdapter : Int {
        get                 { return self.buttonStyle!.hashValue }
        set (styleIndex)    { self.buttonStyle = PJPButtonStyle(rawValue: styleIndex) ?? .none }
    }
    
    @IBInspectable var stateAdapter : Int {
        get                 { return self.buttonState!.hashValue }
        set (stateIndex)    { self.buttonState = PJPButtonState(rawValue: stateIndex) ?? .up }
    }

    enum PJPButtonStyle: Int
    {
        case glassy // 0
        case toggle // 1
        case simple // 2
        case metallic // 3
        case noStyle // 4
    }
    
    var buttonColor         : NSColor? = NSColor.white
    var cornerDivider       : CGFloat? = 2
    var buttonStyle         : PJPButtonStyle? = .glassy
    var buttonState         : PJPButtonState? {
        didSet (oldState){
            if let oldState = oldState,
               let state = self.buttonState {
                Swift.print("old: \(String(describing: oldState)) - new: \(String(describing: state))")
            }
        }
    }
    
    var showBorder          : Bool? = true
    
    func drawButtonShadow(with buttonConfig: PJPButtonConfig)
    {
        let x = buttonConfig.buttonX
        let y = buttonConfig.buttonY
        let width = buttonConfig.buttonWidth
        let height = buttonConfig.buttonHeight
        let rad = buttonConfig.buttonCornerRadius
        let buttonShadowRect = NSRect(x: x, y: y, width: width, height: height)
    
        let buttonShadow = NSBezierPath(roundedRect: buttonShadowRect, xRadius: rad, yRadius: rad)
    
        NSColor.gray.setFill()
        buttonShadow.setClip()
        buttonShadow.fill()
    }
    
    func metallicButtons(with buttonConfig: PJPButtonConfig)
    {
        let x = buttonConfig.buttonX
        let y = buttonConfig.buttonY
        let width = buttonConfig.buttonWidth
        let height = buttonConfig.buttonHeight
        let rad = buttonConfig.buttonCornerRadius
        if let divider = self.cornerDivider,
           let color = buttonConfig.buttonColor
        {
            let frame = NSRect(x: x,y: y,width: width, height: height)
            let buttonShadow = NSBezierPath(roundedRect: frame, xRadius: rad, yRadius: rad)
            let buttonFrameRect = NSRect(x: frame.origin.x+2, y: frame.origin.y+2, width: frame.size.width - 4, height: frame.size.height - 4)
            let buttonBack = NSBezierPath(roundedRect: buttonFrameRect, xRadius: rad, yRadius: rad)
            let buttonHilightRectTop = NSRect(x: rad/(divider*2), y: frame.origin.y+5, width: frame.size.width-(rad/(divider)), height: frame.size.height/2)
            let buttonHilightRectBot = NSRect(x: frame.origin.x+(frame.size.height/6), y: frame.origin.y+(frame.size.height/2)-5, width: frame.size.width-(frame.size.height/3), height: frame.size.height/2)
            let buttonHilightRect = NSRect(x: frame.origin.x+2, y: frame.origin.y+2, width: frame.size.width - 4, height: frame.size.height - 4)
            let buttonHilight = NSBezierPath(roundedRect: buttonHilightRect, xRadius: rad, yRadius: rad)
            let buttonHilightTop = NSBezierPath(roundedRect: buttonHilightRectTop, xRadius: rad, yRadius: rad)
            //_ = NSBezierPath(roundedRect: buttonHilightRectBot, xRadius: rad, yRadius: rad)
            let shadowGradient = NSGradient(colorsAndLocations: (NSColor.black, 0), (NSColor.gray, 0.25),(NSColor.white, 1))
            let hilightGradientTop = NSGradient(colorsAndLocations: (NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 0.75), 0),(NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 0),0.75),(NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 0),1))
            //_ = NSGradient(colorsAndLocations: (NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 0.75), 1),(NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 0),0.25),(NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 0),0))
    
            let colorRGB = color.usingColorSpace(NSColorSpace.genericRGB)!
            let color1 = NSColor(deviceRed: colorRGB.redComponent, green: colorRGB.greenComponent, blue: colorRGB.blueComponent, alpha: 1)
            let color2 = NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 1)
            let color3 = NSColor(deviceRed: colorRGB.redComponent, green: colorRGB.greenComponent, blue: colorRGB.blueComponent, alpha: 0.75)
            
            let hilightGradient = NSGradient(colorsAndLocations: (color1, 1),(color2, 0.25),(color3, 0))
            buttonShadow.setClip()
            if let shadowGradient = shadowGradient {
                shadowGradient.draw(in: frame, angle: 90)
                buttonBack.setClip()
                shadowGradient.draw(in: frame, angle: 90)
                buttonHilight.setClip()
            }
            if let hilightGradient = hilightGradient {
                hilightGradient.draw(in: buttonHilightRect, angle: 90)
            }
            buttonHilightTop.setClip()
            if  let hilightGradientTop = hilightGradientTop {
                hilightGradientTop.draw(in:buttonHilightRectTop, angle: 90)
            }
        }
    }
    
    func glassyButtons(with buttonConfig: PJPButtonConfig)
    {
        let x = buttonConfig.buttonX
        let y = buttonConfig.buttonY
        let width = buttonConfig.buttonWidth
        let height = buttonConfig.buttonHeight
        let rad = buttonConfig.buttonCornerRadius
        if  let divider = self.cornerDivider,
            let color = buttonConfig.buttonColor,
            let buttonState = self.buttonState
        {
            let frame = buttonConfig.buttonFrame
            
            func drawUpButton()
            {
                func drawButtonShadow(inFrame frame: NSRect, rad: CGFloat)
                {
                    let buttonShadowRect = NSRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height)
                    let buttonShadow = NSBezierPath(roundedRect: buttonShadowRect, xRadius: rad, yRadius: rad)
                    
                    NSColor.gray.setFill()
                    buttonShadow.setClip()
                    buttonShadow.fill()
                }
                
                func drawButtonTopHilight(inFrame frame: NSRect, rad: CGFloat)
                {
                    let buttonTopHilightRect = NSRect(x: frame.origin.x+1, y: frame.origin.y+1, width: frame.width-2, height: frame.height-2)
                    let buttonTopHilight = NSBezierPath(roundedRect: buttonTopHilightRect, xRadius: rad, yRadius: rad)
                    
                    buttonTopHilight.setClip()
                    // glassy white
                    //NSColor.white.setFill()
                    NSColor.white.setFill()
                    buttonTopHilight.fill()
                }
                
                func drawButtonMiddle(inFrame frame: NSRect, rad: CGFloat)
                {
                    let buttonMiddleRect = NSRect(x: frame.origin.x+1, y: frame.origin.y+3, width: frame.width-2, height: frame.height-2)
                    let buttonMiddle = NSBezierPath(roundedRect: buttonMiddleRect, xRadius: rad, yRadius: rad)
                    
                    let middleGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite: 0.95, alpha: 1),0),(NSColor(deviceWhite: 0.6, alpha: 1),1))
                    
                    NSColor(deviceWhite: 0.5, alpha: 1).setFill()
                    //buttonMiddle.setClip()
                    if let middleGradient = middleGradient {
                        middleGradient.draw(in: buttonMiddle, angle: 90)
                    }
                    
                }
                
                func drawButtonFront(inFrame frame: NSRect, rad: CGFloat)
                {
                    let buttonFrontRect = NSRect(x: frame.origin.x+2, y: frame.origin.y+4, width: frame.width-4, height: frame.height-6)
                    let buttonFront = NSBezierPath(roundedRect: buttonFrontRect, xRadius: rad, yRadius: rad)
                    
                    let frontGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite:0.95, alpha: 1),0),(NSColor(deviceWhite:0.95, alpha:1),0.3),(NSColor(deviceWhite:0.9, alpha:1),0.4),(NSColor(deviceWhite: 0.99, alpha: 1),1))
                    
                    buttonFront.setClip()
                    if let frontGradient = frontGradient {
                        frontGradient.draw(in: buttonFront, angle: 90)
                    }
                }
                
                func drawButtonFrontHilight(inFrame frame: NSRect, xOffset: CGFloat = 0, yOffset: CGFloat = 0, widthOffset : CGFloat = 0, heightOffset: CGFloat = 0, gradientColors:[NSColor] = [NSColor.white,NSColor.white], rad: CGFloat)
                {
                    let frontHilightRect = NSRect(x: frame.origin.x+xOffset,y: frame.origin.y+yOffset, width: frame.width-widthOffset, height: frame.height/2-heightOffset)
                    
                    _ = NSBezierPath(roundedRect: frontHilightRect, xRadius: rad, yRadius: rad)
                    
                    let frontHilightGradient = NSGradient(colorsAndLocations: (gradientColors[0],0),(gradientColors[1],1))
                    
                    if let frontHilightGradient = frontHilightGradient {
                        frontHilightGradient.draw(in: frontHilightRect, angle: 90)
                    }
                }
                
                func drawGlassyButton(inFrame: NSRect, _ rad: CGFloat)
                {
                    drawButtonShadow(inFrame: inFrame, rad: rad)
                    drawButtonTopHilight(inFrame: frame, rad: rad)
                    drawButtonMiddle(inFrame: frame, rad: rad)
                    drawButtonFront(inFrame: frame, rad: rad)
                    drawButtonFrontHilight(inFrame: frame, yOffset:2,gradientColors:[NSColor(deviceWhite: 1, alpha: 1), NSColor(deviceWhite: 0.96, alpha: 1)], rad: rad)
                }
                
                drawGlassyButton(inFrame: frame, rad)
            }
            
            func drawDownButton()
            {
                func drawButtonShadow(inFrame frame: NSRect, rad: CGFloat)
                {
                    let buttonShadowRect = NSRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height)
                    let buttonShadow = NSBezierPath(roundedRect: buttonShadowRect, xRadius: rad, yRadius: rad)
                    
                    NSColor.gray.setFill()
                    buttonShadow.setClip()
                    buttonShadow.fill()
                }
                
                func drawButtonTopHilight(inFrame frame: NSRect, rad: CGFloat)
                {
                    let buttonTopHilightRect = NSRect(x: frame.origin.x+1, y: frame.origin.y+1, width: frame.width-2, height: frame.height-2)
                    let buttonTopHilight = NSBezierPath(roundedRect: buttonTopHilightRect, xRadius: rad, yRadius: rad)
                    
                    buttonTopHilight.setClip()
                    // glassy white
                    //NSColor.white.setFill()
                    NSColor.white.setFill()
                    buttonTopHilight.fill()
                }
                
                func drawButtonMiddle(inFrame frame: NSRect, rad: CGFloat)
                {
                    let buttonMiddleRect = NSRect(x: frame.origin.x+1, y: frame.origin.y+3, width: frame.width-2, height: frame.height-2)
                    let buttonMiddle = NSBezierPath(roundedRect: buttonMiddleRect, xRadius: rad, yRadius: rad)
                    
                    let middleGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite: 0.95, alpha: 1),0),(NSColor(deviceWhite: 0.6, alpha: 1),1))
                    
                    NSColor(deviceWhite: 0.5, alpha: 1).setFill()
                    //buttonMiddle.setClip()
                    if let middleGradient = middleGradient {
                        middleGradient.draw(in: buttonMiddle, angle: 90)
                    }
                    
                }
                
                func drawButtonFront(inFrame frame: NSRect, rad: CGFloat)
                {
                    let buttonFrontRect = NSRect(x: frame.origin.x+2, y: frame.origin.y+4, width: frame.width-4, height: frame.height-6)
                    let buttonFront = NSBezierPath(roundedRect: buttonFrontRect, xRadius: rad, yRadius: rad)
                    
                    let frontGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite:0.95, alpha: 1),0),(NSColor(deviceWhite:0.95, alpha:1),0.3),(NSColor(deviceWhite:0.9, alpha:1),0.4),(NSColor(deviceWhite: 0.99, alpha: 1),1))
                    
                    buttonFront.setClip()
                    if let frontGradient = frontGradient {
                        frontGradient.draw(in: buttonFront, angle: 90)
                    }
                }
                
                func drawButtonFrontHilight(inFrame frame: NSRect, xOffset: CGFloat = 0, yOffset: CGFloat = 0, widthOffset : CGFloat = 0, heightOffset: CGFloat = 0, gradientColors:[NSColor] = [NSColor.white,NSColor.white], rad: CGFloat)
                {
                    let frontHilightRect = NSRect(x: frame.origin.x+xOffset,y: frame.origin.y+yOffset, width: frame.width-widthOffset, height: frame.height/2-heightOffset)
                    
                    _ = NSBezierPath(roundedRect: frontHilightRect, xRadius: rad, yRadius: rad)
                    
                    let frontHilightGradient = NSGradient(colorsAndLocations: (gradientColors[0],0),(gradientColors[1],1))
                    
                    if let frontHilightGradient = frontHilightGradient {
                        frontHilightGradient.draw(in: frontHilightRect, angle: 90)
                    }
                }
                
                func drawButtonFrontTop(inFrame frame: NSRect, rad: CGFloat)
                {
                    let buttonFrontTopRect = NSRect(x: frame.origin.x+6, y: frame.origin.y+10, width: frame.width-4, height: frame.height-4)
                    let buttonFrontTop = NSBezierPath(roundedRect: buttonFrontTopRect, xRadius: rad, yRadius: rad)
                    
                    let frontTopGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite:1, alpha: 1),0),(NSColor(deviceWhite:0.95, alpha:1),0.3),(NSColor(deviceWhite:0.9, alpha:1),0.4),(NSColor(deviceWhite: 0.99, alpha: 1),1))
                    //NSColor(deviceWhite: 0, alpha: 1).setFill()
                    //buttonFrontTop.fill()
                    if let frontTopGradient = frontTopGradient {
                        frontTopGradient.draw(in: buttonFrontTop, angle: 90)
                    }
                }
                func drawButtonFrontShadow(inFrame frame: NSRect, rad: CGFloat)
                {
                    //let frontShadowGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite:0, alpha: 0.6),0),(NSColor(deviceWhite:0, alpha:0.3),0.3),(NSColor(deviceWhite:0, alpha:0.1),0.4),(NSColor(deviceWhite: 0, alpha: 0),1))
                    var alphaValue : CGFloat = 0.3
                    for offsetNum in 0 ..< 1
                    {
                        let offset = CGFloat(offsetNum)
                        //PJLog("offset: \(offset)")
                        let buttonFrontShadowRect = NSRect(x: frame.origin.x+offset, y: frame.origin.y+offset, width: frame.width, height: frame.height)
                        let buttonFrontShadow = NSBezierPath(roundedRect: buttonFrontShadowRect, xRadius: rad, yRadius: rad)
                        
                            buttonFrontShadow.setClip()
                            //PJLog("alpha: \(alphaValue)")
                            NSColor(deviceWhite:0,alpha:alphaValue).setFill()
                            buttonFrontShadow.fill()
                            alphaValue = alphaValue - 0.01
                        
                            //drawButtonFront(inFrame: frame)
                        
                            //frontShadowGradient.draw(in:buttonFrontShadow, angle: 90)
                        
                        
                        }
                        //drawButtonFrontTop(inFrame: frame)
                        //frontShadowGradient.draw(in:buttonFront, angle: 90)
                    }
                    func drawTopShadow(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                    {
                        let frame2 = NSRect(x: x+(rad/6), y: y+(rad/6), width: width-(rad/6), height: height-(rad/6))
                        let frame3 = NSRect(x: x+(rad/3), y: y+(rad/3), width: width-(rad/3), height: height-(rad/3))
                        _ = NSBezierPath(roundedRect: frame, xRadius: rad, yRadius: rad)
                        _ = NSBezierPath(roundedRect: frame2, xRadius: rad, yRadius: rad)
                        _ = NSBezierPath(roundedRect: frame3, xRadius: rad, yRadius: rad)
                        var ceiling : Int = 15
                        var alphaInc : CGFloat = 0.02
                        if height < 50
                        {
                            ceiling = 10
                            alphaInc = 0.05
                        }
                        for bezNum in 0 ..< ceiling
                        {
                            let num = CGFloat(bezNum)
                            let bezier = NSBezierPath(roundedRect: frame, xRadius: rad, yRadius: rad)
                            
                            let frame2 = NSRect(x: x+num, y: y+num, width: width-num, height: height-num)
                            
                            let bezier2 = NSBezierPath(roundedRect: frame2, xRadius: rad, yRadius: rad)
                            bezier.setClip()
                            bezier.append(bezier2)
                            bezier.windingRule = NSBezierPath.WindingRule.evenOdd
                            NSColor(deviceWhite:0, alpha: alphaInc).setFill()
                            bezier.fill()
                        }
                    }
                
                    func drawColorOverlay(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, buttonColor : NSColor?)
                    {
                        var gradFrontColors = [NSColor(deviceWhite: 1, alpha: 1), NSColor(deviceWhite: 1, alpha: 1),NSColor(deviceWhite: 0.8, alpha: 1)]
                        var gradFrontLocations : [CGFloat] = [0,0.5,1]
                        
                        if let buttonColor = buttonColor?.usingColorSpace(NSColorSpace.genericRGB)
                        {
                            let lightButtonColor = NSColor(deviceRed: buttonColor.redComponent, green: buttonColor.greenComponent, blue: buttonColor.blueComponent, alpha: 0.01)
                            let midButtonColor = NSColor(deviceRed: buttonColor.redComponent, green: buttonColor.greenComponent, blue: buttonColor.blueComponent, alpha: 0.25)
                            gradFrontColors[0] = lightButtonColor
                            gradFrontColors[1] = midButtonColor
                            gradFrontColors[2] = buttonColor
                        }
                        
                        let buttonFrontGradient = NSGradient(colorsAndLocations: (gradFrontColors[0],gradFrontLocations[0]),(gradFrontColors[1],gradFrontLocations[1]),(gradFrontColors[2],gradFrontLocations[2]))
                        
                        let buttonAreaRect = NSRect(x: x+1, y: y+1, width: width-2, height: height-2)
                        let buttonArea = NSBezierPath(roundedRect: buttonAreaRect, xRadius: rad, yRadius: rad)
                        
                        buttonArea.setClip()
                        if let buttonFrontGradient = buttonFrontGradient {
                            buttonFrontGradient.draw(in: buttonArea, angle: 90)
                        }
                    }
                
                    func drawGlassyDown(inFrame: NSRect, _ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, _ rad: CGFloat)
                    {
                        drawButtonShadow(inFrame: frame, rad: rad)
                        drawButtonTopHilight(inFrame: frame, rad: rad)
                        drawButtonMiddle(inFrame: frame, rad: rad)
                        drawButtonFront(inFrame: frame, rad: rad)
                        drawButtonFrontHilight(inFrame: frame, yOffset:2,gradientColors:[NSColor(deviceWhite: 1, alpha: 1), NSColor(deviceWhite: 0.96, alpha: 1)], rad: rad)
                        drawColorOverlay(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, buttonColor: self.buttonColor)
                        drawButtonFrontHilight(inFrame: frame, yOffset:2, gradientColors:[NSColor(deviceWhite: 1, alpha: 0.9), NSColor(deviceWhite: 1, alpha: 0.5)], rad: rad)
                        drawTopShadow(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                    }
                
                    drawGlassyDown(inFrame: frame, x, y , width, height, rad)
                
                }
            
            func drawHoverButton()
            {
                func drawButtonTopHilight(inFrame frame: NSRect, _ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, _ rad: CGFloat)
                {
                    let buttonTopHilightRect = NSRect(x: x+1, y: y+1, width: width-2, height: height-2)
                            let buttonTopHilight = NSBezierPath(roundedRect: buttonTopHilightRect, xRadius: rad, yRadius: rad)
                    
                            buttonTopHilight.setClip()
                            // glassy white
                            //NSColor.white.setFill()
                            NSColor(deviceRed: 0.69, green: 0.91, blue: 0.99, alpha: 1).setFill()
                            buttonTopHilight.fill()
                }
                
                func drawButtonMiddle(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                {
                    let buttonMiddleRect = NSRect(x: x+1, y: y+3, width: width-2, height: height-2)
                    let buttonMiddle = NSBezierPath(roundedRect: buttonMiddleRect, xRadius: rad, yRadius: rad)
                    
                    let middleGradient = NSGradient(colorsAndLocations: (NSColor(deviceRed: 0.38, green: 0.84, blue: 1, alpha: 1),0),(NSColor(deviceWhite: 0.6, alpha: 1),1))
                    
                    NSColor(deviceWhite: 0.5, alpha: 1).setFill()
                    //buttonMiddle.setClip()
                    if let middleGradient = middleGradient {
                        middleGradient.draw(in: buttonMiddle, angle: 90)
                    }
                }
            
                func drawButtonFront(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                {
                    let buttonFrontRect = NSRect(x: x+2, y: y+4, width: width-4, height: height-6)
                    let buttonFront = NSBezierPath(roundedRect: buttonFrontRect, xRadius: rad, yRadius: rad)
                    
                    let frontGradient = NSGradient(colorsAndLocations: (NSColor(deviceRed: 0.38, green: 0.84, blue: 1, alpha: 1),0),(NSColor(deviceRed: 0.24, green: 0.65, blue: 0.91, alpha: 1),0.3),(NSColor(deviceRed: 0.24, green: 0.65, blue: 0.91, alpha: 1),0.4),(NSColor(deviceRed: 0.38, green: 0.84, blue: 1, alpha: 1),1))
                    
                    buttonFront.setClip()
                    if let frontGradient = frontGradient {
                        frontGradient.draw(in: buttonFront, angle: 90)
                    }
                }
        
                func drawButtonFrontHilight(inFrame frame: NSRect, xOffset: CGFloat = 0, yOffset: CGFloat = 0, widthOffset : CGFloat = 0, heightOffset: CGFloat = 0, gradientColors:[NSColor] = [NSColor.white,NSColor.white], x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                {
                    let frontHilightRect = NSRect(x: x+xOffset,y: y+yOffset, width: width-widthOffset, height: height/2-heightOffset)
                    
                    let frontHilight = NSBezierPath(roundedRect: frontHilightRect, xRadius: rad, yRadius: rad)
                    
                    let frontHilightGradient = NSGradient(colorsAndLocations: (gradientColors[0],0),(gradientColors[1],1))
                    
                    if let frontHilightGradient = frontHilightGradient {
                        frontHilightGradient.draw(in: frontHilightRect, angle: 90)
                    }
                    
                }
                func drawColorOverlay(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, buttonColor : NSColor?)
                {
                    var gradFrontColors = [NSColor(deviceWhite: 1, alpha: 1), NSColor(deviceWhite: 1, alpha: 1),NSColor(deviceWhite: 0.8, alpha: 1)]
                    var gradFrontLocations : [CGFloat] = [0,0.5,1]
                    
                    if let buttonColor = buttonColor?.usingColorSpace(NSColorSpace.genericRGB)
                    {
                        let lightButtonColor = NSColor(deviceRed: buttonColor.redComponent, green: buttonColor.greenComponent, blue: buttonColor.blueComponent, alpha: 0.01)
                        let midButtonColor = NSColor(deviceRed: buttonColor.redComponent, green: buttonColor.greenComponent, blue: buttonColor.blueComponent, alpha: 0.25)
                        gradFrontColors[0] = lightButtonColor
                        gradFrontColors[1] = midButtonColor
                        gradFrontColors[2] = buttonColor
                    }
                    
                    let buttonFrontGradient = NSGradient(colorsAndLocations: (gradFrontColors[0],gradFrontLocations[0]),(gradFrontColors[1],gradFrontLocations[1]),(gradFrontColors[2],gradFrontLocations[2]))
                    
                    let buttonAreaRect = NSRect(x: x+1, y: y+1, width: width-2, height: height-2)
                    let buttonArea = NSBezierPath(roundedRect: buttonAreaRect, xRadius: rad, yRadius: rad)
                    
                    buttonArea.setClip()
                    if let buttonFrontGradient = buttonFrontGradient {
                        buttonFrontGradient.draw(in: buttonArea, angle: 90)
                    }
                }
                
                func drawGlassyHover(inFrame: NSRect, _ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, _ rad: CGFloat)
                {
                    drawButtonShadow(with: buttonConfig)
                    drawButtonTopHilight(inFrame: frame, x, y, width, height, rad)
                    drawButtonMiddle(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                    drawButtonFront(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                    drawColorOverlay(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, buttonColor: self.buttonColor)
                    if let buttonColor = buttonColor?.usingColorSpace(NSColorSpace.genericRGB)
                    {
                        drawButtonFrontHilight(inFrame: frame, yOffset:2,gradientColors:[NSColor.white, NSColor(deviceRed: buttonColor.redComponent, green: buttonColor.greenComponent, blue: buttonColor.blueComponent, alpha: 0.75)], x: x, y: y, width: width, height : height, rad: rad)
                    }
                    else
                    {
                         drawButtonFrontHilight(inFrame: frame, yOffset:2,gradientColors:[NSColor.white, NSColor(deviceRed: 0.38, green: 0.84, blue: 1, alpha: 0.75)], x: x, y: y, width: width, height : height, rad: rad)
                    }
                }
                
                drawGlassyHover(inFrame:frame, x, y, width, height, rad)
            }
        
            func drawDisabledButton()
            {
                func drawButtonShadow(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                {
                    let buttonShadowRect = NSRect(x: x, y: y, width: width, height: height)
                    let buttonShadow = NSBezierPath(roundedRect: buttonShadowRect, xRadius: rad, yRadius: rad)
                    
                    NSColor(deviceWhite: 0, alpha: 0.25).setFill()
                    buttonShadow.setClip()
                    buttonShadow.fill()
                }
                
                func drawButtonTopHilight(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                {
                    let buttonTopHilightRect = NSRect(x: x+1, y: y+1, width: width-2, height: height-2)
                    let buttonTopHilight = NSBezierPath(roundedRect: buttonTopHilightRect, xRadius: rad, yRadius: rad)
                    
                    buttonTopHilight.setClip()
                    NSColor.white.setFill()
                    buttonTopHilight.fill()
                }
                
                func drawButtonMiddle(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                {
                    let buttonMiddleRect = NSRect(x: x+1, y: y+3, width: width-2, height: height-2)
                    let buttonMiddle = NSBezierPath(roundedRect: buttonMiddleRect, xRadius: rad, yRadius: rad)
                    
                    let middleGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite: 0.95, alpha: 0.25),0),(NSColor(deviceWhite: 0.6, alpha: 0.25),1))
                    
                    NSColor(deviceWhite: 0.5, alpha: 0.25).setFill()
                    if let middleGradient = middleGradient {
                        middleGradient.draw(in:buttonMiddle, angle: 90)
                    }
                }
                
                func drawButtonFront(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                {
                    let buttonFrontRect = NSRect(x: x+2, y: y+4, width: width-4, height: height-6)
                    let buttonFront = NSBezierPath(roundedRect: buttonFrontRect, xRadius: rad, yRadius: rad)
                    
                    let frontGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite:0.95, alpha: 0.25),0),(NSColor(deviceWhite:0.95, alpha:0.25),0.3),(NSColor(deviceWhite:0.9, alpha:0.25),0.4),(NSColor(deviceWhite: 0.99, alpha: 0.25),1))
                    
                    buttonFront.setClip()
                    if let frontGradient = frontGradient {
                        frontGradient.draw(in:buttonFront, angle: 90)
                    }
                }
                
                func drawButtonFrontHilight(inFrame frame: NSRect, xOffset: CGFloat = 0, yOffset: CGFloat = 0, widthOffset : CGFloat = 0, heightOffset: CGFloat = 0, gradientColors:[NSColor?] = [NSColor.white,NSColor.white], x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                {
                    let frontHilightRect = NSRect(x: x+xOffset,y: y+yOffset, width: width-widthOffset, height: height/2-heightOffset)
                    
                    let frontHilight = NSBezierPath(roundedRect: frontHilightRect, xRadius: rad, yRadius: rad)
                    
                    let frontHilightGradient = NSGradient(colorsAndLocations: (gradientColors[0] as! NSColor,0),(gradientColors[1] as! NSColor,1))
                    
                    if let frontHilightGradient = frontHilightGradient {
                        frontHilightGradient.draw(in:frontHilightRect, angle: 90)
                    }
                }
                
                func drawGlassyDisabledButton(inFrame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                {
                    drawButtonShadow(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                    drawButtonTopHilight(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                    drawButtonMiddle(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                    drawButtonFront(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                    drawButtonFrontHilight(inFrame: frame, yOffset:2,gradientColors:[NSColor(deviceWhite: 1, alpha: 0.25), NSColor(deviceWhite: 0.96, alpha: 0.25)], x: x, y: y, width: width, height: height, rad: rad)
  
                }
                
                drawGlassyDisabledButton(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
            }
        
            switch buttonState
            {
            case .up:
                drawUpButton()
            case .down:
                drawDownButton()
            case .hover:
                drawHoverButton()
            case .disabled:
                drawDisabledButton()
            default:
                drawUpButton()
            }
        }
    }
    
    override func drawBezel(withFrame frame: NSRect, in controlView: NSView)
    {
        if let button = controlView as? PJPButton {
            if !button.isEnabled && self.buttonState != .down && self.buttonState != .on {
                self.buttonState = .disabled
            }
        }
        
        let buttonConfig = PJPButtonConfig(frame: frame)
        let originalFrame : NSRect = frame
    
        if let buttonColor = self.buttonColor {
            buttonConfig.buttonColor = buttonColor
        }
        else {
            buttonConfig.buttonColor = NSColor(deviceRed: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        }
        
        //super.drawBezelWithFrame(frame, inView: controlView)
        var ctx = NSGraphicsContext.current
        
        ctx?.saveGraphicsState()
        
        /*if let cornerDivider = self.cornerDivider {
            buttonConfig.buttonDivider = cornerDivider
        }
        */
        var cornerRad : CGFloat = 0
        
        if let divider = self.cornerDivider {
            if divider > 0 {
                cornerRad = frame.size.height / divider
            }
        }
        
        if  let button = controlView as? PJPButton,
            let buttonStyle = self.buttonStyle
        {
            
            /*buttonConfig.buttonX = frame.origin.x
            buttonConfig.buttonY = frame.origin.y
            buttonConfig.buttonWidth = frame.width
            buttonConfig.buttonHeight = frame.height*/
            
            buttonConfig.buttonCornerRadius = cornerRad
            
            if buttonStyle == .toggle
            {
                buttonConfig.buttonX = frame.origin.x+(frame.height/2)
                buttonConfig.buttonY = frame.origin.y+(frame.height/4)
                buttonConfig.buttonWidth = frame.width
                buttonConfig.buttonHeight = frame.height/2
                buttonConfig.buttonCornerRadius = cornerRad/2
            }
            
            let x = buttonConfig.buttonX
            let y = buttonConfig.buttonY
            let width = buttonConfig.buttonWidth
            let height = buttonConfig.buttonHeight
            let rad = buttonConfig.buttonCornerRadius
            let divider = self.cornerDivider!
            let color = buttonConfig.buttonColor!
            
            func oldToggleButtons(frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, cornerRad: CGFloat, showBorder: Bool?, originalFrame: NSRect)
            {
                if let buttonState = buttonState
                {
                    var alphaInc: CGFloat = 0.05
                    var alphaVal : CGFloat = 1
                    
                    let horOffset = height/4
                    let buttonHeight = height/2
                    let recessWidth = height*2 - horOffset
                    
                    func drawButtonBack(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, showBorder: Bool?, cornerRad: CGFloat, recessWidth: CGFloat, originalFrame: NSRect, alphaInc: CGFloat, alphaVal: CGFloat, buttonColor: NSColor?)
                    {
                        let buttonBackRect = NSRect(x: x, y: y, width: recessWidth, height: height)
                        let buttonBack = NSBezierPath(roundedRect: buttonBackRect, xRadius: rad, yRadius: rad)
                        
                        let buttonBackInteriorRect = NSRect(x: x+1, y: y+1, width: recessWidth-2, height: height-2)
                        let buttonBackInterior = NSBezierPath(roundedRect: buttonBackInteriorRect, xRadius: rad, yRadius: rad)
                        
                        if let bordered = showBorder
                        {
                            if bordered
                            {
                                let buttonAreaRect = NSRect(x: originalFrame.origin.x+1, y: originalFrame.origin.y+1, width: originalFrame.width-2, height: originalFrame.height-2)
                                let buttonArea = NSBezierPath(roundedRect: buttonAreaRect, xRadius: cornerRad, yRadius: cornerRad)
                                
                                NSColor(deviceWhite: 0, alpha: 0.5).setStroke()
                                NSColor(deviceWhite: 0, alpha: alphaInc).setFill()
                                buttonArea.fill()
                                buttonArea.stroke()
                            }
                        }
                        
                        NSColor(deviceWhite:0.7, alpha: alphaVal).setFill()
                        buttonBack.fill()
                        if let buttonColor = buttonColor
                        {
                            buttonColor.setFill()
                            buttonBackInterior.fill()
                        }
                    }
                    
                    func drawTopShadow(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, horOffset: CGFloat, alphaInc: CGFloat)
                    {
                        var newAlphaInc = alphaInc
                        
                        let frame1 = NSRect(x: x, y: y, width: height+horOffset+(height/2), height: height)
                        let frame2 = NSRect(x: x+(rad/6), y: y+(rad/6), width: height+horOffset+(height/2)-(rad/6), height: height-(rad/6))
                        //let frame3 = NSRect(x: x+(rad/3), y: y+(rad/3), width: +(height/2)-(rad/3), height: height-(rad/3))
                        var bezier = NSBezierPath(roundedRect: frame1, xRadius: rad, yRadius: rad)
                        let bezier2 = NSBezierPath(roundedRect: frame2, xRadius: rad, yRadius: rad)
                        //let bezier3 = NSBezierPath(roundedRect: frame3, xRadius: rad, yRadius: rad)
                        var ceiling : Int = 15
                        
                        if height < 50
                        {
                            ceiling = 15
                            newAlphaInc = 0.02
                        }
                        print("Old - frame: \(frame), x: \(x), y: \(y), width: \(width), height:\(height), rad: \(rad), horOffset: \(horOffset)")
                        for bezNum in 0 ..< ceiling
                        {
                            let num = CGFloat(bezNum)
                            let bezier1 = NSBezierPath(roundedRect: frame1, xRadius: rad, yRadius: rad)
                            
                            let frame2 = NSRect(x: x+num, y: y+num, width: height+horOffset+(height/2)-num, height: height-num)
                            print("old frame 2 rect: \(frame2)")
                            
                            let bezier2 = NSBezierPath(roundedRect: frame2, xRadius: rad, yRadius: rad)
                            bezier1.setClip()
                            bezier1.append(bezier2)
                            bezier1.windingRule = NSBezierPath.WindingRule.evenOdd
                            NSColor(deviceWhite:0, alpha: newAlphaInc).setFill()
                            bezier1.fill()
                        }
                    }
                    
                    func drawOnOffIndicators(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, horOffset: CGFloat)
                    {
                        let offIndicatorBackRect = NSRect(x: x+(height)+horOffset, y: y+(height/2)-(height/6), width: height/3, height: height/3)
                        let offIndicatorBack = NSBezierPath(roundedRect: offIndicatorBackRect, xRadius: height/3, yRadius: height/3)
                        
                        let offIndicatorFrontRect = NSRect(x: x+(height)+horOffset+(height/16)-1, y: y+(height/2)-(height/8), width: height/4, height: height/4)
                        let offIndicatorFront = NSBezierPath(roundedRect: offIndicatorFrontRect, xRadius: height/4, yRadius: height/4)
                        
                        let onIndicatorRect = NSRect(x: (x+height/2) - height/16, y: y+(height/2)-(height/6), width: height/16, height: height/3)
                        
                        let onIndicator = NSBezierPath(rect: onIndicatorRect)
                        
                        offIndicatorBack.append(offIndicatorFront)
                        offIndicatorBack.windingRule = NSBezierPath.WindingRule.evenOdd
                        NSColor(deviceWhite:0, alpha: 0.5).setFill()
                        offIndicatorBack.setClip()
                        offIndicatorBack.fill()
                        NSColor(deviceWhite:1, alpha: 1).setFill()
                        onIndicator.setClip()
                        onIndicator.fill()
                    }
                    
                    func drawOnButton()
                    {
                        func drawButtonTopHilight(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, horOffset: CGFloat)
                        {
                            let buttonTopHilightRect = NSRect(x: x+(height/2)+horOffset+1, y: y+1, width: height-2, height: height-2)
                            let buttonTopHilight = NSBezierPath(roundedRect: buttonTopHilightRect, xRadius: rad, yRadius: rad)
                            
                            buttonTopHilight.setClip()
                            NSColor.white.setFill()
                            buttonTopHilight.fill()
                        }
                        
                        func drawButtonShadow(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, horOffset: CGFloat)
                        {
                            let buttonShadowRect = NSRect(x: x+(height/2)+horOffset+5, y: y+5, width: height, height: height)
                            let buttonShadow = NSBezierPath(roundedRect: buttonShadowRect, xRadius: rad, yRadius: rad)
                            
                            buttonShadow.setClip()
                            NSColor(deviceWhite: 0, alpha:0.3).setFill()
                            buttonShadow.fill()
                        }
                        
                        func drawButtonMiddle(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, horOffset: CGFloat)
                        {
                            let buttonMiddleRect = NSRect(x: x+(height/2)+horOffset+1, y: y+3, width: height-2, height: height-2)
                            let buttonMiddle = NSBezierPath(roundedRect: buttonMiddleRect, xRadius: rad, yRadius: rad)
                            
                            let middleGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite: 0.95, alpha: 1),0),(NSColor(deviceWhite: 0.6, alpha: 1),1))
                            
                            NSColor(deviceWhite: 1, alpha: 1).setFill()
                            if let middleGradient = middleGradient {
                                middleGradient.draw(in: buttonMiddle, angle: 90)
                            }
                        }
                        
                        func drawButtonFront(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, horOffset: CGFloat)
                        {
                            let buttonFrontRect = NSRect(x: x+(height/2)+horOffset+2, y: y+4, width: height-4, height: height-6)
                            let buttonFront = NSBezierPath(roundedRect: buttonFrontRect, xRadius: rad, yRadius: rad)
                            
                            let frontGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite:0.95, alpha: 1),0),(NSColor(deviceWhite:0.95, alpha:1),0.3),(NSColor(deviceWhite:0.9, alpha:1),0.4),(NSColor(deviceWhite: 0.99, alpha: 1),1))
                            
                            buttonFront.setClip()
                            if let frontGradient = frontGradient {
                                frontGradient.draw(in: buttonFront, angle: 90)
                            }
                        }
                        
                        func drawButtonFrontHilight(inFrame frame: NSRect, xOffset: CGFloat = 0, yOffset: CGFloat = 0, widthOffset : CGFloat = 0, heightOffset: CGFloat = 0, gradientColors:[NSColor?] = [NSColor.white], x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, horOffset: CGFloat)
                        {
                            let frontHilightRect = NSRect(x: x+(height/2)+horOffset+xOffset,y: y+yOffset, width: height-heightOffset, height: height/2-heightOffset)
                            print("frontHilightRectOld: \(frontHilightRect)")
                            
                            let frontHilightPath = NSBezierPath(roundedRect: frontHilightRect, xRadius: rad, yRadius: rad)
                            
                            let frontHilightGradient = NSGradient(colorsAndLocations: (gradientColors[0]!,0),(gradientColors[1]!,1))
                            
                            if let frontHilightGradient = frontHilightGradient {
                                frontHilightGradient.draw(in: frontHilightRect, angle: 90)
                            }
                        }
                        
                        
                        func drawToggleOn(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, showBorder: Bool?, cornerRad: CGFloat, recessWidth: CGFloat, originalFrame: NSRect, alphaInc: CGFloat, alphaVal: CGFloat, buttonColor: NSColor, horOffset: CGFloat)
                        {
                            drawButtonBack(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, showBorder: showBorder, cornerRad: cornerRad, recessWidth: recessWidth, originalFrame: originalFrame, alphaInc: alphaInc, alphaVal: alphaVal, buttonColor: buttonColor)
                            drawButtonShadow(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, horOffset: horOffset)
                            drawOnOffIndicators(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, horOffset: horOffset)
                            drawTopShadow(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, horOffset: horOffset, alphaInc: alphaInc)
                            drawButtonTopHilight(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, horOffset: horOffset)
                            drawButtonMiddle(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, horOffset: horOffset)
                            drawButtonFront(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, horOffset: horOffset)
                            
                            drawButtonFrontHilight(inFrame: frame, xOffset: 0, yOffset: 2,widthOffset: 0, heightOffset: 0, gradientColors:[NSColor(deviceWhite: 1, alpha: 1), NSColor(deviceWhite: 0.96, alpha: 1)], x: x, y: y, width: width, height: height, rad: rad, horOffset: horOffset)
                        }
                        
                        drawToggleOn(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, showBorder: self.showBorder, cornerRad: cornerRad, recessWidth: recessWidth, originalFrame: originalFrame, alphaInc: alphaInc, alphaVal: alphaVal, buttonColor: self.buttonColor!, horOffset: horOffset)
                    }
                    
                    func drawOffButton()
                    {
                        func drawButtonTopHilight(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let buttonTopHilightRect = NSRect(x: x+1, y: y+1, width: height-2, height: height-2)
                            let buttonTopHilight = NSBezierPath(roundedRect: buttonTopHilightRect, xRadius: rad, yRadius: rad)
                            
                            buttonTopHilight.setClip()
                            NSColor.white.setFill()
                            buttonTopHilight.fill()
                        }
                        
                        func drawButtonShadow(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let buttonShadowRect = NSRect(x: x+(height/8), y: y+(height/8), width: height, height: height)
                            let buttonShadow = NSBezierPath(roundedRect: buttonShadowRect, xRadius: rad, yRadius: rad)
                            
                            buttonShadow.setClip()
                            NSColor(deviceWhite: 0, alpha:0.3).setFill()
                            buttonShadow.fill()
                        }
                        
                        func drawButtonMiddle(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let buttonMiddleRect = NSRect(x: x+1, y: y+1, width: height-2, height: height-2)
                            let buttonMiddle = NSBezierPath(roundedRect: buttonMiddleRect, xRadius: rad, yRadius: rad)
                            
                            let middleGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite: 0.95, alpha: 1),0),(NSColor(deviceWhite: 0.6, alpha: 1),1))
                            
                            NSColor(deviceWhite: 1, alpha: 1).setFill()
                            if let middleGradient = middleGradient {
                                middleGradient.draw(in:buttonMiddle, angle: 90)
                            }
                        }
                        
                        func drawButtonFront(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let buttonFrontRect = NSRect(x: x+2, y: y+4, width: height-4, height: height-6)
                            let buttonFront = NSBezierPath(roundedRect: buttonFrontRect, xRadius: rad, yRadius: rad)
                            
                            let frontGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite:0.95, alpha: 1),0),(NSColor(deviceWhite:0.95, alpha:1),0.3),(NSColor(deviceWhite:0.9, alpha:1),0.4),(NSColor(deviceWhite: 0.99, alpha: 1),1))
                            
                            buttonFront.setClip()
                            if let frontGradient = frontGradient {
                                frontGradient.draw(in:buttonFront, angle: 90)
                            }
                        }
                        
                        func drawButtonFrontHilight(inFrame frame: NSRect, xOffset: CGFloat = 0, yOffset: CGFloat = 0, widthOffset : CGFloat = 0, heightOffset: CGFloat = 0, gradientColors:[NSColor] = [NSColor.white,NSColor.white], x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let frontHilightRect = NSRect(x: x+xOffset+2,y: y+yOffset+2, width: height-heightOffset-4, height: height/2-heightOffset-4)
                            
                            let frontHilight = NSBezierPath(roundedRect: frontHilightRect, xRadius: rad, yRadius: rad)
                            
                            let frontHilightGradient = NSGradient(colorsAndLocations: (gradientColors[0],0),(gradientColors[1],1))
                            
                            if let frontHilightGradient = frontHilightGradient {
                                frontHilightGradient.draw(in:frontHilightRect, angle: 90)
                            }
                        }
                        
                        func drawToggleOff(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, showBorder: Bool?, cornerRad: CGFloat, recessWidth: CGFloat, originalFrame: NSRect, alphaInc: CGFloat, alphaVal: CGFloat, buttonColor: NSColor)
                        {
                            drawButtonBack(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, showBorder: showBorder!, cornerRad: cornerRad, recessWidth: recessWidth, originalFrame: originalFrame, alphaInc: alphaInc, alphaVal: alphaVal, buttonColor: buttonColor)
                            drawOnOffIndicators(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, horOffset: horOffset)
                            drawButtonShadow(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                            drawTopShadow(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, horOffset: horOffset, alphaInc: alphaInc)
                            drawButtonTopHilight(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                            drawButtonMiddle(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                            drawButtonFront(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                            drawButtonFrontHilight(inFrame: frame, xOffset: 0, yOffset: 2, widthOffset: 0, heightOffset: 0, gradientColors: [NSColor(deviceWhite: 1, alpha: 1), NSColor(deviceWhite: 0.96, alpha: 1)], x: x, y: y, width: width, height: height, rad: rad)
                            
                        }
                        if self.buttonColor == nil
                        {
                            self.buttonColor = NSColor.gray
                        }
                        
                        drawToggleOff(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, showBorder: self.showBorder, cornerRad: cornerRad, recessWidth: recessWidth, originalFrame: originalFrame, alphaInc: alphaInc, alphaVal: alphaVal, buttonColor: self.buttonColor!)
                    }
                    
                    func drawHoverOnButton()
                    {
                        func drawButtonTopHilight(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let buttonTopHilightRect = NSRect(x: (x+(height/2))+1, y: y+1, width: (height+(height/4))-2, height: height-2)
                            let buttonTopHilight = NSBezierPath(roundedRect: buttonTopHilightRect, xRadius: rad, yRadius: rad)
                            
                            buttonTopHilight.setClip()
                            NSColor.white.setFill()
                            buttonTopHilight.fill()
                        }
                        
                        func drawButtonShadow(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let buttonShadowRect = NSRect(x: x+(height/2)+5, y: y+5, width: (height+(height/4)), height: height)
                            let buttonShadow = NSBezierPath(roundedRect: buttonShadowRect, xRadius: rad, yRadius: rad)
                            
                            buttonShadow.setClip()
                            NSColor(deviceWhite: 0, alpha:0.3).setFill()
                            buttonShadow.fill()
                        }
                        
                        func drawButtonMiddle(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let buttonMiddleRect = NSRect(x: (x+height/2)+1, y: y+3, width: (height+(height/4))-2, height: height-2)
                            let buttonMiddle = NSBezierPath(roundedRect: buttonMiddleRect, xRadius: rad, yRadius: rad)
                            
                            let middleGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite: 0.95, alpha: 1),0),(NSColor(deviceWhite: 0.6, alpha: 1),1))
                            
                            NSColor(deviceWhite: 1, alpha: 1).setFill()
                            if let middleGradient = middleGradient {
                                middleGradient.draw(in:buttonMiddle, angle: 90)
                            }
                        }
                        
                        func drawButtonFront(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let buttonFrontRect = NSRect(x: (x+height/2)+2, y: y+4, width: (height+(height/4))-4, height: height-6)
                            let buttonFront = NSBezierPath(roundedRect: buttonFrontRect, xRadius: rad, yRadius: rad)
                            
                            let frontGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite:0.95, alpha: 1),0),(NSColor(deviceWhite:0.95, alpha:1),0.3),(NSColor(deviceWhite:0.9, alpha:1),0.4),(NSColor(deviceWhite: 0.99, alpha: 1),1))
                            
                            buttonFront.setClip()
                            if let frontGradient = frontGradient {
                                frontGradient.draw(in:buttonFront, angle: 90)
                            }
                        }
                        
                        func drawButtonFrontHilight(inFrame frame: NSRect, xOffset: CGFloat = 0, yOffset: CGFloat = 0, widthOffset : CGFloat = 0, heightOffset: CGFloat = 0, gradientColors:[NSColor?] = [NSColor.white,NSColor.white], x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let frontHilightRect = NSRect(x: (x+height/2)+xOffset,y: y+yOffset, width: (height+(height/4))-heightOffset, height: height/2-heightOffset)
                            
                            let frontHilight = NSBezierPath(roundedRect: frontHilightRect, xRadius: rad, yRadius: rad)
                            
                            let frontHilightGradient = NSGradient(colorsAndLocations: (gradientColors[0] as! NSColor,0),(gradientColors[1] as! NSColor,1))
                            
                            if let frontHilightGradient = frontHilightGradient {
                                frontHilightGradient.draw(in:frontHilightRect, angle: 90)
                            }
                        }
                        
                        func drawHoverOn(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, showBorder: Bool?, cornerRad: CGFloat, recessWidth: CGFloat, originalFrame: NSRect, alphaInc: CGFloat, alphaVal: CGFloat, buttonColor: NSColor)
                        {
                            drawButtonBack(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, showBorder: showBorder!, cornerRad: cornerRad, recessWidth: recessWidth, originalFrame: originalFrame, alphaInc: alphaInc, alphaVal: alphaVal, buttonColor: buttonColor)
                            drawButtonShadow(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                            drawOnOffIndicators(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, horOffset: horOffset)
                            drawTopShadow(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, horOffset: horOffset, alphaInc: alphaInc)
                            drawButtonTopHilight(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                            drawButtonMiddle(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                            drawButtonFront(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                            drawButtonFrontHilight(inFrame: frame, yOffset:2,gradientColors:[NSColor(deviceWhite: 1, alpha: 1), NSColor(deviceWhite: 0.96, alpha: 1)], x: x, y: y, width: width, height: height, rad: rad)
                        }
                        
                        drawHoverOn(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, showBorder: self.showBorder, cornerRad: cornerRad, recessWidth: recessWidth, originalFrame: originalFrame, alphaInc: alphaInc, alphaVal: alphaVal, buttonColor: self.buttonColor!)
                    }
                    
                    func drawHoverOffButton()
                    {
                        func drawButtonTopHilight(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let buttonTopHilightRect = NSRect(x: x+1, y: y+1, width: (height+(height/4))-2, height: height-2)
                            let buttonTopHilight = NSBezierPath(roundedRect: buttonTopHilightRect, xRadius: rad, yRadius: rad)
                            
                            buttonTopHilight.setClip()
                            NSColor.white.setFill()
                            buttonTopHilight.fill()
                        }
                        
                        func drawButtonShadow(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let buttonShadowRect = NSRect(x: x+5, y: y+5, width: (height+(height/4)), height: height)
                            let buttonShadow = NSBezierPath(roundedRect: buttonShadowRect, xRadius: rad, yRadius: rad)
                            
                            buttonShadow.setClip()
                            NSColor(deviceWhite: 0, alpha:0.3).setFill()
                            buttonShadow.fill()
                        }
                        
                        func drawButtonMiddle(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let buttonMiddleRect = NSRect(x: x+1, y: y+3, width: (height+(height/4))-2, height: height-2)
                            let buttonMiddle = NSBezierPath(roundedRect: buttonMiddleRect, xRadius: rad, yRadius: rad)
                            
                            let middleGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite: 0.95, alpha: 1),0),(NSColor(deviceWhite: 0.6, alpha: 1),1))
                            
                            NSColor(deviceWhite: 1, alpha: 1).setFill()
                            if let middleGradient = middleGradient {
                                middleGradient.draw(in:buttonMiddle, angle: 90)
                            }
                        }
                        
                        func drawButtonFront(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let buttonFrontRect = NSRect(x: x+2, y: y+4, width: (height+(height/4))-4, height: height-6)
                            let buttonFront = NSBezierPath(roundedRect: buttonFrontRect, xRadius: rad, yRadius: rad)
                            
                            let frontGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite:0.95, alpha: 1),0),(NSColor(deviceWhite:0.95, alpha:1),0.3),(NSColor(deviceWhite:0.9, alpha:1),0.4),(NSColor(deviceWhite: 0.99, alpha: 1),1))
                            
                            buttonFront.setClip()
                            if let frontGradient = frontGradient {
                                frontGradient.draw(in:buttonFront, angle: 90)
                            }
                        }
                        
                        func drawButtonFrontHilight(inFrame frame: NSRect, xOffset: CGFloat = 0, yOffset: CGFloat = 0, widthOffset : CGFloat = 0, heightOffset: CGFloat = 0, gradientColors:[NSColor] = [NSColor.white,NSColor.white], x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat)
                        {
                            let frontHilightRect = NSRect(x: x+xOffset,y: y+yOffset, width: (height+(height/4))-heightOffset, height: height/2-heightOffset)
                            
                            let frontHilight = NSBezierPath(roundedRect: frontHilightRect, xRadius: rad, yRadius: rad)
                            
                            let frontHilightGradient = NSGradient(colorsAndLocations: (gradientColors[0],0),(gradientColors[1],1))
                            
                            if let frontHilightGradient = frontHilightGradient {
                                frontHilightGradient.draw(in:frontHilightRect, angle: 90)
                            }
                        }
                        
                        func drawToggleOffHover(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, showBorder: Bool?, cornerRad: CGFloat, recessWidth: CGFloat, originalFrame: NSRect, alphaInc: CGFloat, alphaVal: CGFloat, buttonColor: NSColor)
                        {
                            drawButtonBack(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, showBorder: showBorder!, cornerRad: cornerRad, recessWidth: recessWidth, originalFrame: originalFrame, alphaInc: alphaInc, alphaVal: alphaVal, buttonColor: buttonColor)
                            drawButtonShadow(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                            drawOnOffIndicators(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, horOffset: horOffset)
                            drawTopShadow(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, horOffset: horOffset, alphaInc: alphaInc)
                            drawButtonTopHilight(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                            drawButtonMiddle(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                            drawButtonFront(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad)
                            drawButtonFrontHilight(inFrame: frame, yOffset:2,gradientColors:[NSColor(deviceWhite: 1, alpha: 1), NSColor(deviceWhite: 0.96, alpha: 1)], x: x, y: y, width: width, height: height, rad: rad)
                        }
                        
                        drawToggleOffHover(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, showBorder: self.showBorder, cornerRad: cornerRad, recessWidth: recessWidth, originalFrame: originalFrame, alphaInc: alphaInc, alphaVal: alphaVal, buttonColor: self.buttonColor!)
                    }
                    
                    func drawDisabledButton()
                    {
                        func drawButtonTopHilight(inFrame frame: NSRect)
                        {
                            let buttonTopHilightRect = NSRect(x: x+(height/2)+1, y: y+1, width: height-2, height: height-2)
                            let buttonTopHilight = NSBezierPath(roundedRect: buttonTopHilightRect, xRadius: rad, yRadius: rad)
                            
                            buttonTopHilight.setClip()
                            NSColor.white.setFill()
                            buttonTopHilight.fill()
                        }
                        
                        func drawButtonMiddle(inFrame frame: NSRect)
                        {
                            let buttonMiddleRect = NSRect(x: x+(height/2)+1, y: y+3, width: height-2, height: height-2)
                            let buttonMiddle = NSBezierPath(roundedRect: buttonMiddleRect, xRadius: rad, yRadius: rad)
                            
                            let middleGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite: 0.95, alpha: 1),0),(NSColor(deviceWhite: 0.6, alpha: 1),1))
                            
                            NSColor(deviceWhite: 1, alpha: 1).setFill()
                            if let middleGradient = middleGradient {
                                middleGradient.draw(in: buttonMiddle, angle: 90)
                            }
                        }
                        
                        func drawButtonFront(inFrame frame: NSRect)
                        {
                            let buttonFrontRect = NSRect(x: x+(height/2)+2, y: y+4, width: height-4, height: height-6)
                            let buttonFront = NSBezierPath(roundedRect: buttonFrontRect, xRadius: rad, yRadius: rad)
                            
                            let frontGradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite:0.95, alpha: 1),0),(NSColor(deviceWhite:0.95, alpha:1),0.3),(NSColor(deviceWhite:0.9, alpha:1),0.4),(NSColor(deviceWhite: 0.99, alpha: 1),1))
                            
                            buttonFront.setClip()
                            if let frontGradient = frontGradient {
                                frontGradient.draw(in: buttonFront, angle: 90)
                            }
                        }
                        
                        func drawButtonFrontHilight(inFrame frame: NSRect, xOffset: CGFloat = 0, yOffset: CGFloat = 0, widthOffset : CGFloat = 0, heightOffset: CGFloat = 0, gradientColors:[NSColor?] = [NSColor.white,NSColor.white])
                        {
                            let frontHilightRect = NSRect(x: x+(height/2)+xOffset,y: y+yOffset, width: height-heightOffset, height: height/2-heightOffset)
                            
                            _ = NSBezierPath(roundedRect: frontHilightRect, xRadius: rad, yRadius: rad)
                            
                            let frontHilightGradient = NSGradient(colorsAndLocations: (gradientColors[0] as! NSColor,0),(gradientColors[1] as! NSColor,1))
                            
                            if let frontHilightGradient = frontHilightGradient {
                                frontHilightGradient.draw(in: frontHilightRect, angle: 90)
                            }
                        }
                        
                        func drawToggleDisabled(inFrame frame: NSRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rad: CGFloat, showBorder: Bool?, cornerRad: CGFloat, recessWidth: CGFloat, originalFrame: NSRect, alphaInc: CGFloat, alphaVal: CGFloat, buttonColor:NSColor)
                        {
                            let newAlphaVal : CGFloat = 0.75
                            let newAlphaInc : CGFloat = 0.025
                            let newButtonColor = NSColor(deviceWhite: 1, alpha: CGFloat(newAlphaVal))
                            
                            drawButtonBack(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, showBorder: showBorder!, cornerRad: cornerRad, recessWidth: recessWidth, originalFrame: originalFrame, alphaInc: newAlphaInc, alphaVal: newAlphaVal, buttonColor: newButtonColor)
                            //drawTopShadow(inFrame: frame)
                            //drawButtonTopHilight(inFrame: frame)
                            //drawButtonMiddle(inFrame: frame)
                            //drawButtonFront(inFrame: frame)
                            //drawButtonFrontHilight(inFrame: frame, yOffset:2,gradientColors:[NSColor(deviceWhite: 1, alpha: 1), NSColor(deviceWhite: 0.96, alpha: 1)])
                        }
                        
                        drawToggleDisabled(inFrame: frame, x: x, y: y, width: width, height: height, rad: rad, showBorder: self.showBorder, cornerRad: cornerRad, recessWidth: recessWidth, originalFrame: originalFrame, alphaInc: alphaInc, alphaVal: alphaVal, buttonColor: self.buttonColor!)
                    }
                    
                    switch buttonState
                    {
                    case .on:
                        drawOnButton()
                    case .off:
                        drawOffButton()
                    case .disabled:
                        drawDisabledButton()
                    case .hoverOn:
                        drawHoverOnButton()
                    case .hoverOff:
                        drawHoverOffButton()
                    default:
                        drawOffButton()
                    }
                }
            }
            
            switch buttonStyle
            {
            case .metallic:
                buttonConfig.buttonColor = NSColor.black
                metallicButtons(with: buttonConfig)
            case .glassy:
                Swift.print("glassy")
                glassyButtons(using: GlassyButtonConfig(using: buttonConfig))
            case .simple:
                Swift.print("simple")
                simpleButtons(using: SimpleButtonConfig(using: buttonConfig))
            case .toggle:
                toggleButtons(using: ToggleButtonConfig(using: buttonConfig))
            default:
                simpleButtons(using: SimpleButtonConfig(using: buttonConfig))
            }
            Swift.print("bezier")
            NSBezierPath(rect:frame).setClip()
            drawMyTitle(title: self.title, withFrame: frame, inView: self.controlView!)
        }
        ctx?.restoreGraphicsState()
        
        if let buttonStyle = buttonStyle
        {
            if buttonStyle == .noStyle
            {
                super.drawBezel(withFrame: frame, in: controlView)
                Swift.print("Bezel drawn")
            }
            else
            {
                Swift.print("Bezel not needed")
            }
        }
        else
        {
            Swift.print("No Bezel")
            super.drawBezel(withFrame: frame, in: controlView)
        }
    }

    override func prepareForInterfaceBuilder() {
        self.buttonColor = .blue
        self.buttonStyle = .glassy
        self.buttonState = .up
        super .prepareForInterfaceBuilder()
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
    }
    
    override init(textCell string: String) {
        super.init(textCell: string)
        infoPrint("\(self)", #function, self.className)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        infoPrint("\(self)", #function, self.className)
    }
    
    deinit {
        infoPrint("\(self)", #function, self.className)
    }
}
