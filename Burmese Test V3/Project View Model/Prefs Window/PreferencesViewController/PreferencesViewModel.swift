//
//  PreferencesViewModel.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 08/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

private protocol PreferencesToUserDefaults {
    
    func loadPreferences()
    
    func writeArrayPref(for key: String, array: [String])
    
    func getBoolPref(for key: String)->Bool
    
    func getArrayPref(for key: String)->[String]
}

class PreferencesViewModel: NSObject {
    
    @IBOutlet private var prefsToolbarController : PrefsToolbarController!
    var controller : PreferencesViewController?
    
    var mostRecentIsEnabled : Bool {
        if let openMostRecent = self.openMostRecentAtStart {
            return openMostRecent
        }
        return false
    }
    
    private var openMostRecentAtStart : Bool? {
        didSet(oldValue) {
            guard let openMostRecent = self.openMostRecentAtStart else { return }
            if openMostRecent {
                enableOpenMostRecent()
            }
            else {
                disableOpenMostRecent()
            }
            UserDefaults.standard.set(openMostRecentAtStart, forKey: PreferencesKeys.OpenMostRecentAtStart.rawValue)
        }
    }
    
    private var useDelForCut : Bool? {
        didSet(oldValue) {
            guard let useDelForCut = self.useDelForCut else { return }
            if useDelForCut {
                enableUseDelForCut()
            }
            else {
                disableUseDelForCut()
            }
            UserDefaults.standard.set(useDelForCut, forKey: PreferencesKeys.UseDeleteForCut.rawValue)
        }
    }
    
    private var reIndexOnPaste : Bool? {
        didSet(oldValue) {
            guard let reIndexOnPaste = self.useDelForCut else { return }
            if reIndexOnPaste {
                enableReIndexOnPaste()
            }
            else {
                disableReIndexOnPaste()
            }
            UserDefaults.standard.set(reIndexOnPaste, forKey: PreferencesKeys.ReIndexOnPaste.rawValue)
        }
    }
    
    private var hiddenColumns : [String]? {
        didSet(oldValue) {
            updateHiddenColumns()
        }
    }
    
    private func updateHiddenColumns() {
        guard let hiddenColumns = self.hiddenColumns else { return }
        writeArrayPref(for: UserDefaults.Keys.HiddenColumns, array: hiddenColumns)
        NotificationCenter.default.post(name: .toggleColumn, object: nil, userInfo: [UserInfo.Keys.column : hiddenColumns])
    }
    
    func enableOpenMostRecent() {
        controller?.openMostRecentBtn.state = .on
    }
    
    func disableOpenMostRecent() {
        controller?.openMostRecentBtn.state = .off
    }
        
    func enableUseDelForCut() {
        controller?.useDelForCutBtn.state = .on
    }
    
    func disableUseDelForCut() {
        controller?.useDelForCutBtn.state = .off
    }
    
    func enableReIndexOnPaste() {
        controller?.reIndexOnPasteBtn.state = .on
    }
    
    func disableReIndexOnPaste() {
        controller?.reIndexOnPasteBtn.state = .off
    }
    
    func initialiseColumnVisibility () {
        infoPrint("", #function, "\(self)")
        guard let controller = self.controller else { return }
        if let view = controller.prefsTabView.tabViewItem(at: 1).view {
            for view in view.subviews {
                if  let btn = view as? NSButton,
                    let checkId = btn.identifier?.rawValue {
                    let checkBtnName = checkId.minus(5)
                    if self.hiddenColumns != nil {
                        if self.hiddenColumns!.contains(checkBtnName) {
                            btn.state = .off
                        }
                    }
                }
            }
        }
    }
    
    func didToggleVisibility(for columnBtn: NSButton) {
        infoPrint("", #function, "\(self)")
        guard let BtnId = columnBtn.identifier?.rawValue    else { return }
        guard let hiddenColumns = self.hiddenColumns        else { return }
        let btnName = BtnId.minus(5)
        switch columnBtn.state {
        case .on:
            let removedId = hiddenColumns.filter { (columnName) -> Bool in
                columnName != btnName
            }
            self.hiddenColumns = removedId
        case .off:
            if !hiddenColumns.contains(btnName) {
                self.hiddenColumns!.append(btnName)
            }
        default:
            break
        }
    }
    
    override init() {
        super.init()
    }
}

extension PreferencesViewModel : PreferencesToUserDefaults {
    
    func loadPreferences() {
        self.useDelForCut           = getBoolPref(for: UserDefaults.Keys.UseDeleteForCut)
        self.openMostRecentAtStart  = getBoolPref(for: UserDefaults.Keys.OpenMostRecentAtStart)
        self.reIndexOnPaste         = getBoolPref(for: UserDefaults.Keys.ReIndexOnPaste)
        self.hiddenColumns          = getArrayPref(for: UserDefaults.Keys.HiddenColumns)
    }
    
    fileprivate func writeArrayPref(for key: String, array: [String]) {
        let userDefaults = UserDefaults.standard
        if let hiddenColumns = hiddenColumns {
            userDefaults.setValue(hiddenColumns, forKey: key)
        }
    }
    
    fileprivate func getBoolPref(for key: String)->Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.bool(forKey: key)
    }
    
    fileprivate func getArrayPref(for key: String)->[String] {
        let userDefaults = UserDefaults.standard
        if let array = userDefaults.array(forKey: key) as? [String] {
            return array
        }
        return []
    }
}
