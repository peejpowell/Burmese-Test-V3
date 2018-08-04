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

extension WordType: CaseIterable {}

class Words: NSObject, NSCoding
{
    override var description: String {
        var returnDescription = "Words:\n"
        
        if let burmese = burmese {
            returnDescription = "\(returnDescription)\t\(burmese)\n"
        }
        if let roman = roman {
            returnDescription = "\(returnDescription)\t\(roman)\n"
        }
        if let english = english {
            returnDescription = "\(returnDescription)\t\(english)\n"
        }
        if let filtertype = filtertype {
            switch filtertype {
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
                //self.wordKeys["KBurmese"] = self.burmese as AnyObject
                self.setEdited()
            }
        }
    }
    
    @objc var roman: String? {
        didSet(oldValue) {
            if oldValue != self.roman
            {
                //self.wordKeys["KRoman"] = self.roman as AnyObject
                self.setEdited()
            }
        }
    }
    @objc var english: String? {
        didSet(oldValue) {
            if oldValue != self.english
            {
                //self.wordKeys["KEnglish"] = self.english as AnyObject
                self.setEdited()
            }
        }
    }
    @objc var lesson: String? {
        didSet(oldValue) {
            if oldValue != self.lesson
            {
                //self.wordKeys["KLesson"] = self.lesson as AnyObject
                self.setEdited()
                if let lesson = self.lesson {
                    NotificationCenter.default.post(name: .increaseLessonCount, object: nil, userInfo: ["lesson" : lesson])
                    NotificationCenter.default.post(name: .startPopulateLessonsPopup, object: nil)
                }
                //increaseLessonCount(self.lesson!)
                if oldValue != nil
                {
                    NotificationCenter.default.post(name: .decreaseLessonCount, object: nil, userInfo: ["lesson" : lesson])
                    NotificationCenter.default.post(name: .startPopulateLessonsPopup, object: nil)
                }
            }
        }
    }
    
    @objc var wordindex: String? /*{
        /*didSet(oldValue) {
            if oldValue != self.wordindex
            {
                self.wordKeys["KWordIndex"] = self.wordindex as AnyObject
                self.setEdited()
            }
        }*/
    }*/
    
    @objc var category: String? {
        didSet(oldValue) {
            if oldValue != self.category
            {
                //self.wordKeys["KCategory"] = self.category as AnyObject
                self.setEdited()
            }
        }
    }
    
    
    @objc var categoryindex: String?/* {
        didSet(oldValue) {
            self.wordKeys["KCategoryIndex"] = self.categoryindex as AnyObject
        }
    } */
    
    @objc var insertion: String? {
        didSet(oldValue) {
            //self.wordKeys["KInsertion"] = self.insertion as AnyObject
        }
    }
    
    var filterindex: Int? {
        didSet(oldValue) {
            //self.wordKeys["KFilterIndex"] = self.filterindex as AnyObject
        }
    }
    
    var filtertype: PJFilterType?
    
    @objc var wordcategory: String? {
        didSet(oldValue) {
            //self.wordKeys["KWordCategory"] = self.wordcategory as AnyObject
            setEdited()
        }
    }
    
    @objc var correct: String?
    @objc var incorrect:      String?
    
    var unfilteredRow: Int?
    
    var filtered: Bool = false
    var istitle: Bool = false
    
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
            }
        }
        return nil
    }
    
    func encode(with aCoder: NSCoder)
    {
        WordType.allCases.forEach {
            let key = $0.rawValue
            if let encodeString = self.wordForKey(key) {
                if ["KFilterType", "KFilterIndex"].contains(key) {
                    if let encodeInt = Int(encodeString) {
                        aCoder.encode(encodeInt, forKey: key)
                    }
                }
                else {
                    aCoder.encode(encodeString, forKey: key)
                }
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
        var burmeseToDecode = ""
        var romanToDecode = ""
        var englishToDecode = ""
        var lessonToDecode = ""
        var insertionToDecode = ""
        var wordindexToDecode = ""
        var categoryToDecode = ""
        var categoryindexToDecode = ""
        var wordcategoryToDecode = ""
        var filterindexToDecode : Int?
        var filtertypeToDecode : Int?
        var correctToDecode = ""
        var incorrectToDecode = ""
        var istitleToDecode = false
        
        WordType.allCases.forEach {
            let key = $0.rawValue
            if let decodedValue = aDecoder.decodeObject(forKey: key) as? String {
                switch key {
                case "KBurmese":
                    burmeseToDecode = decodedValue
                case "KRoman":
                    romanToDecode = decodedValue
                case "KEnglish":
                    englishToDecode = decodedValue
                case "KLesson":
                    lessonToDecode = decodedValue
                case "KWordIndex":
                    wordindexToDecode = decodedValue
                case "KCategory":
                    categoryToDecode = decodedValue
                case "KCategoryIndex":
                    categoryindexToDecode = decodedValue
                case "KInsertion":
                    insertionToDecode = decodedValue
                case "KWordCategory":
                    wordcategoryToDecode = decodedValue
                case "KCorrect":
                    correctToDecode = decodedValue
                case "KIncorrect":
                    incorrectToDecode = decodedValue
                case "KFilterType":
                    if let intValue = Int(decodedValue) {
                        filtertypeToDecode = intValue
                    }
                case "KFilterIndex":
                    if let intValue = Int(decodedValue) {
                        filterindexToDecode = intValue
                    }
                default:
                    print("Unhandled key: \(key)")
                }
            }
        }
        
        self.burmese = burmeseToDecode
        self.roman = romanToDecode
        self.english = englishToDecode
        self.lesson = lessonToDecode
        self.insertion = insertionToDecode
        self.wordindex = wordindexToDecode
        self.category = categoryToDecode
        self.categoryindex = categoryindexToDecode
        self.wordcategory = wordcategoryToDecode
        self.filterindex = filterindexToDecode
        if let filterType = filtertypeToDecode {
            self.filtertype = PJFilterType(rawValue:filterType)
        }
        self.correct = correctToDecode
        self.incorrect = incorrectToDecode
        self.istitle = istitleToDecode
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
                //self.wordKeys["KBurmese"] = self.burmese as AnyObject
            case "Roman":
                self.roman = wordDictionary[key]
                //self.wordKeys["KRoman"] = self.roman as AnyObject
            case "English":
                self.english = wordDictionary[key]
                //self.wordKeys["KEnglish"] = self.english as AnyObject
            case "Lesson":
                self.lesson = wordDictionary[key]
                //self.wordKeys["KLesson"] = self.lesson as AnyObject
            case "wordIndex":
                self.wordindex = wordDictionary[key]
                //self.wordKeys["KWordIndex"] = self.wordindex as AnyObject
            case "category":
                self.category = wordDictionary[key]
                //self.wordKeys["KCategory"] = self.category as AnyObject
            case "wordCategory":
                self.category = wordDictionary[key]
                //self.wordKeys["KWordCategory"] = self.category as AnyObject
            case "categoryIndex":
                self.categoryindex = wordDictionary[key]
                //self.wordKeys["KCategoryIndex"] = self.categoryindex as AnyObject
            case "Insertion":
                self.insertion = wordDictionary[key]
                //self.wordKeys["KInsertion"] = self.insertion as AnyObject
            case "isTitle":
                self.istitle = wordDictionary[key] == "true"
                //self.wordKeys["KIsTitle"] = self.istitle as AnyObject
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
        //self.wordKeys["KBurmese"] = burmese as AnyObject
        //self.wordKeys["KEnglish"] = english as AnyObject
        //self.wordKeys["KRoman"] = roman as AnyObject
    }
}
