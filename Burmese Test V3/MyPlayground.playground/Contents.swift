import Cocoa

var str = "Hello, playground.  This is a test to see where the last space is."

enum Test : String {
    static let test = "1"
    case test2 = "2"
}

extension Test: CaseIterable {}

for item in Test.allCases {
    print("\(item)")
}
