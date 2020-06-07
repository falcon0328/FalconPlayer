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
    func didTap(fullScreenVideoPlayerViewController: FullScreenVideoPlayerViewController)
}

class FullScreenVideoPlayerViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var topBar: UIView!
    weak var baseView: UIView?

    weak var delegate: FullScreenVideoPlayerViewControllerDelegate?
    let animationController: FullScreenVideoPlayerAnimationController
    /// フルスクリーン画面が開かれた理由
    let openReason: FullScreenOpenReason
    /// フルスクリーンになる前のプレイヤービューのデバイス向き
    let deviceOrientationForPlayerView: UIDeviceOrientation
    /// フルスクリーンを閉じるためのcompletionHandler
    var closeCompletionHandler: (()->())?
    /// VIewをタップした時のジェスチャー
    var viewTapGesture: UITapGestureRecognizer?
    
    /// フルスクリーン画面が開かれた理由を表す列挙型
    enum FullScreenOpenReason {
        /// ユーザによる指示
        case user
        /// PlayerView表示時に端末の回転を行なったため
        case deviceRotation
    }
    
    init(delegate: FullScreenVideoPlayerViewControllerDelegate,
         baseView: UIView,
         modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
         animationContrller: UIViewControllerAnimatedTransitioning = FullScreenVideoPlayerAnimationController(),
         deviceOrientation: UIDeviceOrientation,
         openReason: FullScreenOpenReason = .user) {
        self.delegate = delegate
        self.baseView = baseView
        self.animationController = FullScreenVideoPlayerAnimationController()
        self.deviceOrientationForPlayerView = deviceOrientation
        self.openReason = openReason
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = modalPresentationStyle
        self.transitioningDelegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        self.view.addGestureRecognizer(tapGesture)
        self.viewTapGesture = tapGesture
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if openReason == .deviceRotation {
            closeButton.isHidden = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            guard let sself = self, let baseView = sself.baseView else { return }
            if size.width <= size.height {
                // 縦向きのレイアウト
                Constraints.shared.update(baseView, rect: Frame.shared.make(toView: sself.view))
                sself.closeButton.isHidden = false
            } else {
                // 横向きのレイアウト
                Constraints.shared.update(baseView)
                sself.closeButton.isHidden = true
            }
        }) { [weak self] (context) in
            guard let sself = self else { return }
            if let closeCompletionHandler = sself.closeCompletionHandler {
                closeCompletionHandler()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        // 動画再生のフルスクリーンUIにはステータスバーは不要
        return true
    }
        
    override var prefersHomeIndicatorAutoHidden: Bool {
        // 動画再生のフルスクリーンUIにはHomeIndicatorは不要
        // [参考文献](https://dev.classmethod.jp/articles/iphone-x-dealing-with-home-indicator/)
        return false
    }
    
    /// フルスクリーンを閉じる
    func close() {
        // 画面向きを必要に応じて回転させる
        if openReason == .user && UIDevice.current.orientation != deviceOrientationForPlayerView {
            // 画面を回転させる
            UIDevice.current.setValue(deviceOrientationForPlayerView.rawValue, forKey: "orientation")
            // viewWillTransition（要は画面が回転してUIコンポーネントが再配置された）後にクローズ処理を行う
            closeCompletionHandler = { [weak self] in
                guard let sself = self else { return }
                sself.close()
            }
        } else {
            self.delegate?.willDismiss(fullScreenVideoPlayerViewController: self)
            self.dismiss(animated: true, completion: { [weak self] in
                guard let sself = self else { return }
                sself.delegate?.didDismiss(fullScreenVideoPlayerViewController: sself)
                sself.closeCompletionHandler = nil
                sself.viewTapGesture = nil
            })
        }
    }

    @IBAction func didTapCloseButton(_ sender: Any) {
        close()
    }
    
    @objc func didTap(_ sender: UITapGestureRecognizer){
        delegate?.didTap(fullScreenVideoPlayerViewController: self)
    }
}

extension FullScreenVideoPlayerViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController
    }
}
