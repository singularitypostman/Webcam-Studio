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
    
    var webcam:AVCaptureDevice? = nil
    var videoOutput:AVCaptureVideoDataOutput? = nil
    var videoSession:AVCaptureSession? = nil
    var videoPreviewLayer:AVCaptureVideoPreviewLayer? = nil
    
    @IBOutlet weak var playerPreview:NSView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        videoOutput = AVCaptureVideoDataOutput()
        videoSession = AVCaptureSession()
        videoPreviewLayer = AVCaptureVideoPreviewLayer()
        playerPreview = NSView()
    }
    
    override func viewWillAppear() {
        // Web cameras
        //let devices = AVCaptureDevice.devices(withMediaType: "AVCaptureDALDevice")
        // Microphone
        // let devices = AVCaptureDevice.devices(withMediaType: "AVCaptureHALDevice")
        
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        // Pick the first one
        if (devices?.count)! > 0 {
            webcam = devices?[0] as? AVCaptureDevice
        }
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func CaptureWebCamVideo(_ sender: AnyObject) {
        do {
            let input = try AVCaptureDeviceInput(device: webcam)
            startVideoSession(input: input)
            print("---> Sending device to session")
            
        }
        catch {
            print("---> Cannot use webcam")
        }
    }
    
    func startVideoSession(input: AVCaptureDeviceInput){
        if videoSession!.canAddInput(input){
            videoSession!.addInput(input)
            
            videoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_420YpCbCr8PlanarFullRange)]
            videoOutput!.alwaysDiscardsLateVideoFrames = true
            //videoOutput!.setSampleBufferDelegate(videoOutput!.sampleBufferDelegate, queue: dispatch_queue_create("VideoBuffer", DISPATCH_QUEUE_SERIAL))
            
            videoSession!.addOutput(videoOutput)
            videoSession!.startRunning()
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: videoSession)
            // resize the video to fill
            videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.portrait
            
            // position the layer
            //videoPreviewLayer!.position = CGPoint(x: self.videoPreviewLayer.frame.width/2, y: self.videoPreview.frame.height/2)
            //videoPreviewLayer!.bounds = self.videoPreview.frame
            
            // add the preview to the view
            //videoPreviewLayer!.layer.addSublayer(videoPreviewLayer)
            
            playerPreview?.layer?.addSublayer(videoPreviewLayer!)
            
        }
    }

}

