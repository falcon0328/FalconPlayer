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
    
    override func awakeFromNib() {
        currentTimeLabel.layer.cornerRadius = 10.0
    }
}
