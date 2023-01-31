//
//  BadRatingReasonTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 29/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class BadRatingReasonTableViewCell: UITableViewCell {

    @IBOutlet weak var selectOptionImageView: UIImageView!
    @IBOutlet weak var reasonContentLabel: UILabel!
   
    func setUpUI(selectedIndex: Int?,index: Int,reasonText: String) {
        reasonContentLabel.text = reasonText
        if selectedIndex == index{
            selectOptionImageView.image = UIImage(named: "ic_radio_button_checked")
        }else {
            selectOptionImageView.image = UIImage(named: "radio_button_1")
        }
    }
}

