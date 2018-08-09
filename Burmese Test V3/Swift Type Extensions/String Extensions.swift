//
//  String Extensions.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 04/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation

extension String {
    
    enum Keys {
        static let id           = "id"
        static let menu         = "menu"
        static let tabItem      = "tabItem"
        static let urls         = "urls"
        static let url          = "url"
        static let lesson       = "lesson"
        static let datasource   = "datasource"
        static let lessonPopup  = "lessonsPopup"
        static let tag          = "tag"
        static let column       = "column"
        static let title        = "title"
        static let menuItem     = "menuItem"
    }
    
    func minus(_ upTo: Int)-> String {
        switch upTo >= 0 {
        case true:
            let lastIndex = self.index(self.endIndex, offsetBy: -upTo)
            let stringToReturn = self[..<lastIndex]
            return String(stringToReturn)
        case false:
            let newUpTo = -upTo
            let firstIndex = self.index(self.startIndex, offsetBy: newUpTo)
            let stringToReturn = self[firstIndex..<self.endIndex]
            return String(stringToReturn)
        }
    }
    
    // MARK: Fixes for String functions/variables
    
    var lastPathComponent : String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
    
    var pathComponents : [String] {
        get {
            return (self as NSString).pathComponents
        }
    }
    
    func stringByAppendingPathComponent(_ path: String)->String
    {
        return (self as NSString).appendingPathComponent(path)
    }
    
    var pathExtension : String {
        get {
            return (self as NSString).pathExtension
        }
    }
    
    // MARK: Custom String Functions etc.
    
    enum PJPadLocation : Int
    {
        case before
        case after
    }
    
    mutating func foldString()
    {
        self = self.folding(options: NSString.CompareOptions.diacriticInsensitive, locale: Locale.current as Locale) as String
    }
    
    mutating func increment()
    {
        let newString = self as NSString
        var stringInt = newString.intValue
        stringInt += 1
        self = "\(stringInt)"
    }
    
    func padString(_ usingString: String, toLength: Int, location: PJPadLocation)->String
    {
        var newWord = self
        while (newWord.distance(from: newWord.startIndex, to: newWord.endIndex) < toLength)
        {
            if location == .before
            {
                newWord = "\(usingString)\(newWord)"
            }
            else
            {
                newWord = "\(newWord)\(usingString)"
            }
        }
        return newWord
    }
    
    mutating func replaceString(_ string: String, withString replacement: String)
    {
        var index = self.startIndex
        var lastIndex = self.startIndex
        while index < self.endIndex
        {
            lastIndex = index
            
            index = self.index(after: index)
            if index > self.endIndex
            {
                break
            }
            //print("range: \(lastIndex) \(index))")
            let testRange = (lastIndex ..< index)
            //print("comparing: \(self.substringWithRange(testRange)) to \(string)")
            if self[lastIndex ..< index] == string
            {
                //if self.substring(with: testRange) == string
                self.replaceSubrange(testRange, with: replacement)
                //print("Matched and replaced : \(string) with \(replacement)")
            }
            else
            {
                //print("No match: \(self.substringWithRange(testRange)) to \(string)")
            }
        }
    }
    
    func containsText(_ searchFor:String, isBurmese:Bool, fullWord: Bool, ignoreDiacritics: Bool) -> Bool
    {
        //print("\(searchFor) in \(self)")
        let oldStringLength = self.distance(from: self.startIndex, to: self.endIndex)
        let stringRange = self.range(of:self)
        var testString = String()
        var range : Range<String.Index>?
        
        var compareOptions = NSString.CompareOptions()
        var rangeOptions   = NSString.CompareOptions()
        switch isBurmese {
        case true:
            compareOptions = [.literal]
            rangeOptions = [.widthInsensitive]
        case false:
            switch ignoreDiacritics {
            case false:
                compareOptions = [.caseInsensitive]
                rangeOptions = [.caseInsensitive]
            case true:
                compareOptions = [.caseInsensitive, .diacriticInsensitive]
                rangeOptions = [.caseInsensitive, .diacriticInsensitive]
            }
        }
        
        testString = self.replacingOccurrences(of: searchFor, with: "", options: compareOptions, range: stringRange)
        range = self.range(of: searchFor, options: rangeOptions)
        
        let stringLength = testString.distance(from: testString.startIndex, to: testString.endIndex)
        
        if stringLength == oldStringLength {
            return false
        }
        else {
            if let range = range {
                if fullWord && !isBurmese {
                    // Convert the word to remove diacritic marks
                    var searchIn : String = self
                    if ignoreDiacritics && !isBurmese {
                        searchIn = self.folding(options: .diacriticInsensitive, locale: .current)
                    }
                    let letters : [String] = ["a","b","c","d","e","f","g","h","i","j",
                                              "k","l","m","n","o","p","q","r","s","t",
                                              "u","v","w","x","y","z",
                                              "A","B","C","D","E","F","G","H","I","J",
                                              "K","L","M","N","O","P","Q","R","S","T",
                                              "U","V","W","X","Y","Z"]
                    let alphabet = NSMutableSet(array: letters)
                    
                    let location = searchIn.distance(from: searchIn.startIndex, to: range.lowerBound)
                    
                    if location != 0
                    {
                        // Check the character before the start of the string.  If it's an alphabetical character then return false
                        
                        let subRange = (searchIn.index(searchIn.startIndex, offsetBy: location-1) ..< searchIn.index(searchIn.startIndex, offsetBy: location))
                        
                        let theChar = searchIn[subRange]
                        
                        if alphabet.member(theChar) != nil {
                            return false
                        }
                    }
                    
                    // Check the character after the end of the substring for a space or the end of the string
                    
                    let subStart = location + distance(from: range.lowerBound, to: range.upperBound)
                    
                    let totalLength = searchIn.distance(from: searchIn.startIndex, to: searchIn.endIndex)
                    
                    if subStart < totalLength {
                        let subRange = (searchIn.index(searchIn.startIndex, offsetBy: subStart) ..< searchIn.index(searchIn.startIndex, offsetBy: subStart+1))
                        
                        let theChar = searchIn[subRange]
                        
                        if alphabet.member(theChar) != nil {
                            return false
                        }
                        else {
                            return true
                        }
                    }
                }
            }
            return true
        }
    }

    // MARK: Fixes for String functions/variables
    
    func padBefore(_ padWith: String,desiredLength:Int)->String
    {
        var stringToPad = self
        while stringToPad.distance(from: stringToPad.startIndex, to: stringToPad.endIndex) < desiredLength
        {
            stringToPad = "\(padWith)\(stringToPad)"
        }
        return stringToPad
    }
    
    func left(_ length:Int)->String?
    {
        let lengthOfString = self.distance(from: self.startIndex, to: self.endIndex)
        
        if length > lengthOfString
        {
            return nil
        }
        
        var myEndIndex : String.Index = self.startIndex
        
        for _ in 0 ..< length
        {
            myEndIndex = self.index(after: myEndIndex)
        }
        
        return "\(self[..<myEndIndex])"
        //return substring(to: myEndIndex)
    }
    
    func right(_ length:Int)->String?
    {
        let lengthOfString = self.distance(from: self.startIndex, to: self.endIndex)
        
        if length > lengthOfString
        {
            return nil
        }
        
        var myStartIndex : String.Index = self.endIndex
        
        for _ in 0 ..< length
        {
            myStartIndex = self.index(before: myStartIndex)
        }
        
        return "\(self[myStartIndex...])"
        //return substring(from: myStartIndex)
    }
    
    func mid(_ loc: Int,length: Int)->String?
    {
        
        let lengthOfString = self.distance(from: self.startIndex, to: self.endIndex)
        let totalRequestedString = lengthOfString - loc
        if length > totalRequestedString
        {
            return nil
        }
        
        var myStartIndex : String.Index = self.startIndex
        
        for _ in 0 ..< loc
        {
            myStartIndex = self.index(after: myStartIndex)
        }
        
        var myEndIndex : String.Index = myStartIndex
        
        for _ in 0 ..< length
        {
            myEndIndex = self.index(after: myEndIndex)
        }
        
        //let myRange : Range = (myStartIndex ..< myEndIndex)
        
        return "\(self[myStartIndex..<myEndIndex])"
        //return self.substring(with: myRange)
    }
    
    func sentenceCase()->String
    {   let initial = self.left(1)!.uppercased()
        let theRest = self.right(self.count-1)!
        return "\(initial)\(theRest)"
    }
    
    func removeLastLine()->String
    {
        // Find the last \r in the text
        let string = self
        var progressText = ""
        var index = string.endIndex
        
        while index != string.startIndex
        {
            index = self.index(before: index)
            //let myoldChar = string.substring(with: (index ..< self.index(after: index)))
            let myChar = "\(string[index..<self.index(after: index)])"
            if myChar == "\r" || myChar == "\n"
            {
                // Check if the following characters are blank
                //let lastLine = string.substring(with: (index ..< string.endIndex)).trimAll()
                let lastLine = "\(string[index ..< string.endIndex])"
                if lastLine == ""
                {
                    index = self.index(before: index)
                }
                else
                {
                    break
                }
            }
        }
        //progressText = string.substring(with: (string.startIndex ..< index))
        progressText = "\(string[string.startIndex..<index])"
        return progressText
    }
    
    func lastLine()->String
    {
        // Find the last \r in the text
        let string = self
        var progressText = ""
        var index = string.endIndex
        
        while index != string.startIndex
        {
            index = self.index(before: index)
            //let myChar = string.substring(with: (index ..< self.index(after: index)))
            let myChar = "\(string[index ..< self.index(after:index)])"
            if myChar == "\r" || myChar == "\n"
            {
                // Check if the following characters are blank
                let lastLine = "\(string[index..<string.endIndex])".trimAll()
                //let lastLine = string.substring(with: (index ..< string.endIndex)).trimAll()
                if lastLine == ""
                {
                    index = self.index(before: index)
                }
                else
                {
                    break
                }
            }
        }
        progressText = "\(string[index..<string.endIndex])"
        //progressText = string.substring(with: (index ..< string.endIndex))
        return progressText
    }
    
    func trimAll()->String
    {
        var string = self
        string = string.replacingOccurrences(of: "\r", with: "", options: NSString.CompareOptions.literal, range: string.stringRange())
        string = string.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: string.stringRange())
        
        return string
    }
    
    func removeString(_ stringToRemove: String)->String
    {
        return self.replacingOccurrences(of: stringToRemove, with: "", options: NSString.CompareOptions.literal, range: self.range(of: self))
    }
    
    func stringRange()->Range<String.Index>
    {
        let myRange = (self.startIndex ..< self.endIndex)
        return myRange
    }
    
    func containsString(_ stringToFind: String)->Bool
    {
        if (self.range(of: stringToFind, options: NSString.CompareOptions.literal, range: self.stringRange(), locale: nil) != nil)
        {
            return true
        }
        else
        {
            return false
        }
    }
}


