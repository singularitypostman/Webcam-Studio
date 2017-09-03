//
//  ViewController.swift
//  Monique
//
//  Created by Shavit Tzuriel on 8/19/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import Cocoa

class MainViewController: NSSplitViewController {

    @IBOutlet var mStage: NSView!
    @IBOutlet var mWebcamLocalPreview: MWebcamLocalPreview!
    @IBOutlet var mBtnFaceDetection: NSButton!
    @IBOutlet var mBtnRecord: NSButton!
    
    @IBOutlet var mSidebar: NSView!
    @IBOutlet var mSidebarProfilePicture: NSImageView!
    @IBOutlet var mSidebarBottomPanel: NSView!
    @IBOutlet var mBtnStream: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let sidebarGradient = NSGradient(colors: [
            NSColor(calibratedRed: 0.09, green: 0.56, blue: 0.92, alpha: 1.0),
            NSColor(calibratedRed: 0.45, green: 0.93, blue: 1.00, alpha: 1.0)
            ])
        //sidebarGradient?.draw(in: mSidebar.bounds, angle: 90)
        mSidebar.layer?.backgroundColor = NSColor.red.cgColor
        
        mSidebarBottomPanel.layer?.backgroundColor = CGColor(red: 0.44, green: 0.63, blue: 0.73, alpha: 1.0)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    // Stream to server
    @IBAction func startStreaming(_ sender: Any){
        print("TODO: Video streaming is not implemented in this version")
    }
    
    // Record to local disk
    @IBAction func startRecording(_ sender: Any) {
        mWebcamLocalPreview.toggleRecording()
    }
    
    // Draw a square around the faces
    @IBAction func startFaceDetection(_ sender: Any){
        print("TODO: Face detection is not implemented in thie version")
    }
}

