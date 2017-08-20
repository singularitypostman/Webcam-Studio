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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testFileWriterCreatesDifferentChannelNames(){
        let writer1 = MFileWriter()
        let writer2 = MFileWriter()
        
        assert(writer1.channel != writer2.channel)
    }
    
    func testFileWriterCreatesDifferentNamesForSegments(){
        let writer = MFileWriter()
        
        let u1 = writer.getFilePath()
        let n1 = writer.getSegmentNumber()
        let u2 = writer.getFilePath()
        let n2 = writer.getSegmentNumber()
        
        assert(u1 != u2)
        assert(n1 != n2)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
