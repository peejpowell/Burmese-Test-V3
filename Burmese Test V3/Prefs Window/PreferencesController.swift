//
//  PreferencesController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 08/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

enum Preferences : String {
    case UseDeleteForCut = "UseDelForCut"
    case OpenMostRecentAtStart = "OpenMostRecentAtStart"
    case ReIndexOnPaste = "ReIndexOnPaste"
    case HiddenColumns = "HiddenColumns"
}

class PreferencesController: NSObject {
    
    var useDelForCut : Bool?
    var openMostRecentAtStart : Bool?
    var reIndexOnPaste : Bool?
    var hiddenColumns : [String]? {
        didSet(oldValue) {
            if let hiddenColumns = hiddenColumns {
                writeArrayPref(for: .HiddenColumns, array: hiddenColumns)
                //NotificationCenter.default.post(name: .columnVisibilityChanged, object: nil, userInfo: ["columnVisibilityChanged":hiddenColumns])
            }
        }
    }
    
    func writeArrayPref(for key: Preferences, array: [String]) {
        let userDefaults = UserDefaults.standard
        if let hiddenColumns = hiddenColumns {
            userDefaults.setValue(hiddenColumns, forKey: key.rawValue)
        }
    }
        
    func getBoolPref(for key: Preferences)->Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: key.rawValue)
    }
    
    func getArrayPref(for key: Preferences)->[String] {
        let userDefaults = UserDefaults.standard
        if let array = userDefaults.array(forKey: key.rawValue) as? [String] {
            return array
        }
        return []
    }
    
    func loadPreferences() {
        self.useDelForCut = getBoolPref(for: .UseDeleteForCut)
        self.openMostRecentAtStart = getBoolPref(for: .OpenMostRecentAtStart)
        self.reIndexOnPaste = getBoolPref(for: .ReIndexOnPaste)
        self.hiddenColumns = getArrayPref(for: .HiddenColumns)
    }
    
    override init() {
        super.init()
        // Read the values from the default Userpreferences
        loadPreferences()
    }
}
