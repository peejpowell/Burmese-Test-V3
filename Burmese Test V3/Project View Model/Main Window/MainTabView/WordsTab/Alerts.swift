//
//  Alerts.swift
//  Burmese Test V3
//
//  Created by Philip Powell on 01/08/2018.
//  Copyright © 2018 Philip Powell. All rights reserved.
//

import Cocoa

class Alerts: NSObject {
    
    /**
     An alert for saving the file.
     */
    var saveAlert : NSAlert {
        let alert = NSAlert()
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Don't Save")
        return alert
    }
    
    /**
     An alert for reverting the file.
     */
    var revertFileAlert : NSAlert {
        let alert = NSAlert()
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "Revert")
        alert.addButton(withTitle: "Cancel")
        return alert
    }
    
    /**
     An alert for general warnings.
     */
    var warningAlert : NSAlert {
        let alert = NSAlert()
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        return alert
    }
}
