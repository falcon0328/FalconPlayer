//
//  Constraints.swift
//  FalconPlayer
//
//  Created by aseo on 2020/05/31.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import Foundation
import UIKit

class Constraints {
    static let shared = Constraints()
    
    func build(_ view: UIView, rect: CGRect, toView: UIView) -> [NSLayoutConstraint] {
        return [
            view.widthAnchor.constraint(equalToConstant: rect.size.width),
            view.heightAnchor.constraint(equalToConstant: rect.size.height),
            view.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: rect.origin.x),
            view.topAnchor.constraint(equalTo: toView.topAnchor, constant: rect.origin.y)
        ]
    }
}

extension Array where Element == NSLayoutConstraint {
    func filter(firstItemView: UIView) -> [NSLayoutConstraint] {
        return filter { (constraints) -> Bool in
            guard let firstItem = constraints.firstItem as? UIView else {
                return false
            }
            return firstItem == firstItemView
        }
    }
}
