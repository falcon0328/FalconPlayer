//
//  VideoPlayerSeekbar.swift
//  FalconPlayer
//
//  Created by aseo on 2020/01/07.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import UIKit

class VideoPlayerSeekbar: UISlider {
    var trackBounds: CGRect {
        return trackRect(forBounds: bounds)
    }
    
    var trackFrame: CGRect {
        guard let superView = superview else { return CGRect.zero }
        return self.convert(trackBounds, to: superView)
    }
    
    var thumbFrame: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackFrame, value: value)
    }
}
