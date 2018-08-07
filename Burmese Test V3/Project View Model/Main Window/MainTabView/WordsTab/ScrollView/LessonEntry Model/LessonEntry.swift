//
//  LessonEntry.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 26/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

enum LessonEntryType : String {
    case burmese = "KBurmese"
    case english = "KEnglish"
    case roman = "KRoman"
    case lesson = "KLesson"
    case lessonEntryIndex = "KWordIndex"
    case category = "KCategory"
    case categoryindex = "KCategoryIndex"
    case insertion = "KInsertion"
    case filterindex = "KFilterIndex"
    case filtertype = "KFilterType"
    case lessonEntryCategory = "KWordCategory"
    case correct = "KCorrect"
    case incorrect = "KIncorrect"
    case istitle = "KIstitle"
}

extension LessonEntryType: CaseIterable {}

class LessonEntry: NSObject, NSCoding {
    override var description: String {
        var returnDescription = "Lesson Entries:\n"
        
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
    
    var name: String = "LessonEntry class"
    
    enum LessonEntryFilterType : Int {
        case none = 0
        case add
        case delete
        case change
    }
    
    @objc  var burmese: String? {
        didSet(oldValue) {
            if oldValue != self.burmese {
                //self.lessonEntryKeys["KBurmese"] = self.burmese as AnyObject
                self.setEdited()
            }
        }
    }
    
    @objc var roman: String? {
        didSet(oldValue) {
            if oldValue != self.roman
            {
                //self.lessonEntryKeys["KRoman"] = self.roman as AnyObject
                self.setEdited()
            }
        }
    }
    @objc var english: String? {
        didSet(oldValue) {
            if oldValue != self.english
            {
                //self.lessonEntryKeys["KEnglish"] = self.english as AnyObject
                self.setEdited()
            }
        }
    }
    @objc var lesson: String? {
        didSet(oldValue) {
            if oldValue != self.lesson
            {
                //self.lessonEntryKeys["KLesson"] = self.lesson as AnyObject
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
    
    @objc var lessonEntryIndex: String? /*{
        /*didSet(oldValue) {
            if oldValue != self.lessonEntryindex
            {
                self.lessonEntryKeys["KWordIndex"] = self.lessonEntryindex as AnyObject
                self.setEdited()
            }
        }*/
    }*/
    
    @objc var category: String? {
        didSet(oldValue) {
            if oldValue != self.category
            {
                //self.lessonEntryKeys["KCategory"] = self.category as AnyObject
                self.setEdited()
            }
        }
    }
    
    
    @objc var categoryindex: String?/* {
        didSet(oldValue) {
            self.lessonEntryKeys["KCategoryIndex"] = self.categoryindex as AnyObject
        }
    } */
    
    @objc var insertion: String? {
        didSet(oldValue) {
            //self.lessonEntryKeys["KInsertion"] = self.insertion as AnyObject
        }
    }
    
    var filterindex: Int? {
        didSet(oldValue) {
            //self.lessonEntryKeys["KFilterIndex"] = self.filterindex as AnyObject
        }
    }
    
    var filtertype: LessonEntryFilterType?
    
    @objc var lessonEntryCategory: String? {
        didSet(oldValue) {
            //self.lessonEntryKeys["KWordCategory"] = self.lessonEntrycategory as AnyObject
            setEdited()
        }
    }
    
    @objc var correct: String?
    @objc var incorrect:      String?
    
    var unfilteredRow: Int?
    
    var filtered: Bool = false
    var istitle: Bool = false
    
    func unwrapped(_ lessonEntry: String?)->String {
        if let unwrappedLessonEntry = lessonEntry {
            return unwrappedLessonEntry
        }
        return ""
    }
    
    func unwrapped(_ lessonEntry: Int?)->String {
        if let unwrappedLessonEntry = lessonEntry {
            return "\(unwrappedLessonEntry)"
        }
        return ""
    }
    
    func unwrapped(_ lessonEntry: Bool?)->String {
        if let unwrappedLessonEntry = lessonEntry {
            return "\(unwrappedLessonEntry)"
        }
        return ""
    }
    
    func unwrapped(_ lessonEntry: LessonEntryFilterType?)->String {
        if let unwrappedLessonEntry = lessonEntry {
            return "\(unwrappedLessonEntry)"
        }
        return ""
    }
    
    func lessonEntryForKey(_ key: String)->String? {
        if let lessonEntryType = LessonEntryType(rawValue: key) {
            switch lessonEntryType {
            case .burmese:
                return unwrapped(burmese)
            case LessonEntryType.roman:
                return unwrapped(roman)
            case LessonEntryType.english:
                return unwrapped(english)
            case LessonEntryType.lesson:
                return unwrapped(lesson)
            case LessonEntryType.lessonEntryIndex:
                return unwrapped(lessonEntryIndex)
            case LessonEntryType.category:
                return unwrapped(category)
            case LessonEntryType.categoryindex:
                return unwrapped(categoryindex)
            case LessonEntryType.insertion:
                return unwrapped(insertion)
            case LessonEntryType.filterindex:
                return unwrapped(filterindex)
            case LessonEntryType.filtertype:
                return unwrapped(filtertype)
            case LessonEntryType.lessonEntryCategory:
                return unwrapped(lessonEntryCategory)
            case LessonEntryType.correct:
                return unwrapped(correct)
            case LessonEntryType.incorrect:
                return unwrapped(incorrect)
            case LessonEntryType.istitle:
                return unwrapped(istitle)
            }
        }
        return nil
    }
    
    func encode(with aCoder: NSCoder)
    {
        LessonEntryType.allCases.forEach {
            let key = $0.rawValue
            if let encodeString = self.lessonEntryForKey(key) {
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
        var lessonEntryindexToDecode = ""
        var categoryToDecode = ""
        var categoryindexToDecode = ""
        var lessonEntrycategoryToDecode = ""
        var filterindexToDecode : Int?
        var filtertypeToDecode : Int?
        var correctToDecode = ""
        var incorrectToDecode = ""
        var istitleToDecode = false
        
        LessonEntryType.allCases.forEach {
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
                    lessonEntryindexToDecode = decodedValue
                case "KCategory":
                    categoryToDecode = decodedValue
                case "KCategoryIndex":
                    categoryindexToDecode = decodedValue
                case "KInsertion":
                    insertionToDecode = decodedValue
                case "KWordCategory":
                    lessonEntrycategoryToDecode = decodedValue
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
        self.lessonEntryIndex = lessonEntryindexToDecode
        self.category = categoryToDecode
        self.categoryindex = categoryindexToDecode
        self.lessonEntryCategory = lessonEntrycategoryToDecode
        self.filterindex = filterindexToDecode
        if let filterType = filtertypeToDecode {
            self.filtertype = LessonEntryFilterType(rawValue:filterType)
        }
        self.correct = correctToDecode
        self.incorrect = incorrectToDecode
        self.istitle = istitleToDecode
    }
    
    func copyWithZone(_ zone: NSZone?)->LessonEntry
    {
        return self
    }
    
    override func copy() -> Any
    {
        let lessonEntryCopy = LessonEntry()
        
        lessonEntryCopy.burmese = self.burmese
        lessonEntryCopy.roman = self.roman
        lessonEntryCopy.english = self.english
        lessonEntryCopy.lesson = self.lesson
        lessonEntryCopy.insertion = self.insertion
        lessonEntryCopy.lessonEntryIndex = self.lessonEntryIndex
        lessonEntryCopy.category = self.category
        lessonEntryCopy.categoryindex = self.categoryindex
        lessonEntryCopy.lessonEntryCategory = self.lessonEntryCategory
        lessonEntryCopy.filterindex = self.filterindex
        lessonEntryCopy.filtertype = self.filtertype
        lessonEntryCopy.correct = self.correct
        lessonEntryCopy.incorrect = self.incorrect
        lessonEntryCopy.istitle = self.istitle
        
        return lessonEntryCopy
    }
    
    init(lessonEntryDictionary:Dictionary<String,String>) {
        for key in lessonEntryDictionary.keys {
            if key.containsString("word") { print ("\(key)") }
            switch key {
            case "wordIndex":
                self.lessonEntryIndex = lessonEntryDictionary[key]
            case "wordCategory":
                self.lessonEntryCategory = lessonEntryDictionary[key]
            case "Burmese":
                self.burmese = lessonEntryDictionary[key]
                //self.lessonEntryKeys["KBurmese"] = self.burmese as AnyObject
            case "Roman":
                self.roman = lessonEntryDictionary[key]
                //self.lessonEntryKeys["KRoman"] = self.roman as AnyObject
            case "English":
                self.english = lessonEntryDictionary[key]
                //self.lessonEntryKeys["KEnglish"] = self.english as AnyObject
            case "Lesson":
                self.lesson = lessonEntryDictionary[key]
                //self.lessonEntryKeys["KLesson"] = self.lesson as AnyObject
            case "lessonEntryIndex":
                self.lessonEntryIndex = lessonEntryDictionary[key]
                //self.lessonEntryKeys["KWordIndex"] = self.lessonEntryindex as AnyObject
            case "category":
                self.category = lessonEntryDictionary[key]
                //self.lessonEntryKeys["KCategory"] = self.category as AnyObject
            case "lessonEntryCategory":
                self.category = lessonEntryDictionary[key]
                //self.lessonEntryKeys["KWordCategory"] = self.category as AnyObject
            case "categoryIndex":
                self.categoryindex = lessonEntryDictionary[key]
                //self.lessonEntryKeys["KCategoryIndex"] = self.categoryindex as AnyObject
            case "Insertion":
                self.insertion = lessonEntryDictionary[key]
                //self.lessonEntryKeys["KInsertion"] = self.insertion as AnyObject
            case "isTitle":
                self.istitle = lessonEntryDictionary[key] == "true"
                //self.lessonEntryKeys["KIsTitle"] = self.istitle as AnyObject
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
        //self.lessonEntryKeys["KBurmese"] = burmese as AnyObject
        //self.lessonEntryKeys["KEnglish"] = english as AnyObject
        //self.lessonEntryKeys["KRoman"] = roman as AnyObject
    }
}
