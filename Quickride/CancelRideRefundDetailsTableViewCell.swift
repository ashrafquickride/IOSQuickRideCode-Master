//
//  CancelRideRefundDetailsTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CancelRideRefundDetailsTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var paymentTypeLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    //MARK: Variable
    
    func initailizeRideRefundDetails(paymentType: String,points: String){
        paymentTypeLabel.text = String(format: Strings.payment_mode, arguments: [paymentType])
        pointsLabel.text = String(format: Strings.points_given, arguments: [points])
    }
}
