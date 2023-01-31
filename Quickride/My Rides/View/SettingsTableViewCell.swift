//
//  SettingsTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 4/13/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit


class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTypeImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI(indexPath: Int) {
        if indexPath == 0{
            cellTypeImageView.image = UIImage(named: "myride_car")
            titleLabel.text = Strings.ride_setting_title
            subtitleLabel.text = Strings.ride_setting_subtitle
            separatorView.isHidden = false
        }else{
            cellTypeImageView.image = UIImage(named: "vacation")
            titleLabel.text = Strings.vacation_title
            subtitleLabel.text = Strings.vaction_subtitle
            separatorView.isHidden = true
        }
    }
    
}
