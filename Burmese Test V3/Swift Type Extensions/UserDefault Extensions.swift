//
//  UserDefaultExtensions.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 04/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum Keys {
        static let RecentFiles              = "RecentFiles"
        static let LanguageMenuItems        = "LanguageMenuItems"
        static let OpenMostRecentAtStart    = "OpenMostRecentAtStart"
        static let OpenFiles                = "OpenFiles"
        static let UseDeleteForCut          = "UseDelForCut"
        static let ReIndexOnPaste           = "ReIndexOnPaste"
        static let HiddenColumns            = "HiddenColumns"
    }
}

enum Preferences : String {
    case UseDeleteForCut = "UseDelForCut"
    case OpenMostRecentAtStart = "OpenMostRecentAtStart"
    case ReIndexOnPaste = "ReIndexOnPaste"
    case HiddenColumns = "HiddenColumns"
}
