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
        tableView.estimatedRowHeight = 58
        tableView.register(UINib(nibName: "VideoPlayerLogTableViewCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "VideoPlayerLogTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "saya-volume", ofType: "gif")!))
        
        let videoPlayerView = Bundle.main.loadNibNamed("VideoPlayerView", owner: self, options: nil)?.first as! VideoPlayerView
        videoPlayerView.frame = playerView.frame
        // https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8
        videoPlayerView.delegate = self
        videoPlayerView.setVideoURL(url: URL(string: "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8"))
        playerView.addSubview(videoPlayerView)

        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerView.leadingAnchor.constraint(equalTo: playerView.leadingAnchor).isActive = true
        videoPlayerView.topAnchor.constraint(equalTo: playerView.topAnchor).isActive = true
        videoPlayerView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor).isActive = true
        videoPlayerView.trailingAnchor.constraint(equalTo: playerView.trailingAnchor).isActive = true
        self.videoPlayerView = videoPlayerView
        playerView.isHidden = false
    }
}

extension ViewController: VideoPlayerViewDelegate {
    func didPrepare(videoPlayerView: VideoPlayerView) {
        videoPlayerView.play()
    }
    
    func didFailure(videoPlayerView: VideoPlayerView) {}
    
    func didUpdatePeriodicTimer(videoPlayerView: VideoPlayerView) {}
    
    func didChange(videoPlayerView: VideoPlayerView, playerState: VideoPlayerState) {}
    
    func didChange(videoPlayerView: VideoPlayerView, audioState: AudioState) {}
    
    func didTap(videoPlayerView: VideoPlayerView, componentName: String) {}
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
        cell.categoryLabel.text = videoPlayerLogList[indexPath.row].category
        cell.valueLabel.text = videoPlayerLogList[indexPath.row].value
        return cell
    }
}
