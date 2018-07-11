import Cocoa

var str = "Hello, playground"

extension FileManager {
    
    /*func isDir(_ url:URL) -> Bool
     {
     // Is it a directory?
     do {
     let fileAttribs = try self.attributesOfItem(atPath: url.path)
     if let fileType : FileAttributeType = fileAttribs[FileAttributeKey.type] as? FileAttributeType {
     if fileType == FileAttributeType.typeDirectory {
     return true
     }
     }
     } catch let error {
     print(error)
     }
     return false
     }*/
    
    func isDir(_ url: URL) -> Bool {
        var isDirectory : ObjCBool = ObjCBool(false)
        let _ = self.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
}

extension URL {
    func pathToFile()->URL {
        let completePathArray = self.pathComponents
        var newPath : String = ""
        for pathNum in 0..<completePathArray.count-1 {
            var section = completePathArray[pathNum]
            section = section.replacingOccurrences(of: " ", with: "%20")
            switch section {
            case "/":
                break
            //newPath = "\(completePathArray[pathNum])"
            default:
                newPath = "\(newPath)/\(section)"
            }
        }
        if let url = URL(string: "\(newPath)/") {
            return url
        }
        return self
    }
}

var url = URL(string:"file:///Users/peejpowell/BMTFiles/Phil/BMT/di%20di/Di%20Di%20Lessons.bmt")!

var newurl = url.pathToFile()
newurl = url.deletingLastPathComponent()
let fileManager = FileManager()
fileManager.isDir(newurl)
newurl = url.deletingPathExtension()
url.deleteLastPathComponent()

"testé".folding(options: NSString.CompareOptions.diacriticInsensitive, locale: Locale.current as Locale)

