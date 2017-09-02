//
//  ViewController.swift
//  Monique
//
//  Created by Shavit Tzuriel on 8/19/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet var mWebcamLocalPreview: MWebcamLocalPreviewContainer!
    @IBOutlet var mVideoPlayer: MVideoPlayerContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    // Record to local disk
    @IBAction func startRecording(_ sender: Any) {
        mWebcamLocalPreview.toggleRecording()
    }
}

