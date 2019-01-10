//
//  MainWindowController.swift
//  Monique
//
//  Created by Shavit Tzuriel on 9/2/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    @IBOutlet var mainWindow: NSWindow!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        mainWindow.isMovableByWindowBackground = true
        mainWindow.titlebarAppearsTransparent = true
    }
}
