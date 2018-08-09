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
        
    }
}


extension PreferencesViewController {
    
}
