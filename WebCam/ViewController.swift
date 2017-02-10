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


class ViewController: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
    var webcam:AVCaptureDevice? = nil
    var videoOutput:AVCaptureVideoDataOutput? = nil
    var audioOutput:AVCaptureAudioDataOutput? = nil
    var videoSession:AVCaptureSession? = nil
    var videoPreviewLayer:AVCaptureVideoPreviewLayer? = nil
    var videoFilePath: URL? = nil
    
    var sessionReady:Bool = true
    var detectionBoxView: NSView?
    
    let videoWriterQueue: DispatchQueue = DispatchQueue(label: "videoWriter")
    
    var avAsset: AVAsset? = nil
    var avAssetWriter: AVAssetWriter? = nil
    var avAssetWriterInput: AVAssetWriterInput? = nil
    
    let cmTimeScale: Int32 = 1000000000
    var currentRecordingTime: Int64 = 0
    
    let stream: Stream = Stream()
    
    @IBOutlet weak var playerPreview:NSView?
    @IBOutlet weak var videoPlayerView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        videoOutput = AVCaptureVideoDataOutput()
        audioOutput = AVCaptureAudioDataOutput()
        
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
        currentRecordingTime = Int64(CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds)
        let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        _ = CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let imageWidth: size_t = CVPixelBufferGetWidth(imageBuffer)
        let imageHeight: size_t = CVPixelBufferGetHeight(imageBuffer)
        let bytes: size_t = CVPixelBufferGetBytesPerRow(imageBuffer)
        let image = CVPixelBufferGetBaseAddress(imageBuffer)
        
        // Perform core animation in the main thread
        //        DispatchQueue.main.async {
        // Detect the image
        //self.detectLiveImage(picture: imageBuffer)
        //        }
        
        // Unlock the buffer
        //CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // Write to a file from NSData for debugging
        let imageData: NSData = NSData(bytes: image, length: (bytes * imageHeight))
        let videoFileDirectory: URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0], isDirectory: true).appendingPathComponent("Webcam")
        let dataOutputFile: URL = URL(fileURLWithPath: videoFileDirectory.path.appending("/session_2.mp4"))
        imageData.write(to: dataOutputFile, atomically: true)
        
        // Send the live image to the server
        stream.broadcastData(message: imageData)
        
        // Audio
        //print(CMSampleBufferGetFormatDescription(sampleBuffer))
        
        // Append to the asset writer input
        videoWriterQueue.async {
            self.avAssetWriterInput?.append(sampleBuffer)
        }
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
        if (self.sessionReady == false){
            // Stop the session
            videoPreviewLayer?.session.stopRunning()
            sessionReady = !sessionReady
            
            
            // Not needed
            //let cmTime: CMTime = CMTimeMake(currentRecordingTime, cmTimeScale)
            //self.avAssetWriter?.endSession(atSourceTime: cmTime)
            self.avAssetWriter?.finishWriting {
                print("---> Finish writing")
            }
            
            print("---> Stopping camera session")
            
            return
        }
        
        print("---> Starting camera session")
        // Set the writer
        // It can be only use once
        createWriter()
        
        // Start the session
        videoPreviewLayer?.session.startRunning()
        
        // Start the writing session
        self.avAssetWriter?.startWriting()
        let cmTime: CMTime = CMTimeMake(currentRecordingTime, cmTimeScale)
        self.avAssetWriter?.startSession(atSourceTime: cmTime)
        
        // Set the camera state
        self.sessionReady = !sessionReady
        
    }
    
    
    func setVideoSession(){
        // Web cameras
        //let devices = AVCaptureDevice.devices(withMediaType: "AVCaptureDALDevice")
        // Microphone
        // let devices = AVCaptureDevice.devices(withMediaType: "AVCaptureHALDevice")
        
        let videoFileDirectory: URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0], isDirectory: true).appendingPathComponent("Webcam")
        print("---> Create directory at path \(videoFileDirectory.path)")
        
        do {
            try FileManager.default.createDirectory(atPath: videoFileDirectory.path, withIntermediateDirectories: true, attributes: nil)
        } catch let err as NSError {
            print("Error creating a directory for the output file \(err)")
        }
        self.videoFilePath = URL(fileURLWithPath: videoFileDirectory.path.appending("/session_1.mp4"))
        
        // Set the writer
        //createWriter()
        
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        // Pick the first one
        if (devices?.count)! > 0 {
            webcam = devices?[0] as? AVCaptureDevice
        } else{
            print("---> No available devices")
            return
        }
        
        do {
            let webcamInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: webcam)
            if videoSession!.canAddInput(webcamInput){
                videoSession!.addInput(webcamInput)
            }
            
        }
        catch {
            print("---> Cannot use webcam")
        }
        
        //                videoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_420YpCbCr8PlanarFullRange)]
        videoOutput!.alwaysDiscardsLateVideoFrames = true
        
        // Register the sample buffer callback
        let videoOutputQueue = DispatchQueue(label: "WebcamVideo")
        videoOutput!.setSampleBufferDelegate(self, queue: videoOutputQueue)
        
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
        
//        audioOutput?.audioSettings = [
//            AVSampleRateKey: 44100,
//            AVFormatIDKey: kAudioFormatLinearPCM,
//            AVNumberOfChannelsKey: 2,
//            AVLinearPCMBitDepthKey: 16,
//            AVLinearPCMIsNonInterleaved: false,
//            AVLinearPCMIsBigEndianKey: false,
//            AVLinearPCMIsFloatKey: false
//        ]
        let audioOutputQueue = DispatchQueue(label: "WebcamAudio")
        audioOutput?.setSampleBufferDelegate(self, queue: audioOutputQueue)
        
        // Output data
        if videoSession!.canAddOutput(videoOutput){
            videoSession!.addOutput(videoOutput)
        }
        if videoSession!.canAddOutput(audioOutput){
            videoSession!.addOutput(audioOutput)
        }
        
    }
    
    private func createWriter(){
        
        let numPixels: Float64 = 480*320
        //let bitsPerPixel: Float64 = 10.1
        let bitsPerPixel: Float64 = 4
        let bitsPerSecond: Float64 = numPixels * bitsPerPixel
        let avAssetWriterInputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: 480,
            AVVideoHeightKey: 320,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: bitsPerSecond,
                AVVideoExpectedSourceFrameRateKey: 30,
                AVVideoMaxKeyFrameIntervalKey: 30
            ]
        ]
        avAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: avAssetWriterInputSettings)
        // Set it to true, to ensure that readyForMoreMediaData is calculated appropriatley
        avAssetWriterInput?.expectsMediaDataInRealTime = true
        
        do {
            self.avAssetWriter = try AVAssetWriter(outputURL: videoFilePath!, fileType: AVFileTypeMPEG4)
            if self.avAssetWriter!.canAdd(avAssetWriterInput!) {
                print("---> Adding input to AVAsset at \(videoFilePath!.path)")
                self.avAssetWriter!.add(avAssetWriterInput!)
            }
            
        } catch let err as NSError {
            print("Error initializing AVAssetWriter: \(err)")
        }
    }
    
}
