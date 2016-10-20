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
    
    var sessionReady:Bool = true
    
    @IBOutlet weak var playerPreview:NSView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        videoOutput = AVCaptureVideoDataOutput()
        videoSession = AVCaptureSession()
//        videoPreviewLayer = AVCaptureVideoPreviewLayer()
//        playerPreview = NSView()
    }
    
    override func viewWillAppear() {
        self.setVideoSession()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func CaptureWebCamVideo(_ sender: AnyObject) {
        if (sessionReady == false){
            // Stop the session
            videoPreviewLayer?.session.stopRunning()
            sessionReady = !sessionReady
            print("---> Already capturing video")
            return
        }
        
        // Start the session
        videoPreviewLayer?.session.startRunning()
        print("---> Starting a new video session")
        
        sessionReady = !sessionReady
    }
    
    func setVideoSession(){
        // Web cameras
        //let devices = AVCaptureDevice.devices(withMediaType: "AVCaptureDALDevice")
        // Microphone
        // let devices = AVCaptureDevice.devices(withMediaType: "AVCaptureHALDevice")
        
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        // Pick the first one
        if (devices?.count)! > 0 {
            webcam = devices?[0] as? AVCaptureDevice
        } else{
            print("---> No available devices")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: webcam)
            if videoSession!.canAddInput(input){
                videoSession!.addInput(input)
                
                videoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_420YpCbCr8PlanarFullRange)]
                videoOutput!.alwaysDiscardsLateVideoFrames = true
                //videoOutput!.setSampleBufferDelegate(videoOutput!.sampleBufferDelegate, queue: dispatch_queue_create("VideoBuffer", DISPATCH_QUEUE_SERIAL))
                
                videoSession!.addOutput(videoOutput)
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: videoSession)
                // resize the video to fill
                videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                videoPreviewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                
                // position the layer
                videoPreviewLayer!.position = CGPoint(x: (self.playerPreview?.frame.width)!/2, y: (self.playerPreview?.frame.height)!/2)
                videoPreviewLayer!.bounds = (self.playerPreview?.frame)!
                
                // add the preview to the view
                playerPreview?.layer?.addSublayer(videoPreviewLayer!)
                
                let videoFileOutput:AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
                if videoSession!.canAddOutput(videoFileOutput){
                    videoSession!.addOutput(videoFileOutput)
                    
                    print("---> Video file output \(videoFileOutput)")
                }
            }
            
        }
        catch {
            print("---> Cannot use webcam")
        }
        
    }
    
    func startVideoSession(input: AVCaptureDeviceInput){
        // Need to initialize the session in a different function on start
        // This only need to start the session if ready
        if videoSession!.canAddInput(input){
            videoSession!.startRunning()
            
            // Stream to the server
            //let streamURL:NSURL = NSURL(string: "http://localhost:3000")!
            //let outputStream:OutputStream = OutputStream(url: streamURL as URL, append: true)!
            //outputStream.open()
        }
    }

}

