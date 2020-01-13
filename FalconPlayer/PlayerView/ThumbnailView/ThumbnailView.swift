//
//  ThumbnailView.swift
//  FalconPlayer
//
//  Created by aseo on 2020/01/13.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import UIKit

class ThumbnailView: UIView {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        activityIndicatorView.hidesWhenStopped = true
    }
    
    /// 画像を設定する
    /// - Parameter image: サムネイル
    func setImage(image: UIImage?) {
        imageView.image = image
    }
    
    /// 画像の読み込みを開始する
    func loadImage() {
        // TODO: 画像読み込み処理
        startAnimating()
    }
    
    /// activityIndicatorViewのアニメーションを開始する
    func startAnimating() {
        activityIndicatorView.startAnimating()
    }
    
    /// activityIndicatorViewのアニメーションを停止する
    func stopAnimating() {
        activityIndicatorView.stopAnimating()
    }
}
