//
//  SemiModalTableViewController.swift
//  FalconPlayer
//
//  Created by aseo on 2020/01/14.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import UIKit

class SemiModalTableViewController: SemiModalBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var draggerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableViewHightConstraint: NSLayoutConstraint!
    
    var tableViewContentOffsetY: CGFloat = 0.0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    /// VIewをBundleから生成する
    static func make() -> SemiModalTableViewController {
        let semiModalTableViewController = Bundle.main.loadNibNamed("SemiModalTableViewController",
                                                                    owner: self,
                                                                    options: nil)?.first as! SemiModalTableViewController
        
        return semiModalTableViewController
    }
    
    /// セミモーダル内のUITableViewに高さを設定する
    /// - Parameter height: 高さ
    func setTableViewHight(_ height: CGFloat) {
        tableViewHightConstraint.constant = height
    }
    
    /// セミモーダルビュー内のUITableViewにdelegateを設定する
    func setDelegate(delegate: UITableViewDelegate?) {
        tableView.delegate = delegate
    }
    
    /// セミモーダルビュー内のUITableViewにdataSourceを設定する
    func setDataSource(dataSource: UITableViewDataSource?) {
        tableView.dataSource = dataSource
    }
    
    ///　セミモーダルビュー内のUITableViewにUINibを登録する
    ///
    ///　UITableViewのregisterを内部的に呼び出している
    /// - Parameter nib: UINib
    /// - Parameter identifier: 再利用時のIdentifier
    func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        interactor.startHandler = { [weak self] in
            self?.tableView.bounces = false
        }
        interactor.resetHandler = { [weak self] in
            self?.tableView.bounces = true
        }
        setupViews()
    }

    /// UIのセットアップ
    func setupViews() {
        let draggerGesture = UIPanGestureRecognizer(target: self, action: #selector(didScrollHeader(_:)))
        draggerView.addGestureRecognizer(draggerGesture)
        headerView.layer.cornerRadius = 8.0
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let headerGesture = UIPanGestureRecognizer(target: self, action: #selector(didScrollHeader(_:)))
        headerView.addGestureRecognizer(headerGesture)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        backgroundView.addGestureRecognizer(gesture)

        let tableViewGesture = UIPanGestureRecognizer(target: self, action: #selector(didScrollTableView(_:)))
        tableViewGesture.delegate = self
        tableView.addGestureRecognizer(tableViewGesture)
    }
    
    @objc func didTapBackground() {
        dismiss(animated: true, completion: nil)
    }

    @objc func didScrollHeader(_ sender: UIPanGestureRecognizer) {
        interactor.updateStateShouldStartIfNeeded()
        handleTransitionGesture(sender)
    }

    @objc func didScrollTableView(_ sender: UIPanGestureRecognizer) {
        interactor.updateStateShouldStartIfNeeded()
        handleTransitionGesture(sender)
    }
}
