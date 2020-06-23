//
//  ViewController.swift
//  ViewController
//
//  Created by aseo on 2019/12/22.
//  Copyright © 2019 Falcon Tech. All rights reserved.
//

import UIKit
import AVFoundation
import CoreGraphics

struct VideoPlayerLog {
    /// 日時
    let date = Date()
    /// 種類
    let category: String
    /// 種類の色
    let categoryColor: UIColor
    /// 値
    let value: String
}

class ViewController: UIViewController {
    @IBOutlet weak var playerBaseView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var playerView: PlayerView?
    
    var videoPlayerLogList: [VideoPlayerLog] = []
    var insertRowCount = 0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 14
        tableView.register(UINib(nibName: "VideoPlayerLogTableViewCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "VideoPlayerLogTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if playerView == nil {
//            let videoURL = URL(string: "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8")
            let videoURL = Bundle.main.url(forResource: "BigBuckBunny_320x180", withExtension: "mp4")
            
            let playerView = PlayerView(frame: playerBaseView.frame)
            insertLog(category: "frame = ", categoryColor: UIColor.systemOrange, value: "frame: \(playerView.frame)")
            playerView.delegate = self
            playerView.set(videoURL: videoURL)
            insertLog(category: "setVideoURL(url:)", categoryColor: UIColor.systemOrange, value: videoURL!.absoluteString)
            playerBaseView.addSubview(playerView)
            insertLog(category: "playerView.addSubview", categoryColor: UIColor.systemOrange)
            
            playerView.translatesAutoresizingMaskIntoConstraints = false
            playerView.leadingAnchor.constraint(equalTo: playerBaseView.leadingAnchor).isActive = true
            playerView.topAnchor.constraint(equalTo: playerBaseView.topAnchor).isActive = true
            playerView.bottomAnchor.constraint(equalTo: playerBaseView.bottomAnchor).isActive = true
            playerView.trailingAnchor.constraint(equalTo: playerBaseView.trailingAnchor).isActive = true
            self.playerView = playerView
            playerBaseView.isHidden = false
        }
    }
    
    func updateLogIfNeed() {
        guard insertRowCount > 0, let playerView = playerView, playerView.fullScreenVC == nil else { return }
        var insertRows: [IndexPath] = []
        for index in 0..<insertRowCount {
            insertRows.append(IndexPath(row: index, section: 0))
        }
        tableView.insertRows(at: insertRows, with: .automatic)
        insertRowCount = 0
    }
    
    func insertLog(category: String, categoryColor: UIColor, value: String = "") {
        // ログデータをテーブルビューに表示するために配列に保存しておく
        videoPlayerLogList.insert(VideoPlayerLog(category: category, categoryColor: categoryColor, value: value), at: 0)
        // 挿入した行数を覚えておく
        insertRowCount += 1
        // テーブルビューに更新反映を行う
        updateLogIfNeed()
    }
}

extension ViewController: PlayerViewDelegate {
    func didPrepare(playerView: PlayerView) {
        insertLog(category: "didPrepare", categoryColor: UIColor.systemGreen)
        playerView.videoPlayerView?.play()
        insertLog(category: "play()", categoryColor: UIColor.systemOrange)
    }
    
    func didFailure(playerView: PlayerView) {
        insertLog(category: "didFailure", categoryColor: UIColor.systemRed)
    }
    
    func didUpdatePeriodicTimer(playerView: PlayerView) {}
    
    func didChange(playerView: PlayerView, playerState: VideoPlayerState) {
        insertLog(category: "didChange playerState", categoryColor: UIColor.systemGreen, value: "playerState: \(playerState)")
    }
    
    func didChange(playerView: PlayerView, audioState: AudioState) {
        insertLog(category: "didChange audioState", categoryColor: UIColor.systemGreen, value: "audioState: \(audioState)")
    }
    
    func didChange(playerView: PlayerView, rate: Float) {
        insertLog(category: "didChange rate", categoryColor: UIColor.systemGreen, value: "rate: \(rate)")
    }
    
    func didChange(playerView: PlayerView, effectiveRate: Float) {
        insertLog(category: "didChange effectiveRate", categoryColor: UIColor.systemGreen, value: "effectiveRate: \(effectiveRate)")
    }
    
    func didChange(playerView: PlayerView, isExpand: Bool) {
        insertLog(category: "didChange isExpand", categoryColor: UIColor.systemGreen, value: "isExpand: \(isExpand)")
    }
    
    func didPlaybackStalled(playerView: PlayerView) {
        insertLog(category: "didPlaybackStalled", categoryColor: UIColor.systemRed)
    }
    
    func didTap(playerView: PlayerView, componentName: VideoPlayerView.ComponentName) {
        insertLog(category: "didTap", categoryColor: UIColor.systemOrange, value: "componentName: \(componentName)")
    }
    
    func didPlayerItemTimeJump(playerView: PlayerView) {
        insertLog(category: "didPlayerItemTimeJump", categoryColor: UIColor.systemGreen)
    }
    
    func willPresent(semiModalBaseViewController: SemiModalBaseViewController) {
        insertLog(category: "willPresent semiModalBaseViewController", categoryColor: UIColor.systemOrange)
    }
    
    func didPresent(semiModalBaseViewController: SemiModalBaseViewController) {
        insertLog(category: "didPresent semiModalBaseViewController", categoryColor: UIColor.systemOrange)
    }
    
    func willDismiss(semiModalBaseViewController: SemiModalBaseViewController) {
        insertLog(category: "willDismiss semiModalBaseViewController", categoryColor: UIColor.systemOrange)
    }
    
    func didDismiss(semiModalBaseViewController: SemiModalBaseViewController) {
        insertLog(category: "didDismiss semiModalBaseViewController", categoryColor: UIColor.systemOrange)
    }
    
    func willPresent(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController) {
        insertLog(category: "willPresent fullScreenVideoPlayerViewController", categoryColor: UIColor.systemOrange)
    }
    
    func didPresent(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController) {
        insertLog(category: "didPresent fullScreenVideoPlayerViewController", categoryColor: UIColor.systemOrange)
    }
    
    func willDismiss(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController) {
        insertLog(category: "willDismiss fullScreenVideoPlayerViewController", categoryColor: UIColor.systemOrange)
    }
    
    func didDismiss(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController) {
        insertLog(category: "didDismiss fullScreenVideoPlayerViewController", categoryColor: UIColor.systemOrange)
        // フルスクリーン中に追加されたログをアプリ上に表示するためにテーブルビューの表示更新を行う
        updateLogIfNeed()
    }
    
    func didTap(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController) {
        insertLog(category: "didTap fullScreenVideoPlayerViewController", categoryColor: UIColor.systemOrange)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoPlayerLogList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoPlayerLogTableViewCell", for: indexPath) as! VideoPlayerLogTableViewCell
        cell.dateLabel.text = dateFormatter.string(from: videoPlayerLogList[indexPath.row].date)
        cell.categoryLabel.text = " \(videoPlayerLogList[indexPath.row].category) "
        cell.categoryLabel.backgroundColor = videoPlayerLogList[indexPath.row].categoryColor
        cell.valueLabel.text = videoPlayerLogList[indexPath.row].value
        return cell
    }
}
