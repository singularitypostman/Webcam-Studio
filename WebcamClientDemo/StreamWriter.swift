//
//  StreamWriter.swift
//  WebcamClientDemo
//
//  Copyright © 2019 All rights reserved.
//

import AVFoundation

class StreamWriter: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    // MARK - AVFoundation
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        debugPrint("[StreamWriter]", "Did start streaming")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didPauseRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        debugPrint("[StreamWriter]", "Did pause streaming")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didResumeRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        debugPrint("[StreamWriter]", "Did resume streaming")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        debugPrint("[StreamWriter]", "Did stop streaming")
    }
    
}
