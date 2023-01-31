//
//  CancelRideSupportTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
protocol CancelRideSupportTableViewCellDelegate {
    func supportMailTapped()
}

class CancelRideSupportTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var supportDetailLabel: UILabel!
    
    //MARK: Variable
    private var delegate: CancelRideSupportTableViewCellDelegate?
    
    func initailizeRideRefundSupportDetails(rideType: String,delegate: CancelRideSupportTableViewCellDelegate){
        self.delegate = delegate
        if rideType == Ride.RIDER_RIDE{
            supportDetailLabel.attributedText = ViewCustomizationUtils.getAttributedString(string: Strings.cancel_giver_ride_help, rangeofString: "support@quickride.in", textColor: UIColor.init(netHex: 0x007AFF), textSize: 12)
        }else{
            supportDetailLabel.attributedText = ViewCustomizationUtils.getAttributedString(string: Strings.cancel_ride_taker_help, rangeofString: "support@quickride.in", textColor: UIColor.init(netHex: 0x007AFF), textSize: 12)
        }
    }
    
    @IBAction func supportMailTapped(_ sender: UIButton) {
        delegate?.supportMailTapped()
    }
}
