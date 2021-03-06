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
    
    /// 設定画面のセミモーダルビューが表示されることを通知する
    /// - Parameter semiModalBaseViewController: 設定画面のセミモーダルビュー
    func willPresent(semiModalBaseViewController: SemiModalBaseViewController)
    /// 設定画面のセミモーダルビューが表示されたことを通知する
    /// - Parameter semiModalBaseViewController: 設定画面のセミモーダルビュー
    func didPresent(semiModalBaseViewController: SemiModalBaseViewController)
    /// 設定画面のセミモーダルビューが閉じることを通知する
    /// - Parameter semiModalBaseViewController: 設定画面のセミモーダルビュー
    func willDismiss(semiModalBaseViewController: SemiModalBaseViewController)
    /// 設定画面のセミモーダルビューが閉じたことを通知する
    /// - Parameter semiModalBaseViewController: 設定画面のセミモーダルビュー
    func didDismiss(semiModalBaseViewController: SemiModalBaseViewController)
    
    /// フルスクリーンが表示されることを通知する
    /// - Parameter fullScreenVideoPlayerViewController: フルスクリーン
    func willPresent(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController)
    /// フルスクリーンが表示されたことを通知する
    /// - Parameter fullScreenVideoPlayerViewController: フルスクリーン
    func didPresent(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController)
    /// フルスクリーンが閉じることを通知する
    /// - Parameter fullScreenVideoPlayerViewController: フルスクリーン
    func willDismiss(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController)
    /// フルスクリーンが閉じたことを通知する
    /// - Parameter fullScreenVideoPlayerViewController: フルスクリーン
    func didDismiss(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController)
    /// フルスクリーンの画面がタップされたことを通知する
    /// - Parameter fullScreenVideoPlayerViewController: フルスクリーン
    func didTap(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController)
}

/**
 - リポジトリを切り替えて、個人用のPCで開発できるようにする
 - currentVideoURLはPlayerView側
 - PlayerViewからリソース破棄命令を呼べるようにする
 - 動画リソースとしてモデルクラスを渡す形に修正する
 - シークサムネイルを渡せる・表示できるようにする
 - TwitterUI/YoutubeUI を切り替えれるようにする
 - 設定画面の項目の見直しと実装
 - 画面の自動回転制御対応・拡大縮小ボタンの非表示
 - iPad SlideOver・SplitViewの対応と確認
 - デリゲートメソッドの見直し
 - VideoPlayer, VideoPlayerView, PlayerVIewで同一のメソッド名に統一する
 - ライブラリの形にまとめる（名前：Rupin）
 ===
 - PiP・ネイティブのVC対応
 - ライブ対応
 - iPad用UI修正機能追加（ボタンサイズ変更など）
 - CI/CD対応
 - README.md英語対応
 */
class PlayerView: UIView {
    weak var baseView: UIView?
    weak var videoPlayerView: VideoPlayerView?
    
    weak var delegate: PlayerViewDelegate?
    
    var fullScreenVC: FullScreenVideoPlayerViewController?
    /// 設定の一覧を表示するセミモーダルビュー
    var settingViewController: SemiModalTableViewController?
    /// 設定一覧画面のデータソース
    let settingViewDataSouce = SettingViewDataSource()
    
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
        internalOpenFullScreenViewController(openReason: .callToOpenFullScreen)
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
                                                               interfaceOrientation: Orientation.shared.interfaceOrientation(topVC),
                                                               openReason: openReason)
        videoPlayerView?.hideControlView()
        videoPlayerView?.fullScreenButton.isHidden = true
        videoPlayerView?.pause()
        delegate?.willPresent(fullScreenVideoPlayerViewController: fullScreenVC)
        topVC.present(fullScreenVC,
                      animated: true,
                      completion: { [weak self] in
                        guard let sself = self else { return }
                        sself.videoPlayerView?.hideControlView()
                        sself.videoPlayerView?.play()
                        sself.delegate?.didPresent(fullScreenVideoPlayerViewController: fullScreenVC)
        })
        self.fullScreenVC = fullScreenVC
    }
    
    func openSettingViewController() {
        let settingViewController = SemiModalTableViewController.make()
        settingViewController.semiModalBaseViewControllerDelegate = self
        settingViewController.register(SettingViewDataSource.cellNib,
                                       forCellReuseIdentifier: SettingViewDataSource.cellReuseIdentifier)
        settingViewController.setDataSource(dataSource: settingViewDataSouce)
        delegate?.willPresent(semiModalBaseViewController: settingViewController)
        let presentCompletion = { [weak self] in
            guard let sself = self else { return }
            sself.delegate?.didPresent(semiModalBaseViewController: settingViewController)
        }
        if let fullScreenVC = self.fullScreenVC {
            fullScreenVC.present(settingViewController,
                                 animated: true,
                                 completion: presentCompletion)
        } else if let topVC = RootViewControllerGetter.getRootViewController() {
            topVC.present(settingViewController,
                          animated: true,
                          completion: presentCompletion)
        }
        self.settingViewController = settingViewController
    }
    
    func closeSettingViewController() {
        guard let settingViewController = settingViewController else { return }
        settingViewController.dismiss(animated: true, completion: nil)
    }
    
    func expand() {
        videoPlayerView?.expand()
    }
    
    func collapse() {
        videoPlayerView?.collapse()
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
            internalOpenFullScreenViewController(openReason: .callToExpand)
        } else if let fullScreenVC = fullScreenVC, fullScreenVC.openReason != .callToOpenFullScreen, !isExpand {
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
        } else if componentName == .listButton {
            openSettingViewController()
        }
    }
    
    func didPlayerItemTimeJump(videoPlayerView: VideoPlayerView) {
        delegate?.didPlayerItemTimeJump(playerView: self)
    }
}

extension PlayerView: SemiModalBaseViewControllerDelegate {
    func willDismiss(semiModalBaseViewController: SemiModalBaseViewController) {
        delegate?.willDismiss(semiModalBaseViewController: semiModalBaseViewController)
    }
    
    func didDismiss(semiModalBaseViewController: SemiModalBaseViewController) {
        settingViewController = nil
        delegate?.didDismiss(semiModalBaseViewController: semiModalBaseViewController)
    }
}

extension PlayerView: FullScreenVideoPlayerViewControllerDelegate {
    func willDismiss(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController) {
        videoPlayerView?.fullScreenButton.isHidden = false
        videoPlayerView?.hideControlView()
        delegate?.willDismiss(fullScreenVideoPlayerViewController: fullScreenVideoPlayerViewController)
    }
    
    func didDismiss(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController) {
        fullScreenVC = nil
        delegate?.didDismiss(fullScreenVideoPlayerViewController: fullScreenVideoPlayerViewController)
    }
    
    func didTap(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController) {
        guard let videoPlayerView = videoPlayerView else { return }
        if videoPlayerView.controlView.isHidden {
            videoPlayerView.showControlView()
        } else {
            videoPlayerView.hideControlView()
        }
        delegate?.didTap(fullScreenVideoPlayerViewController: fullScreenVideoPlayerViewController)
    }
}
