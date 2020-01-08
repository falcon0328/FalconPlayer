//
//  SettingTableViewCell.swift
//  FalconPlayer
//
//  Created by aseo on 2020/01/09.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        iconImageView.image = nil
        categoryLabel.text = ""
        valueLabel.text = ""
    }
    
}
