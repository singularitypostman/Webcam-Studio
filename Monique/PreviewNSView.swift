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

class PreviewNSView: NSView {
  
  private var session: AVCaptureSession? = nil
  private var previewLayer: AVCaptureVideoPreviewLayer? = nil
  
  fileprivate let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
  
  override func draw(_ dirtyRect: NSRect) {
    startPreview()
  }
  
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
    let audioOutput: AVCaptureAudioDataOutput = AVCaptureAudioDataOutput()
    session?.sessionPreset = AVCaptureSession.Preset.high
    session?.addOutput(videoOutput)
    session?.addOutput(audioOutput)
    
    guard session != nil else { return }
    previewLayer = AVCaptureVideoPreviewLayer(session: session!)
    layer = previewLayer
    
    queue.async { [weak self] in
      self?.previewLayer?.session?.startRunning()
    }
  }
}
