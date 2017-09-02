//
//  MWebcamLocalPreviewContainer.swift
//  Monique
//
//  Created by Shavit Tzuriel on 8/19/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import Cocoa
import AVFoundation

class MWebcamLocalPreview: NSView, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
    
    private let session: AVCaptureSession = AVCaptureSession()
    private let writer: MFileWriter = MFileWriter()
    let videoOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    let audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer? = nil
    let queue = DispatchQueue(label: "webcamPreview")
    private var isRecording = false
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        writer.delegate = self
        addPreviewLayer()
        setInput()
        setOutput()
        startPreview()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("---> Did output \(Int64(CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds))")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("---> Started recording to file")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("---> Finish recording to file \(outputFileURL.absoluteString)")
        writer.moveFile(from: outputFileURL)
    }
    
    func toggleRecording(){
        print("---> Toggle recording: \(isRecording)")
        if isRecording {
            writer.stop()
        } else {
            writer.record()
        }
        
        isRecording = !isRecording
    }
    
    fileprivate func addPreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.backgroundColor = NSColor.green.cgColor
        
        layer = previewLayer
    }
    
    fileprivate func setInput(){
        let webcamVideo: AVCaptureDevice? = AVCaptureDevice.devices(for: .video)[0]
        let webcamAudio: AVCaptureDevice? = AVCaptureDevice.devices(for: .audio)[0]
        
        // Add video input
        do{
            let videoInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: webcamVideo!)
            session.addInput(videoInput)
        } catch let err as NSError{
            print("---> Error adding video device: \(err)")
        }
        
        // Add audio input
        do{
            let audioInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: webcamAudio!)
            session.addInput(audioInput)
        } catch let err as NSError{
            print("---> Error adding audio device: \(err)")
        }
    }
    
    fileprivate func setOutput(){
        session.sessionPreset = AVCaptureSession.Preset.high
        session.addOutput(videoOutput)
        session.addOutput(audioOutput)
        // File output
        session.addOutput(writer.getOutput())
    }
    
    fileprivate func startPreview(){
        queue.async {
            self.previewLayer?.session?.startRunning()
        }
    }
}

