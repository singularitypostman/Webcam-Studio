//
//  ViewController.swift
//  Monique
//
//  Created by Shavit Tzuriel on 8/19/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import Cocoa

class MainViewController: NSSplitViewController {
  
  @IBOutlet var mStage: NSView!
  
  @IBOutlet var mBtnStream: NSButton!
  
  fileprivate var isStreaming = false
  
  // Stream to server
  @IBAction func startStreaming(_ sender: Any){
    debugPrint("[MainViewController]", "Toggle. Is streaming?", isStreaming)
    
    isStreaming = !isStreaming
  }
  
}

