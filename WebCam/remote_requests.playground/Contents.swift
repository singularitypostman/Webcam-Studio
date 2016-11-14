//: Playground - noun: a place where people can play

import Cocoa
import Darwin


let INADDR_ANY = in_addr(s_addr: 0)

func htons(value: CUnsignedShort) -> CUnsignedShort {
    return (value << 8) + (value >> 8)
}


let fd = socket(AF_INET, SOCK_DGRAM, 0)
var addr_in = sockaddr_in(sin_len: __uint8_t(MemoryLayout<sockaddr_in>.size), sin_family: sa_family_t(AF_INET), sin_port: htons(value: 3001), sin_addr: INADDR_ANY, sin_zero: (0,0,0,0, 0,0,0,0))
let addr_to = sockaddr(sa_len: __uint8_t(MemoryLayout<sockaddr_in>.size), sa_family: sa_family_t(AF_INET), sa_data: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
let message = "Message from Swift 3"


message.withCString { cstr -> Void in
    let sent = withUnsafePointer(to: &addr_in) {
        
        let broadcastMessageLength = Int(strlen(cstr) + 1)
        let p = UnsafeRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1)
        
        // Send the message
        sendto(fd, cstr, broadcastMessageLength, 0, p, socklen_t(addr_in.sin_len))
        
    }
    
    print("Sent? \(sent)")
}
