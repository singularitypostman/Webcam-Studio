//
//  ViewController.swift
//  Monique
//
//  Created by Shavit Tzuriel on 8/19/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import Cocoa
import AVFoundation

class MainViewController: NSSplitViewController {
  
  @IBOutlet var previewView: PreviewNSView!
  
  @IBOutlet weak var mBtnStream: NSButton!
  @IBOutlet weak var mLabelStatus: NSTextField!
  
  fileprivate var isStreaming = false
  
  // Stream to server
  @IBAction func startStreaming(_ sender: Any){
    debugPrint("[MainViewController]", "Toggle. Is streaming?", isStreaming)
    
    if isStreaming {
      // TODO: Stop the stream
    } else {
      startStreaming()
    }
    
    isStreaming = !isStreaming
  }
  
  // MARK: Streaming
  
  fileprivate func startStreaming(){
    /*
    let hostname: String = ProcessInfo.processInfo.environment["RTMP_HOST"] ?? "127.0.0.1"
    let url = "rtmp://\(hostname):1935/stream/dev_stream"
    debugPrint("[MainViewController]", "Starting a stream ", url)
    
    //let captureSession = AVCaptureSession()
    
    mLabelStatus.stringValue = "Connecting"
    // TODO: Remove this
    let streamer = Streamer()
    streamer.connect(to: URL(string: "rtmp://127.0.0.1")!)
    // TODO: Check the connection status
    mLabelStatus.stringValue = "Connected"
    */
    
    let hostname: String = ProcessInfo.processInfo.environment["RTMP_HOST"] ?? "127.0.0.1"
    let url = "rtmp://\(hostname):1935/live/dev_stream"
    let client = StreamClient(address: url)
  }
}

