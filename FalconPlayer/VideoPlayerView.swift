//
//  VideoPlayerView.swift
//  AVPlayerExample
//
//  Created by aseo on 2019/12/22.
//  Copyright © 2019 Falcon Tech. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoPlayerViewDelegate: class {
    func didTap(videoPlayerView: VideoPlayerView, componentName: String)
}

class VideoPlayerView: UIView {
    var isExpand = false
    var videoPlayerViewFrame: CGRect!
    weak var delegate: VideoPlayerViewDelegate?
    
    @IBOutlet weak var videoPlayer: VideoPlayer!
    @IBOutlet weak var seekbar: UISlider!
    @IBOutlet weak var bufferbar: UISlider!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var muteUnmuteButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var expandCollapseButton: UIButton!
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didEnterBackgroundNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
    }
    
    func setPlayer(player: AVPlayer?) {
        videoPlayer.setPlayer(player: player)
        videoPlayer.setVideoGravity(videoGravity: .resize)
        durationLabel.text = VideoPlayerTimeFormatter.format(time: videoPlayer.duration)
        seekbar.maximumValue = videoPlayer.duration
        bufferbar.maximumValue = videoPlayer.duration
        videoPlayer.setPeriodicTimeObserver(interval: CMTime(value: 5, timescale: 10))
        videoPlayer.delegate = self
        videoPlayer.mute()
    }
    
    override func awakeFromNib() {
        seekbar.minimumValue = 0
        seekbar.maximumValue = 0
        seekbar.setValue(0, animated: false)
        seekbar.setThumbImage(makeCircleWith(size: CGSize(width: 12, height: 12), backgroundColor: .red), for: .normal)
        bufferbar.isUserInteractionEnabled = false
        bufferbar.minimumValue = 0
        bufferbar.maximumValue = 0
        bufferbar.setValue(0, animated: false)
        bufferbar.setThumbImage(makeCircleWith(size: CGSize(width: 0.01, height: 0.01), backgroundColor: .white), for: .normal)
        controlView.isHidden = true
        controlView.alpha = 0
        hideErrorView()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewWillEnterForeground(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewDidEnterBackground(notification:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didChangeOrientation(notification:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    func play() {
        videoPlayer.play()
    }
    
    func pause() {
        videoPlayer.pause()
    }
    
    func seek(to: Double, completionHandler: @escaping (Bool) -> Void) {
        videoPlayer.seek(to: to, completionHandler: completionHandler)
    }
    
    func expand(transform: CGAffineTransform) {
         if isExpand {
            return
        }
        isExpand = true
        
        videoPlayerViewFrame = superview!.frame
        UIView.animate(withDuration: 0.5, animations: {
            self.superview?.translatesAutoresizingMaskIntoConstraints = true
            self.superview?.transform = transform
            self.superview?.frame = CGRect(x: 0,
                                           y: 0,
                                           width: UIScreen.main.bounds.width,
                                           height: UIScreen.main.bounds.height)
        })

        let collapseImage = UIImage(systemName: "arrow.down.right.and.arrow.up.left")
        expandCollapseButton.setBackgroundImage(collapseImage, for: .normal)
    }
    
    func expand() {
        expand(transform: calcurateTransform(deviceOrientation: UIDevice.current.orientation))
    }
    
    func collapse() {
        if !isExpand {
            return
        }
        isExpand = false
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.superview?.translatesAutoresizingMaskIntoConstraints = true
                        self.superview?.transform = self.calcurateTransform(deviceOrientation: UIDevice.current.orientation)
                        self.superview?.frame = self.videoPlayerViewFrame
        }, completion: { finished in })
        
        let expandImage = UIImage(systemName: "arrow.up.left.and.arrow.down.right")
        self.expandCollapseButton.setBackgroundImage(expandImage, for: .normal)
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
        if videoPlayer.playerState == .playing {
            videoPlayer.pause()
        } else {
            videoPlayer.play()
        }
        updatePlayPauseButtonImage()
    }
    
    @IBAction func didTapForward10secButton(_ sender: Any) {
        videoPlayer.seek(to: Double(videoPlayer.currentTime + 10.0),
                         completionHandler: { finished in
            
        })
    }
    
    @IBAction func didTapBackward10secButton(_ sender: Any) {
        videoPlayer.seek(to: Double(videoPlayer.currentTime - 10.0),
                         completionHandler: { finished in
            
        })
    }
    
    @IBAction func didTapMuteUnmuteButton(_ sender: Any) {
        if videoPlayer.audioState == .mute {
            videoPlayer.unmute()
        } else {
            videoPlayer.mute()
        }
    }
    
    @IBAction func didTapExpandCollapseButton(_ sender: Any) {
        if isExpand {
            collapse()
        } else {
            expand(transform: CGAffineTransform(rotationAngle: (90 * .pi) / 180))
        }
    }
    
    @IBAction func didTapListButton(_ sender: Any) {
        delegate?.didTap(videoPlayerView: self,
                         componentName: "List")
        guard let topVC = RootViewControllerGetter.getRootViewController() else {
            return
        }
        topVC.present(SemiModalViewController.make(),
                      animated: true,
                      completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if videoPlayer.playerState == .error {
            // TODO: リロード
            return
        }
        if controlView.isHidden {
            showControlView()
        } else {
            hideControlView()
        }
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
    
    /// エラー画面を表示にする
    func showErrorView() {
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
    
    func updatePlayPauseButtonImage() {
        if videoPlayer.playerState == .playing {
            let pauseImage = UIImage(systemName: "pause")
            playPauseButton.setBackgroundImage(pauseImage, for: .normal)
        } else {
            let playImage = UIImage(systemName: "play")
            playPauseButton.setBackgroundImage(playImage, for: .normal)
        }
    }
    
    func updateMuteUnmuteButtonImage() {
        if videoPlayer.audioState == .mute {
            let unmuteImage = UIImage(systemName: "speaker.slash")
            muteUnmuteButton.setBackgroundImage(unmuteImage, for: .normal)
        } else {
            let unmuteImage = UIImage(systemName: "speaker.3")
            muteUnmuteButton.setBackgroundImage(unmuteImage, for: .normal)
        }
    }
    
    /// デバイスの向きに対応した回転角度
    /// - Parameter deviceOrientation: デバイスの向き
    func calcurateTransform(deviceOrientation: UIDeviceOrientation) -> CGAffineTransform {
        if deviceOrientation == .landscapeLeft {
            return CGAffineTransform(rotationAngle: (90 * .pi) / 180)
        } else if deviceOrientation == .landscapeRight {
            return CGAffineTransform(rotationAngle: (-90 * .pi) / 180)
        }
        return CGAffineTransform(rotationAngle: (0 * .pi) / 180)
    }
    
    @objc func viewWillEnterForeground(notification: Notification) {}

    
    @objc func viewDidEnterBackground(notification: Notification) {
        self.pause()
    }
    
    @objc func timerUpdate() {
        hideControlView()
    }
    
    @objc func didChangeOrientation(notification: NSNotification){
        seekbar.maximumValue = videoPlayer.duration
        bufferbar.maximumValue = videoPlayer.duration
        seekbar.value = videoPlayer.currentTime
        bufferbar.value = videoPlayer.bufferLoadedRange
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            expand()
        case .portrait, .portraitUpsideDown:
            collapse()
        default:
            break
        }
    }
}

extension VideoPlayerView: PlayerStateDelegate {
    func didPrepareToPlayer(player: VideoPlayer) {}
    
    func didFailure(player: VideoPlayer) {
        showErrorView()
    }
    
    func didUpdatePeriodicTimer(player: VideoPlayer) {
        currentTimeLabel.text = VideoPlayerTimeFormatter.format(time: videoPlayer.currentTime)
        self.seekbar.setValue(videoPlayer.currentTime, animated: true)
        self.bufferbar.setValue(videoPlayer.bufferLoadedRange, animated: true)
    }
    
    func didChange(player: VideoPlayer, playerState: VideoPlayerState) {
        updatePlayPauseButtonImage()
    }
    
    func didChange(player: VideoPlayer, audioState: AudioState) {
        updateMuteUnmuteButtonImage()
    }
    
}
