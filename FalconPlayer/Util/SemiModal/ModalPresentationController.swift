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
        if !VideoPlayerConfiguration.shared.isExpand { return }
        // transformとboundsの処理
        if VideoPlayerConfiguration.shared.isExpand {
            if deviceOrientation == .landscapeRight {
                updateContainerView(rotationAngle: (-90 * .pi) / 180)
                return
            }
            updateContainerView(rotationAngle: (90 * .pi) / 180)

        }
    }
    
    /// ContainerViewのBoundsを指定された回転角をもとに更新する
    /// - Parameter rotationAngle: 回転させる角度
    func updateContainerView(rotationAngle: CGFloat) {
        guard let containerView = self.containerView else {
            return
        }
        // containerViewを操作できるようにする
        containerView.translatesAutoresizingMaskIntoConstraints = true
        // 角度とbounds情報の更新
        containerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        containerView.bounds = CGRect(x: 0, y: 0, width: containerView.bounds.height, height: containerView.bounds.width)
    }
}
