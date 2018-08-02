//
//  WordsTabViewModel.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 02/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation

class WordsTabViewModel {
 
    var fileManager : BMTFileManager?
    var removingFirstItem : Bool = false
    
    /**
     Holds the currently open files. When changed saves to userdefaults.
     */
    private(set) var openFiles = [URL]()
    
}

extension WordsTabViewModel {
    
    func updateOpenFilesPref() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self.openFiles)
        UserDefaults.standard.set(data, forKey: "OpenFiles")
    }
    
    func addOpenFile(_ fileUrl: URL) {
        self.openFiles.append(fileUrl)
        updateOpenFilesPref()
    }
    
    func removeOpenFile(at index: Int) {
        self.openFiles.remove(at: index)
        updateOpenFilesPref()
    }
}
