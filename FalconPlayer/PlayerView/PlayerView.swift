//
//  PlayerView.swift
//  FalconPlayer
//
//  Created by aseo on 2020/05/27.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import UIKit

protocol PlayerViewDelegate: class {
    /// プレイヤービューの準備ができた
    /// - Parameter playerView: プレイヤービュー
    func didPrepare(playerView: PlayerView)
    /// プレイヤービューの準備が失敗した
    /// - Parameter playerView: プレイヤービュー
    func didFailure(playerView: PlayerView)
    /// プレイヤービュー内で再生中のプレイヤーのタイマーが更新されたことを通知する
    /// - Parameter playerView: プレイヤービュー
    func didUpdatePeriodicTimer(playerView: PlayerView)
    /// プレイヤービュー内のプレイヤー状態が変わったことを通知する
    /// - Parameter playerView: プレイヤービュー
    /// - Parameter playerState: 変更後のプレイヤー状態
    func didChange(playerView: PlayerView, playerState: VideoPlayerState)
    /// プレイヤービュー内のプレイヤーのオーディオ状態が変わったことを通知する
    /// - Parameter videoPlayerView: プレイヤービュー
    /// - Parameter audioState: 変更後のオーディオ状態
    func didChange(playerView: PlayerView, audioState: AudioState)
    /// プレイヤービュー内のプレイヤーの設定している再生速度がユーザによって変更されたことを通知する
    /// - Parameter playerView: プレイヤービュー
    /// - Parameter rate: 変更後の再生速度
    func didChange(playerView: PlayerView, rate: Float)
    /// プレイヤービュー内のプレイヤーの設定しているバッファリング中なども含めた実際の再生速度が変更されたことを通知する
    /// - Parameter playerView: プレイヤービュー
    /// - Parameter effectiveRate: 変更後の実際の再生速度
    func didChange(playerView: PlayerView, effectiveRate: Float)
    /// プレイヤービュー内のプレイヤーの拡大・縮小状態が変更されたことを通知する
    /// - Parameters:
    ///   - playerView: プレイヤービュー
    ///   - isExpand: 拡大状態かどうか
    func didChange(playerView: PlayerView, isExpand: Bool)
    /// プレイヤービュー内のプレイヤーがバッファリング状況によってストール状態になった
    /// - Parameter playerView: プレイヤービュー
    func didPlaybackStalled(playerView: PlayerView)
    /// プレイヤービュー内の各UIコンポーネントがタップされた
    /// - Parameter playerView: プレイヤービュー
    /// - Parameter componentName: タップされたUIコンポーネント
    func didTap(playerView: PlayerView, componentName: VideoPlayerView.ComponentName)
    /// プレイヤーの再生時間がシークなどによって不連続に再生時間が変更されたことを通知する
    /// - Parameter playerView: プレイヤービュー
    func didPlayerItemTimeJump(playerView: PlayerView)
}

class PlayerView: UIView {
    var baseView: UIView?
    var videoPlayerView: VideoPlayerView?
    
    weak var delegate: PlayerViewDelegate?
    
    var fullScreenVC: FullScreenVideoPlayerViewController?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let baseView = UIView(frame: frame)
        let videoPlayerView = Bundle.main.loadNibNamed("VideoPlayerView", owner: self, options: nil)?.first as! VideoPlayerView
        videoPlayerView.frame = frame
        videoPlayerView.delegate = self
        baseView.addSubview(videoPlayerView)
        addSubview(baseView)
        
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        baseView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        baseView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        baseView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor).isActive = true
        videoPlayerView.topAnchor.constraint(equalTo: baseView.topAnchor).isActive = true
        videoPlayerView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor).isActive = true
        videoPlayerView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor).isActive = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewDidEnterBackground(notification:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didChangeOrientation(notification:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
        self.baseView = baseView
        self.videoPlayerView = videoPlayerView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(videoURL: URL?) {
        videoPlayerView?.setVideoURL(url: videoURL)
    }
    
    func openFullScreenViewController() {
        internalOpenFullScreenViewController(openReason: .user)
    }
    
    func closeFullScreenViewController() {
        guard let fullScreenVC = self.fullScreenVC else { return }
        fullScreenVC.close()
    }
    
    func internalOpenFullScreenViewController(openReason: FullScreenVideoPlayerViewController.FullScreenOpenReason) {
        guard fullScreenVC == nil,
            let topVC = RootViewControllerGetter.getRootViewController(),
            let baseView = self.baseView else {
            return
        }
        let fullScreenVC = FullScreenVideoPlayerViewController(delegate: self,
                                                               baseView: baseView,
                                                               deviceOrientation: UIDevice.current.orientation,
                                                               openReason: openReason)
        self.fullScreenVC = fullScreenVC
        topVC.present(fullScreenVC,
                      animated: true,
                      completion: { [weak self] in
                        guard let sself = self else { return }
                        sself.videoPlayerView?.hideControlView()
                        sself.videoPlayerView?.play()
        })
    }
    
    @objc func viewDidEnterBackground(notification: Notification) {
        videoPlayerView?.pause()
    }
    
    @objc func didChangeOrientation(notification: NSNotification){
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            videoPlayerView?.expand()
        case .portrait:
            videoPlayerView?.collapse()
        default:
            break
        }
    }
}

extension PlayerView: VideoPlayerViewDelegate {
    func didPrepare(videoPlayerView: VideoPlayerView) {
        delegate?.didPrepare(playerView: self)
    }
    
    func didFailure(videoPlayerView: VideoPlayerView) {
        delegate?.didFailure(playerView: self)
    }
    
    func didUpdatePeriodicTimer(videoPlayerView: VideoPlayerView) {
        delegate?.didUpdatePeriodicTimer(playerView: self)
    }
    
    func didChange(videoPlayerView: VideoPlayerView, playerState: VideoPlayerState) {
        delegate?.didChange(playerView: self, playerState: playerState)
    }
    
    func didChange(videoPlayerView: VideoPlayerView, audioState: AudioState) {
        delegate?.didChange(playerView: self, audioState: audioState)
    }

    func didChange(videoPlayerView: VideoPlayerView, rate: Float) {
        delegate?.didChange(playerView: self, rate: rate)
    }

    func didChange(videoPlayerView: VideoPlayerView, effectiveRate: Float) {
        delegate?.didChange(playerView: self, effectiveRate: effectiveRate)
    }
    
    func didChange(videoPlayerView: VideoPlayerView, isExpand: Bool) {
        delegate?.didChange(playerView: self, isExpand: isExpand)
        if fullScreenVC == nil, isExpand {
            internalOpenFullScreenViewController(openReason: .deviceRotation)
        } else if let fullScreenVC = fullScreenVC, fullScreenVC.openReason != .user, !isExpand {
            // ユーザ指示以外でフルスクリーンが開かれていて、isExpandがfalse
            closeFullScreenViewController()
        }
    }
    
    func didPlaybackStalled(videoPlayerView: VideoPlayerView) {
        delegate?.didPlaybackStalled(playerView: self)
    }
    
    func didTap(videoPlayerView: VideoPlayerView, componentName: VideoPlayerView.ComponentName) {
        delegate?.didTap(playerView: self, componentName: componentName)
        if componentName == .fullScreenButton {
            videoPlayerView.hideControlView()
            videoPlayerView.pause()
            openFullScreenViewController()
        }
    }
    
    func didPlayerItemTimeJump(videoPlayerView: VideoPlayerView) {
        delegate?.didPlayerItemTimeJump(playerView: self)
    }
}

extension PlayerView: FullScreenVideoPlayerViewControllerDelegate {
    func willDismiss(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController) {
        videoPlayerView?.hideControlView()
    }
    
    func didDismiss(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController) {
        fullScreenVC = nil
    }
}
