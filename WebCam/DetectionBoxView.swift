//
//  DetectionBoxView.swift
//  WebCam
//
//  Created by Shavit Tzuriel on 11/16/16.
//  Copyright © 2016 Shavit Tzuriel. All rights reserved.
//

import Cocoa

class DetectionBoxView: NSView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        self.layer?.backgroundColor = CGColor.clear
        self.layer?.borderColor = NSColor.orange.cgColor
        
//        self.layer?.frame.origin = dirtyRect.origin
//        self.layer?.frame.size = dirtyRect.size
        
        self.layer?.frame.origin.x = dirtyRect.origin.x / 4
        self.layer?.frame.origin.y = dirtyRect.origin.y / 2
        self.layer?.frame.size.width = dirtyRect.size.width / 2
        self.layer?.frame.size.height = dirtyRect.size.height / 2
        
        self.layer?.borderWidth = 4
    }
    
}
