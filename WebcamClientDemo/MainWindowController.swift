//
//  MainWindowController.swift
//  WebcamClientDemo
//
//  Copyright © 2019 All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    @IBOutlet var mainWindow: NSWindow!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        mainWindow.isMovableByWindowBackground = true
        mainWindow.titlebarAppearsTransparent = true
    }
}
