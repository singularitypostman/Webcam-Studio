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
    
    @IBOutlet var mBtnStream: NSButton!
    
    fileprivate var isStreaming = false
    
    // MARK: Streaming
    
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
    
    fileprivate func startStreaming(){
        let hostname: String = ProcessInfo.processInfo.environment["RTMP_HOST"] ?? "127.0.0.1"
        let url = "rtmp://\(hostname):1935/stream/dev_stream"
        debugPrint("[MainViewController]", "Starting a stream to ", url)
        
        //let captureSession = AVCaptureSession()
        
    }
}

