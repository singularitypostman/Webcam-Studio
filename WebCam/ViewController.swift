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
    let videoOutput:AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    let audioOutput:AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    let videoSession:AVCaptureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer? = nil
    var videoFilePath: URL? = nil
    
    var webcamSessionStarted:Bool = false
    var webcamSessionReady:Bool = false
    var detectionBoxView: NSView?
    var detectionBoxActive: Bool = false
    
    let webcamDetectionQueue: DispatchQueue = DispatchQueue(label: "webcamDetection")
    let webcamWriterQueue: DispatchQueue = DispatchQueue(label: "writer")
    let webcamAudioQueue: DispatchQueue = DispatchQueue(label: "webcamAudio")
    let videoStreamerQueue: DispatchQueue = DispatchQueue(label: "streamer")
    let videoPreviewQueue: DispatchQueue = DispatchQueue(label: "preview")
    let videoPlayerQueue: DispatchQueue = DispatchQueue(label: "player")
    
    var avAsset: AVAsset? = nil
    var avAssetWriter: AVAssetWriter? = nil
    var avAssetWriterInput: AVAssetWriterInput? = nil
    
    // Player
    let player:AVPlayer = AVPlayer()
    
    let cmTimeScale: Int32 = 1000000000
    var currentRecordingTime: Int64 = 0
    
    let stream: Stream = Stream()
    
    @IBOutlet weak var playerPreview:NSView!
    @IBOutlet weak var videoPlayerView: NSView!
    @IBOutlet weak var btnCaptureWebcam: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Webcam broadcast and preview
        self.setVideoSession()
        
        // Video player preview
        let playerView = AVPlayerView()
        playerView.frame = videoPlayerView.frame
        playerView.player = player
        videoPlayerView.addSubview(playerView)
        // Use a m3u8 playlist of live video
        //let streamURL:URL = URL(string: "http://localhost:3000/videos/live/playlist")!
        // Encode and stream
        let streamURL: URL = URL(string: "http://localhost:3000/playlists/1")!
        startPlaying(from: streamURL)
        
        // Create the video writer
        createWriter()
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
        // Unlock the buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))

        // Another write
        let imageWidth: size_t = CVPixelBufferGetWidth(imageBuffer)
        let imageHeight: size_t = CVPixelBufferGetHeight(imageBuffer)
        let bytes: size_t = CVPixelBufferGetBytesPerRow(imageBuffer)
        let image = CVPixelBufferGetBaseAddress(imageBuffer)
        // Write to a file from NSData for debugging
        let imageData: NSData = NSData(bytes: image, length: (bytes * imageHeight))
        let videoFileDirectory: URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0], isDirectory: true).appendingPathComponent("Webcam")
        let dataOutputFile: URL = URL(fileURLWithPath: videoFileDirectory.path.appending("/session_2.mp4"))
        imageData.write(to: dataOutputFile, atomically: true)
        
        // Send the live image to the server
        //stream.broadcastData(message: imageData)
        
        // Audio
        //print(CMSampleBufferGetFormatDescription(sampleBuffer))
        
        if webcamSessionReady == true {
            // Append to the asset writer input
            webcamWriterQueue.async {
                self.avAssetWriterInput?.append(sampleBuffer)
            }
        }
      
        
        // Detection
        if self.detectionBoxActive {
            startImageDetection(imageBuffer: imageBuffer)
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
    
    @IBAction func CaptureWebCamVideo(_ sender: AnyObject) {
        // Set the camera state
        webcamSessionReady = !webcamSessionReady
        
        // Not in session and there is data
        if (self.webcamSessionReady == true && webcamSessionStarted == true){
            // Not needed
            let cmTime: CMTime = CMTimeMake(currentRecordingTime, cmTimeScale)
            self.avAssetWriter?.endSession(atSourceTime: cmTime)
            print("---> Stopping camera session")
            self.avAssetWriter?.finishWriting {
                print("---> Finish writing")
            }
            btnCaptureWebcam.layer?.backgroundColor = NSColor.white.cgColor
            btnCaptureWebcam.title = "Ready"
            
            return
        }
        
        print("---> Starting camera session")
        webcamSessionStarted = true
        // Start the writing session
        let cmTime: CMTime = CMTimeMake(currentRecordingTime, cmTimeScale)
        avAssetWriter!.startSession(atSourceTime: cmTime)
        btnCaptureWebcam.layer?.backgroundColor = NSColor.red.cgColor
        btnCaptureWebcam.title = "Recording"
    }
    
    
    func setVideoSession(){
        // Set the device
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)!
        webcam = devices[0] as? AVCaptureDevice
        
        do {
            let webcamInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: webcam)
            if videoSession.canAddInput(webcamInput){
                videoSession.addInput(webcamInput)
                print("---> Adding webcam input")
            }
        } catch let err as NSError {
            print("---> Error using the webcam: \(err)")
        }
        // Webcam session
        videoSession.sessionPreset = AVCaptureSessionPresetHigh
        videoSession.addOutput(videoOutput)
        videoSession.addOutput(audioOutput)
        // Register the sample buffer callback
        videoOutput.setSampleBufferDelegate(self, queue: videoPreviewQueue)
        // Audio
        audioOutput.setSampleBufferDelegate(self, queue: webcamAudioQueue)
        // Preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: videoSession)
        // Attach the preview to the view
        playerPreview.layer = videoPreviewLayer
        // Resize the preview
        videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.portrait
        
        // Start the video preview session
        videoPreviewQueue.async {
            self.videoPreviewLayer!.session.startRunning()
        }
        
    }
    
    private func createWriter(){
        
        let videoFileDirectory: URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0], isDirectory: true).appendingPathComponent("Webcam")
        print("---> Create directory at path \(videoFileDirectory.path)")

        do {
            try FileManager.default.createDirectory(atPath: videoFileDirectory.path, withIntermediateDirectories: true, attributes: nil)
        } catch let err as NSError {
            print("Error creating a directory for the output file \(err)")
        }
        self.videoFilePath = URL(fileURLWithPath: videoFileDirectory.path.appending("/session_1.mp4"))
        
        // Video recording settings
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
                avAssetWriter!.add(avAssetWriterInput!)
            }
            
        } catch let err as NSError {
            print("Error initializing AVAssetWriter: \(err)")
        }
        
        // Need to be set once before starting the session
        avAssetWriter!.startWriting()
        
    }
    
    // Switch the state of the detection box
    @IBAction func startImageDetectionAction(_ sender: AnyObject){
        self.detectionBoxActive = !self.detectionBoxActive
    }
    
    // Image detection box
    private func startImageDetection(imageBuffer: CVImageBuffer){
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: nil)
        let image: CIImage = CIImage(cvImageBuffer: imageBuffer)
        let features = detector?.features(in: image) // [CIFeature]
        // Add a detection box on top of the preview layer
        self.detectionBoxView = DetectionBoxView()
        playerPreview.addSubview(self.detectionBoxView!)
        
        webcamDetectionQueue.async {
            
            print("---> Detecting")
            print("---> Image: \(image)")
            
            for ciFeature in features! {
                // Display a rectangle
                print("---> Features bounds: \(ciFeature.bounds)")
                self.detectionBoxView?.draw(ciFeature.bounds)
            }
        }
        
    }
 
    // Play video on a different thread
    private func startPlaying(from url: URL){
        let playerResourceItem: AVPlayerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerResourceItem)
        
        videoPlayerQueue.async {
            print("---> Playing video from \(url.absoluteString)")
            self.player.play()
        }
    }
}
