//
//  TISInputSourceExtensions.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 04/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Carbon

extension TISInputSource {
    
    var id: String {
        let unsafeID = TISGetInputSourceProperty(self, kTISPropertyInputSourceID).assumingMemoryBound(to: CFString.self)
        let name = Unmanaged<CFString>.fromOpaque(unsafeID).takeUnretainedValue()
        
        return name as String
    }
    
    var type: String {
        let unsafeID = TISGetInputSourceProperty(self, kTISPropertyInputSourceType).assumingMemoryBound(to: CFString.self)
        let name = Unmanaged<CFString>.fromOpaque(unsafeID).takeUnretainedValue()
        
        return name as String
    }
    
    var isEnabled: Bool {
        let unsafeIsEnabled = TISGetInputSourceProperty(self, kTISPropertyInputSourceIsEnabled).assumingMemoryBound(to: CFBoolean.self)
        let isEnabled = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(unsafeIsEnabled).takeUnretainedValue())
        
        return isEnabled
    }
    
    var isSelected: Bool {
        let unsafeIsSelected = TISGetInputSourceProperty(self, kTISPropertyInputSourceIsSelected).assumingMemoryBound(to: CFBoolean.self)
        let isSelected = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(unsafeIsSelected).takeUnretainedValue())
        
        return isSelected
    }
    
    var isEnableCapable: Bool {
        let unsafeIsEnableCapable = TISGetInputSourceProperty(self, kTISPropertyInputSourceIsEnableCapable).assumingMemoryBound(to: CFBoolean.self)
        let isEnableCapable = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(unsafeIsEnableCapable).takeUnretainedValue())
        
        return isEnableCapable
    }
    
    var isSelectCapable: Bool {
        let unsafeIsSelectCapable = TISGetInputSourceProperty(self, kTISPropertyInputSourceIsSelectCapable).assumingMemoryBound(to: CFBoolean.self)
        let isSelectCapable = CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(unsafeIsSelectCapable).takeUnretainedValue())
        
        return isSelectCapable
    }
    
    func enable() {
        if TISEnableInputSource(self) != noErr {
            print("Input source enabling failed. Source: \(self)")
        }
    }
    
    func disable() {
        if TISDisableInputSource(self) != noErr {
            print("Input source disabling failed. Source: \(self)")
        }
    }
    
    func select() {
        if TISSelectInputSource(self) != noErr {
            print("input selection failed")
        }
    }
}
