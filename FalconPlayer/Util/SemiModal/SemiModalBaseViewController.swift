//
//  SemiModalBaseViewController.swift
//  FalconPlayer
//
//  Created by aseo on 2020/01/09.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import UIKit

protocol SemiModalBaseViewControllerDelegate: class {
    func willDismiss(semiModalBaseViewController: SemiModalBaseViewController)
    func didDismiss(semiModalBaseViewController: SemiModalBaseViewController)
}

class SemiModalBaseViewController: UIViewController, OverCurrentTransitionable {
    var percentThreshold: CGFloat = 0.3
    var interactor = OverCurrentTransitioningInteractor()
    weak var semiModalBaseViewControllerDelegate: SemiModalBaseViewControllerDelegate?
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        semiModalBaseViewControllerDelegate?.willDismiss(semiModalBaseViewController: self)
        super.dismiss(animated: flag, completion: { [weak self] in
            guard let sself = self else { return }
            if let completion = completion {
                completion()
            }
            sself.semiModalBaseViewControllerDelegate?.didDismiss(semiModalBaseViewController: sself)
        })
    }
}

extension SemiModalBaseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension SemiModalBaseViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        switch interactor.state {
        case .hasStarted, .shouldFinish:
            return interactor
        case .none, .shouldStart:
            return nil
        }
    }
}
