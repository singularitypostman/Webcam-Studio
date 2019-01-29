//
//  Connection.swift
//  Monique
//
//  Created by Shavit Tzuriel on 1/21/19.
//  Copyright © 2019 Shavit Tzuriel. All rights reserved.
//

import CFNetwork

class Connection {
    
    private var sockfd: CFSocket?
    
    init(addr: String, port: uint) {
        self.sockfd = CFSocketCreate(nil, AF_INET, SOCK_STREAM, IPPROTO_TCP, 0, nil, nil)
        /*
         if sockfd == nil {
         // TOOD: Add error here
         // TODO: Remove this
         fatalError("Could not initialize a Connection. Error creating a socket")
         // return
         }
         */
        
        //        struct servAddr sockaddr_in
        //        memset(&servAddr, 0, sizeof(servAddr))
        //        servAddr.sin_len
    }
    
    /**
     Write to the socket
     */
    func write() { }
    
    /**
     Receive from the socket
     */
    func receive() { }
}
