//
//  VideoPlayerConfiguration.swift
//  FalconPlayer
//
//  Created by aseo on 2020/01/10.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import Foundation

/// プレイヤーの設定
class VideoPlayerConfiguration {
    static let shared = VideoPlayerConfiguration()
    
    /// 拡大中かどうかを示すフラグ
    var isExpand: Bool = false
    
    private init() {}
}
