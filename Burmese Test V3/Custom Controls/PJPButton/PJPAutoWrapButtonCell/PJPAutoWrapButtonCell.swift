//
//  PJPAutoWrapButtonCell.swift
//  testButtonWrap
//
//  Created by Phil on 28/08/2014.
//  Copyright (c) 2014 Phil. All rights reserved.
//

import Cocoa

enum PJPButtonStyle: Int
{
    case glassy // 0
    case toggle // 1
    case simple // 2
    case metallic // 3
    case noStyle // 4
}

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
    
    override func drawBezel(withFrame frame: NSRect, in controlView: NSView)
    {
        if  let button = controlView as? PJPButton,
            let buttonStyle = self.buttonStyle {
            
            // Set the cell's state to disabled if the button is disabled and is up and off
            
            if !button.isEnabled {// && self.buttonState != .down && self.buttonState != .on {
                self.buttonState = .disabled
            }
            
            NSGraphicsContext.current?.saveGraphicsState()
            
            // Set up an initial configuration with basic parameters
            
            let buttonConfig = PJPButtonConfig(frame: frame)
        
            if let buttonColor = self.buttonColor {
                buttonConfig.buttonColor = buttonColor
            }
            else {
                buttonConfig.buttonColor = NSColor(deviceRed: 0.5, green: 0.5, blue: 0.5, alpha: 1)
            }
            
            if let divider = self.cornerDivider {
                if divider > 0 {
                    buttonConfig.buttonCornerRadius = frame.size.height / divider
                }
            }
            
            switch buttonStyle {
            case .noStyle:
                super.drawBezel(withFrame: frame, in: controlView)
            case .metallic:
                buttonConfig.buttonColor = NSColor.black
                metallicButtons(with: buttonConfig)
            case .glassy:
                glassyButtons(using: GlassyButtonConfig(using: buttonConfig))
            case .simple:
                simpleButtons(using: SimpleButtonConfig(using: buttonConfig))
            case .toggle:
                toggleButtons(using: ToggleButtonConfig(using: buttonConfig))
            }
            
            NSGraphicsContext.current?.restoreGraphicsState()
        }
        else {
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
