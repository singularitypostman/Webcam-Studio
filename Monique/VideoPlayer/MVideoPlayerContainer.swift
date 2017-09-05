//
//  MVideoPlayerContainer.swift
//  Monique
//
//  Created by Shavit Tzuriel on 8/19/17.
//  Copyright © 2017 Shavit Tzuriel. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit

class MVideoPlayerContainer: NSView {
    
    let player: AVPlayer = AVPlayer()
    let cmTimeScale: Int32 = 1000000000
    let currentRecordingTime: Int64 = 0
    let queue = DispatchQueue(label: "videoPlayer")

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        setVideoPlayerView()
        
        // Use a m3u8 playlist of live video
        // https://github.com/shavit/Diana
        addResource(fromString: "http://localhost:3000/playlists/1")
        //play()
    }
    
    fileprivate func setVideoPlayerView(){
        let playerView = AVPlayerView()
        playerView.frame = playerView.frame
        playerView.player = player
        
        addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        playerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playerView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        playerView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    fileprivate func addResource(fromString _url: String){
        guard let url = URL(string: _url) else {
            fatalError("Error adding a resource URL: \(_url)")
        }
        let playerResourceItem: AVPlayerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerResourceItem)
    }
    
    fileprivate func play(){
        queue.async {
            self.player.play()
        }
    }
}
