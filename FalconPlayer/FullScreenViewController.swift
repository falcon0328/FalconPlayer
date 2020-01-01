//
//  FullScreenViewController.swift
//  AVPlayerExample
//
//  Created by aseo on 2020/01/01.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import UIKit

class FullScreenViewController: UIViewController {
    
    var videoPlayerView: VideoPlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        videoPlayerView.frame = self.view.frame
        
        self.view.addSubview(videoPlayerView)
        
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        videoPlayerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        videoPlayerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        videoPlayerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

}
