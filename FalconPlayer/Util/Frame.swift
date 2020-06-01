//
//  Frame.swift
//  FalconPlayer
//
//  Created by aseo on 2020/05/31.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import Foundation
import UIKit

class Frame {
    static let shared = Frame()
    
    enum AspectRatio {
        case ratio16_9
    }
    
    func make(aspectRatio: AspectRatio = AspectRatio.ratio16_9, toView: UIView) -> CGRect {
        let width: CGFloat = toView.frame.size.width
        let height: CGFloat = width * 9 / 16
        return CGRect(x: 0,
                      y: toView.center.y - height / 2.0,
                      width: width,
                      height: height)
    }
}
