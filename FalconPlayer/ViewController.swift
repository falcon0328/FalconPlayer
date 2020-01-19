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
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var videoPlayerView: VideoPlayerView?
    
    var videoPlayerLogList: [VideoPlayerLog] = []
    
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
        
        let videoURL = URL(string: "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8")
        let videoPlayerViewFrame = playerView.frame
        
        let videoPlayerView = Bundle.main.loadNibNamed("VideoPlayerView", owner: self, options: nil)?.first as! VideoPlayerView
        videoPlayerView.frame = playerView.frame
        insertLog(category: "frame = ", categoryColor: UIColor.orange, value: "frame: \(videoPlayerViewFrame)")
        // https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8
        videoPlayerView.delegate = self
        videoPlayerView.setVideoURL(url: videoURL)
        insertLog(category: "setVideoURL(url:)", categoryColor: UIColor.systemOrange, value: videoURL!.absoluteString)
        playerView.addSubview(videoPlayerView)
        insertLog(category: "playerView.addSubview", categoryColor: UIColor.orange)
        

        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerView.leadingAnchor.constraint(equalTo: playerView.leadingAnchor).isActive = true
        videoPlayerView.topAnchor.constraint(equalTo: playerView.topAnchor).isActive = true
        videoPlayerView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor).isActive = true
        videoPlayerView.trailingAnchor.constraint(equalTo: playerView.trailingAnchor).isActive = true
        self.videoPlayerView = videoPlayerView
        playerView.isHidden = false
    }
    
    func insertLog(category: String, categoryColor: UIColor, value: String = "") {
        videoPlayerLogList.insert(VideoPlayerLog(category: category, categoryColor: categoryColor, value: value), at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}

extension ViewController: VideoPlayerViewDelegate {
    func didPrepare(videoPlayerView: VideoPlayerView) {
        insertLog(category: "didPrepare", categoryColor: UIColor.systemGreen)
        videoPlayerView.play()
        insertLog(category: "play()", categoryColor: UIColor.systemOrange)
    }
    
    func didFailure(videoPlayerView: VideoPlayerView) {
        insertLog(category: "didFailure", categoryColor: UIColor.systemRed)
    }
    
    func didUpdatePeriodicTimer(videoPlayerView: VideoPlayerView) {}
    
    func didChange(videoPlayerView: VideoPlayerView, playerState: VideoPlayerState) {
        insertLog(category: "didChange playerState", categoryColor: UIColor.systemGreen, value: "playerState: \(playerState)")
    }
    
    func didChange(videoPlayerView: VideoPlayerView, audioState: AudioState) {
        insertLog(category: "didChange audioState", categoryColor: UIColor.systemGreen, value: "audioState: \(audioState)")
    }
    
    func didChange(videoPlayerView: VideoPlayerView, rate: Float) {
        insertLog(category: "didChange rate", categoryColor: UIColor.systemGreen, value: "rate: \(rate)")
    }
    
    func didTap(videoPlayerView: VideoPlayerView, componentName: VideoPlayerView.ComponentName) {
        insertLog(category: "didTap", categoryColor: UIColor.systemOrange, value: "componentName: \(componentName)")
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
