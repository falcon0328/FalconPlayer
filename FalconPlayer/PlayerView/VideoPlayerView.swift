//
//  VideoPlayerView.swift
//  AVPlayerExample
//
//  Created by aseo on 2019/12/22.
//  Copyright © 2019 Falcon Tech. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol VideoPlayerViewDelegate: class {
    /// プレイヤービューの準備ができた
    /// - Parameter videoPlayerView: プレイヤービュー
    func didPrepare(videoPlayerView: VideoPlayerView)
    /// プレイヤービューの準備が失敗した
    /// - Parameter videoPlayerView: プレイヤービュー
    func didFailure(videoPlayerView: VideoPlayerView)
    /// プレイヤービュー内で再生中のプレイヤーのタイマーが更新されたことを通知する
    /// - Parameter videoPlayerView: プレイヤービュー
    func didUpdatePeriodicTimer(videoPlayerView: VideoPlayerView)
    /// プレイヤービュー内のプレイヤー状態が変わったことを通知する
    /// - Parameter videoPlayerView: プレイヤービュー
    /// - Parameter playerState: 変更後のプレイヤー状態
    func didChange(videoPlayerView: VideoPlayerView, playerState: VideoPlayerState)
    /// プレイヤービュー内のプレイヤーのオーディオ状態が変わったことを通知する
    /// - Parameter videoPlayerView: プレイヤービュー
    /// - Parameter audioState: 変更後のオーディオ状態
    func didChange(videoPlayerView: VideoPlayerView, audioState: AudioState)
    /// プレイヤービュー内のプレイヤーの設定している再生速度がユーザによって変更されたことを通知する
    /// - Parameter videoPlayerView: プレイヤービュー
    /// - Parameter rate: 変更後の再生速度
    func didChange(videoPlayerView: VideoPlayerView, rate: Float)
    /// プレイヤービュー内のプレイヤーの設定しているバッファリング中なども含めた実際の再生速度が変更されたことを通知する
    /// - Parameter videoPlayerView: プレイヤービュー
    /// - Parameter effectiveRate: 変更後の実際の再生速度
    func didChange(videoPlayerView: VideoPlayerView, effectiveRate: Float)
    /// プレイヤービュー内のプレイヤーがバッファリング状況によってストール状態になった
    /// - Parameter videoPlayerView: プレイヤービュー
    func didPlaybackStalled(videoPlayerView: VideoPlayerView)
    /// プレイヤービュー内の各UIコンポーネントがタップされた
    /// - Parameter videoPlayerView: プレイヤービュー
    /// - Parameter componentName: タップされたUIコンポーネント
    func didTap(videoPlayerView: VideoPlayerView, componentName: VideoPlayerView.ComponentName)
    /// プレイヤーの再生時間がシークなどによって不連続に再生時間が変更されたことを通知する
    /// - Parameter videoPlayerView: プレイヤービュー
    func didPlayerItemTimeJump(videoPlayerView: VideoPlayerView)
}

class VideoPlayerView: UIView {
    /// 各UI要素の名前
    enum ComponentName: String {
        case videoPlayer
        case errorView
        case controlView
        case listButton
        case fullScreenButton
        case playButton
        case pauseButton
        case replayButton
        case gobackward10Button
        case goforward10Button
        case muteButton
        case unmuteButton
        case expandButton
        case collapseButton
        case routePickerView
    }
    
    static let SEEKBAR_THUMB_SIZE: CGFloat = 12.0
    
    var videoPlayerViewFrame: CGRect?
    weak var delegate: VideoPlayerViewDelegate?
    /// 拡大中かどうかを示すフラグ
    var isExpand = false
    /// シークバーを操作したことによるシーク処理をしている間かどうかを示すフラグ
    var isSeekFromBar = false
    /// シークバーに触れているかどうかを示すフラグ
    var isTouchSeekbar = false
    
    @IBOutlet weak var videoPlayer: VideoPlayer!
    @IBOutlet weak var seekbar: VideoPlayerSeekbar!
    @IBOutlet weak var bufferbar: UISlider!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var routePickerBaseView: UIView!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var gobackward10Button: UIButton!
    @IBOutlet weak var goforward10Button: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var muteUnmuteButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var expandCollapseButton: UIButton!
    @IBOutlet weak var bufferActivityIndicatiorView: UIActivityIndicatorView!
    
    var routePickerView: AVRoutePickerView!
    
    /// シークサムネイルを表示するView
    var seekThumbnailView: VideoPlayerSeekThumbnailView!
    
    /// サムネイルを表示するView
    var thumbnailView: ThumbnailView!
    
    /// 設定の一覧を表示するセミモーダルビュー
    var settingViewController: SemiModalTableViewController!
    /// 設定一覧画面のデータソース
    let settingViewDataSouce = SettingViewDataSource()
    /// 再生中の動画URL
    var currentVideoURL: URL?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Portrait時に指定するFrame情報
    func setPortraitFrame(_ frame: CGRect) {
        videoPlayerViewFrame = frame
    }
    
    func setVideoURL(url: URL?) {
        currentVideoURL = url
        videoPlayer.setVideoURL(url: url)
    }
    
    /// 内部のプレイヤーを破棄させる
    func releaseVideoPlayer() {
        videoPlayer.releaseVideoPlayer()
    }
    
    override func awakeFromNib() {
        videoPlayer.delegate = self
        let videoPlayerTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapVideoView))
        videoPlayer.addGestureRecognizer(videoPlayerTapGesture)
        
        seekbar.minimumValue = 0
        seekbar.maximumValue = 0
        seekbar.setValue(0, animated: false)
        seekbar.setThumbImage(makeCircleWith(size: CGSize(width: VideoPlayerView.SEEKBAR_THUMB_SIZE,height: VideoPlayerView.SEEKBAR_THUMB_SIZE),backgroundColor: .red),
                              for: .normal)
        bufferbar.isUserInteractionEnabled = false
        bufferbar.minimumValue = 0
        bufferbar.maximumValue = 0
        bufferbar.setValue(0, animated: false)
        bufferbar.setThumbImage(makeCircleWith(size: CGSize(width: 0.01, height: 0.01), backgroundColor: .white),
                                for: .normal)
        controlView.isHidden = true
        controlView.alpha = 0
        let controlViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapControlView))
        controlView.addGestureRecognizer(controlViewTapGesture)
        
        hideErrorView()
        
        let seekThumbnailView = Bundle.main.loadNibNamed("VideoPlayerSeekThumbnailView",
                                                         owner: self,
                                                         options: nil)?.first as! VideoPlayerSeekThumbnailView
        controlView.addSubview(seekThumbnailView)
        self.seekThumbnailView = seekThumbnailView
        hideSeekThumbnailView()
        
        let routePickerView = AVRoutePickerView(frame: routePickerBaseView.bounds)
        routePickerView.tintColor = .white
        routePickerView.delegate = self
        self.routePickerView = routePickerView
        routePickerBaseView.addSubview(routePickerView)
        
        hideBufferActivityIndicatorView()
        
        let thumbnailView = Bundle.main.loadNibNamed("ThumbnailView",
                                                     owner: self,
                                                     options: nil)?.first as! ThumbnailView
        thumbnailView.setImage(image: UIImage(named: "BigBuckBunny"))
        insertSubview(thumbnailView, aboveSubview: errorView)
        self.thumbnailView = thumbnailView
        showThumbnailView()
        
        settingViewController = SemiModalTableViewController.make()
        settingViewController.register(SettingViewDataSource.cellNib, forCellReuseIdentifier: SettingViewDataSource.cellReuseIdentifier)
        settingViewController.setDataSource(dataSource: settingViewDataSouce)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewWillEnterForeground(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewDidEnterBackground(notification:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didChangeOrientation(notification:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    func play() {
        videoPlayer.play()
    }
    
    func pause() {
        videoPlayer.pause()
    }
    
    func seek(to: Float, completionHandler: @escaping (Bool) -> Void) {
        videoPlayer.seek(to: to, completionHandler: completionHandler)
    }
    
    /// 動画を最初から再生する
    func replay() {
        videoPlayer.replay()
    }
    
    /// 動画のリソース取得から再度行う
    func retry() {
        hideErrorView()
        showThumbnailView()
        releaseVideoPlayer()
        setVideoURL(url: currentVideoURL)
    }
    
    func expand() {
        if isExpand { return }
        isExpand = true
        expandCollapseButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left"), for: .normal)
    }
    
    func collapse() {
        if !isExpand { return }
        isExpand = false
        expandCollapseButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
    }
    
    /// 円形画像を作成するプログラム
    /// [参考文献](https://www.code-adviser.com/detail_42092907)
    /// - Parameter size: 丸のサイズ
    /// - Parameter backgroundColor: 赤色
    func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    @IBAction func didTapPlayPauseButton(_ sender: Any) {
        switch videoPlayer.playerState {
        case .playing:
            delegate?.didTap(videoPlayerView: self, componentName: .pauseButton)
            pause()
        case .paused:
            delegate?.didTap(videoPlayerView: self, componentName: .playButton)
            play()
        case .ended:
            delegate?.didTap(videoPlayerView: self, componentName: .replayButton)
            replay()
        default:
            break
        }
        updatePlayPauseButtonImage()
    }
    
    @IBAction func didTapForward10secButton(_ sender: Any) {
        delegate?.didTap(videoPlayerView: self, componentName: .goforward10Button)
        videoPlayer.seek(to: videoPlayer.currentTime + 10.0,
                         completionHandler: { finished in
            
        })
    }
    
    @IBAction func didTapBackward10secButton(_ sender: Any) {
        delegate?.didTap(videoPlayerView: self, componentName: .gobackward10Button)
        videoPlayer.seek(to: videoPlayer.currentTime - 10.0,
                         completionHandler: { finished in
            
        })
    }
    
    @IBAction func didTapMuteUnmuteButton(_ sender: Any) {
        if videoPlayer.audioState == .mute {
            delegate?.didTap(videoPlayerView: self, componentName: .unmuteButton)
            videoPlayer.unmute()
        } else {
            delegate?.didTap(videoPlayerView: self, componentName: .muteButton)
            videoPlayer.mute()
        }
    }
    
    @IBAction func didTapExpandCollapseButton(_ sender: Any) {
        if isExpand {
            delegate?.didTap(videoPlayerView: self, componentName: .collapseButton)
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue,
                                      forKey: "orientation")

        } else {
            delegate?.didTap(videoPlayerView: self, componentName: .expandButton)
            UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue,
                                      forKey: "orientation")

        }
    }
    
    @IBAction func didTapListButton(_ sender: Any) {
        delegate?.didTap(videoPlayerView: self,
                         componentName: .listButton)
        guard let topVC = RootViewControllerGetter.getRootViewController() else {
            return
        }
        topVC.present(settingViewController,
                      animated: true,
                      completion: nil)
    }
    
    @IBAction func didTapFullScreenButton(_ sender: Any) {
        delegate?.didTap(videoPlayerView: self,
                         componentName: .fullScreenButton)
    }
    
    @IBAction func didTouchStartSeekbar(_ sender: Any) {
        isTouchSeekbar = true
        if !isSeekFromBar {
            // シーク中扱いにし、UIを更新する
            isSeekFromBar = true
            hideButtons()
        }
        showSeekThumbnailView()
    }
    
    @IBAction func didTouchFinishSeekbar(_ sender: Any) {
        // シークバーから指が離れた
        isTouchSeekbar = false
        if !isSeekFromBar {
            return
        }
        hideSeekThumbnailView()
        showButtons()
        seek(to: seekbar.value,
             completionHandler: { finish in
                self.isSeekFromBar = false
        })
    }
    
    func showControlView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.controlView.alpha = 0.8
            self.controlView.isHidden = false
        }, completion: { finished in })
    }
    
    func hideControlView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.controlView.alpha = 0.0
        }, completion: { finished in
            self.controlView.isHidden = true
        })
    }
    
    
    /// 10秒戻る・進むボタンと再生停止ボタンを表示する
    func showButtons() {
        listButton.isHidden = false
        routePickerBaseView.isHidden = false
        goforward10Button.isHidden = false
        gobackward10Button.isHidden = false
        playPauseButton.isHidden = false
    }
    
    /// 10秒戻る・進むボタンと再生停止ボタンを非表示する
    func hideButtons() {
        listButton.isHidden = true
        routePickerBaseView.isHidden = true
        goforward10Button.isHidden = true
        gobackward10Button.isHidden = true
        playPauseButton.isHidden = true
    }
    
    /// エラー画面を表示にする
    func showErrorView() {
        hideThumbnailView()
        errorView.isHidden = false
        controlView.isHidden = true
        seekbar.isHidden = true
        bufferbar.isHidden = true
    }
    
    /// エラー画面を非表示にする
    func hideErrorView() {
        errorView.isHidden = true
        seekbar.isHidden = false
        bufferbar.isHidden = false
    }
    
    /// シークサムネイルを表示する
    func showSeekThumbnailView() {
        seekThumbnailView.isHidden = false
        seekThumbnailView.updateCurrentTime(currentTime: seekbar.value)
//        seekThumbnailView.updateThumbnail(image: nil)
        updatePositionToSeekThumbnailView()
    }
    
    /// シークサムネイルを非表示にする
    ///
    /// シークサムネイルの表示位置の更新は呼ぶ
    func hideSeekThumbnailView() {
        seekThumbnailView.isHidden = true
    }
    
    /// シークサムネイルの位置を更新する
    func updatePositionToSeekThumbnailView() {
        seekThumbnailView.translatesAutoresizingMaskIntoConstraints = true
        let seekbarThumbFrameCenterX = seekbar.thumbFrame.origin.x + VideoPlayerView.SEEKBAR_THUMB_SIZE / 2.0
        let tmpX: CGFloat = seekbarThumbFrameCenterX - seekThumbnailView.frame.width / 2.0
        // シークサムネイルがシークバーの中で完結するように座標を修正
        var x = tmpX
        if tmpX <= seekbar.frame.origin.x {
            x = seekbar.frame.origin.x
        } else if (tmpX + seekThumbnailView.frame.width) >= (seekbar.frame.origin.x + seekbar.frame.width) {
            x = (seekbar.frame.origin.x + seekbar.frame.width) - seekThumbnailView.frame.width
        }
        let y = seekbar.thumbFrame.origin.y - seekThumbnailView.frame.height - 16.0
        seekThumbnailView.frame = CGRect(x: x,
                                         y: y,
                                         width: seekThumbnailView.frame.width,
                                         height: seekThumbnailView.frame.height)
    }
    
    func updatePlayPauseButtonImage() {
        switch videoPlayer.playerState {
        case .playing:
            let pauseImage = UIImage(systemName: "pause")
            playPauseButton.setBackgroundImage(pauseImage, for: .normal)
        case .paused:
            let playImage = UIImage(systemName: "play")
            playPauseButton.setBackgroundImage(playImage, for: .normal)
        case .ended:
            let reloadImage = UIImage(systemName: "arrow.clockwise")
            playPauseButton.setBackgroundImage(reloadImage, for: .normal)
        default:
            break
        }
    }
    
    func updateMuteUnmuteButtonImage() {
        if videoPlayer.audioState == .mute {
            let unmuteImage = UIImage(systemName: "speaker.slash")
            muteUnmuteButton.setImage(unmuteImage, for: .normal)
        } else {
            let unmuteImage = UIImage(systemName: "speaker.3")
            muteUnmuteButton.setImage(unmuteImage, for: .normal)
        }
    }
    
    /// バッファリング中を示すインジケーターを表示する
    func showBufferActivityIndicatorView() {
        playPauseButton.isHidden = true
        bufferActivityIndicatiorView.isHidden = false
        bufferActivityIndicatiorView.startAnimating()
    }
    
    /// バッファリング中を示すインジケーターを非表示にする
    func hideBufferActivityIndicatorView() {
        playPauseButton.isHidden = false
        bufferActivityIndicatiorView.isHidden = true
        bufferActivityIndicatiorView.stopAnimating()
    }
    
    ///　バッファリング中を示すインジケーターの状態をplayerStateに合わせて更新する
    func updateBufferActivityIndicatorView(playerState: VideoPlayerState) {
        if playerState == .buffering {
            showBufferActivityIndicatorView()
        } else {
            hideBufferActivityIndicatorView()
        }
    }
    
    /// サムネイルを表示する
    func showThumbnailView() {
        thumbnailView.loadImage()
        thumbnailView.isHidden = false
        thumbnailView.alpha = 1.0
    }
    
    /// サムネイルを非表示にする
    func hideThumbnailView() {
        thumbnailView.stopAnimating()
        UIView.animate(withDuration: 0.5,
                       animations: { [weak self] in
                        self?.thumbnailView.alpha = 0.0
        },
                       completion: { [weak self] finished in
                        self?.thumbnailView.isHidden = true
        })
    }
    
    @objc func viewWillEnterForeground(notification: Notification) {}

    
    @objc func viewDidEnterBackground(notification: Notification) {
        pause()
    }
    
    @objc func timerUpdate() {
        hideControlView()
    }
    
    @objc func didChangeOrientation(notification: NSNotification){
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            expand()
        case .portrait:
            collapse()
        default:
            break
        }
    }
    
    @objc func didTapVideoView() {
        delegate?.didTap(videoPlayerView: self, componentName: .videoPlayer)
        if videoPlayer.playerState != .error {
            showControlView()
        } else {
            retry()
        }
    }
    
    @objc func didTapControlView() {
        delegate?.didTap(videoPlayerView: self, componentName: .controlView)
        if videoPlayer.playerState != .error {
            hideControlView()
        }
    }
}

extension VideoPlayerView: PlayerStateDelegate {
    func didPrepare(player: VideoPlayer) {
        hideThumbnailView()
        videoPlayer.setVideoGravity(videoGravity: .resize)
        durationLabel.text = VideoPlayerTimeFormatter.format(time: videoPlayer.duration)
        seekbar.maximumValue = videoPlayer.duration
        bufferbar.maximumValue = videoPlayer.duration
        videoPlayer.setPeriodicTimeObserver(interval: CMTime(value: 5, timescale: 10))
        videoPlayer.mute()
        delegate?.didPrepare(videoPlayerView: self)
    }
    
    func didFailure(player: VideoPlayer) {
        showErrorView()
        delegate?.didFailure(videoPlayerView: self)
    }
    
    func didUpdatePeriodicTimer(player: VideoPlayer) {
        currentTimeLabel.text = VideoPlayerTimeFormatter.format(time: videoPlayer.currentTime)
        bufferbar.setValue(videoPlayer.bufferLoadedRange, animated: true)
        if !isSeekFromBar {
            seekbar.setValue(videoPlayer.currentTime, animated: true)
        } else if isSeekFromBar && !isTouchSeekbar {
            currentTimeLabel.text = VideoPlayerTimeFormatter.format(time: seekbar.value)
        }
        delegate?.didUpdatePeriodicTimer(videoPlayerView: self)
    }
    
    func didChange(player: VideoPlayer, playerState: VideoPlayerState) {
        updateBufferActivityIndicatorView(playerState: playerState)
        updatePlayPauseButtonImage()
        delegate?.didChange(videoPlayerView: self, playerState: playerState)
    }
    
    func didChange(player: VideoPlayer, audioState: AudioState) {
        updateMuteUnmuteButtonImage()
        delegate?.didChange(videoPlayerView: self, audioState: audioState)
    }
    
    func didChange(player: VideoPlayer, rate: Float) {
        delegate?.didChange(videoPlayerView: self, rate: rate)
    }
    
    func didChange(player: VideoPlayer, effectiveRate: Float) {
        delegate?.didChange(videoPlayerView: self, effectiveRate: effectiveRate)
    }
    
    func didPlaybackStalled(playr: VideoPlayer) {
        delegate?.didPlaybackStalled(videoPlayerView: self)
    }
    
    func didPlayerItemTimeJump(player: VideoPlayer) {
        delegate?.didPlayerItemTimeJump(videoPlayerView: self)
    }
}

extension VideoPlayerView: AVRoutePickerViewDelegate {
    func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        delegate?.didTap(videoPlayerView: self, componentName: .routePickerView)
    }
    
    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {}
}
