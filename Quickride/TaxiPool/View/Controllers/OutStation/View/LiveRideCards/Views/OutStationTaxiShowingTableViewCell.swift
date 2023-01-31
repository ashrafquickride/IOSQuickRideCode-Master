//
//  OutStationTaxiShowingTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 04/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class OutStationTaxiShowingTableViewCell: UITableViewCell {


    @IBOutlet weak var timeInfoLabel: UILabel!
    static let TAXI_TYPE_SEDAN = "SEDAN"
    static let TAXI_TYPE_SUV = "SUV"
    static let TAXI_TYPE_TEMPO = "TEMPO"
    var viewModel: TaxiPoolLiveRideViewModel?

    func updateUI(viewModel: TaxiPoolLiveRideViewModel){
        self.viewModel = viewModel
        let TaxiallowedTime =  (viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.pickupTimeMs ?? 0) - Double(20*60*1000)
        let date = DateUtils.getTimeStringFromTimeInMillis(timeStamp: TaxiallowedTime, timeFormat: DateUtils.TIME_FORMAT_hmm_a)
        timeInfoLabel.text = String(format: Strings.driver_details_shared_at, arguments: [(date ?? "")])
    }
    
    
    
    @IBAction func callButtonTapped(_ sender: Any) {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration().taxiSupportMobileNumber
        AppUtilConnect.dialNumber(phoneNumber: clientConfiguration, viewController: self.parentViewController ?? ViewControllerUtils.getCenterViewController())
    }

}
