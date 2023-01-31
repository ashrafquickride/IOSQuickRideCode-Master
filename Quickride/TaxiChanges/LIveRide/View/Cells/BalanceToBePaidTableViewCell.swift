//
//  BalanceToBePaidTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 22/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class BalanceToBePaidTableViewCell: UITableViewCell {

    @IBOutlet weak var balancePaymentLabel: UILabel!
    @IBOutlet weak var amountButton: UIButton!
    
    func showPendingAmount(amount: Double){
        amountButton.setTitle(String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: amount)]), for: .normal)
    }
}
