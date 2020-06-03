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
    @IBOutlet weak var topBar: UIView!
    weak var baseView: UIView?

    weak var delegate: FullScreenVideoPlayerViewControllerDelegate?
    let animationController: FullScreenVideoPlayerAnimationController
    
    init(delegate: FullScreenVideoPlayerViewControllerDelegate,
         baseView: UIView,
         modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
         animationContrller: UIViewControllerAnimatedTransitioning = FullScreenVideoPlayerAnimationController()) {
        self.delegate = delegate
        self.baseView = baseView
        self.animationController = FullScreenVideoPlayerAnimationController()
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = modalPresentationStyle
        self.transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            guard let sself = self, let baseView = sself.baseView else { return }
            if size.width <= size.height {
                // 縦向きのレイアウト
                Constraints.shared.update(baseView, rect: Frame.shared.make(toView: sself.view))
            } else {
                // 横向きのレイアウト
                Constraints.shared.update(baseView)
            }
        }) { (context) in }
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

extension FullScreenVideoPlayerViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController
    }
}
