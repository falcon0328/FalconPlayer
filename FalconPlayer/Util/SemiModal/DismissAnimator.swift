import UIKit

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }

        let containerView = transitionContext.containerView

        containerView.addSubview(fromVC.view)

        let screenBoundsSize = getScreenBounds(deviceOrientation: UIDevice.current.orientation)
        let bottomLeftCorner = CGPoint(x: 0, y: screenBoundsSize.height)
        let finalFrame = CGRect(origin: bottomLeftCorner, size: screenBoundsSize)
        let option: UIView.AnimationOptions = transitionContext.isInteractive ? .curveLinear : .curveEaseIn

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: [option],
                       animations: {
                           fromVC.view.frame = finalFrame
                       },
                       completion: { _ in
                           transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                       }
        )
    }
    
    /// CGSizeをデバイスの向きに合わせて生成する
    /// - Parameter deviceOrientation: デバイスの向き
    func getScreenBounds(deviceOrientation: UIDeviceOrientation) -> CGSize {
        if deviceOrientation == .landscapeLeft || deviceOrientation == .landscapeRight {
            return CGSize(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
        }
        return UIScreen.main.bounds.size
    }
}
