//
//  FileManager.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 27/06/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

// MARK: Open File Functions

extension PJFileManager {
    enum OpenFileResponse : Int {
        case invalidNotBMT
        case invalidNotThere
        case validDir
        case validFile
    }
    
    
}

// MARK: Save File Functions

extension PJFileManager {
    
}

class PJFileManager : FileManager {
    
    func checkFileValidity(at fileUrl: URL)->OpenFileResponse{
        // If the url is a directory then return valid
        let alert = Alerts().warningAlert
        if !self.fileExists(atPath: fileUrl.path) {
            alert.messageText = "File does not exist.\n\(fileUrl.path)"
            alert.runModal()
            return .invalidNotThere
        }
        if self.isDir(fileUrl) {
            return .validDir
        }
        // try to load the file into an NSArray and show an error if we fail
        if NSArray(contentsOf: fileUrl) != nil {
            return .validFile
        }
        alert.messageText = "File is not a valid BMT file.\n\(fileUrl.path)"
        alert.runModal()
        return .invalidNotBMT
    }
    
    func convertToPlist(_ arrayToConvert: [Words])->[Dictionary<NSString, NSString>]
    {
        infoPrint("", #function, self.className)
        
        var convertedArray = [Dictionary<NSString, NSString>]()
        if arrayToConvert.count > 0 {
            let fieldNames : [String] = ["Burmese","Roman","English","Insertion","Lesson","wordIndex","categoryIndex","category","wordCategory","isTitle"]
            for item : Words in arrayToConvert {
                var convertDict = Dictionary<NSString,NSString>()
                let fieldValues = [item.burmese,item.roman,item.english,item.insertion,item.lesson,item.wordindex,item.categoryindex,item.category,item.wordcategory,"\(item.istitle)"]
                
                for fieldNum in 0 ..< fieldNames.count {
                    if fieldValues[fieldNum] != "" && fieldValues[fieldNum] != nil {
                        convertDict[fieldNames[fieldNum] as NSString] = fieldValues[fieldNum] as NSString?
                    }
                }
                convertedArray.append(convertDict)
            }
        }
        return convertedArray
    }
    
    func saveWordsToFile(_ fileURL: URL)->String
    {
        infoPrint("", #function, self.className)
        
        let index = getCurrentIndex()
        let wordsTabController = getWordsTabViewDelegate()
        switch index {
        case -1:
            break
        default:
            let dataSource = wordsTabController.dataSources[index]
            let pListToSave : [Dictionary<NSString, NSString>] = self.convertToPlist(dataSource.words)
            _ = PropertyListSerialization.propertyList(pListToSave, isValidFor: PropertyListSerialization.PropertyListFormat.binary)
            
            let plistData : Data?
            do {
                plistData = try PropertyListSerialization.data(fromPropertyList: pListToSave, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
                do {
                    try plistData!.write(to: fileURL, options: NSData.WritingOptions.atomicWrite)
                        wordsTabController.tabViewItems[index].label = fileURL.path.lastPathComponent
                    } catch let error as NSError {
                        print("Could not write \(error), \(error.userInfo)")
                        return "Failed to save file \(fileURL.path)"
                    }
            } catch let error as NSError {
                NSAlert(error: error).runModal()
                //plistData = nil
                return "Failed to save file \(fileURL.path)"
            }
        }
        return "Saved \(fileURL.path)"
    }
    
    override init() {
        super.init()
        infoPrint("Created new filemanager", #function, self.className)
    }
    
    deinit {
        infoPrint("Removed filemanager", #function, self.className)
    }
}
