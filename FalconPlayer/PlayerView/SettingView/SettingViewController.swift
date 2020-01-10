//
//  SettingViewController.swift
//  FalconPlayer
//
//  Created by aseo on 2020/01/08.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import UIKit

/// 設定画面で表示するデータを表す列挙型
struct SettingTableViewCellData {
    /// 画像
    let image: UIImage?
    /// カテゴリ
    let category: String?
    /// 値
    let value: String?
}

class SettingViewController: SemiModalBaseViewController {
    var tableViewContentOffsetY: CGFloat = 0.0
    /// 設定画面に表示するセル一覧
    var cellDatas: [SettingTableViewCellData] = []
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var draggerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
        setupDatas()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self
        modalPresentationStyle = .custom
        setupDatas()
    }
    
    /// VIewをBundleから生成する
    static func make() -> SettingViewController {
        return Bundle.main.loadNibNamed("SettingViewController",
                                        owner: self,
                                        options: nil)?.first as! SettingViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactor.startHandler = { [weak self] in
            self?.tableView.bounces = false
        }
        interactor.resetHandler = { [weak self] in
            self?.tableView.bounces = true
        }
        
        setupViews()
    }
    
    /// テーブルに表示するデータの用意
    func setupDatas() {
        let bitrateCell = SettingTableViewCellData(image: UIImage(systemName: "gear"),
                                                   category: "画質",
                                                   value: nil)
        let subtitleCell = SettingTableViewCellData(image: UIImage(systemName: "text.bubble"),
                                                    category: "字幕",
                                                    value: nil)
        let rateCell = SettingTableViewCellData(image: UIImage(systemName: "memories"),
                                                category: "再生速度",
                                                value: nil)
        let vrCell = SettingTableViewCellData(image: UIImage(systemName: "eyeglasses"),
                                                category: "VRで再生",
                                                value: nil)
        cellDatas = [bitrateCell, subtitleCell, rateCell, vrCell]
    }
    
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
        tableView.register(UINib(nibName: "SettingTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func didTapBackground() {
        dismiss(animated: true, completion: nil)
    }

    @objc func didScrollHeader(_ sender: UIPanGestureRecognizer) {
        interactor.updateStateShouldStartIfNeeded()
        handleTransitionGesture(sender)
    }

    @objc func didScrollTableView(_ sender: UIPanGestureRecognizer) {
        if tableViewContentOffsetY <= 0 {
            interactor.updateStateShouldStartIfNeeded()
        }
        interactor.setStartInteractionTranslationY(sender.translation(in: view).y)
        handleTransitionGesture(sender)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDatas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        cell.iconImageView.image = cellDatas[indexPath.row].image
        cell.categoryLabel.text = cellDatas[indexPath.row].category
        cell.valueLabel.text = cellDatas[indexPath.row].value
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableViewContentOffsetY = scrollView.contentOffset.y
    }
}
