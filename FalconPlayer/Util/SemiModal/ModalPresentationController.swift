import UIKit

final class ModalPresentationController: UIPresentationController {
    private let overlayView = UIView()

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        overlayView.frame = containerView!.bounds
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.0
        containerView!.insertSubview(overlayView, at: 0)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [unowned self] _ in
            self.overlayView.alpha = 0.5
        })
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [unowned self] _ in
            self.overlayView.alpha = 0.0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)

        if completed {
            overlayView.removeFromSuperview()
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        return containerView!.bounds
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        updateContainerViewBoundsIfNeeded(deviceOrientation: UIDevice.current.orientation)
        overlayView.frame = containerView!.bounds
        presentedView!.frame = frameOfPresentedViewInContainerView
    }
    
    /// ContainerViewのBoundsを更新
    /// - Parameter deviceOrientation: デバイスの向き
    func updateContainerViewBoundsIfNeeded(deviceOrientation: UIDeviceOrientation) {
        guard let containerView = self.containerView else {
            return
        }
        // containerViewを操作できるようにする
        containerView.translatesAutoresizingMaskIntoConstraints = true
        // transformとboundsの処理
        if deviceOrientation == .landscapeLeft {
            containerView.transform = CGAffineTransform(rotationAngle: (90 * .pi) / 180)
            containerView.bounds = CGRect(x: 0, y: 0, width: containerView.bounds.height, height: containerView.bounds.width)
        } else if deviceOrientation == .landscapeRight {
            containerView.transform = CGAffineTransform(rotationAngle: (-90 * .pi) / 180)
            containerView.bounds = CGRect(x: 0, y: 0, width: containerView.bounds.height, height: containerView.bounds.width)
        }
    }
}
