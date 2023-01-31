//
//  TripHistoryTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 05/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class TripHistoryTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var sectionHeaderTimingLabel: UILabel!
    @IBOutlet weak var rideTimingLabel: UILabel!
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var rideStatusLabel: UILabel!
    @IBOutlet weak var sectionHeaderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var taxiPoolImageView: UIImageView!
    @IBOutlet weak var taxiTypeImageView: UIImageView!
    
    func initialiseTaxiTrip(taxiRidePassenger: TaxiRidePassenger) {
        fromAddressLabel.text = taxiRidePassenger.startAddress
        toAddressLabel.text = taxiRidePassenger.endAddress
        rideTimingLabel.text = AppUtil.getTimeAndDateFromTimeStamp(date: NSDate(timeIntervalSince1970: (taxiRidePassenger.startTimeMs ?? 0.0)/1000), format : DateUtils.TIME_FORMAT_hmm_a)
        if taxiRidePassenger.shareType == TaxiPoolConstants.SHARE_TYPE_ANY_SHARING{
            taxiPoolImageView.image = UIImage(named: "taxiPool_icon")
            taxiPoolImageView.isHidden = false
            taxiTypeImageView.isHidden = true
        }else{
            taxiPoolImageView.isHidden = true
            taxiTypeImageView.image = TaxiUtils.getTaxiTypeIcon(taxiType: taxiRidePassenger.taxiType)
            taxiTypeImageView.isHidden = false
        }
        sectionHeaderTimingLabel.text = ""
        checkStatusInfoTaxiPool(taxiRide: taxiRidePassenger)
    }
    func checkStatusInfoTaxiPool(taxiRide: TaxiRidePassenger) {
        if taxiRide.status == TaxiRidePassenger.STATUS_CANCELLED {
            rideStatusLabel.textColor = UIColor(netHex: 0xE20000)
            rideStatusLabel.text = Strings.cancelled_status
        }else if taxiRide.status == TaxiRidePassenger.STATUS_COMPLETED {
            rideStatusLabel.textColor = UIColor(netHex: 0x00B557)
            rideStatusLabel.text = Strings.completed.uppercased()
        }
    }
    func setSectionHeader(isHeaderShow: Bool,taxiRidePassenger: TaxiRidePassenger) {
        if isHeaderShow {
            sectionHeaderViewHeightConstraint.constant = 42
            sectionHeaderTimingLabel.text = DateUtils.configureRideDateTime(ride: taxiRidePassenger)
        } else {
            sectionHeaderViewHeightConstraint.constant = 0
            sectionHeaderTimingLabel.text = ""
        }
    }
}
