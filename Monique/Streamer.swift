//
//  Streamer.swift
//  Monique
//
//  Created by Shavit Tzuriel on 12/26/18.
//  Copyright © 2018 Shavit Tzuriel. All rights reserved.
//

import Foundation
import Darwin

class Streamer: NSObject, StreamDelegate {
    
    let queue = DispatchQueue.global(qos: .background)
    
    var streamUrl: URL? = nil
    var timestamp: [UInt8] = []
    
    let port: UInt32 = 1935
    let INADDR_ANY = in_addr(s_addr: 0)
    var fd: Int32? = nil
    
    var inputStream: InputStream?
    var outputStream: OutputStream?
    
    /**
     Connect to the stream
     
     - Parameters:
     - url: URL of the RTMP server
     
     Recommended settings:
     - RTMP URL: rtmp://live.stream.highwebmedia.com/live-origin
     - Codec: H.264 Video, AAC Audio.
     - Aspect ratio: 4:3 or 16:9 only.
     - Resolution: From a height of 240 pixels up to 4k (2160 pixels).
     - Frame Rate: Up to 30 fps, between 24-30 fps is reasonable.
     - Bitrate: Up to 20 Mbps (20 000 Kbps) Video, 192 Kbps Audio - CBR Preferred.
     - Key Frame Interval: Any reasonable value; between 2-5s is good.
     - H.264 Profile: Main or High preferred; baseline is acceptable.
     */
    func connect(to url: URL){
        streamUrl = url
        
        //fd = socket(AF_INET, SOCK_DGRAM, 0) // UDP test
        //fd = socket(AF_INET, SOCK_STREAM, 0) // TCP test
        
        let allocator: CFAllocator? = kCFAllocatorDefault
        let host: CFString = url.absoluteString as CFString
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        // TODO: Remove this
        debugPrint("[Streamer]", "Connect to", host)
        CFStreamCreatePairWithSocketToHost(allocator, host, port, &readStream, &writeStream)
        
        inputStream = readStream!.takeRetainedValue() as InputStream
        inputStream?.delegate = self
        inputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        outputStream = writeStream!.takeRetainedValue() as OutputStream
        outputStream?.delegate = self
        outputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        
        queue.async {
            self.inputStream?.open()
            self.outputStream?.open()
        }
    }
    
    /**
     Exchange of 3 static sized chunks between the client and server
     - From the client: c0, c1, c2
     - From the server: s0, s1, s2
     
     http://wwwimages.adobe.com/www.adobe.com/content/dam/acom/en/devnet/rtmp/pdf/rtmp_specification_1.0.pdf
     
     The client sends first 2 chunks c0, c1. Then waits for the server to
     response with s0 and s1.
     
     
     */
    func handshake(){
        // Send C0 + C1
        
        // Read S1
        let s1Data: [UInt8] = []
        let validS1 = validate(s1: s1Data)
        // TODO: Handle handshake errors with alert
        guard validS1 else { return }
        
        // Send C2
        // ...
        
    }
    
    
    func packC0() -> [UInt8] {
        return [0x03]
    }
    
    func packC1() -> [UInt8] {
        let date: NSDate = NSDate()
        var timeInterval = Int(date.timeIntervalSince1970)
        let time: [UInt8] = withUnsafeBytes(of: &timeInterval) {
            Array<UInt8>($0).filter({ (item) -> Bool in item != 0})
        }
        //let zero: [UInt8] = [0x00, 0x00, 0x00, 0x00]
        let zero: [UInt8] = [UInt8].init(repeating: 0x00, count: 4)
        let rand: [UInt8] = [UInt8].init(repeating: UInt8.random(in: 0...255), count: 1528)
        
        return time + zero + rand
    }
    
    func validate(s1 data: [UInt8]) -> Bool {
        guard data.count == 1536 else { return false }
        
        // TODO: Validate
        
        // TODO: Save the timestamp
        // self.timestamp = serverTimestamp
        
        return true
    }
    
    func validate(s2 data: [UInt8]) -> Bool {
        return false
    }
    
    // MARK - StreamDelegate
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        // TODO: Remove this
        debugPrint("[Streamer]", "Stream", eventCode)
    }
}
