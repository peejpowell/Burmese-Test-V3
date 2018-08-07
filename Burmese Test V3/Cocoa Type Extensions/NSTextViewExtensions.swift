//
//  NSTextViewExtensions.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 04/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

extension NSTextView {
    
    func clear() {
        self.replaceCharacters(in: NSRange(location: 0,length: self.textStorage!.length), with: "")
    }
    
    func replaceAllWithText(_ textToInsert: String) {
        self.clear()
        let lengthOfString = self.string.distance(from: self.string.startIndex, to: self.string.endIndex)
        let fullRange = NSRange(location: 0, length: lengthOfString)
        self.insertText(textToInsert, replacementRange: fullRange)
        self.moveToBeginningOfDocument(nil)
    }
}
