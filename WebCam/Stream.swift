//
//  Stream.swift
//  WebCam
//
//  Created by Shavit Tzuriel on 11/13/16.
//  Copyright © 2016 Shavit Tzuriel. All rights reserved.
//

import Foundation
import Darwin

class Stream {
    
    let port = UInt16(3001)
    let INADDR_ANY = in_addr(s_addr: 0)
    let fd = socket(AF_INET, SOCK_DGRAM, 0)
    
    func broadcast(message: String){
        var addr_in = sockaddr_in(sin_len: __uint8_t(MemoryLayout<sockaddr_in>.size), sin_family: sa_family_t(AF_INET), sin_port: self.htons(value: port), sin_addr: INADDR_ANY, sin_zero: (0,0,0,0, 0,0,0,0))
        
        message.withCString { cstr -> Void in
            withUnsafePointer(to: &addr_in) {
                let broadcastMessageLength = Int(strlen(cstr) + 1)
                let p = UnsafeRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1)
                
                // Send the message
                sendto(fd, cstr, broadcastMessageLength, 0, p, socklen_t(addr_in.sin_len))
            }
        }
    }
    
    func broadcastData(message: NSData){
        var addr_in = sockaddr_in(sin_len: __uint8_t(MemoryLayout<sockaddr_in>.size), sin_family: sa_family_t(AF_INET), sin_port: self.htons(value: port), sin_addr: INADDR_ANY, sin_zero: (0,0,0,0, 0,0,0,0))
        
        withUnsafePointer(to: &addr_in) {
            let broadcastMessageLength = message.length
            let p = UnsafeRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1)
            
            // Send the message
            sendto(fd, message.bytes, broadcastMessageLength, 0, p, socklen_t(addr_in.sin_len))
        }
    }
    
    private func htons(value: CUnsignedShort) -> CUnsignedShort {
        return (value << 8) + (value >> 8)
    }
    
}
