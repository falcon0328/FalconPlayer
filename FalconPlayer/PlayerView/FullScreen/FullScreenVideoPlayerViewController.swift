//
//  FullScreenVideoPlayerViewController.swift
//  FalconPlayer
//
//  Created by aseo on 2020/05/27.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import UIKit
import AVFoundation

protocol FullScreenVideoPlayerViewControllerDelegate: class {
    func willDismiss(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController)
    func didDismiss(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController)
}

class FullScreenVideoPlayerViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    weak var delegate: FullScreenVideoPlayerViewControllerDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
        
    override var prefersHomeIndicatorAutoHidden: Bool {
        // 動画再生のフルスクリーンUIにはHomeIndicatorは不要
        // [参考文献](https://dev.classmethod.jp/articles/iphone-x-dealing-with-home-indicator/)
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // 動画再生のフルスクリーンUIではステータスバーのテキストを白色にしないと見えづらい
        // [参考文献](https://qiita.com/k-yamada-github/items/c1c653084a11129dcbbb)
        return .lightContent
    }

    @IBAction func didTapCloseButton(_ sender: Any) {
        self.delegate?.willDismiss(fullScreenVideoPlayerViewController: self)
        self.dismiss(animated: true, completion: { [weak self] in
            guard let sself = self else { return }
            sself.delegate?.didDismiss(fullScreenVideoPlayerViewController: sself)
        })
    }
}
