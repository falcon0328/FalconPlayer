//
//  Orientation.swift
//  FalconPlayer
//
//  Created by aseo on 2020/06/09.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import Foundation
import UIKit

class Orientation {
    static let shared = Orientation()
    
    func interfaceOrientation(_ viewController: UIViewController) -> UIInterfaceOrientation {
        guard let windowScene = viewController.view.window?.windowScene else {
            return .unknown
        }
        return windowScene.interfaceOrientation
    }
    
    func isLandscape(_ viewController: UIViewController) -> Bool {
        return interfaceOrientation(viewController).isLandscape
    }
    
    func isPortrait(_ viewController: UIViewController) -> Bool {
        return interfaceOrientation(viewController).isPortrait
    }
    
    func deviceOrientationFrom(interfaceOrientation: UIInterfaceOrientation) -> UIDeviceOrientation {
        if interfaceOrientation == .landscapeLeft { 
            return .landscapeRight
        } else if interfaceOrientation == .landscapeRight {
            return .landscapeLeft
        } else if let deviceOrientation = UIDeviceOrientation(rawValue: interfaceOrientation.rawValue) {
            return deviceOrientation
        }
        return .unknown
    }
}
