//
//  ViewController.swift
//  ViewController
//
//  Created by aseo on 2019/12/22.
//  Copyright © 2019 Falcon Tech. All rights reserved.
//

import UIKit
import AVFoundation
import CoreGraphics

class ViewController: UIViewController {
    @IBOutlet weak var playerView: UIView!
    var videoPlayerView: VideoPlayerView?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "saya-volume", ofType: "gif")!))
        
        let videoPlayerView = Bundle.main.loadNibNamed("VideoPlayerView", owner: self, options: nil)?.first as! VideoPlayerView
        videoPlayerView.frame = playerView.frame
        // https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8
        videoPlayerView.delegate = self
        videoPlayerView.setVideoURL(url: URL(string: "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8"))
        playerView.addSubview(videoPlayerView)

        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerView.leadingAnchor.constraint(equalTo: playerView.leadingAnchor).isActive = true
        videoPlayerView.topAnchor.constraint(equalTo: playerView.topAnchor).isActive = true
        videoPlayerView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor).isActive = true
        videoPlayerView.trailingAnchor.constraint(equalTo: playerView.trailingAnchor).isActive = true
        self.videoPlayerView = videoPlayerView
        playerView.isHidden = false
    }
}

extension ViewController: VideoPlayerViewDelegate {
    func didPrepare(videoPlayerView: VideoPlayerView) {
        videoPlayerView.play()
    }
    
    func didFailure(videoPlayerView: VideoPlayerView) {}
    
    func didUpdatePeriodicTimer(videoPlayerView: VideoPlayerView) {}
    
    func didChange(videoPlayerView: VideoPlayerView, playerState: VideoPlayerState) {}
    
    func didChange(videoPlayerView: VideoPlayerView, audioState: AudioState) {}
    
    func didTap(videoPlayerView: VideoPlayerView, componentName: String) {}
}
