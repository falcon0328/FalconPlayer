//
//  AVPlayerExample.swift
//  AVPlayerExample
//
//  Created by aseo on 2019/12/22.
//  Copyright © 2019 Falcon Tech. All rights reserved.
//

import UIKit
import AVFoundation
import CoreGraphics

class AVPlayerExample: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playerView: UIView!
    var videoPlayerView: VideoPlayerView?
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didChangeOrientation(notification:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "saya-volume", ofType: "gif")!))
        
        let videoPlayerView = Bundle.main.loadNibNamed("VideoPlayerView", owner: self, options: nil)?.first as! VideoPlayerView
        videoPlayerView.frame = playerView.frame
        self.videoPlayerView = videoPlayerView
        
        let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!
        
        // iOSでAVの情報を管理するためのモデルクラス
        // AVの参照先URL、作成日、尺の長さなどが取得できる
        let asset = AVAsset(url: url)
        
        // 動画の表示状態や状況を管理するためのモデルクラスを生成
        // 再生時間、再生状態（未定義・準備完了・エラー）、バッファリング済みの動画尺などの取得ができる
        let playerItem = AVPlayerItem(asset: asset)

        // AVの再生や停止、ミュートやアンミュート、ボリューム変更など各種AV操作を行う
        // AVPlayerは再生したいAVPlayerItemをセットして行う
        let player = AVPlayer(playerItem: playerItem)
        videoPlayerView.setPlayer(player: player)
        videoPlayerView.play()
        videoPlayerView.delegate = self
        
        playerView.addSubview(videoPlayerView)
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerView.leadingAnchor.constraint(equalTo: playerView.leadingAnchor).isActive = true
        videoPlayerView.topAnchor.constraint(equalTo: playerView.topAnchor).isActive = true
        videoPlayerView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor).isActive = true
        videoPlayerView.trailingAnchor.constraint(equalTo: playerView.trailingAnchor).isActive = true
        playerView.isHidden = false
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewWillEnterForeground(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewDidEnterBackground(notification:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    @objc func viewWillEnterForeground(notification: Notification) {
        
    }

    
    @objc func viewDidEnterBackground(notification: Notification) {
        self.videoPlayerView?.pause()
    }
    
    @objc func didChangeOrientation(notification: NSNotification){
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            break
        case .portrait, .portraitUpsideDown:
            print("😺Portrait")
        default:
            print("😺other")
        }
    }
}

extension AVPlayerExample: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

extension AVPlayerExample: VideoPlayerViewDelegate {
    func didTap(videoPlayerView: VideoPlayerView, componentName: String) {
        videoPlayerView.pause()
        
        let vc = UIStoryboard(name: "FullScreen", bundle: Bundle.main).instantiateInitialViewController() as! FullScreenViewController
        vc.videoPlayerView = videoPlayerView
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
}
