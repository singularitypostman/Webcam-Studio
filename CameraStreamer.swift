//
//  CameraStreamer.swift
//  WebCam
//
//  Created by Shavit Tzuriel on 3/2/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import Cocoa

class CameraStreamer: NSViewController {
    
    let btnStream: NSButton = NSButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    private func setupView(){
        // Main view
        view.wantsLayer = true
        view.layer?.borderWidth = 4
        view.layer?.borderColor = NSColor.darkGray.cgColor
        
        // Button
        //btnStream.layer?.backgroundColor = NSColor.white.cgColor
        view.addSubview(btnStream)
        btnStream.translatesAutoresizingMaskIntoConstraints = false
        btnStream.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnStream.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        btnStream.widthAnchor.constraint(equalToConstant: 120)
        btnStream.heightAnchor.constraint(equalToConstant: 32)
    }
    
}
