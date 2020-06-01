//
//  FullScreenVideoPlayerAnimatedTransitioning.swift
//  FalconPlayer
//
//  Created by aseo on 2020/05/30.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import Foundation
import UIKit

class FullScreenVideoPlayerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresent: Bool
    var shouldAnimate: Bool
    let baseView: UIView
    
    init(isPresent: Bool = false,
         shouldAnimate: Bool = true,
         baseView: UIView) {
        self.isPresent = isPresent
        self.shouldAnimate = shouldAnimate
        self.baseView = baseView
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return shouldAnimate ? 0.3 : 0.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {
            present(transitionContext: transitionContext)
        } else {
            dismiss(transitionContext: transitionContext)
        }
    }
    
    func present(transitionContext: UIViewControllerContextTransitioning) {
        // 遷移元、遷移先及び、遷移コンテナの取得
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? FullScreenVideoPlayerViewController,
            let window = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first,
            let originalRect = baseView.superview?.convert(baseView.frame, to: baseView.window?.rootViewController?.view) else {
                return
        }
        let containerView = transitionContext.containerView
        
        // 既に追加されている遷移元のViewの下に、遷移先のViewを追加
        toVC.view.frame = window.bounds
        containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        toVC.view.insertSubview(baseView, belowSubview: toVC.closeButton)
        toVC.baseView = baseView

        // この後のアニメーションのために背景色を無効化
        toVC.view.backgroundColor = UIColor.clear
        // 制約（Constraint）を利用してアニメーションを行う
        // 以下の手順で行う
        //
        // 1. 元々、baseViewに掛けられていた制約を全て削除
        // 2. baseViewの現在の位置に合うように制約をかける
        // 3. 画面中央に16:9になる位置・サイズで制約をかける（この手順はアニメーションさせたい制約なので、UIView.animate内で行う）
        toVC.view.removeConstraints(toVC.view.constraints.filter(firstItemView: baseView)) // 1
        toVC.view.addConstraints(Constraints.shared.build(baseView,
                                                          rect: originalRect,
                                                          toView: toVC.view)) // 2
        toVC.view.layoutIfNeeded()
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            // アニメーションのために透明にした背景色を黒色に戻す
            toVC.view.backgroundColor = UIColor.black
            // 16:9の位置になるように制約をかける
            toVC.view.removeConstraints(toVC.view.constraints.filter(firstItemView: self.baseView)) // 3
            toVC.view.addConstraints(Constraints.shared.build(self.baseView,
                                                              rect: Frame.shared.make(toView: toVC.view),
                                                              toView: toVC.view)) // 3
            toVC.view.layoutIfNeeded()
        }, completion: { finished in
            transitionContext.completeTransition(true)
        })
    }
    
    func dismiss(transitionContext: UIViewControllerContextTransitioning) {
        
    }
}

extension FullScreenVideoPlayerAnimatedTransitioning: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = false
        return self
    }
}
