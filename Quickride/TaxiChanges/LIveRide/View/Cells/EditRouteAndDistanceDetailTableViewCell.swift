//
//  EditRouteAndDistanceDetailTableViewCell.swift
//  Quickride
//
//  Created by Rajesab on 05/12/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class EditRouteAndDistanceDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var editRouteButton: UIButton!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var pickupDateAndTimeLabel: UILabel!

    @IBOutlet weak var dropDateAndTimeLabel: UILabel!
    
    @IBOutlet weak var dateAndTimeContainerView: UIView!
    
    @IBOutlet weak var dropTimeStackView: UIStackView!
    
    private var taxiLiveRideViewModel = TaxiPoolLiveRideViewModel()

    func initialiseData(viewModel: TaxiPoolLiveRideViewModel ) {
        self.taxiLiveRideViewModel = viewModel
        if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.tripType == TaxiRidePassenger.OUTSTATION {
            dateAndTimeContainerView.isHidden = false
            pickupDateAndTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.startTimeMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
            if taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.journeyType == TaxiRidePassenger.oneWay {
                dropTimeStackView.isHidden = true
            }else {
                dropTimeStackView.isHidden = false
                dropDateAndTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.expectedEndTimeMs, timeFormat: DateUtils.DATE_FORMAT_D_MM_HH_MM_A)
            }
        }else {
            dateAndTimeContainerView.isHidden = true
        }

        distanceLabel.text = StringUtils.getStringFromDouble(decimalNumber: taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger?.distance) + " KM"
    }
    
    @IBAction func editRouteButtonTapped(_ sender: Any) {
        guard let taxiRidePassenger = taxiLiveRideViewModel.taxiRidePassengerDetails?.taxiRidePassenger else { return }
        let taxiRideEditViewController = UIStoryboard(name: "TaxiEdit", bundle: nil).instantiateViewController(withIdentifier: "TaxiRideEditViewController") as! TaxiRideEditViewController
        taxiRideEditViewController.initialiseData(taxiRidePassenger: taxiRidePassenger.copy() as! TaxiRidePassenger) { [weak self]
                    (taxiRidePassenger) in
            if let vc = self?.parentViewController as? TaxiLiveRideBottomViewController, let taxiLiveRideMapVC = vc.parent?.parent as? TaxiLiveRideMapViewController {
                taxiLiveRideMapVC.getTaxiRideDetails()
            }
        }
        ViewControllerUtils.displayViewController(currentViewController: self.parentViewController, viewControllerToBeDisplayed: taxiRideEditViewController, animated: false)
    }
    
}
