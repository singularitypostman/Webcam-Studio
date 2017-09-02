//
//  ViewController.swift
//  Monique
//
//  Created by Shavit Tzuriel on 8/19/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet var mWebcamLocalPreview: MWebcamLocalPreview!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

