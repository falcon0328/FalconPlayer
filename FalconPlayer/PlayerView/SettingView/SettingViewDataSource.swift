//
//  SettingViewDataSource.swift
//  FalconPlayer
//
//  Created by aseo on 2020/01/14.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import Foundation
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
/// 設定画面のデータソース
class SettingViewDataSource: NSObject, UITableViewDataSource {
    /// 設定画面に表示するセル一覧
    var cellDatas: [SettingTableViewCellData] = []
    /// セルのUINib
    static var cellNib: UINib {
        return UINib(nibName: "SettingTableViewCell", bundle: nil)
    }
    /// セルの再利用ID
    static var cellReuseIdentifier: String {
        return "SettingTableViewCell"
    }
    
    override init() {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDatas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingViewDataSource.cellReuseIdentifier, for: indexPath) as! SettingTableViewCell
        cell.iconImageView.image = cellDatas[indexPath.row].image
        cell.categoryLabel.text = cellDatas[indexPath.row].category
        cell.valueLabel.text = cellDatas[indexPath.row].value
        return cell
    }
}
