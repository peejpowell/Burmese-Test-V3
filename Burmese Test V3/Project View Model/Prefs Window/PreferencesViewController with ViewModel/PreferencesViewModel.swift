//
//  PreferencesViewModel.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 08/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Foundation
import Cocoa

private protocol PreferencesGeneralTab {
    
    func switchOpenMostRecent(_ state: NSControl.StateValue)
    
    func switchUseDelForCutBtn(_ stateIsOn: Bool)
    
    func switchUseDelForCut(_ state: NSControl.StateValue)
    
    func switchOpenMostRecentBtn(_ stateIsOn: Bool)
    
    func switchReIndexOnPaste(_ state: NSControl.StateValue)
    
    func switchReIndexOnPasteBtn(_ stateIsOn: Bool)
    
}

private protocol PreferencesTableTab {
    
    func updateHiddenColumnsBtns()
    
    func updateHiddenColumns()
    
}

private protocol PreferencesToUserDefaults {
    
    func loadPreferences()
    
    func writeArrayPref(for key: String, array: [String])
    
    func getBoolPref(for key: String)->Bool
    
    func getArrayPref(for key: String)->[String]
}

class PreferencesViewModel: NSObject {
    
    @IBOutlet private var prefsToolbarController : PrefsToolbarController!
    
    private var openMostRecentAtStart : Bool? {
        didSet(oldValue) {
            guard let openMostRecent = self.openMostRecentAtStart else { return }
            self.switchOpenMostRecentBtn(openMostRecent)
            UserDefaults.standard.set(openMostRecentAtStart, forKey: PreferencesKeys.OpenMostRecentAtStart.rawValue)
        }
    }
    private var useDelForCut : Bool? {
        didSet(oldValue) {
            guard let useDelForCut = self.useDelForCut else { return }
            self.switchUseDelForCutBtn(useDelForCut)
            UserDefaults.standard.set(useDelForCut, forKey: PreferencesKeys.UseDeleteForCut.rawValue)
        }
    }
    private var reIndexOnPaste : Bool? {
        didSet(oldValue) {
            guard let reIndexOnPaste = self.useDelForCut else { return }
            self.switchReIndexOnPasteBtn(reIndexOnPaste)
            UserDefaults.standard.set(reIndexOnPaste, forKey: PreferencesKeys.ReIndexOnPaste.rawValue)
        }
    }
    private var hiddenColumns : [String]? {
        didSet(oldValue) {
            updateHiddenColumnsBtns()
            updateHiddenColumns()
        }
    }
    var mostRecentIsEnabled : Bool {
        if let openMostRecent = self.openMostRecentAtStart {
            return openMostRecent
        }
        return false
    }
    var useDelIsEnabled : Bool {
        if let useDelForCut = self.useDelForCut {
            return useDelForCut
        }
        return false
    }
    var reIndexOnPasteIsEnabled : Bool {
        if let reIndexOnPaste = self.reIndexOnPaste {
            return reIndexOnPaste
        }
        return false
    }
    var controller : PreferencesViewController?
    
}

// MARK: Protocol: PreferencesGeneralTab
extension PreferencesViewModel: PreferencesGeneralTab {
    
    func switchOpenMostRecent(_ state: NSControl.StateValue) {
        self.openMostRecentAtStart = state == .on
    }
    
    func switchUseDelForCutBtn(_ stateIsOn: Bool) {
        controller?.useDelForCutBtn.setStateFromBool(stateIsOn)
    }
    
    func switchUseDelForCut(_ state: NSControl.StateValue) {
        self.useDelForCut = state == .on
    }
    
    func switchOpenMostRecentBtn(_ stateIsOn: Bool) {
        controller?.openMostRecentBtn.setStateFromBool(stateIsOn)
    }
    
    func switchReIndexOnPaste(_ state: NSControl.StateValue) {
        self.reIndexOnPaste = state == .on
    }
    
    func switchReIndexOnPasteBtn(_ stateIsOn: Bool) {
        controller?.reIndexOnPasteBtn.setStateFromBool(stateIsOn)
    }
    
}

// MARK: Protocol: PreferencesTableTab
extension PreferencesViewModel: PreferencesTableTab {
    
    fileprivate func updateHiddenColumnsBtns() {
        if let stackView = controller?.columnVisibilityStackView {
            // Find all the checkboxes
            for subview in stackView.subviews {
                for btn in subview.subviews{
                    if  let btn = btn as? NSButton,
                        let id = btn.identifier?.rawValue,
                        let hiddenColumns = self.hiddenColumns {
                        if hiddenColumns.contains(id.minus(5)) {
                            btn.state = .off
                        }
                        else {
                            btn.state = .on
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func updateHiddenColumns() {
        guard let hiddenColumns = self.hiddenColumns else { return }
        writeArrayPref(for: UserDefaults.Keys.HiddenColumns, array: hiddenColumns)
        NotificationCenter.default.post(name: .toggleColumn, object: nil, userInfo: [UserInfo.Keys.column : hiddenColumns])
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
    
    func toggleVisibility(for columnBtn: NSButton) {
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
    
}

// MARK: Protocol: PreferencesToUserDefaults
extension PreferencesViewModel : PreferencesToUserDefaults {
    
    func loadPreferences() {
        self.useDelForCut           = getBoolPref(for: UserDefaults.Keys.UseDeleteForCut)
        self.openMostRecentAtStart  = getBoolPref(for: UserDefaults.Keys.OpenMostRecentAtStart)
        self.reIndexOnPaste         = getBoolPref(for: UserDefaults.Keys.ReIndexOnPaste)
        self.hiddenColumns          = getArrayPref(for: UserDefaults.Keys.HiddenColumns)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if let hiddenColumns = self.hiddenColumns {
                NotificationCenter.default.post(name: .toggleColumn, object: nil, userInfo: [UserInfo.Keys.column : hiddenColumns])
            }
        }
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
