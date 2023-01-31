//
//  AddedOutStationPaymentsTableViewCell.swift
//  Quickride
//
//  Created by HK on 11/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddedOutStationPaymentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var paymentForLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var remarksLabel: UILabel!
    @IBOutlet weak var disputeBtn: UIButton!
    func initialiseAddedPayment(taxiUserAdditionalPaymentDetails: TaxiUserAdditionalPaymentDetails){
        amountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: taxiUserAdditionalPaymentDetails.amount)])
        paymentForLabel.text = taxiUserAdditionalPaymentDetails.fareType
        remarksLabel.text = taxiUserAdditionalPaymentDetails.description
        if taxiUserAdditionalPaymentDetails.status == TaxiUserAdditionalPaymentDetails.STATUS_REJECTED{
            disputeBtn.setTitleColor(UIColor(netHex: 0xE20000), for: .normal)
            disputeBtn.setTitle("Disputed", for: .normal)
            disputeBtn.isUserInteractionEnabled = false
        }else{
            disputeBtn.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            disputeBtn.isUserInteractionEnabled = true
            disputeBtn.setTitle(Strings.Dispute, for: .normal)
        }
        
    }
}
