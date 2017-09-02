//
//  MWebcamView.swift
//  Monique
//
//  Created by Shavit Tzuriel on 9/2/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import Cocoa

class MWebcamView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override var mouseDownCanMoveWindow: Bool {
        get {
            return true
        }
    }
}
