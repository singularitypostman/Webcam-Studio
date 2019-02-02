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
    
    var streamClient: StreamClient? = nil
    
    @IBOutlet var previewView: PreviewNSView!
    
    @IBOutlet weak var mBtnStream: NSButton!
    @IBOutlet weak var mLabelStatus: NSTextField!
    
    fileprivate var isStreaming = false
    
    // Stream to server
    @IBAction func startStreaming(_ sender: Any){
        debugPrint("[MainViewController]", "Toggle. Is streaming?", isStreaming)
        
        //@IBOutlet var previewView: PreviewNSView!
        
        //@IBOutlet var mBtnStream: NSButton!
        
        isStreaming = !isStreaming
    }
    
    // MARK: Streaming
    
    fileprivate func startStreaming(){
        // TODO: Replace the environment variable with user settings
        //let hostname: String = ProcessInfo.processInfo.environment["RTMP_HOST"] ?? "127.0.0.1"
        let hostname: String = "127.0.0.1"
        let url = "rtmp://\(hostname):1935/live/dev_stream"
        streamClient = StreamClient(address: url)
        let err = streamClient?.publishStream()
        // TODO: Remove this
        debugPrint("[MainViewController]", "Publish stream:", err)
    }
}
