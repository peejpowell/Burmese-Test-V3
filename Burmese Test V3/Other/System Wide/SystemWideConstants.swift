//
//  SystemWideConstants.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 08/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

typealias UserInfo = String

enum SortKeys: String {
    case Burmese    = "KBurmese"
    case Roman      = "KRoman"
    case English    = "KEnglish"
    case Lesson     = "KLesson"
    case Category   = "KCategory"
}

enum PreferencesKeys : String {
    case UseDeleteForCut = "UseDelForCut"
    case OpenMostRecentAtStart = "OpenMostRecentAtStart"
    case ReIndexOnPaste = "ReIndexOnPaste"
    case HiddenColumns = "HiddenColumns"
}
