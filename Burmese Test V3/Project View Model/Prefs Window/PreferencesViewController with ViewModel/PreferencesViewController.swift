//
//  PreferencesViewController.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 08/07/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    // MARK: Outlets
    @IBOutlet weak var openMostRecentBtn: NSButton!
    @IBOutlet weak var useDelForCutBtn: NSButton!
    @IBOutlet weak var reIndexOnPasteBtn: NSButton!
    @IBOutlet weak var prefsTabView : NSTabView!
    @IBOutlet weak var columnVisibilityStackView: NSStackView!
    
    @IBOutlet var preferencesViewModel : PreferencesViewModel!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        preferencesViewModel?.controller = self
        preferencesViewModel?.loadPreferences()
        preferencesViewModel?.initialiseColumnVisibility()
    }
    
    override func viewDidAppear() {
        createObservers()
    }
 
    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: General Tab
extension PreferencesViewController {
    
    @IBAction func toggleOpenMostRecent(_ sender: NSButton) {
        preferencesViewModel?.switchOpenMostRecent(sender.state)
    }
    
    @IBAction func toggleUseDelForCut(_ sender: NSButton) {
        preferencesViewModel?.switchUseDelForCut(sender.state)
    }
    
    @IBAction func toggleReIndexOnPaste(_ sender: NSButton) {
        preferencesViewModel?.switchReIndexOnPaste(sender.state)
    }
}

// MARK: Table Tab
extension PreferencesViewController {
    
    @IBAction func toggleColumnVisibilityBtn(_ sender: NSButton) {
        guard let preferencesViewModel = self.preferencesViewModel else { return }
        preferencesViewModel.toggleVisibility(for: sender)
        //preferencesViewModel.toggleColumnVisibilityBtn(sender)
    }
        
}
