//
//  Words.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

enum WordType : String {
    case burmese = "KBurmese"
    case english = "KEnglish"
    case roman = "KRoman"
    case lesson = "KLesson"
    case wordindex = "KWordIndex"
    case category = "KCategory"
    case categoryindex = "KCategoryIndex"
    case insertion = "KInsertion"
    case filterindex = "KFilterIndex"
    case filtertype = "KFilterType"
    case wordcategory = "KWordCategory"
    case correct = "KCorrect"
    case incorrect = "KIncorrect"
    case istitle = "KIstitle"
}

class Words: NSObject, NSCoding
{
    var wordKeys : Dictionary<String,AnyObject> = ["KBurmese":"" as AnyObject,"KRoman":"" as AnyObject,"KEnglish":"" as AnyObject,"KLesson":"" as AnyObject,"KWordIndex":"" as AnyObject,"KCategory":"" as AnyObject,"KCategoryIndex":"" as AnyObject,"KInsertion":"" as AnyObject,"KFilterIndex":0 as AnyObject,"KFilterType":0 as AnyObject,"KWordCategory":"" as AnyObject,"KCorrect":"" as AnyObject,"KIncorrect":"" as AnyObject,"KIstitle":false as AnyObject]
    /*{
     didSet(oldValue)
     {
     for key in wordKeys.keys
     {
     switch key
     {
     case "KBurmese":
     self.burmese = wordKeys[key] as? String
     case "KRoman":
     self.roman = wordKeys[key] as? String
     case "KEnglish":
     self.english = wordKeys[key] as? String
     case "KLesson":
     self.lesson = wordKeys[key] as? String
     case "KWordIndex":
     self.wordindex = wordKeys[key] as? String
     default:
     print("Unhandled wordKeys key: \(key)")
     }
     }
     }
     }*/
    
    override var description: String
    {
        var returnDescription = "Words:\n"
        
        if let burmese = burmese
        {
            returnDescription = "\(returnDescription)\t\(burmese)\n"
        }
        if let roman = roman
        {
            returnDescription = "\(returnDescription)\t\(roman)\n"
        }
        if let english = english
        {
            returnDescription = "\(returnDescription)\t\(english)\n"
        }
        if let filtertype = filtertype
        {
            switch filtertype
            {
            case .add:
                returnDescription = "\(returnDescription)\t[Add]\n"
            case .delete:
                returnDescription = "\(returnDescription)\t[[Delete]\n"
            case .change:
                returnDescription = "\(returnDescription)\t[Change]\n"
            case .none:
                returnDescription = "\(returnDescription)\t[None]\n"
            }
            
        }
        
        return returnDescription
    }
    
    var name: String = "PJWord class"
    
    enum PJFilterType : Int {
        case none = 0
        case add
        case delete
        case change
    }
    
    @objc  var burmese: String? {
        didSet(oldValue) {
            if oldValue != self.burmese {
                self.wordKeys["KBurmese"] = self.burmese as AnyObject
                self.setEdited()
            }
        }
    }
    
    @objc var roman: String? {
        didSet(oldValue) {
            if oldValue != self.roman
            {
                self.wordKeys["KRoman"] = self.roman as AnyObject
                self.setEdited()
            }
        }
    }
    @objc var english: String? {
        didSet(oldValue) {
            if oldValue != self.english
            {
                self.wordKeys["KEnglish"] = self.english as AnyObject
                self.setEdited()
            }
        }
    }
    @objc var lesson: String? {
        didSet(oldValue) {
            if oldValue != self.lesson
            {
                self.wordKeys["KLesson"] = self.lesson as AnyObject
                self.setEdited()
                increaseLessonCount(self.lesson!)
                if oldValue != nil
                {
                    decreaseLessonCount(oldValue!)
                }
            }
        }
    }
    @objc var wordindex: String? {
        didSet(oldValue) {
            if oldValue != self.wordindex
            {
                self.wordKeys["KWordIndex"] = self.wordindex as AnyObject
                self.setEdited()
            }
        }
    }
    @objc var category: String? {
        didSet(oldValue) {
            if oldValue != self.category
            {
                self.wordKeys["KCategory"] = self.category as AnyObject
                self.setEdited()
            }
        }
    }
    
    
    @objc var categoryindex: String? {
        didSet(oldValue) {
            self.wordKeys["KCategoryIndex"] = self.categoryindex as AnyObject
        }
    }
    
    @objc var insertion: String? {
        didSet(oldValue) {
            self.wordKeys["KInsertion"] = self.insertion as AnyObject
        }
    }
    
    var filterindex: Int? {
        didSet(oldValue) {
            self.wordKeys["KFilterIndex"] = self.filterindex as AnyObject
        }
    }
    
    var filtertype: PJFilterType? {
        didSet(oldValue) {
            if oldValue?.rawValue != self.filtertype?.rawValue {
                self.wordKeys["KFilterType"] = self.filtertype?.rawValue as AnyObject
            }
        }
    }
    @objc var wordcategory: String? {
        didSet(oldValue) {
            self.wordKeys["KWordCategory"] = self.wordcategory as AnyObject
        }
    }
    
    @objc var correct: String? {
        didSet(oldValue) {
            self.wordKeys["KCorrect"] = self.correct as AnyObject
        }
    }
    
    @objc var incorrect:      String? {
        didSet(oldValue) {
            self.wordKeys["KIncorrect"] = self.incorrect as AnyObject
        }
    }
    
    var unfilteredRow: Int?
    
    var filtered: Bool = false
    var istitle: Bool = false
    {
        didSet(oldValue)
        {
            print("Title changed: \(oldValue) to \(self.istitle)")
            self.wordKeys["KIsTitle"] = self.istitle as AnyObject
        }
    }
    
    func wordForKey(_ key: String)->String? {
        if let wordType = WordType(rawValue: key) {
            switch wordType {
            case .burmese:
                if let burmeseWord = self.burmese {
                    return burmeseWord
                }
            case .roman:
                if let romanWord = self.roman {
                    return romanWord
                }
            case .english:
                if let englishWord = self.english {
                    return englishWord
                }
            case .lesson:
                if let lesson = self.lesson {
                    return lesson
                }
            case .wordindex:
                if let wordIndex = self.wordindex {
                    return wordIndex
                }
            case .category:
                if let category = self.category {
                    return category
                }
            case .categoryindex:
                if let categoryIndex = self.categoryindex {
                    return categoryIndex
                }
            case .insertion:
                if let insertion = self.insertion {
                    return insertion
                }
            case .filterindex:
                if let filterIndex = self.filterindex {
                    return "\(filterIndex)"
                }
            case .filtertype:
                if let filterType = self.filtertype {
                    return "\(filterType.rawValue)"
                }
            case .wordcategory:
                if let wordCategory = self.wordcategory {
                    return wordCategory
                }
            case .correct:
                if let correct = self.correct {
                    return correct
                }
            case .incorrect:
                if let incorrect = self.incorrect {
                    return incorrect
                }
            case .istitle:
                return "\(self.istitle)"
            default:
                break
            }
        }
        return nil
    }
    
    func encode(with aCoder: NSCoder)
    {
        for key in self.wordKeys.keys
        {
            if let encodeString = self.wordKeys[key]! as? String
            {
                aCoder.encode(encodeString, forKey: key)
            }
            if let encodeInt = self.wordKeys[key]! as? Int
            {
                aCoder.encode(encodeInt, forKey: key)
            }
        }
    }
    
    func setEdited()
    {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .dataSourceNeedsSaving, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        for key in self.wordKeys.keys
        {
            if let decodedValue = aDecoder.decodeObject(forKey: key) as? String
            {
                self.wordKeys[key] = decodedValue as AnyObject
                switch key
                {
                case "KBurmese":
                    self.burmese = decodedValue
                case "KRoman":
                    self.roman = decodedValue
                case "KEnglish":
                    self.english = decodedValue
                case "KLesson":
                    self.lesson = decodedValue
                case "KWordIndex":
                    self.wordindex = decodedValue
                case "KCategory":
                    self.category = decodedValue
                case "KCategoryIndex":
                    self.categoryindex = decodedValue
                case "KInsertion":
                    self.insertion = decodedValue
                case "KWordCategory":
                    self.wordcategory = decodedValue
                case "KCorrect":
                    self.correct = decodedValue
                case "KIncorrect":
                    self.incorrect = decodedValue
                default:
                    print("Unhandled key: \(key)")
                }
            }
            if let decodedValue = aDecoder.decodeObject(forKey: key) as? Int
            {
                switch key
                {
                case "KFilterType":
                    self.filtertype = PJFilterType(rawValue: decodedValue)
                case "KFilterIndex":
                    self.filterindex = decodedValue
                default:
                    break
                }
            }
        }
    }
    
    func copyWithZone(_ zone: NSZone?)->Words
    {
        return self
    }
    
    override func copy() -> Any
    {
        let wordCopy = Words()
        
        wordCopy.burmese = self.burmese
        wordCopy.roman = self.roman
        wordCopy.english = self.english
        wordCopy.lesson = self.lesson
        wordCopy.insertion = self.insertion
        wordCopy.wordindex = self.wordindex
        wordCopy.category = self.category
        wordCopy.categoryindex = self.categoryindex
        wordCopy.wordcategory = self.wordcategory
        wordCopy.filterindex = self.filterindex
        wordCopy.filtertype = self.filtertype
        wordCopy.correct = self.correct
        wordCopy.incorrect = self.incorrect
        wordCopy.istitle = self.istitle
        
        return wordCopy
    }
    
    init(wordDictionary:Dictionary<String,String>)
    {
        for key in wordDictionary.keys
        {
            switch key
            {
            case "Burmese":
                self.burmese = wordDictionary[key]
                self.wordKeys["KBurmese"] = self.burmese as AnyObject
            case "Roman":
                self.roman = wordDictionary[key]
                self.wordKeys["KRoman"] = self.roman as AnyObject
            case "English":
                self.english = wordDictionary[key]
                self.wordKeys["KEnglish"] = self.english as AnyObject
            case "Lesson":
                self.lesson = wordDictionary[key]
                self.wordKeys["KLesson"] = self.lesson as AnyObject
            case "wordIndex":
                self.wordindex = wordDictionary[key]
                self.wordKeys["KWordIndex"] = self.wordindex as AnyObject
            case "category":
                self.category = wordDictionary[key]
                self.wordKeys["KCategory"] = self.category as AnyObject
            case "wordCategory":
                self.category = wordDictionary[key]
                self.wordKeys["KWordCategory"] = self.category as AnyObject
            case "categoryIndex":
                self.categoryindex = wordDictionary[key]
                self.wordKeys["KCategoryIndex"] = self.categoryindex as AnyObject
            case "Insertion":
                self.insertion = wordDictionary[key]
                self.wordKeys["KInsertion"] = self.insertion as AnyObject
            case "isTitle":
                self.istitle = wordDictionary[key] == "true"
                self.wordKeys["KIsTitle"] = self.istitle as AnyObject
            default:
                break
                //print("Unhandled dict key: \(key)")
            }
        }
    }
    
    override convenience init()
    {
        self.init(burmese: "", english: "", roman: "")
    }
    
    init(burmese: String, english: String, roman: String)
    {
        self.burmese = burmese
        self.english = english
        self.roman = roman
        self.wordKeys["KBurmese"] = burmese as AnyObject
        self.wordKeys["KEnglish"] = english as AnyObject
        self.wordKeys["KRoman"] = roman as AnyObject
    }
}
