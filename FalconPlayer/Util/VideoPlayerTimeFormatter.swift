//
//  VideoPlayerTimeFormatter.swift
//  AVPlayerExample
//
//  Created by aseo on 2019/12/30.
//  Copyright © 2019 Falcon Tech. All rights reserved.
//

import Foundation

class VideoPlayerTimeFormatter {
    static func format(time: Float) -> String {
        if time < 0 {
            return ""
        }
        let s = time.truncatingRemainder(dividingBy: 60)
        let m = ((time - s) / 60).truncatingRemainder(dividingBy: 60)
        let h = ((time - s - m * 60) / 3600).truncatingRemainder(dividingBy: 3600)
        if (h > 0) {
            return String(format: "%d:%02d:%02d", Int(h), Int(m), Int(s))
        } else if (m >= 10) {
            return String(format: "%02d:%02d", Int(m), Int(s))
        }
        return String(format: "%d:%02d", Int(m), Int(s))
    }
}
