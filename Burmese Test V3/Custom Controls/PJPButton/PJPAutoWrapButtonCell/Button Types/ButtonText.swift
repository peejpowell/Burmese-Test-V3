//
//  ButtonText.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 22/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

/// MARK: Button Text Functions

extension PJPAutoWrapButtonCell {
    
    func getLastSpaceIndex(text: String)->String.Index
    {
        infoPrint("\(self)", #function, self.className)
        let textLength : Int = text.count
        var firstIndex = text.index(before: text.endIndex)
        let lastIndex = text.endIndex
        for _ in 1 ..< textLength
        {
            let charRange : Range = text.index(before:firstIndex) ..< firstIndex
            //let charRange : Range = Range(start:firstIndex.predecessor(), end:firstIndex)
            let substrToCheck = text[charRange]
            if substrToCheck == " "
            {
                return firstIndex
            }
            firstIndex = charRange.lowerBound
        }
        return lastIndex
    }
    
    func wrapTitleText(title: String, frame: NSRect, titleFont: NSFont)->(String, NSSize)
    {
        infoPrint("\(self)", #function, self.className)
        //var buttonWidth = button.frame.size.width// - (button.frame.size.width * 0.10)
        if self.buttonStyle == .toggle
        {
            //buttonWidth = button.frame.size.width - ((button.frame.size.height+button.frame.size.height/2)+20) - (button.frame.size.width * 0.10)-50
        }
        
        let buttonTitle = title.replacingOccurrences(of: "  ", with: " ", options: String.CompareOptions.literal, range: title.startIndex..<title.endIndex)
        
        var paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        if let copyOfParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        {
            paragraphStyle = copyOfParagraphStyle
        }
        /*if self.buttonStyle == .toggle
        {
            paragraphStyle.alignment = NSTextAlignment.left
        }
        else
        {
            paragraphStyle.alignment = NSTextAlignment.center
        }*/
        let font = titleFont
        //let attributes = NSDictionary(objectsAndKeys: font, NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName)
        //var textSize = buttonTitle.sizeWithAttributes(attributes)
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let textSize = buttonTitle.size(withAttributes: attributes)
        
        var chunkArray = [String]()
        var remainingChunk = buttonTitle
        
        var counter = 0
        
        if frame.width < textSize.width
        {
            //PJLog("too long, chop it up")
            // Find the last space
            var tooLong = true
            
            var firstChunk : String = buttonTitle
            var initialText = buttonTitle
            
            while tooLong
            {
                let lastIndex = getLastSpaceIndex(text: firstChunk)
                //firstChunk = firstChunk.substringWithRange(Range(start:firstChunk.startIndex, end: lastIndex.predecessor()))
                firstChunk = String(firstChunk[firstChunk.startIndex..<firstChunk.index(before:lastIndex)])
                //PJLog("firstChunk: '\(firstChunk)'")
                //remainingChunk = initialText.substringFromIndex(lastIndex)
                remainingChunk = String(initialText[lastIndex...])
                //PJLog("remainingChunk: '\(remainingChunk)'")
                var firstTextSize = firstChunk.size(withAttributes: attributes)
                
                //PJLog(textSize.width)
                
                if frame.width < firstTextSize.width
                {
                    tooLong = true
                }
                else
                {
                    chunkArray.append(firstChunk)
                    //PJLog("first: \(chunkArray.last)")
                    //PJLog("last:  '\(remainingChunk)'")
                    
                    counter += 1
                    //PJLog("remainingChunk: '\(remainingChunk)'")
                    firstChunk = remainingChunk
                    initialText = remainingChunk
                    _ = remainingChunk.size(withAttributes: attributes)
                    firstTextSize = firstChunk.size(withAttributes: attributes)
                    if firstTextSize.width < frame.width
                    {
                        tooLong = false
                    }
                }
                if counter == 200
                {
                    tooLong = false
                }
                
            }
        }
        chunkArray.append(remainingChunk)
        print("remaining: \(remainingChunk)")
        var wrappedText = ""
        for text in 0 ..< chunkArray.count-1
        {
            wrappedText += chunkArray[text] + "\n"
        }
        if let endText : String = chunkArray.last
        {
            wrappedText += endText
        }
        
        let newSize = wrappedText.size(withAttributes: attributes)
        
        return (wrappedText, newSize)
    }
    
    /// Takes a string of text and inserts line feeds where a word will make it exceed the width of frame
    
    func boundsForStyle(_ style: PJPButtonStyle?, frame: NSRect, down: Bool = false)->NSRect {
        var textBounds = frame
        var cornerRadius : CGFloat = 0
        let offset: CGFloat = 2
        if let buttonStyle = style {
            switch buttonStyle {
            case .noStyle:
                break
            case .glassy, .metallic, .simple:
                if let divider = self.cornerDivider {
                    if divider > 0 {
                        cornerRadius = frame.size.height / divider
                    }
                }
                textBounds.origin.x = textBounds.origin.x + cornerRadius
                textBounds.size.width = textBounds.width - (cornerRadius * 2)
                if down {
                    textBounds.origin.x = textBounds.origin.x + offset*2
                    textBounds.origin.y = textBounds.origin.y + offset
                    textBounds.size.width = textBounds.width - offset * 2
                }
            case .toggle:
                var recessWidth : CGFloat = 0
                if let controlView = self.controlView {
                    recessWidth = (controlView.frame.height * 2) - (controlView.frame.height / 3)
                
                    print("recess: \(recessWidth)")
                    textBounds.origin.x = textBounds.origin.x + (controlView.frame.height / 2) + recessWidth
                }
                textBounds.size.width = textBounds.width - textBounds.origin.x - 5
                NSGraphicsContext.current?.saveGraphicsState()
                //NSColor.yellow.setFill()
                //textBounds.fill()
                switch self.buttonStyle! {
                case .toggle:
                    print("text frame: \(textBounds)")
                default:
                    break
                }
                NSGraphicsContext.current?.restoreGraphicsState()
                
            }
        }
        return textBounds
    }
    
    func wrapTitle(titleText: String, frame: NSRect, font: NSFont)->(String, NSFont, NSSize)
    {
        infoPrint("\(self)", #function, self.className)
        
        // Work out how wide the bounds of the text box should be so it doesn't overlap the edges of the button (even if curved)
        var textBounds = frame
        var cornerRadius : CGFloat = 0
        textBounds = boundsForStyle(self.buttonStyle, frame: textBounds)
        
        var (newTitleText, newSize) = wrapTitleText(title: titleText, frame: textBounds, titleFont: font)
        
        infoPrint("title Text: \(newTitleText)", #function, self.className)
        var paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        if let copyOfParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle {
            paragraphStyle = copyOfParagraphStyle
        }
        /*if self.buttonStyle == .toggle
        {
            paragraphStyle.alignment = NSTextAlignment.left
        }
        else
        {
            paragraphStyle.alignment = NSTextAlignment.center
        }*/
        
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        var textSize = newTitleText.size(withAttributes: attributes)
        var myFont = font
        /*
        while textSize.height > frame.height - 10
        {
            //PJLog("textsize height: \(textSize.height) - \(button.frame.size.height)")
            
            myFont = NSFont(name:font.fontName, size: myFont.pointSize - 1)!
            if myFont.pointSize < 10 {
                break
            }
            
            let attributes = [NSAttributedString.Key.font: myFont, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            let unwrappedText =  titleText.replacingOccurrences(of: "\n", with: " ", options: String.CompareOptions.literal, range: titleText.startIndex..<titleText.endIndex)
            
            titleText = wrapTitleText(title: unwrappedText, frame: textBounds, titleFont: myFont)
            textSize = titleText.size(withAttributes: attributes)
        }*/
        return (newTitleText, myFont, newSize)
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
        if let font = self.font,
           let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle {
            var xOffset: CGFloat = 0
            paragraphStyle.alignment = self.alignment
            switch paragraphStyle.alignment {
            case .center:
                break
            case .right:
                xOffset = -10
            case .left:
                xOffset = 10
            case .justified:
                xOffset = 10
            case .natural:
                break
            }
            
            //NSColor.green.setFill()
            //frame.fill()
            
            let (originalText, newFont, newSize) = wrapTitle(titleText: title.string, frame: frame, font: font)
            //self.font = newFont
            //var attributes = NSDictionary(objectsAndKeys: newFont, NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName)
            var attributes = [NSAttributedString.Key.font : newFont, NSAttributedString.Key.paragraphStyle : paragraphStyle]
            
            if let button = controlView as? PJPButton
            {
                if !button.isEnabled
                {
                    //attributes = NSDictionary(objectsAndKeys: newFont, NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName, NSColor(deviceRed: 0, green: 0, blue: 0, alpha: 0.5), NSForegroundColorAttributeName)
                    attributes = [NSAttributedString.Key.font : newFont, NSAttributedString.Key.paragraphStyle : paragraphStyle, NSAttributedString.Key.foregroundColor : NSColor(deviceRed: 0, green: 0, blue: 0, alpha: 0.5)]
                }
            }
            
            let textSize = newSize//originalText.size(withAttributes: attributes)
            
            var newFrame = frame
            //newFrame.size.width = textSize.width
            if textSize.height > frame.height {
                newFrame.size.height = textSize.height
                newFrame.origin.y = newFrame.origin.y - (textSize.height / 4)
            }
            let textFrame = boundsForStyle(buttonStyle, frame: newFrame)
            
            let downTextFrame = boundsForStyle(buttonStyle, frame: newFrame, down: true)
            let textBounds = textFrame
            
            if self.buttonState == .down {
                originalText.draw(in:downTextFrame, withAttributes: attributes)
            }
            else {
                //NSColor.red.setFill()
                //textFrame.fill()
                originalText.draw(in:textFrame, withAttributes: attributes)
            }
            return textBounds
        }
        return frame
    }
}
