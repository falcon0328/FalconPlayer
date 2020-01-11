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
    func didPrepareToPlayer(player: VideoPlayer)
    
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
}

class VideoPlayer: UIView {
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

    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    deinit {
        removePeriodicTimeObserver()
        removePlayerObserver()
        removeDidPlayToEndTimeNotification()
    }
    
    func setPlayer(player: AVPlayer?) {
        self.player = player
        setPlayerObserver()
        setDidPlayToEndTimeNotification()
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
    }
    
    func removePlayerObserver() {
        playerItemStatusObservation?.invalidate()
        playerItemStatusObservation = nil
        playerRateObservation?.invalidate()
        playerRateObservation = nil
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
    
    /// AVPlayerItemのステータスによってコールバックの内容を変更する
    /// - Parameter playerItemStatus: AVPlayerItemのステータス
    func playerItemStatusChangeHandler(playerItemStatus: AVPlayerItem.Status) {
        if playerItemStatus == .readyToPlay {
            delegate?.didPrepareToPlayer(player: self)
        } else {
            playerState = .error
        }
    }
    
    /// AVPlayerのrateが変更された際のコールバックメソッド
    /// - Parameter rate:
    func playerRateChangeHandler(rate: Float) {
        if rate == 0.0 {
            if playerState == .ended { return }
            playerState = .paused
        } else {
            playerState = .playing
        }
    }
    
    @objc func didPlayToEndTimeNotification(notification: Notification) {
        playerState = .ended
    }
}
