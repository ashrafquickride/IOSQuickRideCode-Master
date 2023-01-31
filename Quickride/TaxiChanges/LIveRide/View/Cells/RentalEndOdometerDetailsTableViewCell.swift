//
//  RentalEndOdometerDetailsTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 06/09/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RentalEndOdometerDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var startOdometerReadingLabel: UILabel!
    @IBOutlet weak var endOdometerReadingLabel: UILabel!
    @IBOutlet weak var rentalPackageDistanceLabel: UILabel!
    @IBOutlet weak var rentalPackageDurationLabel: UILabel!
    
    private var viewModel = RentalTaxiEndOdometerDetailsViewModel()
    
    func initialiseData(viewModel: RentalTaxiEndOdometerDetailsViewModel){
        self.viewModel = viewModel
        setupUI()
    }
    
    private func setupUI(){
        startOdometerReadingLabel.text = viewModel.rentalTaxiOdometerDetails.startOdometerReading ?? ""
        endOdometerReadingLabel.text = viewModel.rentalTaxiOdometerDetails.endOdometerReading ?? ""
        
        startTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: viewModel.taxiRidePassengerDetails.taxiRidePassenger?.actualStartTimeMs , timeFormat: DateUtils.TIME_FORMAT_hmm_a) ?? ""
        endTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: DateUtils.addMinutesToTimeStamp(time: NSDate().getTimeStamp(), minutesToAdd: 2) , timeFormat: DateUtils.TIME_FORMAT_hmm_a) ?? ""
        
        rentalPackageDistanceLabel.text = viewModel.rentalPackageDistance
        rentalPackageDurationLabel.text = viewModel.rentalPackageDuration
    }
}
