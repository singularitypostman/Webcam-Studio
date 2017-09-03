//
//  MWebcamLocalPreviewTests.swift
//  MoniqueTests
//
//  Created by Shavit Tzuriel on 9/2/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import Foundation
import XCTest
@testable import Monique

class MWebcamLocalPreviewTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUseDefinedStreamingStatuses(){
        let status = MWebcamLocalPreview.Status(Recording: true, Detecting: true, Streaming: true)
        
        assert(status.Recording)
        assert(status.Detecting)
        assert(status.Streaming)
    }
}
