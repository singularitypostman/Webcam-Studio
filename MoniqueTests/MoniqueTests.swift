//
//  MoniqueTests.swift
//  MoniqueTests
//
//  Created by Shavit Tzuriel on 8/19/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import XCTest
@testable import Monique

class MoniqueTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateMainViewController(){
        let controller = MainViewController(nibName: nil, bundle: nil)
        XCTAssertNotNil(controller)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK - Streamer
    
    func testStreamerConnect(){
        let streamer = Streamer()
        XCTAssertNotNil(streamer)
        
        //let url = URL(string: "rtmp://live.stream.highwebmedia.com/live-origin")
        let url = URL(string: "rtmp://127.0.0.1/stream/test-room")
        XCTAssertNotNil(url)
        let token = ProcessInfo.processInfo.environment["RTMP_TOKEN"]
        XCTAssertNotNil(token)
        
        // TODO: Complete this
        //streamer.connect(to: url!)
        
        
    }
    
    func testStreamerCreatePacket0(){
        let streamer = Streamer()
        let packet: [UInt8] = streamer.packC0()
        XCTAssertEqual(packet.count, 1)
        XCTAssertEqual(packet, [0x03])
    }
    
    func testStreamerCreatePacket1(){
        let streamer = Streamer()
        let packet: [UInt8] = streamer.packC1()
        XCTAssertEqual(packet.count, 1536)
    }
    
    //
    //  MARK - StreamClient
    //
    
    func testCreateStreamclient(){
        let client = StreamClient(address: "127.0.0.1", port: 1935)
        XCTAssertNotNil(client)
    }
}
