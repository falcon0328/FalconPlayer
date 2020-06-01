//
//  Constraints.swift
//  FalconPlayer
//
//  Created by aseo on 2020/05/31.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import Foundation
import UIKit

/// UIViewに対するConstraintsを操作するためのUtilクラス
///
/// [参考文献](https://qiita.com/taka1068/items/5bb1bed06aaaec58c662)
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
    
    /// 親ビューにぴったり合うような制約情報を生成する
    func build(_ view: UIView) -> [NSLayoutConstraint] {
        guard let superView = view.superview else { return [] }
        return [
            view.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0.0),
            view.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0.0),
            view.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0.0),
            view.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0.0)
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
    
    /// Objective-Cで動作するconstraints = の挙動を再現したメソッド
    ///
    /// superViewで指定されたview用のConstraintsを削除し、新しく親ビューにぴったり合うようにConstraintを指定する
    @discardableResult
    func update(_ view: UIView) -> Bool {
        guard let superView = view.superview else { return false }
        // superViewにviewを対象とした（viewがfirstItemの）Constraintsが指定されているはずなので削除する
        superView.removeConstraints(superView.constraints.filter(firstItemView: view))
        superView.addConstraints(build(view))
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
