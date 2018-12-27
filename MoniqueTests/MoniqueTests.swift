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
    let url = URL(string: "rtmp://12.0.0.1/test-room")
    XCTAssertNotNil(url)
    let token = ProcessInfo.processInfo.environment["RTMP_TOKEN"]
    XCTAssertNotNil(token)
    streamer.connect(to: url!)
  }
}
