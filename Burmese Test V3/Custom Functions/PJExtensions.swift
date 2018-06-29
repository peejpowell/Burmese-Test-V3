//
//  PJExtensions.swift
//  Burmese Test V2
//
//  Created by Phil on 25/07/2015.
//  Copyright © 2015 Phil. All rights reserved.
//

import Foundation
import Cocoa
import Carbon

extension TISInputSource {
    
    var id: String {
        let unsafeID = TISGetInputSourceProperty(self, kTISPropertyInputSourceID).assumingMemoryBound(to: CFString.self)
        let name = Unmanaged<CFString>.fromOpaque(unsafeID).takeUnretainedValue()
        
        return name as String
    }
    
    var type: String {
        let unsafeID = TISGetInputSourceProperty(self, kTISPropertyInputSourceType).assumingMemoryBound(to: CFString.self)
        let name = Unmanaged<CFString>.fromOpaque(unsafeID).takeUnretainedValue()
        
        return name as String
    }
    
    var isEnabled: Bool {
        let unsafeIsEnabled = TISGetInputSourceProperty(self, kTISPropertyInputSourceIsEnabled).assumingMemoryBound(to: CFBoolean.self)
        let isEnabled = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(unsafeIsEnabled).takeUnretainedValue())
        
        return isEnabled
    }
    
    var isSelected: Bool {
        let unsafeIsSelected = TISGetInputSourceProperty(self, kTISPropertyInputSourceIsSelected).assumingMemoryBound(to: CFBoolean.self)
        let isSelected = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(unsafeIsSelected).takeUnretainedValue())
        
        return isSelected
    }
    
    var isEnableCapable: Bool {
        let unsafeIsEnableCapable = TISGetInputSourceProperty(self, kTISPropertyInputSourceIsEnableCapable).assumingMemoryBound(to: CFBoolean.self)
        let isEnableCapable = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(unsafeIsEnableCapable).takeUnretainedValue())
        
        return isEnableCapable
    }
    
    var isSelectCapable: Bool {
        let unsafeIsSelectCapable = TISGetInputSourceProperty(self, kTISPropertyInputSourceIsSelectCapable).assumingMemoryBound(to: CFBoolean.self)
        let isSelectCapable = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(unsafeIsSelectCapable).takeUnretainedValue())
        
        return isSelectCapable
    }
    
    func enable() {
        if TISEnableInputSource(self) != noErr {
            print("Input source enabling failed. Source: \(self)")
        }
    }
    
    func disable() {
        if TISDisableInputSource(self) != noErr {
            print("Input source disabling failed. Source: \(self)")
        }
    }
    
    func select() {
        if TISSelectInputSource(self) != noErr {
            print("input selection failed")
        }
    }
}

extension String
{
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
        let oldstringLength = self.characters.distance(from: self.startIndex, to: self.endIndex)
        let stringRange = self.range(of:self)
        var testString = String()
        var range : Range<String.Index>?
        
        if isBurmese==true
        {
            testString = self.replacingOccurrences(of: searchFor, with: "", options: NSString.CompareOptions.literal, range: stringRange)
            range = self.range(of: searchFor,options:NSString.CompareOptions.widthInsensitive)
        }
        else if isBurmese == false && ignoreDiacritics == false
        {
            testString = self.replacingOccurrences(of: searchFor, with: "", options: NSString.CompareOptions.caseInsensitive, range: stringRange)
            range = self.range(of: searchFor,options:NSString.CompareOptions.caseInsensitive)
        }
        else
        {
            testString = self.replacingOccurrences(of: searchFor, with: "", options: [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive], range: stringRange)
            range = self.range(of: searchFor,options:[NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.diacriticInsensitive])
        }
        
        
        let stringLength = testString.distance(from: testString.startIndex, to: testString.endIndex)
        
        if stringLength == oldstringLength
        {
            return false
        }
        else
        {
            if let range = range
            {
                if fullWord == true && isBurmese == false
                {
                    // Convert the word to remove diacritic marks
                    var searchIn : String = self
                    if ignoreDiacritics == true && isBurmese == false
                    {
                        searchIn = self.folding(options: NSString.CompareOptions.diacriticInsensitive, locale: Locale.current as Locale)
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
                        
                        let theChar = (searchIn.substring(with: subRange))
                        
                        if alphabet.member(theChar) != nil
                        {
                            return false
                        }
                    }
                    
                    // Check the character after the end of the substring for a space or the end of the string
                    
                    let subStart = location + distance(from: range.lowerBound, to: range.upperBound)
                    //range.distance(from: range.startIndex, to: range.endIndex)
                    
                    let totalLength = searchIn.distance(from: searchIn.startIndex, to: searchIn.endIndex)
                    
                    if subStart < totalLength
                    {
                        let subRange = (searchIn.index(searchIn.startIndex, offsetBy: subStart) ..< searchIn.index(searchIn.startIndex, offsetBy: subStart+1))
                        
                        let theChar = (searchIn.substring(with: subRange))
                        
                        if alphabet.member(theChar) != nil
                        {
                            return false
                        }
                        else
                        {
                            return true
                        }
                    }
                }
            }
            return true
        }
    }
    /*
    func containsText(_ searchFor:String, isBurmese:Bool, fullWord: Bool, ignoreDiacritics: Bool) -> Bool
    {
        //print("\(searchFor) in \(self)")
        let oldstringLength = self.characters.distance(from: self.startIndex, to: self.endIndex)
        let stringRange = (self.characters.indices)
        var testString = String()
        var range : Range<String.Index>?
        
        if isBurmese==true
        {
            testString = self.replacingOccurrences(of: searchFor, with: "", options: NSString.CompareOptions.literalSearch, range: stringRange)
            range = self.range(of: searchFor,options:NSString.CompareOptions.widthInsensitiveSearch)
        }
        else if isBurmese == false && ignoreDiacritics == false
        {
            testString = self.replacingOccurrences(of: searchFor, with: "", options: NSString.CompareOptions.caseInsensitiveSearch, range: stringRange)
            range = self.range(of: searchFor,options:NSString.CompareOptions.caseInsensitiveSearch)
        }
        else
        {
            testString = self.replacingOccurrences(of: searchFor, with: "", options: [NSString.CompareOptions.caseInsensitiveSearch, NSString.CompareOptions.diacriticInsensitiveSearch], range: stringRange)
            range = self.range(of: searchFor,options:[NSString.CompareOptions.caseInsensitiveSearch, NSString.CompareOptions.diacriticInsensitiveSearch])
        }
        
        
        let stringLength = testString.distance(from: testString.startIndex, to: testString.endIndex)
        
        if stringLength == oldstringLength
        {
            return false
        }
        else
        {
            if let range = range
            {
                if fullWord == true && isBurmese == false
                {
                    // Convert the word to remove diacritic marks
                    var searchIn : String = self
                    if ignoreDiacritics == true && isBurmese == false
                    {
                        searchIn = self.folding(NSString.CompareOptions.diacriticInsensitiveSearch, locale: Locale.current() as Locale)
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
                        
                        let theChar = (searchIn.substring(with: subRange))
                        
                        if alphabet.member(theChar) != nil
                        {
                            return false
                        }
                    }
                    
                    // Check the character after the end of the substring for a space or the end of the string
                    
                    let subStart = location + range.distance(from: range.startIndex, to: range.endIndex)
                    
                    let totalLength = searchIn.distance(from: searchIn.startIndex, to: searchIn.endIndex)
                    
                    if subStart < totalLength
                    {
                        let subRange = (searchIn.index(searchIn.startIndex, offsetBy: subStart) ..< searchIn.index(searchIn.startIndex, offsetBy: subStart+1))
                        
                        let theChar = (searchIn.substring(with: subRange))
                        
                        if alphabet.member(theChar) != nil
                        {
                            return false
                        }
                        else
                        {
                            return true
                        }
                    }
                }
            }
            return true
        }
    }*/
}


extension NSTextView
{
    func clear()
    {
        self.replaceCharacters(in: NSRange(location: 0,length: self.textStorage!.length), with: "")
    }
    
    func replaceAllWithText(_ textToInsert: String)
    {
        self.clear()
        self.insertText(textToInsert)
        self.moveToBeginningOfDocument(nil)
    }
}
