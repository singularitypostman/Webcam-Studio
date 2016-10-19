//
//  ViewController.swift
//  WebCam
//
//  Created by Shavit Tzuriel on 10/18/16.
//  Copyright © 2016 Shavit Tzuriel. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
    var videoOutput:AVCaptureVideoDataOutput? = nil
    var videoSession:AVCaptureSession? = nil
    var videoPreviewLayer:AVCaptureVideoPreviewLayer? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear() {
//        let devices = AVCaptureDevice.devices(withMediaType: "AVMediaTypeVideo")
        let devices = AVCaptureDevice.devices()
        print("---> Devices")
        for device in devices!{
            print("---> Device \(device)")
            if (device as AnyObject).position == AVCaptureDevicePosition.back {
                // Trying to use the camera
                do {
                    let input = try AVCaptureDeviceInput(device: device as! AVCaptureDevice)
                    // Start the video session
                    //
                }
                catch {
                    print("---> Cannot use the camera")
                }
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func CaptureWebCamVideo(_ sender: AnyObject) {
        
    }

}

