//
//  UIImageView+AnimatedGIF.swift
//  AVPlayerExample
//
//  Created by aseo on 2019/12/22.
//  Copyright © 2019 Falcon Tech. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {

    func animateGIF(data: Data,
                    animationRepeatCount: UInt = 1,
                    completion: (() -> Void)? = nil) {
        guard let animatedGIFImage = UIImage.animatedGIF(data: data) else {
            return
        }

        self.image = animatedGIFImage.images?.last
        self.animationImages = animatedGIFImage.images
        self.animationDuration = animatedGIFImage.duration
        self.animationRepeatCount = -1
        self.startAnimating()

        DispatchQueue.main.asyncAfter(deadline: .now() + animatedGIFImage.duration * Double(animationRepeatCount)) {
            completion?()
        }
    }
    
    func stopAnimateGIF() {
        self.stopAnimating()
    }
}
