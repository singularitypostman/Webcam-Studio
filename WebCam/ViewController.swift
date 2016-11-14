//
//  ViewController.swift
//  WebCam
//
//  Created by Shavit Tzuriel on 10/18/16.
//  Copyright © 2016 Shavit Tzuriel. All rights reserved.
//

import Cocoa
import AVKit
import AVFoundation
import CoreMedia

class ViewController: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var webcam:AVCaptureDevice? = nil
    var videoOutput:AVCaptureVideoDataOutput? = nil
    var videoSession:AVCaptureSession? = nil
    let videoFileOutput:AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer? = nil
    
    var sessionReady:Bool = true
    
    let stream: Stream = Stream()
    
    @IBOutlet weak var playerPreview:NSView?
    @IBOutlet weak var playerStreamView:AVPlayerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        videoOutput = AVCaptureVideoDataOutput()
        videoSession = AVCaptureSession()
//        videoPreviewLayer = AVCaptureVideoPreviewLayer()
//        playerPreview = NSView()
        
        playerStreamView = AVPlayerView()
    }
    
    override func viewWillAppear() {
        self.setVideoSession()
    }
    
    override func viewDidAppear() {
        // Start playing
        let streamURL:NSURL = NSURL(string: "rtmp://localhost:3001/live/1")!
        let asset = AVAsset.init(url: streamURL as URL)
        let player:AVPlayerItem = AVPlayerItem(asset: asset)
        
        playerStreamView?.player = AVPlayer(playerItem: player)
        playerStreamView?.player?.play()
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
//        print("---> Streaming now")
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
//        print("---> Streaming (end?)")
        print(sampleBuffer)
        print(CMSampleBufferGetImageBuffer(sampleBuffer))
        
//        stream.broadcast(message: "Message from camera")

    }

    @IBAction func CaptureWebCamVideo(_ sender: AnyObject) {
        if (sessionReady == false){
            // Stop the session
            videoPreviewLayer?.session.stopRunning()
            sessionReady = !sessionReady
            return
        }
        
        // Start the session
        videoPreviewLayer?.session.startRunning()
        
        // Set the camera state
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
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: videoSession)
                // resize the video to fill
                videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                videoPreviewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                
                // position the layer
                videoPreviewLayer!.position = CGPoint(x: (self.playerPreview?.frame.width)!/2, y: (self.playerPreview?.frame.height)!/2)
                videoPreviewLayer!.bounds = (self.playerPreview?.frame)!
                
                // add the preview to the view
                playerPreview?.layer?.addSublayer(videoPreviewLayer!)
                
                // Output data
                if videoSession!.canAddOutput(videoOutput){
                    videoSession!.addOutput(videoOutput)
                }
                
                if videoSession!.canAddOutput(videoFileOutput){
                    videoSession!.addOutput(videoFileOutput)
                    
                    print("---> Video file output \(videoFileOutput)")
                }
                
                // Register the sample buffer callback
                let queue = DispatchQueue(label: "Streaming")
                videoOutput?.setSampleBufferDelegate(self, queue: queue)

                
                
            }
            
        }
        catch {
            print("---> Cannot use webcam")
        }
        
    }

}

