//
//  InstantHighFareDriverAvailableTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 25/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

class InstantHighFareDriverAvailableTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var animatingView: AnimationView!
    @IBOutlet weak var fareRangeLabel: UILabel!
    @IBOutlet weak var currentFareLabel: UILabel!
    @IBOutlet weak var tripTimeLabel: UILabel!
    
    private var taxiLiveRideViewModel: TaxiPoolLiveRideViewModel?
    
    func initialiseView(taxiLiveRideViewModel: TaxiPoolLiveRideViewModel){
        self.taxiLiveRideViewModel = taxiLiveRideViewModel
        animatingView.animation = Animation.named("lnstant_booking")
        animatingView.play()
        animatingView.loopMode = .loop
        animatingView.contentMode = .scaleAspectFill
        currentFareLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.initialFare)])
        tripTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startTimeMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
        fareRangeLabel.text = String(format: Strings.drivers_available_range, arguments: [StringUtils.getStringFromDouble(decimalNumber: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.initialFare),StringUtils.getStringFromDouble(decimalNumber: taxiLiveRideViewModel.taxiRideUpdateSuggestion?.newFare)])
    }
    
    @IBAction func tryWithNewFareTapped(_ sender: Any) {
        QuickRideProgressSpinner.startSpinner()
        self.taxiLiveRideViewModel?.updateTaxiFare(viewcontroller: parentViewController ?? ViewControllerUtils.getCenterViewController(),complition: { (result) in
            QuickRideProgressSpinner.stopSpinner()
        })
    }
    
    @IBAction func cancelRideTapped(_ sender: Any) {
        taxiLiveRideViewModel?.taxiRideUpdateSuggestion?.isSuggestionShowed = true
        NotificationCenter.default.post(name: .cancelInstantTrip, object: nil)
    }
    
    @IBAction func scheduleLaterTapped(_ sender: Any) {
        taxiLiveRideViewModel?.taxiRideUpdateSuggestion?.isSuggestionShowed = true
        NotificationCenter.default.post(name: .scheduleInstantRideLater, object: nil)
    }
}
