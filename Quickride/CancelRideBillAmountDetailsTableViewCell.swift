//
//  CancelRideBillAmountDetailsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol CancelRideBillAmountDetailsTableViewCellDelegate {
    func infoButtonTapped()
}

class CancelRideBillAmountDetailsTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var reservedLabel: UILabel!
    @IBOutlet weak var cancellationFeeLabel: UILabel!
    @IBOutlet weak var totalRefundLabel: UILabel!
    @IBOutlet weak var infoIcon: UIImageView!
    
    //MARK: Variable
    private var delegate: CancelRideBillAmountDetailsTableViewCellDelegate?
    
    func initailizeRideAmountDetails(reservedPoints: String,cancellationFee: String,totalRefundPoints: String){
        reservedLabel.text = reservedPoints
        cancellationFeeLabel.text = cancellationFee
        totalRefundLabel.text = totalRefundPoints
        infoIcon.image = infoIcon.image?.withRenderingMode(.alwaysTemplate)
        infoIcon.tintColor = UIColor(netHex: 0xE20000)
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        delegate?.infoButtonTapped()
    }
}
