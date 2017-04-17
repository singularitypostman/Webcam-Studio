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
    
    func broadcastData(channel: String, resolution: String, message: NSData){
        //var addr_in = sockaddr_in(sin_len: __uint8_t(MemoryLayout<sockaddr_in>.size), sin_family: sa_family_t(AF_INET), sin_port: self.htons(value: port), sin_addr: INADDR_ANY, sin_zero: (0,0,0,0, 0,0,0,0))
        
        let messageSize: Int32 = 256
        let header: String = channel+resolution
        //let header: [Int32] = [channel,resolution,messageSize,0,2,3,2,4,1]
//        let mutableData: NSMutableData = NSMutableData()
//        mutableData.append(header, length: header.count)
//        mutableData.append(message.bytes, length: message.length)
        
        let dataSize: Int = Int32(message.length)
        var chunkSize: Int = 4000-headerSize
        if Int(dataSize) < (4000 - headerSize) {
            chunkSize = Int(dataSize)
        }
        var dataOffset: Int = 0
        
        print("---> Chunk size is \(chunkSize) of \(dataSize)")
        
        while dataOffset < dataSize {
            let tmpChunkSize: Int = ((dataSize - dataOffset) > chunkSize)
                ? (chunkSize)
                : (dataSize - dataOffset)
            let chunk: NSData = fileData.subdata(with: NSMakeRange(dataOffset, tmpChunkSize)) as NSData
            mutableData.append(header, length: headerSize)
            mutableData.append(chunk.bytes, length: chunk.length)
            sendChunk(chunk: mutableData.bytes, messageLength: mutableData.length)
            
            dataOffset = dataOffset + chunk.length
        }
        
            
        repeat {
            let tmpChunkSize = ((message.length - dataOffset) > chunkSize) ? chunkSize : (message.length - dataOffset)
            //let chunk: NSData = message.subdata(with: NSMakeRange(dataOffset, tmpChunkSize)) as NSData
            let chunk: NSData = message.subdata(with: NSMakeRange(dataOffset, tmpChunkSize+header.count)) as NSData
            
            let mutableData: NSMutableData = NSMutableData()
            mutableData.append(header, length: header.count)
            mutableData.append(chunk.bytes, length: chunk.length)
            
            // Send chunk of data
            //sendChunk(chunk: message.bytes, messageLength: tmpChunkSize)
            //sendChunk(chunk: chunk.bytes, messageLength: tmpChunkSize)
            sendChunk(chunk: mutableData.bytes, messageLength: mutableData.length)
            
            // Update the offset
            dataOffset = dataOffset + tmpChunkSize
        } while (dataOffset < message.length)
        
    }
    
    func broadcastData(url: URL?){
        do {
            let fileData: NSData = try NSData(contentsOf: url!)
            let channel: String = "1200"
            let resolution: String = "2"
            broadcastData(channel: channel, resolution: resolution, message: fileData)
            
            //broadcastData(message: data)
            
        } catch let err as NSError {
            print("Error streaming file: \(err)")
        }
    }
    
    private func htons(value: CUnsignedShort) -> CUnsignedShort {
        return (value << 8) + (value >> 8)
    }
    
    private func sendChunk(chunk: UnsafeRawPointer, messageLength: Int){
        var addr_in = sockaddr_in(sin_len: __uint8_t(MemoryLayout<sockaddr_in>.size), sin_family: sa_family_t(AF_INET), sin_port: self.htons(value: port), sin_addr: INADDR_ANY, sin_zero: (0,0,0,0, 0,0,0,0))
        
        withUnsafePointer(to: &addr_in) {
            let p = UnsafeRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1)
            let sent = sendto(fd, chunk, messageLength, 0, p, socklen_t(addr_in.sin_len))
            //print("---> (\(messageLength)) Sent? \(sent) = \(messageLength)")
            
            if sent == -1{
                print("Error sending a message: \(errno)")
                perror("Error reported ")
            }
        }
    }
    
}
