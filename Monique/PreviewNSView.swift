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
    AVCaptureVideoDataOutputSampleBufferDelegate,
AVCaptureAudioDataOutputSampleBufferDelegate {
    
    private var session: AVCaptureSession? = nil
    private var previewLayer: AVCaptureVideoPreviewLayer? = nil
    
    fileprivate var streamClient: StreamClient? = nil
    fileprivate var isStreaming: Bool = false
    
    fileprivate let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    //fileprivate let queueWriter = DispatchQueue(label: "PreviewNSView.Writer")
    
    fileprivate var bufWriter: AVAssetWriterInput? = nil
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        startPreview()
    }
    
    // MARK: AVFoundation
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if isStreaming {
            debugPrint("[PreviewNSView]", "captureOutput.didOutput", sampleBuffer)
        }
        // bufWriter?.append(sampleBuffer)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let imageSize = CVImageBufferGetEncodedSize(imageBuffer)
        
        //debugPrint("[PreviewNSView]", "captureOutput.didDrop", imageSize)
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
        
        let videoOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        let audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
        audioOutput.setSampleBufferDelegate(self, queue: queue)
        session?.sessionPreset = AVCaptureSession.Preset.high
        session?.addOutput(videoOutput)
        session?.addOutput(audioOutput)
        
        guard session != nil else { return }
        previewLayer = AVCaptureVideoPreviewLayer(session: session!)
        layer = previewLayer
        
        bufWriter = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1280,
            AVVideoHeightKey: 720,
            ])
        
        queue.async { [weak self] in
            self?.session?.startRunning()
        }
    }
    
    // MARK: Streaming Client
    
    // Stream to server
    @IBAction func startStreaming(_ sender: Any){
        debugPrint("[MainViewController]", "Toggle. Is streaming?", isStreaming)
        
        // TODO: Replace the environment variable with user settings
        //let hostname: String = ProcessInfo.processInfo.environment["RTMP_HOST"] ?? "127.0.0.1"
        let hostname: String = "127.0.0.1"
        let url = "rtmp://\(hostname):1935/live/dev_stream"
        streamClient = StreamClient(address: url)
        let err = streamClient?.publishStream()
        // TODO: Remove this
        debugPrint("[PreviewNSView]", "Publish stream:", Int32(err))
        
        //@IBOutlet var previewView: PreviewNSView!
        
        //@IBOutlet var mBtnStream: NSButton!
        
        isStreaming = !isStreaming
    }
    
}
