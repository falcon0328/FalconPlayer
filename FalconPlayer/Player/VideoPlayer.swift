//
//  VideoPlayer.swift
//  AVPlayerExample
//
//  Created by aseo on 2019/12/23.
//  Copyright © 2019 Falcon Tech. All rights reserved.
//

import UIKit
import AVFoundation

/// プレイヤーの状態
enum VideoPlayerState: Int {
    /// アイドル
    case idle
    /// バッファリング
    case buffering
    /// 再生
    case playing
    /// 停止
    case paused
    /// 再生完了
    case ended
    /// エラー
    case error
}

/// オーディオ状態
enum AudioState: Int {
    /// ミュート
    case mute
    /// アンミュート
    case unmute
}

/// プレイヤーの状態が変わったことを通知するデリゲート
protocol PlayerStateDelegate: class {
    /// プレイヤーの準備ができた
    /// - Parameter player: プレイヤー
    func didPrepare(player: VideoPlayer)
    
    /// プレイヤーでエラーが起きた
    /// - Parameter player: プレイヤー
    func didFailure(player: VideoPlayer)
    
    /// 動画再生中のタイマーが更新されたことを通知する
    /// - Parameter player: プレイヤー
    func didUpdatePeriodicTimer(player: VideoPlayer)
    
    /// プレイヤー状態が変わったことを通知する
    /// - Parameter player: プレイヤー
    /// - Parameter playerState: 変更後のプレイヤー状態
    func didChange(player: VideoPlayer, playerState: VideoPlayerState)
    
    /// オーディオ状態が変わったことを通知する
    /// - Parameter player: プレイヤー
    /// - Parameter audioState: 変更後のオーディオ状態
    func didChange(player: VideoPlayer, audioState: AudioState)
    
    /// プレイヤーの設定している再生速度がユーザによって変更されたことを通知する
    /// - Parameter player: プレイヤー
    /// - Parameter rate: 変更後の再生速度
    func didChange(player: VideoPlayer, rate: Float)
    
    /// プレイヤーの設定しているバッファリング中なども含めた実際の再生速度が変更されたことを通知する
    /// - Parameter player: プレイヤー
    /// - Parameter effectiveRate: 変更後の実際の再生速度
    func didChange(player: VideoPlayer, effectiveRate: Float)
}

class VideoPlayer: UIView {
    /// AVAsset生成時に読み込ませたいキーの一覧
    enum AssetLoadKeys: String {
        /// 再生可能かどうか
        case playable
    }
    
    private(set) var player: AVPlayer? {
        get {
            let layer = self.layer as! AVPlayerLayer
            return layer.player
        }
        set(newValue) {
            let layer = self.layer as! AVPlayerLayer
            layer.player = newValue
        }
    }
    /// プレイヤーの状態
    private(set) var playerState: VideoPlayerState = .idle {
        didSet {
            if oldValue == playerState { return }
            delegate?.didChange(player: self, playerState: playerState)
        }
    }
    
    var audioState: AudioState {
        guard let player = self.player else {
            return .unmute
        }
        if player.isMuted {
            return .mute
        } else {
            return .unmute
        }
    }
    /// プレイヤーの現在の位置
    var currentTime: Float {
        guard let player = self.player else {
            return 0.0
        }
        return Float(CMTimeGetSeconds(player.currentTime()))
    }
    /// プレイヤー動画をバッファできている時間
    var bufferLoadedRange: Float {
        guard let timeRangeValue = player?.currentItem?.loadedTimeRanges.last?.timeRangeValue else {
            return 0.0
        }
        return Float(CMTimeGetSeconds(CMTimeAdd(timeRangeValue.start, timeRangeValue.duration)))
    }
    /// 動画尺
    var duration: Float {
        guard let duration = player?.currentItem?.asset.duration else {
            return 0.0
        }
        return Float(CMTimeGetSeconds(duration))
    }
    /// ユーザの設定している再生速度
    var rate: Float {
        guard let rate = player?.rate else {
            return 0.0
        }
        return rate
    }
    /// バッファリング中なども含めた実際の再生速度
    var effectiveRate: Float = 0.0 {
        didSet {
            if effectiveRate == oldValue { return }
            delegate?.didChange(player: self, effectiveRate: effectiveRate)
        }
    }
    /// プレイヤーの状態が変わったことを通知するデリゲート
    weak var delegate: PlayerStateDelegate?
    /// TimeObserverのインスタンス
    var timeObserverToken: Any?
    /// AVPlayerのPeriodicTimerで動作する関数
    var periodicTimerFunction: ((CMTime) -> Void)?
    /// AVPlayerのRate監視をしているインスタンス
    var playerRateObservation: NSKeyValueObservation?
    /// AVPlayerItemのKVO監視をしているインスタンス
    var playerItemStatusObservation: NSKeyValueObservation?
    /// AVPlayerの現状のステータス監視をしているインスタンス
    var playerTimeControlStatusObservation: NSKeyValueObservation?

    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    deinit {
        releaseVideoPlayer()
    }
    
    /// AVPlayerをセットし、各種オブザーバーを起動させる
    /// - Parameter player: プレイヤー
    func setPlayer(player: AVPlayer?) {
        self.player = player
        setPlayerObserver()
        setDidPlayToEndTimeNotification()
        setTimeBaseEffectiveRateChanged()
    }
    
    /// 動画のURLを設定し、プレイヤーを生成する
    /// - Parameter url: 動画のURL
    func setVideoURL(url: URL?) {
        guard let url = url else {
            delegate?.didFailure(player: self)
            return
        }
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: [AssetLoadKeys.playable.rawValue],
                                       completionHandler: { [weak self] in
                                        guard let sself = self else {
                                            return
                                        }
                                        var error: NSError?
                                        let status = asset.statusOfValue(forKey: AssetLoadKeys.playable.rawValue,
                                                                         error: &error)
                                        DispatchQueue.main.async {
                                            switch status {
                                            case .loaded:
                                                let playerItem = AVPlayerItem(asset: asset)
                                                let player = AVPlayer(playerItem: playerItem)
                                                sself.setPlayer(player: player)
                                            default:
                                                sself.playerState = .error
                                                sself.delegate?.didFailure(player: sself)
                                            }
                                        }
        })
    }
    
    func setPeriodicTimeObserver(interval: CMTime) {
        removePeriodicTimeObserver()
        let periodicTimerFunction: ((CMTime) -> Void) = { [weak self] time in
            guard let wself = self else { return }
            wself.delegate?.didUpdatePeriodicTimer(player: wself)
        }
        self.periodicTimerFunction = periodicTimerFunction
        // メインスレッドでコールバックさせる
        let mainQueue = DispatchQueue.main
        // タイマーオブザーバーを用意する
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval,
                                                            queue: mainQueue,
                                                            using: periodicTimerFunction)
    }
    
    func removePeriodicTimeObserver() {
        guard let timeObserverToken = timeObserverToken else {
            return
        }
        player?.removeTimeObserver(timeObserverToken)
        self.timeObserverToken = nil
        periodicTimerFunction = nil
    }
    
    func setPlayerObserver() {
        removePlayerObserver()
        playerItemStatusObservation = self.player?.currentItem?.observe(\.status, changeHandler: { [weak self] playerItem, change in
            guard let wself = self else {
                return
            }
            wself.playerItemStatusChangeHandler(playerItemStatus: playerItem.status)
        })
        playerRateObservation = self.player?.observe(\.rate, changeHandler: { [weak self] player, change in
            guard let wself = self else {
                return
            }
            wself.playerRateChangeHandler(rate: player.rate)
        })
        // timeControlStatus
        playerTimeControlStatusObservation = self.player?.observe(\.timeControlStatus, changeHandler: { [weak self] player, change in
            guard let sSelf = self else {
                return
            }
            sSelf.playerTimeControlStatusChangeHandler(timeControlStatus: player.timeControlStatus)
        })
    }
    
    func removePlayerObserver() {
        playerItemStatusObservation?.invalidate()
        playerItemStatusObservation = nil
        playerRateObservation?.invalidate()
        playerRateObservation = nil
        playerTimeControlStatusObservation?.invalidate()
        playerTimeControlStatusObservation = nil
    }
    
    func setDidPlayToEndTimeNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didPlayToEndTimeNotification(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    func removeDidPlayToEndTimeNotification() {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: player?.currentItem)
    }
    
    func setTimeBaseEffectiveRateChanged() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didTimeBaseEffectiveRateChanged(notification:)),
                                               name: Notification.Name(rawValue: String(kCMTimebaseNotification_EffectiveRateChanged)),
                                               object: player?.currentItem?.timebase)
    }
    
    func removeTimeBaseEffectiveRateChanged() {
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(rawValue: String(kCMTimebaseNotification_EffectiveRateChanged)),
                                                  object: player?.currentItem?.timebase)
    }
    
    func setVideoGravity(videoGravity: AVLayerVideoGravity) {
        (layer as! AVPlayerLayer).videoGravity = videoGravity
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func seek(to: Float, completionHandler: @escaping (Bool) -> Void) {
        player?.seek(to: CMTimeMakeWithSeconds(Float64(to), preferredTimescale: Int32(NSEC_PER_SEC)),
                     toleranceBefore: CMTime.zero,
                     toleranceAfter: CMTime.zero,
                     completionHandler: { [weak self] finished in
                        guard let strongSelf = self else {
                            return
                        }
                        if strongSelf.playerState == .ended {
                            strongSelf.playerState = .paused
                        }
                        completionHandler(finished)
        })
    }
    
    func replay() {
        seek(to: 0.0, completionHandler: { [weak self] finished in
            guard let strongSelf = self else {
                return
            }
            strongSelf.play()
        })
    }
    
    func mute() {
        player?.isMuted = true
        delegate?.didChange(player: self, audioState: self.audioState)
    }
    
    func unmute() {
        player?.isMuted = false
        delegate?.didChange(player: self, audioState: self.audioState)
    }
    
    /// プレイヤーの破棄を行う
    func releaseVideoPlayer() {
        removePeriodicTimeObserver()
        removePlayerObserver()
        removeDidPlayToEndTimeNotification()
        removeTimeBaseEffectiveRateChanged()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerState = .idle
    }
    
    /// AVPlayerItemのステータスによってコールバックの内容を変更する
    /// - Parameter playerItemStatus: AVPlayerItemのステータス
    func playerItemStatusChangeHandler(playerItemStatus: AVPlayerItem.Status) {
        if playerItemStatus == .readyToPlay {
            // 初回のreadyToPlay時は、ステータスをpausedにしプレイヤーの準備成功をコールバックする
            if playerState == .idle {
                playerState = .paused
                delegate?.didPrepare(player: self)
                return
            }
        } else {
            playerState = .error
            delegate?.didFailure(player: self)
        }
    }
    
    /// AVPlayerのrateが変更された際のコールバックメソッド
    /// - Parameter rate:
    func playerRateChangeHandler(rate: Float) {
        delegate?.didChange(player: self, rate: rate)
    }
    
    /// AVPlayerのtimeControlStatusが変更された際に何をコールバックするか決定するメソッド
    /// - Parameter timeControlStatus: プレイヤーの再生状態
    /// - Warning: 再生完了後はシークするまで動作しない
    func playerTimeControlStatusChangeHandler(timeControlStatus: AVPlayer.TimeControlStatus) {
        switch timeControlStatus {
        case .paused:
            if playerState == .ended { return }
            playerState = .paused
        case .playing:
            playerState = .playing
        case .waitingToPlayAtSpecifiedRate:
            playerState = .buffering
        @unknown default:
            playerState = .idle
        }
    }
    
    @objc func didPlayToEndTimeNotification(notification: Notification) {
        playerState = .ended
    }
    
    @objc func didTimeBaseEffectiveRateChanged(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let timebase = self?.player?.currentItem?.timebase else {
                return
            }
            let effectiveRate = Float(CMTimebaseGetRate(timebase))
            self?.effectiveRate = effectiveRate
        }
    }
}
