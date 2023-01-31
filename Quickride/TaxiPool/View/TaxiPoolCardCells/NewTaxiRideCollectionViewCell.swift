//
//  NewTaxiRideCollectionViewCell.swift
//  Quickride
//
//  Created by Ashutos on 4/21/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit

class NewTaxiRideCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var numberOfSharingLabel: UILabel!
    @IBOutlet weak var priceShowingLabel: UILabel!
    @IBOutlet weak var pickUpTimeShowingLabel: UILabel!
    @IBOutlet weak var createRideButton: UIButton!
    @IBOutlet weak var sharingOptionShowingButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUPUI(taxiPoolNewCardData : GetTaxiShareMinMaxFare?,currentRide: Ride?) {
        if let taxiData = taxiPoolNewCardData {
            numberOfSharingLabel.text = taxiData.shareType
            priceShowingLabel.text = "₹\(Int(taxiData.minFare!))"
            guard let rideObj = currentRide else {return}
            let rideTime = rideObj.startTime
            let addedTimeRangeTime = DateUtils.addMinutesToTimeStamp(time: rideTime, minutesToAdd: ConfigurationCache.getObjectClientConfiguration().taxiPickUpTimeRangeInMins)
            pickUpTimeShowingLabel.text  = DateUtils.getTimeStringFromTimeInMillis(timeStamp: rideTime, timeFormat: DateUtils.TIME_FORMAT_hh_mm)! + "-" +
            DateUtils.getTimeStringFromTimeInMillis(timeStamp: addedTimeRangeTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        } else {
            numberOfSharingLabel.text = ""
            priceShowingLabel.text = ""
        }
    }
}
