//
//  FareSummaryTableViewCell.swift
//  Quickride
//
//  Created by HK on 14/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class FareSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    func updateUIForFare(title: String, amount: String) {
        titleLabel.text = title
        amountLabel.text = amount
    }
}
