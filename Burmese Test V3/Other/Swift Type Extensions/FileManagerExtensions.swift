//
//  FileManagerExtensions.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 04/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation

extension FileManager
{
    func isDir(_ url: URL) -> Bool {
        var isDirectory : ObjCBool = ObjCBool(false)
        let _ = self.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
}
