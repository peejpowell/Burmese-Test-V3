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
    case lessonEntryIndex = "KLessonEntryIndex"
    case category = "KCategory"
    case categoryindex = "KCategoryIndex"
    case insertion = "KInsertion"
    case filterindex = "KFilterIndex"
    case filtertype = "KFilterType"
    case lessonEntryCategory = "KLessonEntryCategory"
    case correct = "KCorrect"
    case incorrect = "KIncorrect"
    case istitle = "KIstitle"
}

extension LessonEntryType: CaseIterable {}

extension LessonEntry {
    enum LessonDictionaryKey {
        static let burmese  = "Burmese"
        static let english  = "English"
        static let roman    = "Roman"
        static let lesson   = "Lesson"
        static let lessonEntryIndex = "lessonEntryIndex"
        static let category = "category"
        static let categoryindex = "categoryIndex"
        static let insertion = "insertion"
        static let filterindex = "filterIndex"
        static let filtertype = "filterType"
        static let lessonEntryCategory = "lessonEntryCategory"
        static let correct = "Correct"
        static let incorrect = "Incorrect"
        static let istitle = "isTitle"
    }
}

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
    
    var burmese: String? {
        didSet(oldValue) {
            if oldValue != self.burmese {
                self.setEdited()
            }
        }
    }
    
    var roman: String? {
        didSet(oldValue) {
            if oldValue != self.roman {
                self.setEdited()
            }
        }
    }
    var english: String? {
        didSet(oldValue) {
            if oldValue != self.english
            {
                self.setEdited()
            }
        }
    }
    var lesson: String? {
        didSet(oldValue) {
            if oldValue != self.lesson {
                self.setEdited()
                if let lesson = self.lesson {
                    NotificationCenter.default.post(name: .increaseLessonCount,
                                                    object: nil,
                                                    userInfo: [UserInfo.Keys.lesson : lesson])
                }
                if oldValue != nil {
                    NotificationCenter.default.post(name: .decreaseLessonCount,
                                                        object: nil,
                                                        userInfo: [UserInfo.Keys.lesson : oldValue!])
                }
                print("Posting start populate lessons in var")
                NotificationCenter.default.post(name: .startPopulateLessonsPopup, object: nil)
            }
        }
    }
    
    var lessonEntryIndex: String?
    var category: String? {
        didSet(oldValue) {
            if oldValue != self.category {
                self.setEdited()
            }
        }
    }
    var categoryindex: String?
    var insertion: String?
    var filterindex: Int?
    var filtertype: LessonEntryFilterType?
    var lessonEntryCategory: String? {
        didSet(oldValue) {
            setEdited()
        }
    }
    var correct:   String?
    var incorrect: String?
    var unfilteredRow: Int?
    var filtered: Bool = false
    var istitle: Bool = false
    
    func unwrapped(_ lessonEntry: Any?)->String {
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
    
    func encode(with aCoder: NSCoder) {
        LessonEntryType.allCases.forEach {
            let key = $0.rawValue
            if let encodeString = self.lessonEntryForKey(key) {
                if [LessonEntryType.filtertype.rawValue, LessonEntryType.filterindex.rawValue].contains(key) {
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
    
    func setEdited() {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .dataSourceNeedsSaving, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        let istitleToDecode = false
        
        LessonEntryType.allCases.forEach {
            let key = $0.rawValue
            if let decodedValue = aDecoder.decodeObject(forKey: key) as? String {
                switch key {
                case LessonEntryType.burmese.rawValue:
                    burmeseToDecode = decodedValue
                case LessonEntryType.roman.rawValue:
                    romanToDecode = decodedValue
                case LessonEntryType.english.rawValue:
                    englishToDecode = decodedValue
                case LessonEntryType.lesson.rawValue:
                    lessonToDecode = decodedValue
                case LessonEntryType.lessonEntryIndex.rawValue:
                    lessonEntryindexToDecode = decodedValue
                case LessonEntryType.category.rawValue:
                    categoryToDecode = decodedValue
                case LessonEntryType.categoryindex.rawValue:
                    categoryindexToDecode = decodedValue
                case LessonEntryType.insertion.rawValue:
                    insertionToDecode = decodedValue
                case LessonEntryType.lessonEntryCategory.rawValue:
                    lessonEntrycategoryToDecode = decodedValue
                case LessonEntryType.correct.rawValue:
                    correctToDecode = decodedValue
                case LessonEntryType.incorrect.rawValue:
                    incorrectToDecode = decodedValue
                case LessonEntryType.filtertype.rawValue:
                    if let intValue = Int(decodedValue) {
                        filtertypeToDecode = intValue
                    }
                case LessonEntryType.filterindex.rawValue:
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
    
    override func copy() -> Any {
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
                //self.lessonEntryKeys["KLessonEntryIndex"] = self.lessonEntryindex as AnyObject
            case "category":
                self.category = lessonEntryDictionary[key]
                //self.lessonEntryKeys["KCategory"] = self.category as AnyObject
            case "lessonEntryCategory":
                self.category = lessonEntryDictionary[key]
                //self.lessonEntryKeys["KLessonEntryCategory"] = self.category as AnyObject
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
    
    override convenience init() {
        self.init(burmese: "", english: "", roman: "")
    }
    
    init(burmese: String, english: String, roman: String) {
        self.burmese = burmese
        self.english = english
        self.roman = roman
    }
}
