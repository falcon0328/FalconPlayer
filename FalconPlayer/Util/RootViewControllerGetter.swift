//
//  RootViewControllerGetter.swift
//  FalconPlayer
//
//  Created by aseo on 2020/01/04.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import Foundation
import UIKit

/// 現在表示されているViewControllerを取得する
class RootViewControllerGetter {
    /// 現在表示されているViewControllerを取得する
    class func getRootViewController() -> UIViewController? {
        guard let rootViewController =
            UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first?.rootViewController else {
                    return nil
        }
        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.visibleViewController
        }
        if let tabController = rootViewController as? UITabBarController {
            return tabController.selectedViewController
        }
        return rootViewController
    }
}
