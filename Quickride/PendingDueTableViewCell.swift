//
//  PendingDueTableViewCell.swift
//  Quickride
//
//  Created by HK on 24/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class PendingDueTableViewCell: UITableViewCell {

    @IBOutlet weak var moduleTypeLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var extraAmountDueView: UIView!
    @IBOutlet weak var dueInfoLabel: UILabel!
    @IBOutlet weak var rideTimeLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var dueAmountLabel: UILabel!
    @IBOutlet weak var rideGiverNameLabel: UILabel!
    @IBOutlet weak var rideView: UIView!
    
    func initialiseDueView(pendingDue: PendingDue){
        dayLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(pendingDue.date), timeFormat: DateUtils.DATE_FORMAT_EE)
        monthLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(pendingDue.date), timeFormat: DateUtils.DATE_FORMAT_MMM)
        dateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(pendingDue.date), timeFormat: DateUtils.DATE_FORMAT_dd)
        dueAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getPointsInDecimal(points: pendingDue.getDueAmount())])
        switch pendingDue.dueType {
        case PendingDue.RidePayment,PendingDue.RideCompensationPayment:
            let ride = Mapper<PassengerRide>().map(JSONString: pendingDue.dataObject ?? "")
            rideView.isHidden = false
            extraAmountDueView.isHidden = true
            moduleTypeLabel.text = "Carpool Ride"
            fromLabel.text = ride?.startAddress
            toLabel.text = ride?.endAddress
            rideGiverNameLabel.isHidden = false
            rideGiverNameLabel.text = ride?.riderName
            rideTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(pendingDue.date), timeFormat: DateUtils.TIME_FORMAT_hmm_a)
        case PendingDue.TaxiPayment,PendingDue.TaxiCompensationPayment:
            let taxiRide = Mapper<TaxiRidePassenger>().map(JSONString: pendingDue.dataObject ?? "")
            rideView.isHidden = false
            extraAmountDueView.isHidden = true
            moduleTypeLabel.text = "Taxi Trip"
            fromLabel.text = taxiRide?.startAddress
            toLabel.text = taxiRide?.endAddress
            rideGiverNameLabel.isHidden = true
            rideTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(pendingDue.date), timeFormat: DateUtils.TIME_FORMAT_hmm_a)
        default:
            moduleTypeLabel.text = "Pending Dues"
            rideView.isHidden = true
            extraAmountDueView.isHidden = false
            dueInfoLabel.text = pendingDue.remarks
            rideGiverNameLabel.isHidden = true
        }
    }
}
