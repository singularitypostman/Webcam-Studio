//
//  MFileWriterProtocol.swift
//  Monique
//
//  Created by Shavit Tzuriel on 8/19/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import Foundation
protocol MfileWriterDelegate {
    func moveFile(from url: URL)
    func record()
    func stop()
}
