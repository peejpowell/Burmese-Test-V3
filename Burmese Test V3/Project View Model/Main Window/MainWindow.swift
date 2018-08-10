//
//  PJWindow.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 01/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class MainWindow: NSWindow, NSDraggingDestination {

    @IBAction override func performClose(_ sender: Any?) {
        infoPrint("", #function, self.className)
        NotificationCenter.default.post(name: .closeDocument, object: nil)
    }
    
    @IBAction override func performTextFinderAction(_ sender: Any?) {
        infoPrint("", #function, self.className)
        guard let sender = sender else { return }
        // Sends message to select the Lessons Tab
        NotificationCenter.default.post(name: .selectLessonsTab, object:nil, userInfo: [UserInfo.Keys.any:sender as Any])
    }
    
    override func awakeFromNib() {
        infoPrint("", #function, self.className)
        super.awakeFromNib()
        registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        infoPrint("", #function, self.className)
        let sourceDragMask = sender.draggingSourceOperationMask
        let pboard = sender.draggingPasteboard
        if pboard.availableType(from: [NSPasteboard.PasteboardType.fileURL]) == NSPasteboard.PasteboardType.fileURL {
            if sourceDragMask.rawValue & NSDragOperation.generic.rawValue != 0 {
                return NSDragOperation.generic
            }
        }
        return []
    }
    
    func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        infoPrint("", #function, self.className)
        return NSDragOperation.generic
    }
    
    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        infoPrint("", #function, self.className)
        return true
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        infoPrint("", #function, self.className)
        // ... perform your magic
        // return true/false depending on success
        let pasteboard = sender.draggingPasteboard
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) {
            var fileUrls : [URL] = []
            for fileUrl in urls {
                if let fileUrl = fileUrl as? URL {
                    fileUrls.append(fileUrl)
                }
            }
            NotificationCenter.default.post(name: .loadRequestedFromDrag, object: nil, userInfo: [UserInfo.Keys.urls:fileUrls])
        }
        return false
    }
}
