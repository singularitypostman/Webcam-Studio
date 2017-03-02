//
//  AppDelegate.swift
//  WebCam
//
//  Created by Shavit Tzuriel on 10/18/16.
//  Copyright © 2016 Shavit Tzuriel. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let delegate: AppDelegate = AppDelegate()
        let app: NSApplication = NSApplication.shared()
        app.delegate = delegate
        
        let window: NSWindow = NSWindow(contentRect: NSMakeRect(10, 10, 400, 400), styleMask: .resizable, backing: .buffered, defer: false)
        let controller: NSViewController = ViewController()
        let content: NSView = window.contentView!
        content.addSubview(controller.view)
        
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

