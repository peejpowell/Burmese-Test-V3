//
//  NSButtonExtensions.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 08/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

extension NSButton {
    func setStateFromBool(_ boolValue: Bool?) {
        if let boolValue = boolValue {
            switch boolValue {
            case true:
                self.state = .on
            case false:
                self.state = .off
            }
        }
    }
}
