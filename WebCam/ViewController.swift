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


class ViewController: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
    var webcam:AVCaptureDevice? = nil
    var videoOutput:AVCaptureVideoDataOutput? = nil
    var videoSession:AVCaptureSession? = nil
    var videoPreviewLayer:AVCaptureVideoPreviewLayer? = nil
    var videoFilePath: URL? = nil
    
    var sessionReady:Bool = true
    var detectionBoxView: NSView?
    
    let stream: Stream = Stream()
    
    var avAssetWriterInput: AVAssetWriterInput? = nil
    var avAsset: AVAsset? = nil
    var avAssetWriter: AVAssetWriter? = nil
    
    @IBOutlet weak var playerPreview:NSView?
    @IBOutlet weak var videoPlayerView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        videoOutput = AVCaptureVideoDataOutput()
        
        // Webcam session
        videoSession = AVCaptureSession()
        videoSession?.sessionPreset = AVCaptureSessionPresetHigh
        
        self.setVideoSession()
    }
    
    override func viewWillAppear() {
        // Use a m3u8 playlist of live video
        let streamURL:URL = URL(string: "http://localhost:3000//videos/live/playlist")!
        let player:AVPlayer = AVPlayer(url: streamURL)
        
        let playerView = AVPlayerView()
        playerView.frame = videoPlayerView.frame
        playerView.player = player
        videoPlayerView.addSubview(playerView)
        
        // Start streaming
        print("---> Playing video from \(streamURL.absoluteURL.absoluteString)")
        player.play()
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            print("---> Update the view if it was loaded")
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        _ = CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        //        let imageWidth: size_t = CVPixelBufferGetWidth(imageBuffer)
        let imageHeight: size_t = CVPixelBufferGetHeight(imageBuffer)
        let bytes: size_t = CVPixelBufferGetBytesPerRow(imageBuffer)
        let image = CVPixelBufferGetBaseAddress(imageBuffer)
        
        
        // Perform core animation in the main thread
        //        DispatchQueue.main.async {
        // Detect the image
        //self.detectLiveImage(picture: imageBuffer)
        //        }
        
        // Unlock the buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // Send the live image to the server
        let imageData: NSData = NSData(bytes: image, length: (bytes * imageHeight))
        stream.broadcastData(message: imageData)
        
        // Append to the asset writer input
        //self.avAssetWriterInput?.append(sampleBuffer)
        
        let res = imageData.write(to: self.videoFilePath!, atomically: true)
        print(res)
        
        //self.avAssetWriter?.startWriting()
    }
    
    
    /*!
     @method captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:
     @abstract
     Informs the delegate when all pending data has been written to an output file.
     
     @param captureOutput
     The capture file output that has finished writing the file.
     @param fileURL
     The file URL of the file that has been written.
     @param connections
     An array of AVCaptureConnection objects attached to the file output that provided the data that was written to the
     file.
     @param error
     An error describing what caused the file to stop recording, or nil if there was no error.
     
     @discussion
     This method is called when the file output has finished writing all data to a file whose recording was stopped,
     either because startRecordingToOutputFileURL:recordingDelegate: or stopRecording were called, or because an error,
     described by the error parameter, occurred (if no error occurred, the error parameter will be nil).  This method will
     always be called for each recording request, even if no data is successfully written to the file.
     
     Clients should not assume that this method will be called on a specific thread.
     
     Delegates are required to implement this method.
     */
    @available(OSX 10.7, *)
    public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        print("---> Finish recording to \(outputFileURL.absoluteString)")
        
        do {
            try FileManager.default.moveItem(at: outputFileURL, to: self.videoFilePath!)
        } catch let err as NSError {
            print("Error moving video file: \(err)")
        }
    }
    
    func detectLiveImage(picture: CVImageBuffer){
        
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: nil)
        let image: CIImage = CIImage(cvImageBuffer: picture)
        let features = detector?.features(in: image) // [CIFeature]
        
        print("---> Detecting")
        print("---> Image: \(image)")
        
        for ciFeature in features! {
            // Display a rectangle
            print("---> Features bounds: \(ciFeature.bounds)")
            detectionBoxView?.draw(ciFeature.bounds)
        }
    }
    
    @IBAction func CaptureWebCamVideo(_ sender: AnyObject) {
        if (sessionReady == false){
            // Stop the session
            videoPreviewLayer?.session.stopRunning()
            sessionReady = !sessionReady
            
            self.avAssetWriter?.cancelWriting()
            
            print("---> Stopping camera")
            
            return
        }
        
        // Start the session
        videoPreviewLayer?.session.startRunning()
        
        // Start the writing session
        let cmTime: CMTime = CMTime()
        self.avAssetWriter?.startSession(atSourceTime: cmTime)
        
        // Set the camera state
        sessionReady = !sessionReady
        
    }
    
    @IBAction func CaptureScreenVideo(_ sender: Any) {
        if (sessionReady == false){
            // Stop the session
            sessionReady = !sessionReady
            return
        }
        
        sessionReady = !sessionReady
    }
    
    
    func setVideoSession(){
        // Web cameras
        //let devices = AVCaptureDevice.devices(withMediaType: "AVCaptureDALDevice")
        // Microphone
        // let devices = AVCaptureDevice.devices(withMediaType: "AVCaptureHALDevice")
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.downloadsDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let videoFileDirectory = URL(fileURLWithPath: paths[0].appending("/WebCam"))
        self.videoFilePath = URL(fileURLWithPath: videoFileDirectory.path.appending("/session_1.mp4"))
        
        // Set the writer
        self.avAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: nil)
        self.avAssetWriterInput?.expectsMediaDataInRealTime = true
        do {
            self.avAssetWriter = try AVAssetWriter(outputURL: videoFilePath!, fileType: AVFileTypeMPEG4)
            //self.avAssetWriter?.add(self.avAssetWriterInput!)
        } catch let err as NSError {
            print("Error initializing AVAssetWriter: \(err)")
        }
        
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
                
                //                videoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_420YpCbCr8PlanarFullRange)]
                videoOutput!.alwaysDiscardsLateVideoFrames = true
                
                // Register the sample buffer callback
                let queue = DispatchQueue(label: "Streaming")
                videoOutput!.setSampleBufferDelegate(self, queue: queue)
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: videoSession)
                // resize the video to fill
                videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                videoPreviewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                
                // position the layer
                videoPreviewLayer!.position = CGPoint(x: (self.playerPreview?.frame.width)!/2, y: (self.playerPreview?.frame.height)!/2)
                videoPreviewLayer!.bounds = (self.playerPreview?.frame)!
                
                // add the preview to the view
                //                playerPreview?.layer?.addSublayer(videoPreviewLayer!)
                playerPreview?.layer? = videoPreviewLayer!
                
                // Add a detection box on top of the preview layer
                self.detectionBoxView = DetectionBoxView()
                playerPreview?.addSubview(self.detectionBoxView!)
                
                // Output data
                if videoSession!.canAddOutput(videoOutput){
                    videoSession!.addOutput(videoOutput)
                }
                
            }
            
        }
        catch {
            print("---> Cannot use webcam")
        }
        
    }
    
}
