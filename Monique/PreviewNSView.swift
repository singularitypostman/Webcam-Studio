//
//  PreviewNSView.swift
//  Monique
//
//  Created by Shavit Tzuriel on 12/16/18.
//  Copyright © 2018 Shavit Tzuriel. All rights reserved.
//
//  This class display a preview of the captured video
//
//

import Cocoa
import AVFoundation

class PreviewNSView: NSView,
    AVCaptureFileOutputRecordingDelegate {
    
    private var session: AVCaptureSession? = nil
    private var previewLayer: AVCaptureVideoPreviewLayer? = nil
    
    //fileprivate var streamClient: StreamClient? = nil
    fileprivate var isStreaming: Bool = false
    
    fileprivate let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    //fileprivate let queueWriter = DispatchQueue(label: "PreviewNSView.Writer")
    
    fileprivate var recordingTimer: Timer? = nil
    fileprivate var segmentsCount: Int = 0
    fileprivate let sessionId = Int(arc4random_uniform(1000)+1)
    fileprivate var videoDirPath: URL? = nil
    fileprivate var videoFileOutput: AVCaptureMovieFileOutput? = nil
    
    // TODO: Create a writer
    // TODO: Move this
    //fileprivate let encodingClient = EncodingClient()
    
    
    @IBOutlet weak var mUserPreview: NSView!
    @IBOutlet weak var mLabelStatus: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // TODO: Uncomment this line
        //startPreview()
        
        // TODO: Remove this line
        mLabelStatus.stringValue = "Ready to stream"
    }
    
    // MARK: AVFoundation
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // TODO: Remove this
        debugPrint("[PreviewNSView]", "didStartRecordingTo", fileURL)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        debugPrint("[PreviewNSView]", "didFinishRecordingTo")
        
        //encodingClient.encodeFile(outputFileURL)
    }
    
    // MARK: Video preview
    
    /**
     Display the preview from the webcam
     */
    func startPreview(){
        session?.stopRunning()
        session = AVCaptureSession()
        
        let webcamVideo: AVCaptureDevice? = AVCaptureDevice.devices(for: .video)[0]
        let webcamAudio: AVCaptureDevice? = AVCaptureDevice.devices(for: .audio)[0]
        
        // Add video input
        do{
            let videoInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: webcamVideo!)
            session?.addInput(videoInput)
            
            let audioInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: webcamAudio!)
            session?.addInput(audioInput)
        } catch let err as NSError{
            print("Error adding device: \(err)")
        }
        
        videoFileOutput = AVCaptureMovieFileOutput()
        videoFileOutput?.minFreeDiskSpaceLimit = 1024 * 1024 * 1024 * 1024 * 12
        videoFileOutput?.maxRecordedDuration = CMTime(seconds: Double(6), preferredTimescale: 1)
        session?.sessionPreset = AVCaptureSession.Preset.qvga320x240
        if videoFileOutput != nil {
            session?.addOutput(videoFileOutput!)
        } else {
            fatalError("No output")
        }
        //session?.addOutput(videoOutput)
        //session?.addOutput(audioOutput)
        
        guard session != nil else { return }
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session!)
        DispatchQueue.main.async { [weak self] in
            // TODO: Uncomment this line when the design is ready
            //self?.layer = self?.previewLayer
            self?.mUserPreview.layer = self?.previewLayer
        }
        
        queue.async { [weak self] in
            self?.session?.startRunning()
        }
    }
    
    func stopPreview(){
        session?.stopRunning()
    }
    
    // MARK: Recording
    
    /**
     Create a media writer
     */
    func createWriter(){
        // TODO: Get the value from teh preferences
        if videoDirPath == nil {
            createDownloadsDirectory()
        }
        guard let dir = videoDirPath else { return }
        
        recordingTimer?.invalidate()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true, block: { (t) in
            // TODO: Remove this
            debugPrint("[PreviewNSView]", "Timer tick", self.segmentsCount)
            self.videoFileOutput?.stopRecording()
            guard let connection = self.videoFileOutput?.connections.first,
                connection.isActive else { return }
            
            let outputFile = URL(fileURLWithPath: "\(self.sessionId)/seg_\(self.segmentsCount).mp4", relativeTo: dir)
            debugPrint("[PreviewNSView]", "Output file", outputFile, "Directory", dir)
            self.videoFileOutput?.startRecording(to: outputFile, recordingDelegate: self)
            self.segmentsCount += 1
        })
    }
    
    func stopRecording(){
        recordingTimer?.invalidate()
        videoFileOutput?.stopRecording()
    }
    
    func createDownloadsDirectory(){
        // TODO: Get the value from the preferences
        // For debugging
        guard let path = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).first else { return }
        videoDirPath = URL(fileURLWithPath: path, isDirectory: true).appendingPathComponent("Webcam/sessions/\(sessionId)")
        guard let dir = videoDirPath else { return }
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        } catch let err as NSError {
            // TODO: Remove this
            debugPrint("[PreviewNSView]", "Error creating a directory", err.localizedDescription)
            videoDirPath = nil
            return
        }
    }
    
    // MARK: Streaming Client
    
    /**
     Stream to server
     */
    @IBAction func toggleStreaming(_ sender: Any){
        if isStreaming {
            //stopStreaming()
            stopPreview()
            // TODO: Remove this line
            mLabelStatus.stringValue = "Ready to stream"
        } else {
            //startStreaming()
            startPreview()
            // TODO: Remove this line
            mLabelStatus.stringValue = "Started the stream"
        }
        
        isStreaming = !isStreaming
    }
    
    /*
    fileprivate func startStreaming(){
        // TODO: Replace the environment variable with user settings
        //let hostname: String = ProcessInfo.processInfo.environment["RTMP_HOST"] ?? "127.0.0.1"
        let hostname: String = "127.0.0.1"
        let url = "rtmp://\(hostname):1935/live/dev_stream"
        streamClient = StreamClient(address: url)
        
        // TODO: Handle errors
        let err = streamClient?.publishStream()
        if err != 0 {
            DispatchQueue.main.async { [weak self] in
                self?.mLabelStatus?.stringValue = NSLocalizedString(STREAMING_ERROR_STATUS, comment: "Started the stream")
            }
            return
        }
        
        // TODO: Handle errors
        startPreview()
        createWriter()
        
        DispatchQueue.main.async { [weak self] in
            self?.mLabelStatus?.stringValue = NSLocalizedString(STREAMING_ACTIVE_STATUS, comment: "Started the stream")
        }
    }
    
    fileprivate func stopStreaming(){
        stopPreview()
        stopRecording()
        
        DispatchQueue.main.async { [weak self] in
            self?.mLabelStatus?.stringValue = NSLocalizedString(STREAMING_READY_STATUS, comment: "Ready to stream")
        }
    }
    */
}
