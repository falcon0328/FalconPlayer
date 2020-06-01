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
    
    func build(_ view: UIView, rect: CGRect) -> [NSLayoutConstraint] {
        guard let superView = view.superview else { return [] }
        return [
            view.widthAnchor.constraint(equalToConstant: rect.size.width),
            view.heightAnchor.constraint(equalToConstant: rect.size.height),
            view.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: rect.origin.x),
            view.topAnchor.constraint(equalTo: superView.topAnchor, constant: rect.origin.y)
        ]
    }
    
    /// Objective-Cで動作するconstraints = の挙動を再現したメソッド
    ///
    /// toView上で指定されたview用のConstraintsを削除し、新しくrect指定のConstraintsを指定する
    /// - Parameters:
    ///   - view: 制約をかけたいView
    ///   - rect: 制約のかけ方をRectで指定する
    ///   - toView: 制約をかけたいViewの親ビュー
    @discardableResult
    func update(_ view: UIView, rect: CGRect) -> Bool {
        guard let superView = view.superview else { return false }
        // toViewにviewを対象とした（viewがfirstItemの）Constraintsが指定されているはずなので削除する
        superView.removeConstraints(superView.constraints.filter(firstItemView: view))
        superView.addConstraints(build(view, rect: rect))
        return true
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
