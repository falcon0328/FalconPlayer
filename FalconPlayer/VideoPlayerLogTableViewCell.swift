//
//  VideoPlayerLogTableViewCell.swift
//  FalconPlayer
//
//  Created by aseo on 2020/01/19.
//  Copyright © 2020 Falcon Tech. All rights reserved.
//

import UIKit

class VideoPlayerLogTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        categoryLabel.clipsToBounds = true
        categoryLabel.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        dateLabel.text = ""
        categoryLabel.text = ""
        categoryLabel.backgroundColor = UIColor.clear
        valueLabel.text = ""
    }
    
}
