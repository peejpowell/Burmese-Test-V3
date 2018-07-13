import Cocoa

var str = "Hello, playground"

extension String {
    enum MinusLocation: Int {
        case front
        case back
    }
    
    func minus(_ upTo: Int)-> String {
        switch upTo >= 0 {
        case true:
            let lastIndex = self.index(self.endIndex, offsetBy: -upTo)
            let stringToReturn = self[..<lastIndex]
            return String(stringToReturn)
        case false:
            let newUpTo = -upTo
            let firstIndex = self.index(self.startIndex, offsetBy: newUpTo)
            let stringToReturn = self[firstIndex..<self.endIndex]
            return String(stringToReturn)
        }
    }
    
    func minus(_ upTo: Int, location: MinusLocation)-> String {
        switch location {
        case .front:
            let lastIndex = self.index(self.endIndex, offsetBy: -upTo)
            let stringToReturn = self[..<lastIndex]
            return String(stringToReturn)
        case .back:
            let firstIndex = self.index(self.startIndex, offsetBy: upTo)
            let stringToReturn = self[firstIndex..<self.endIndex]
            return String(stringToReturn)
        }
    }
    
    func left(_ to: Int)-> String {
        let lastIndex = self.index(self.startIndex, offsetBy: to)
        
        let stringToReturn = self[..<lastIndex]
        return String(stringToReturn)
    }
}

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

let testString = "<--KBurmeseCol-->"
testString.minus(3)
testString.minus(-3)




