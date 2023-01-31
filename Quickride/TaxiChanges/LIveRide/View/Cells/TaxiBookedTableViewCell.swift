//
//  TaxiBookedTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 01/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie


class TaxiBookedTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var taxiTypeImage: UIImageView!
    var viewModel: TaxiPoolLiveRideViewModel?

    func initialiseView(viewModel: TaxiPoolLiveRideViewModel) {
        self.viewModel = viewModel
        let TaxiallowedTime =  (viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.pickupTimeMs ?? 0) - Double(viewModel.getallocationTime()*60*1000)
         let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: TaxiallowedTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
        infoLabel.text  = String(format: Strings.driver_details_shared_at, arguments: [(date ?? "")])
        if viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_AUTO{
            taxiTypeImage.image = UIImage(named: "auto")
        }else if viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.taxiType == TaxiPoolConstants.TAXI_TYPE_BIKE{
            taxiTypeImage.image = UIImage(named: "bike_taxi_pool")
        }else{
            taxiTypeImage.image = UIImage(named: "outstation_taxi_booked")
        }
    }

    @IBAction func callSupportTapped(_ sender: Any) {
        AppUtilConnect.callSupportNumber(phoneNumber: ConfigurationCache.getObjectClientConfiguration().quickRideSupportNumberForTaxi, targetViewController: self.parentViewController ?? ViewControllerUtils.getCenterViewController())
    }
}
