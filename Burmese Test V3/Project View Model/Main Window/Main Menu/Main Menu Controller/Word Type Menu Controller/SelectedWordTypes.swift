//
//  SelectedWordTypes.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 04/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

class SelectedWordTypes : NSObject, NSCoding {
    var lessonName      : String = "" // Lesson name
    var selectedWords   : [String] = [String]() // Checked items in the list
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(lessonName, forKey: "KLessonName")
        aCoder.encode(selectedWords, forKey: "KSelectedWords")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.lessonName = aDecoder.decodeObject(forKey: "KLessonName") as! String
        self.selectedWords = aDecoder.decodeObject(forKey: "KSelectedWords") as! [String]
    }
    
    override init() {
        super.init()
    }
}
