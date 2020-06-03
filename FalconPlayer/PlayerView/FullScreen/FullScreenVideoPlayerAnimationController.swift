//
//  FullScreenVideoPlayerAnimationController.swift
//  FalconPlayer
//
//  Created by aseo on 2020/05/30.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import Foundation
import UIKit

class FullScreenVideoPlayerAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    var shouldAnimate: Bool
    
    /// フルスクリーンに遷移したbaseViewのsuperViewを覚えておく変数
    weak var baseViewSuperView: UIView?
    /// フルスクリーンに遷移したbaseViewのFrame位置を覚えておく変数
    var originalRect: CGRect = CGRect.zero
    
    init(shouldAnimate: Bool = true) {
        self.shouldAnimate = shouldAnimate
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return shouldAnimate ? 0.3 : 0.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        if type(of: toVC) == FullScreenVideoPlayerViewController.self {
            // 遷移先がフルスクリーン用のViewControllerなら開こう（present）としている
            present(transitionContext: transitionContext)
        } else if type(of: fromVC) == FullScreenVideoPlayerViewController.self {
            // 遷移元がフルスクリーン用のViewControllerなら閉じよう（dismiss）としている
            dismiss(transitionContext: transitionContext)
        }
    }
    
    func present(transitionContext: UIViewControllerContextTransitioning) {
        // 遷移元、遷移先及び、遷移コンテナの取得
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? FullScreenVideoPlayerViewController,
            let baseView = toVC.baseView,
            let window = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first,
            let originalRect = baseView.superview?.convert(baseView.frame, to: baseView.window?.rootViewController?.view) else {
                return
        }
        let containerView = transitionContext.containerView
        
        // フルスクリーンから復帰する際に必要になるパラメータを覚えておく
        self.originalRect = originalRect
        self.baseViewSuperView = baseView.superview
        // 既に追加されている遷移元のViewの下に、遷移先のViewを追加
        toVC.view.frame = window.bounds
        containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        toVC.view.insertSubview(baseView, belowSubview: toVC.closeButton)

        // この後のアニメーションのために背景色を無効化
        toVC.view.backgroundColor = UIColor.clear
        // 制約（Constraint）を利用してアニメーションを行う
        // 以下の手順で行う
        //
        // 1. 元々、baseViewに掛けられていた制約を全て削除
        // 2. baseViewの現在の位置に合うように制約をかける
        // 3. 画面中央に16:9になる位置・サイズで制約をかける（この手順はアニメーションさせたい制約なので、UIView.animate内で行う）
        Constraints.shared.update(baseView, rect: originalRect)
        toVC.view.layoutIfNeeded()
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            // アニメーションのために透明にした背景色を黒色に戻す
            toVC.view.backgroundColor = UIColor.black
            if let orientation = fromVC.view.window?.windowScene?.interfaceOrientation, orientation.isLandscape {
                Constraints.shared.update(baseView)
            } else {
                // 16:9の位置になるように制約をかける
                Constraints.shared.update(baseView, rect: Frame.shared.make(toView: toVC.view))
            }
            toVC.view.layoutIfNeeded()
        }, completion: { finished in
            transitionContext.completeTransition(true)
        })
    }
    
    func dismiss(transitionContext: UIViewControllerContextTransitioning) {
        // 遷移元、遷移先及び、遷移コンテナの取得
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? FullScreenVideoPlayerViewController,
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) ,
            let baseView = fromVC.baseView else {
                return
        }
        let containerView = transitionContext.containerView
        // アニメーション完了後のFrame情報を事前に取得
        let toVCFinalFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = toVCFinalFrame
        // 既に追加されている遷移元のViewの下に、遷移先のViewを追加
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)

        // 16:9の位置にあらかじめ動画のViewを制約をかけて移動させる
        Constraints.shared.update(baseView, rect: Frame.shared.make(toView: fromVC.view))
        fromVC.view.layoutIfNeeded()
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { [weak self] in
            guard let sself = self else { return }
            fromVC.view.backgroundColor = UIColor.clear
            Constraints.shared.update(baseView, rect: sself.originalRect)
            fromVC.view.layoutIfNeeded()
        }) { [weak self] (completion) in
            guard let sself = self else { return }
            if let baseViewSuperView = sself.baseViewSuperView {
                baseViewSuperView.addSubview(baseView)
                Constraints.shared.update(baseView)
                baseViewSuperView.layoutIfNeeded()
            }
            transitionContext.completeTransition(true)
        }
    }
}
