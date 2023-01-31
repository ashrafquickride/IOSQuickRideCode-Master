//
//  HeaderTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 9/25/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerRightDetailLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI(headerString: String,rightDetailString: String, subTitleString: String) {
        headerTitleLabel.text = headerString
        headerRightDetailLabel.text = rightDetailString
        subtitleLabel.text = subTitleString
    }
}
