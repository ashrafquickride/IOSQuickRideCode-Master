//
//  PaymentDetailsOutStationTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 04/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PaymentDetailsOutStationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var advancePaidAmountLabel: UILabel!
    @IBOutlet weak var restAmountToBePaidLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(estimatefare: Double, advancePaid: Double) {
        advancePaidAmountLabel.text = "₹ \(Int(advancePaid))"
        let pendingAmtToBePaid = estimatefare - advancePaid
        restAmountToBePaidLabel.text = "₹ \(Int(pendingAmtToBePaid))"
    }
}
