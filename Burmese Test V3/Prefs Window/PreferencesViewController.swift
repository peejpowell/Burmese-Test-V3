//
//  PreferencesViewController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 08/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

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

extension Notification.Name {
    static var selectPrefsGeneralTab: Notification.Name {
        return .init(rawValue: "PreferencesViewController.selectGeneralTab")
    }
    
    static var selectPrefsTableTab: Notification.Name {
        return .init(rawValue: "PreferencesViewController.selectTableTab")
    }
}

class PreferencesViewController: NSViewController {

    @IBOutlet var prefsToolbarController : PrefsToolbarController!
    
    @IBOutlet weak var openMostRecentBtn: NSButton!
    @IBOutlet weak var useDelForCutBtn: NSButton!
    @IBOutlet weak var reIndexOnPasteBtn: NSButton!
    @IBOutlet var preferencesController: PreferencesController!
    @IBOutlet weak var prefsTabView : NSTabView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setPrefsFromLoadedPrefs()
        setInitialVisibilityButtonStates()
    }
    
    override func viewDidAppear() {
        createObservers()
        // Set defaults for table btns
        
    }
 
    override func viewDidDisappear() {
        infoPrint("Removing Observers", #function, self.className)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func createObservers() {
        infoPrint("Creating Observers", #function, self.className)
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectGeneralTab(_:)),
                                               name: .selectPrefsGeneralTab, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectTableTab(_:)),
                                               name: .selectPrefsTableTab, object: nil)
    }
}

// MARK: Notification Functions

extension PreferencesViewController {
    
    // MARK: Prefs Tabs
    
    @objc func selectGeneralTab(_ sender: NSToolbarItem) {
        infoPrint("", #function, self.className)
        self.prefsTabView.selectTabViewItem(at: 0)
        self.view.window?.title = "General"
    }
    
    @objc func selectTableTab(_ sender: NSToolbarItem) {
        infoPrint("", #function, self.className)
        self.prefsTabView.selectTabViewItem(at: 1)
        self.view.window?.title = "Table"
    }

    // MARK: General Tab

    @IBAction func toggleOpenMostRecent(_ sender: NSButton) {
        UserDefaults.standard.set(sender.state == .on, forKey: Preferences.OpenMostRecentAtStart.rawValue)
    }
    
    @IBAction func toggleUseDelForCut(_ sender: NSButton) {
        UserDefaults.standard.set(sender.state == .on, forKey: Preferences.UseDeleteForCut.rawValue)
    }
    
    @IBAction func toggleReIndexOnPaste(_ sender: NSButton) {
        UserDefaults.standard.set(sender.state == .on, forKey: Preferences.ReIndexOnPaste.rawValue)
    }
    // MARK: Table Tab

    func setInitialVisibilityButtonStates () {
        infoPrint("", #function, self.className)
        if let view = prefsTabView.tabViewItem(at: 1).view {
            for view in view.subviews {
                if  let btn = view as? NSButton,
                    let checkId = btn.identifier?.rawValue,
                    let checkBtnName = checkId.left(checkId.length() - 5){
                    if preferencesController.hiddenColumns != nil {
                        if preferencesController.hiddenColumns!.contains(checkBtnName) {
                            btn.state = .off
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func toggleColumnVisibilityBtn(_ sender: NSButton) {
        infoPrint("", #function, self.className)
        switch sender.state {
        case .on:
            if let checkId = sender.identifier?.rawValue {
                if let btnName = checkId.left(checkId.length()-5) {
                    if let hiddenColumns = preferencesController.hiddenColumns {
                        let removedId = hiddenColumns.filter { (someString) -> Bool in
                            someString != btnName
                        }
                        preferencesController.hiddenColumns = removedId
                        showColumnForBtn(sender)
                    }
                }
            }
        case .off:
            if let checkId = sender.identifier?.rawValue {
                if let btnName = checkId.left(checkId.length()-5) {
                    if let hiddenColumns = preferencesController.hiddenColumns {
                        if !hiddenColumns.contains(btnName) {
                            preferencesController.hiddenColumns!.append(btnName)
                            hideColumnForBtn(sender)
                        }
                    }
                }
            }
        default:
            break
        }
    }
    
    func hideColumnForBtn(_ button: NSButton) {
        infoPrint("", #function, self.className)
        if  let id = button.identifier?.rawValue,
            let btnName = id.left(id.length()-5) {
            NotificationCenter.default.post(name: .toggleColumn, object: nil, userInfo: ["HideColumn" : btnName])
        }
    }
    
    func showColumnForBtn(_ button: NSButton) {
        infoPrint("", #function, self.className)
        if  let id = button.identifier?.rawValue,
            let btnName = id.left(id.length()-5) {
            NotificationCenter.default.post(name: .toggleColumn, object: nil, userInfo: ["ShowColumn" : btnName])
        }
    }
}

extension PreferencesViewController {
    
    func setPrefsFromLoadedPrefs() {
        if let prefs = self.preferencesController {
            self.openMostRecentBtn.setStateFromBool(
                prefs.openMostRecentAtStart)
            self.useDelForCutBtn.setStateFromBool(
                prefs.useDelForCut)
            self.reIndexOnPasteBtn.setStateFromBool(
                prefs.reIndexOnPaste)
        }
    }
}
