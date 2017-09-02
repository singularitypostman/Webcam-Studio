//
//  MFileWriter.swift
//  Monique
//
//  Created by Shavit Tzuriel on 8/19/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import Foundation
import AVFoundation
class MFileWriter: MfileWriterProtocol {
    
    private var dir: URL? = nil
    private var filePath: URL? = nil
    private var fileOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    private var segmentsCount: Int = 0
    private let timeScale: Int32 = 1000000000
    private var timer: Timer? = nil
    var channel: String = String(format: "monique_%04d", Int(arc4random_uniform(1000)+1))
    var delegate: AVCaptureFileOutputRecordingDelegate? = nil
    
    init() {
        createDirectory(path: "Webcam/sessions")
    }
    
    func getFilePath() -> URL?{
        segmentsCount += 1
        let fileNumber = String(format: "%04d", segmentsCount)
        let name = "/session_\(channel)_\(fileNumber).mp4"
        filePath = URL(fileURLWithPath: dir!.path.appending(name))
        
        return filePath
    }
    
    func getOutput() -> AVCaptureMovieFileOutput {
        return fileOutput
    }
    
    func getSegmentNumber() -> Int{
        return segmentsCount
    }
    
    func moveFile(from url: URL){
        print("---> Moving file to \(filePath!)")
        do {
            try FileManager.default.moveItem(at: url, to: filePath!)
        } catch let err as NSError {
            print("Error moving video file: \(err)")
        }
    }
    
    func record(){
        print("---> Writer start")
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { (t) in
            print("---> Starting recording session segment \(self.segmentsCount)")
            
            // Stop and restart and a new segment
            self.fileOutput.stopRecording()
            self.fileOutput = AVCaptureMovieFileOutput()
            self.fileOutput.startRecording(to: self.getFilePath()!, recordingDelegate: self.delegate!)
        })
    }
    
    func stop(){
        print("---> Writer stop")
        timer?.invalidate()
        fileOutput.stopRecording()
    }
    
    fileprivate func createDirectory(path: String){
        dir = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0], isDirectory: true).appendingPathComponent(path)
        
        do{
            // TODO: Permissions problems, it shouldn't run as root
            print("---> Creating a directory:")
            print(dir!.path)
            try FileManager.default.createDirectory(at: dir!, withIntermediateDirectories: true, attributes: nil)
        } catch let err as NSError {
            fatalError("Error creating a directory for the output file: \(err)")
        }
    }

}
