//
//  RechargeOptionsTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 05/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RechargeOptionsTableViewCell: RedemptionOptionsTableViewCell {

    func initializeRechargeCell(option: String, selectedRow: Int, index: Int,viewController: UIViewController) {
        if index == selectedRow{
            encashOptionSelectionImage.image = UIImage(named: "selected")
        }else{
            encashOptionSelectionImage.image = UIImage(named: "unselected")
        }
        setImageAndTextBasedOnRechargeOption(encashType: option)
    }
    func setImageAndTextBasedOnRechargeOption(encashType: String){  
        switch encashType {
        case AccountTransaction.ACCOUNT_RECHARGE_SOURCE_PAYTM:
            encashOptionLabel.text = Strings.cc_dc_paytm
            redeemTypeIconBtn.setImage(UIImage(named: "paytm_for_recharge"), for: .normal)
        case AccountTransaction.ACCOUNT_RECHARGE_SOURCE_AMAZON_PAY:
            encashOptionLabel.text = Strings.amazon
            redeemTypeIconBtn.setImage(UIImage(named: "amazon_pay"), for: .normal)
        case AccountTransaction.ACCOUNT_RECHARGE_SOURCE_FREECHARGE:
            encashOptionLabel.text = Strings.freecharge
            redeemTypeIconBtn.setImage(UIImage(named: "freecharge"), for: .normal)
        default:
            encashOptionLabel.text = ""
            redeemTypeIconBtn.setImage(nil, for: .normal)
        }
    }
}
