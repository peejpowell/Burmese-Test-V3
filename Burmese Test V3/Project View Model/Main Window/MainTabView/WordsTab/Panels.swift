//
//  Panels.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 01/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class Panels: NSObject {

    var openBMTDocPanel : NSOpenPanel {
        let newOpenPanel = NSOpenPanel()
        newOpenPanel.canChooseFiles = true
        newOpenPanel.canChooseDirectories = true
        newOpenPanel.canCreateDirectories = true
        newOpenPanel.allowsMultipleSelection = true
        newOpenPanel.prompt = "Select"
        return newOpenPanel
    }
    
    var saveDocumentPanel : NSSavePanel {
        let saveDocumentPanel = NSSavePanel()
        saveDocumentPanel.canCreateDirectories = true
        //saveDlg.setDirectory(self.prefs.filePath)
        saveDocumentPanel.allowedFileTypes = ["bmt"]
        saveDocumentPanel.allowsOtherFileTypes = false
        return saveDocumentPanel
    }
    
}
