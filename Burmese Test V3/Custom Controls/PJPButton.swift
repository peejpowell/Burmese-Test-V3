//
//  PJPButton.swift
//  Burmese Test Swift
//
//  Created by Phil on 31/08/2014.
//  Copyright (c) 2014 Phil. All rights reserved.
//

import Cocoa

enum PJPButtonState: Int
{
    // MARK: 
    
    case up // 0
    case down // 1
    case disabled // 2
    case hover // 3
    case hoverOn // 4
    case hoverOff // 5
    case on // 6
    case off // 7
    case none // 8
}

@IBDesignable class PJPButton: NSButton {
    
    var oldState : PJPButtonState?
    var enteredCount : Int = 0
    
    func createTrackingArea()
    {
        let focusTrackingAreaOptions : NSTrackingArea.Options = [NSTrackingArea.Options.activeInActiveApp,
             NSTrackingArea.Options.mouseEnteredAndExited,
             NSTrackingArea.Options.assumeInside,
             NSTrackingArea.Options.inVisibleRect]
        let focusTrackingArea = NSTrackingArea(rect: NSZeroRect, options: focusTrackingAreaOptions, owner: self, userInfo: nil)
        self.addTrackingArea(focusTrackingArea)
    }

    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        
        self.createTrackingArea()
       
    }
    
    required init?(coder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        self.createTrackingArea()
        if let cell = self.cell as? NSButtonCell
        {
            Swift.print("cell is: \(cell)")
        }
    }
    
    func removeTrackingAreas()
    {
        for trackingArea in self.trackingAreas
        {
            self.removeTrackingArea(trackingArea as NSTrackingArea)
        }
    }
    /*

    - (void)createTrackingArea
    {
    NSTrackingAreaOptions focusTrackingAreaOptions = NSTrackingActiveInActiveApp;
    focusTrackingAreaOptions |= NSTrackingMouseEnteredAndExited;
    focusTrackingAreaOptions |= NSTrackingAssumeInside;
    focusTrackingAreaOptions |= NSTrackingInVisibleRect;
    
    NSTrackingArea *focusTrackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect
    options:focusTrackingAreaOptions owner:self userInfo:nil];
    [self addTrackingArea:focusTrackingArea];
    }
    
    
    - (void)awakeFromNib
    {
    [self createTrackingArea];
    }
*/
    
    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)

        // Drawing code here.
    }
 
    override func mouseMoved(with event: NSEvent) {
        Swift.print("mouseMoved")
        
        if self.isEnabled
        {
            if let cell = self.cell as? PJPAutoWrapButtonCell
            {
                cell.buttonState = .hover
                self.setNeedsDisplay()
            }
        }
        super.mouseMoved(with: event)
    }
    
    override func mouseDown(with event: NSEvent)
    {
        Swift.print("mouseDown")
        
        if self.isEnabled
        {
            if  let cell = self.cell as? PJPAutoWrapButtonCell,
                let buttonState = cell.buttonState,
                let buttonStyle = cell.buttonStyle
            {
                switch buttonState
                {
                case .on:
                    switch buttonStyle
                    {
                    case .glassy:
                        cell.buttonState = .down
                    case .toggle:
                        cell.buttonState = .hoverOn
                    default:
                        break
                    }
                case .off:
                    switch buttonStyle
                    {
                    case .glassy:
                        cell.buttonState = .down
                    case .toggle:
                        cell.buttonState = .hoverOn
                    default:
                        break
                    }
                case .hover:
                    switch buttonStyle
                    {
                    case .glassy:
                        cell.buttonState = .down
                    case .toggle:
                        break
                    default:
                        break
                    }
                default:
                    break
                }
                self.setNeedsDisplay()
            }
        }
        super.mouseDown(with: event)
        //self.mouseUp(theEvent)
    }
    
    override func mouseUp(with event: NSEvent)
    {
        Swift.print("mouseUp")
        if self.isEnabled
        {
            if let cell = self.cell as? PJPAutoWrapButtonCell
            {
                if cell.buttonState == .on
                {
                    cell.buttonState = .off
                }
                else if cell.buttonState == .down
                {
                    cell.buttonState = .hover
                }
                self.setNeedsDisplay()
            }
        }
        super.mouseUp(with: event)
    }

    override func mouseEntered(with event: NSEvent)
    {
        Swift.print("entered")
        if self.isEnabled
        {
            if  let cell = self.cell as? PJPAutoWrapButtonCell,
                let buttonState = cell.buttonState,
                let buttonStyle = cell.buttonStyle
            {
                switch self.enteredCount
                {
                case 0:
                    self.oldState = buttonState
                    switch buttonState
                    {
                    case .off:
                        Swift.print("Off")
                        switch buttonStyle
                        {
                        case .glassy:
                            cell.buttonState = .hover
                        case .toggle:
                            cell.buttonState = .hoverOff
                        default:
                            cell.buttonState = .hoverOff
                        }
                    case .on:
                        Swift.print("On")
                        switch buttonStyle
                        {
                        case .glassy:
                            cell.buttonState = .hover
                        case .toggle:
                            cell.buttonState = .hoverOn
                        default:
                            cell.buttonState = .hoverOn
                        }
                    case .hoverOn:
                        Swift.print("hoverOn")
                    case .hoverOff:
                        Swift.print("hoverOff")
                    case .up:
                        Swift.print("up")
                        switch buttonStyle
                        {
                        case .glassy:
                            cell.buttonState = .hover
                        default:
                            cell.buttonState = .hover
                        }
                    case .down:
                        Swift.print("down")
                    default:
                        switch buttonStyle
                        {
                        case .glassy:
                            cell.buttonState = .hover
                        case .toggle:
                            break
                        default:
                            break
                        }
                    }
                    self.enteredCount = 1
                default:
                    self.enteredCount = 0
                    switch buttonState
                    {
                    case .off:
                        switch buttonStyle
                        {
                        case .glassy:
                            cell.buttonState = .hover
                        case .toggle:
                            cell.buttonState = .hoverOff
                        default:
                            cell.buttonState = .hoverOff
                        }
                    case .on:
                        switch buttonStyle
                        {
                        case .glassy:
                            cell.buttonState = .hover
                        case .toggle:
                            cell.buttonState = .hoverOn
                        default:
                            cell.buttonState = .hoverOn
                        }
                    default:
                        switch buttonStyle
                        {
                        case .glassy:
                            cell.buttonState = .hover
                        case .toggle:
                            cell.buttonState = .hoverOn
                        default:
                            cell.buttonState = .hoverOn
                        }
                    }
                }
                
                self.setNeedsDisplay()
            }
        }
        super.mouseEntered(with:event)
    }
    
    override func mouseExited(with event: NSEvent)
    {
        Swift.print("exited")
        if self.isEnabled
        {
            if let cell = self.cell as? PJPAutoWrapButtonCell,
                let buttonState = cell.buttonState,
                let buttonStyle = cell.buttonStyle
            {
                switch buttonState
                {
                case .on:
                    switch buttonStyle
                    {
                    case .glassy:
                        cell.buttonState = .down
                    case .toggle:
                        cell.buttonState = .on
                    default:
                        break
                    }
                case .off:
                    switch buttonStyle
                    {
                    case .glassy:
                        cell.buttonState = .down
                    case .toggle:
                        cell.buttonState = .off
                    default:
                        break
                    }
                case .hover, .hoverOff:
                    switch buttonStyle
                    {
                    case .glassy:
                        cell.buttonState = .up
                    case .toggle:
                        cell.buttonState = .off
                    default:
                        break
                    }
                case .hoverOn:
                    switch buttonStyle
                    {
                    case .glassy:
                        cell.buttonState = .up
                    case .toggle:
                        cell.buttonState = .on
                    default:
                        break
                    }
                default:
                    break
                }
               /* if cell.buttonState == .hover || cell.buttonState == .down
                {
                    Swift.print("Setting up state")
                    
                    
                    cell.buttonState = .up
                }
                else if cell.buttonState == .hoverOn || cell.buttonState == .hoverOff
                {
                    Swift.print("Setting old state back")
                    if self.oldState == .off
                    {
                        Swift.print("Off")
                    }
                    else if self.oldState == .on
                    {
                        Swift.print("On")
                    }
                    else if self.oldState == .hoverOn
                    {
                        Swift.print("hoverOn")
                    }
                    else if self.oldState == .hoverOff
                    {
                        Swift.print("hoverOff")
                    }
                    else if self.oldState == .up
                    {
                        Swift.print("up")
                    }
                    else if self.oldState == .down
                    {
                        Swift.print("down")
                    }

                    cell.buttonState = self.oldState
                }*/
                self.setNeedsDisplay()
            }
            super.mouseExited(with:event)
        }
    }
    
}
