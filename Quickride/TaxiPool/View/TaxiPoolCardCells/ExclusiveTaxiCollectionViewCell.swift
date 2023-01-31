//
//  ExclusiveTaxiCollectionViewCell.swift
//  Quickride
//
//  Created by Ashutos on 7/15/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ExclusiveTaxiCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pickUpTimeShowingLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpUI(price: Int, currentRide: Ride?) {
        if price == 0 {
            priceLabel.text = ""
            pickUpTimeShowingLabel.text  = ""
        } else {
            priceLabel.text = "₹\(price)"
            guard let rideObj = currentRide else {return}
            pickUpTimeShowingLabel.text  = DateUtils.getTimeStringFromTimeInMillis(timeStamp: rideObj.startTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        }
    }

}
