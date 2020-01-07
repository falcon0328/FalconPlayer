//
//  VideoPlayerSeekThumbnailView.swift
//  FalconPlayer
//
//  Created by aseo on 2020/01/07.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import UIKit

class VideoPlayerSeekThumbnailView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    /// 表示中の再生時間を更新する
    /// - Parameter currentTime: 再生時間
    func updateCurrentTime(currentTime: Float) {
        currentTimeLabel.text = VideoPlayerTimeFormatter.format(time: currentTime)
    }
}
