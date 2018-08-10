//
//  ButtonText.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 22/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

// Extension to hold the functions related to drawing the button title

extension PJPAutoWrapButtonCell {
    
    /**
    Finds the index of the last space in the string passed to it.
    - Parameter text: The string to search.
    - Returns: A String.Index for the last space character.
     */
    
    func lastSpaceIndex(in text: String)->String.Index {
        //infoPrint("\(self)", #function, self.className)
        if let spaceIndex = text.lastIndex(of: " ") {
            return spaceIndex
        }
        return text.endIndex
    }
    
    /**
    Wraps the title text to fit in the frame it is given using the font provided. Successively checks the size of the text before each space character starting from the last and working backwards and inserts newline characters until the text fits in the given frame's width.
     - Parameter title:     The button title to wrap.
     - Parameter frame:     The frame to wrap the text in.
     - Parameter font:      The font to use to test whether wrapping is needed.
     - Returns: A tuple with the wrapped string and size for the frame of the wrapped string.
     */
    func wrapText(_ text: String, in frame: NSRect, using font: NSFont)->(String, NSSize) {
        //infoPrint("\(self)", #function, self.className)
        var textToWrap = text.replacingOccurrences(of: "  ", with: " ", options: String.CompareOptions.literal, range: text.startIndex..<text.endIndex)
        
        if let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle {
            let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            let textSize = textToWrap.size(withAttributes: attributes)
            
            var chunkArray = [String]()
            var postWrapText = textToWrap
            var counter = 0
            
            if self.buttonStyle! == .metallic {
                print("Metallic")
            }
            
            if frame.width < textSize.width {
                var tooLong = true
                var preWrapText : String = textToWrap
                
                // counter to make sure we don't get into an endless loop
                
                while tooLong && counter < 200 {
                    let lastSpaceIndex = self.lastSpaceIndex(in: preWrapText)
                    preWrapText = String(preWrapText[preWrapText.startIndex..<lastSpaceIndex])
                    postWrapText = String(textToWrap[lastSpaceIndex...])
                    var preWrapTextSize = preWrapText.size(withAttributes: attributes)
                    if frame.width < preWrapTextSize.width {
                        tooLong = true
                    }
                    else {
                        counter += 1
                        chunkArray.append(preWrapText)
                        preWrapText = postWrapText
                        textToWrap = postWrapText
                        preWrapTextSize = preWrapText.size(withAttributes: attributes)
                        if preWrapTextSize.width < frame.width {
                            chunkArray.append(postWrapText)
                            tooLong = false
                        }
                    }
                }
            }
            if chunkArray.count > 0 {
                var wrappedText = ""
                for chunkNum in 0 ..< chunkArray.count-1 {
                    wrappedText += chunkArray[chunkNum] + "\n"
                }
                if let endText : String = chunkArray.last {
                    wrappedText += endText
                }
                // Remove any leading spaces after a newline character
                wrappedText = wrappedText.replacingOccurrences(of: "\n ", with: "\n")
                return (wrappedText, wrappedText.size(withAttributes: attributes))
            }
            return (textToWrap, textToWrap.size(withAttributes: attributes))
        }
        return (textToWrap, frame.size)
    }

    func boundsForStyle(_ style: PJPButtonStyle?,in frame: NSRect, down: Bool = false)->NSRect {
        var textBounds = frame
        if let buttonStyle = style {
            switch buttonStyle {
            case .noStyle:
                break
            case .glassy, .metallic, .simple:
                if let cellFrame = self.controlView?.frame {
                    textBounds.origin.x = (cellFrame.height / 2) + 5
                    textBounds.origin.y = 5
                    textBounds.size.width = cellFrame.width - ((cellFrame.height / 2) * 2) - 10
                    textBounds.size.height = cellFrame.height - 5
                }
            case .toggle:
                if let cellFrame = self.controlView?.frame {
                    let toggleConfig = ToggleButtonConfig(frame: cellFrame)
                    textBounds.origin.x = (cellFrame.height / 2) + toggleConfig.recessWidth + 20
                    textBounds.origin.y = 5
                    textBounds.size.width = toggleConfig.width - ((cellFrame.height / 2) * 2) - toggleConfig.recessWidth - 20
                    textBounds.size.height = cellFrame.height - 5
                }
            }
        }
        return textBounds
    }
    
    func shrinkText(_ text: String, toFit frame: NSRect, with font: NSFont, using attributes: [NSAttributedString.Key : Any])->(String, NSSize, NSFont) {
        var textToShrink = text
        var textSize = textToShrink.size(withAttributes: attributes)
        textToShrink = textToShrink.replacingOccurrences(of: "\n", with: " ", options: String.CompareOptions.literal, range: textToShrink.startIndex..<textToShrink.endIndex)
        var currentFont = font
        while textSize.height > frame.height || textSize.width > frame.width {
            print("shrinking font: \(currentFont)")
            if let smallerFont = NSFont(name:currentFont.fontName, size: currentFont.pointSize - 1) {
                currentFont = smallerFont
                if smallerFont.pointSize < 10 {
                    break
                }
                let attributes = [NSAttributedString.Key.font: currentFont, NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle()]
                textToShrink =  textToShrink.replacingOccurrences(of: "\n", with: " ", options: String.CompareOptions.literal, range: textToShrink.startIndex..<textToShrink.endIndex)
            
                (textToShrink, textSize) = wrapText(textToShrink, in: frame, using: currentFont)
                textSize = textToShrink.size(withAttributes: attributes)
                print("text size: \(textSize), \(currentFont)")
            }
        }
        return (textToShrink, textSize, currentFont)
    }
    
    func wrapTitle(titleText: String, frame: NSRect, font: NSFont)->(String, NSFont, NSSize)
    {
        infoPrint("\(self)", #function, self.className)
        
        // Work out how wide the bounds of the text box should be so it doesn't overlap the edges of the button (even if curved)
        var textBounds = frame
        textBounds = boundsForStyle(self.buttonStyle, in : textBounds)
        
        var (wrappedTitle, wrappedTitleSize) = wrapText(titleText, in: textBounds, using: font)
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle()]
        var fontToUse = font
        switch self.shouldShrinkText {
        case true:
            print("font before shrinkText: \(fontToUse)")
            (wrappedTitle, wrappedTitleSize, fontToUse) = shrinkText(wrappedTitle, toFit: textBounds, with: fontToUse, using: attributes)
            print("font after shrinkText: \(fontToUse)")
        case false:
            break
        }
        
        return (wrappedTitle, fontToUse, wrappedTitleSize)
    }
    
    func findSpaces(inString string: String)->[String.Index]
    {
        var spaceIndexes : [String.Index] = [string.startIndex]
        spaceIndexes.remove(at: 0)
        //spaceIndexes.removeAtIndex(0)
        var start : String.Index = string.startIndex
        var end : String.Index = string.index(after:string.startIndex)
        
        while end < string.endIndex
        {
            //var char = string.substringWithRange(Range(start: start, end: end))
            let char = string[start..<end]
            if char == " "
            {
                spaceIndexes.append(end)
            }
            start = string.index(after:start)
            end = string.index(after:start)
        }
        return spaceIndexes
    }
    
    func wrapString(stringToWrap: String, inRect: NSRect, attributes: Dictionary<NSAttributedString.Key, AnyObject>)->(String, Int)
    {
        infoPrint("\(self)", #function, self.className)
        if stringToWrap.size(withAttributes: attributes).width < inRect.width
        {
            return (stringToWrap, 1)
        }
        var wrappedString = ""
        let stringSize : NSSize = stringToWrap.size(withAttributes: attributes)
        let spaceLocations : [String.Index] = findSpaces(inString: stringToWrap)
        var newString = ""
        var startLoc = stringToWrap.startIndex
        var endLoc = spaceLocations[0]
        let startNum = 0
        var strings = [String]()
        var returnString = ""
        for spaceNum in startNum ..< spaceLocations.count
        {
            // check the length of the string from start to the first space
            let oldString = newString
            newString = String(stringToWrap[startLoc..<endLoc])
            //PJLog(newString)
            
            if newString.size(withAttributes: attributes).width < inRect.width {
                returnString = newString
                if spaceNum < spaceLocations.count-1 {
                    endLoc = spaceLocations[spaceNum+1]
                }
                if spaceNum == spaceLocations.count-1 {
                    strings.append(returnString)
                }
            }
            else {
                //PJLog("newstring is too long : \(newString)")
                returnString = oldString
                startLoc = spaceLocations[spaceNum-1]
                //PJLog("return: \(returnString)")
                strings.append(returnString)
                if spaceNum == spaceLocations.count-1 {
                    endLoc = startLoc
                }
            }
        }
        let remainder = stringToWrap[endLoc..<stringToWrap.endIndex]
        //PJLog("remainder: \(remainder)")
        let lastAndRemainder = "\(strings[strings.count-1])\(remainder)"
        if lastAndRemainder.size(withAttributes: attributes).width > inRect.width {
            strings.append(String(remainder))
        }
        else {
            strings[strings.count-1] = lastAndRemainder
        }
        
        for stringNum in 0 ..< strings.count-1 {
            strings[stringNum] = "\(strings[stringNum])\n"
            wrappedString = wrappedString + strings[stringNum]
        }
        wrappedString = wrappedString + strings[strings.count-1]
        if wrappedString != "" {
            return (wrappedString,strings.count-1)
        }
        else {
            return (stringToWrap,1)
        }
    }
    
    func findString(dirtyRect: NSRect, string: String, attributes: Dictionary<NSAttributedString.Key, AnyObject>)->(Dictionary<NSAttributedString.Key, AnyObject>, Int)
    {
        infoPrint("\(self)", #function, self.className)
        let paragraphStyle : NSParagraphStyle = attributes[NSAttributedString.Key.paragraphStyle] as! NSParagraphStyle
        var font : NSFont = attributes[NSAttributedString.Key.font] as! NSFont
        
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        var wrappedString = ""
        var stringLines : Int = 0
        (wrappedString, stringLines) = wrapString(stringToWrap: string, inRect: dirtyRect, attributes: attributes)
        //PJLog(wrappedString)
        var textSize = wrappedString.size(withAttributes: attributes)
        
        while textSize.height > dirtyRect.height && font.pointSize > 2
        {
            font = NSFont(name: font.fontName, size: font.pointSize-1)!
            let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            (wrappedString, stringLines) = wrapString(stringToWrap: string, inRect: dirtyRect, attributes: attributes)
            //PJLog("wrapped: \(wrappedString)")
            textSize = wrappedString.size(withAttributes: attributes)
        }
        return (attributes, stringLines)
    }
    
    /*override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
     return controlView.frame
     }*/
    
    /*func drawMyTitle(title: String, withFrame frame: NSRect, inView controlView : NSView)
    {
        infoPrint("\(self)", #function, self.className)
        return
        /*
         if let lastTitle = self.lastTitle
         {
         if lastTitle == title
         {
         if let lastBounds = self.lastBounds
         {
         if lastBounds == frame
         {
         PJLog("shortCut")
         let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
         paragraphStyle.alignment = self.alignment
         let attributes = NSDictionary(objectsAndKeys: lastFont!, NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName)
         
         title.draw(in:self.lastRect!, withAttributes: attributes)
         return
         }
         }
         }
         }*/
        var bounds = frame
        let x = bounds.origin.x
        let y = bounds.origin.y
        let width = bounds.width
        let height = bounds.height
        let offset : CGFloat = 2
        
        if self.buttonStyle == .toggle
        {
            let xOffset = (height*2)-(height/4)
            let yOffset = (height/8)
            bounds = NSRect(x: x+xOffset, y: y+yOffset, width: width-(xOffset+(height/8)), height: height-(yOffset*2))
            //NSColor(deviceWhite: 0, alpha: 0.1).setFill()
            //NSBezierPath(rect: bounds).fill()
        }
        else
        {
            if self.buttonState == .down
            {
                bounds = NSRect(x: x+offset, y: y+offset, width: width, height: height)
            }
            else
            {
                bounds = NSRect(x: x, y: y, width: width, height: height)
            }
        }
        
        //let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy() as NSMutableParagraphStyle
        
        let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        
        var font : NSFont = NSFont(name: "Calibri", size: 20)!
        if let controlView = controlView as? NSButton
        {
            font = controlView.font!
        }
        
        if controlView is NSButton
        {
            paragraphStyle.alignment = self.alignment
        }
        else
        {
            paragraphStyle.alignment = NSTextAlignment.center
        }
        
        var attributes : [NSAttributedString.Key : AnyObject] = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        var stringLines : Int = 0
        (attributes, stringLines) = findString(dirtyRect: bounds, string: title, attributes: attributes)
        if let button = controlView as? PJPButton
        {
            if !button.isEnabled
            {
                //attributes = NSDictionary(objectsAndKeys: attributes.valueForKey(NSFontAttributeName) as NSFont, NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName, NSColor(deviceRed: 0, green: 0, blue: 0, alpha: 0.5), NSForegroundColorAttributeName)
                attributes = [NSAttributedString.Key.font:attributes[NSAttributedString.Key.font], NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: NSColor(deviceRed: 0, green: 0, blue: 0, alpha: 0.5)] as [NSAttributedString.Key : AnyObject]
            }
        }
        
        // move the bounds window to suit the number of wrapped lines
        //let fontSize = (attributes.valueForKey(NSFontAttributeName) as NSFont).pointSize
        let fontSize = (attributes[NSAttributedString.Key.font] as! NSFont).pointSize
        _ = CGFloat(stringLines) * (fontSize + 15)
        
        //bounds.origin.y = bounds.origin.y + ((bounds.height/2) - (wrappedLinesOffset/2))
        
        self.lastRect = bounds
        self.lastFont = attributes[NSAttributedString.Key.font] as? NSFont
        self.lastTitle = title
        self.lastBounds = frame
        title.draw(in: bounds, withAttributes: attributes)
    }*/
    
    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect
    {
        infoPrint("\(self)", #function, self.className)
        if  let font = self.font,
            let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle {
            //var xOffset: CGFloat = 0
            paragraphStyle.alignment = self.alignment
//            switch paragraphStyle.alignment {
//            case .center:
//                break
//            case .right:
//                xOffset = -10
//            case .left:
//                xOffset = 10
//            case .justified:
//                xOffset = 10
//            case .natural:
//                break
//            }
            
            var boundsForText = boundsForStyle(self.buttonStyle, in: frame)
            let (originalText, titleFont, textSize) = wrapTitle(titleText: title.string, frame: boundsForText, font: font)
            var attributes = [NSAttributedString.Key.font : titleFont, NSAttributedString.Key.paragraphStyle : paragraphStyle]
            
            if let button = controlView as? PJPButton {
                if !button.isEnabled {
                    attributes = [NSAttributedString.Key.font : titleFont, NSAttributedString.Key.paragraphStyle : paragraphStyle, NSAttributedString.Key.foregroundColor : NSColor(deviceRed: 0, green: 0, blue: 0, alpha: 0.5)]
                }
            }
            var newFrame = frame
            //var textFrame = boundsForStyle(buttonStyle, in: newFrame)
            //newFrame.size.width = textSize.width
            //if textSize.height > boundsForText.height {
            newFrame.size.height = frame.height
            newFrame.origin.y = newFrame.origin.y - (textSize.height / 4)
            //}
            
            let downTextFrame = boundsForStyle(buttonStyle, in: newFrame, down: true)
            if self.buttonState == .down {
                originalText.draw(in:downTextFrame, withAttributes: attributes)
            }
            else {
                
                // Center the textFrame in the button vertically by altering the origin of y
                boundsForText.origin.y = (controlView.frame.height - textSize.height) / 2
                originalText.draw(in:boundsForText, withAttributes: attributes)
            }
            return boundsForText
        }
        return frame
    }
}
