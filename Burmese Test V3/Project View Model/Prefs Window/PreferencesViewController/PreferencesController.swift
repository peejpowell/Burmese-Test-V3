//
//  PreferencesController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 08/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class PreferencesController: NSObject {
    
    var useDelForCut : Bool?
    var openMostRecentAtStart : Bool?
    var reIndexOnPaste : Bool?
    var hiddenColumns : [String]? {
        didSet(oldValue) {
            if let hiddenColumns = hiddenColumns {
                writeArrayPref(for: UserDefaults.Keys.HiddenColumns, array: hiddenColumns)
            }
        }
    }
    
    override init() {
        super.init()
        loadPreferences()
    }
}

extension PreferencesController {
    
    func writeArrayPref(for key: String, array: [String]) {
        let userDefaults = UserDefaults.standard
        if let hiddenColumns = hiddenColumns {
            userDefaults.setValue(hiddenColumns, forKey: key)
        }
    }
        
    func getBoolPref(for key: String)->Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: key)
    }
    
    func getArrayPref(for key: String)->[String] {
        let userDefaults = UserDefaults.standard
        if let array = userDefaults.array(forKey: key) as? [String] {
            return array
        }
        return []
    }
    
    func loadPreferences() {
        self.useDelForCut           = getBoolPref(for: UserDefaults.Keys.UseDeleteForCut)
        self.openMostRecentAtStart  = getBoolPref(for: UserDefaults.Keys.OpenMostRecentAtStart)
        self.reIndexOnPaste         = getBoolPref(for: UserDefaults.Keys.ReIndexOnPaste)
        self.hiddenColumns          = getArrayPref(for: UserDefaults.Keys.HiddenColumns)
    }
    
}
