//
//  OutStationTaxiBookedTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 04/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

class OutStationTaxiBookedTableViewCell: UITableViewCell {


@IBOutlet weak var driverDetailsTimeLbl: UILabel!
 var viewModel: TaxiPoolLiveRideViewModel?

    static let TAXI_TYPE_SEDAN = "SEDAN"
    static let TAXI_TYPE_SUV = "SUV"
    static let TAXI_TYPE_TEMPO = "TEMPO"
   
    func  initialiseView(viewModel : TaxiPoolLiveRideViewModel){
        self.viewModel = viewModel
        if (viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.pickupTimeMs ?? 0) - NSDate().getTimeStamp() <= Double(300*60*1000) {
            driverDetailsTimeLbl.text = "Driver details will be shared soon "
        } else {
           let TaxiallowedTime =  (viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.pickupTimeMs ?? 0) - Double(viewModel.allowtedtime*60*1000)
            let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: TaxiallowedTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
            driverDetailsTimeLbl.text = String(format: Strings.driver_details_shared_at, arguments: [(date ?? "")])
        }
    }
    
    @IBAction func callButtonTapped(_ sender: Any) {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration().taxiSupportMobileNumber
        AppUtilConnect.dialNumber(phoneNumber: clientConfiguration, viewController: self.parentViewController ?? ViewControllerUtils.getCenterViewController())
    }
}
