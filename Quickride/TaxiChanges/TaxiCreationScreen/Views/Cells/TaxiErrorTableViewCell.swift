//
//  TaxiErrorTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 21/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TaxiErrorTableViewCell: UITableViewCell {

    @IBOutlet weak var taxiServiceNotAvilableMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpUI(message: String) {
        taxiServiceNotAvilableMessageLabel.text = message
    }
}
