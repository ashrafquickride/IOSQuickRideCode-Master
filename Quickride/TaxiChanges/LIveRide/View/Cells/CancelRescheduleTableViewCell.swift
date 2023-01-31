//
//  CancelRescheduleTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 23/07/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CancelRescheduleTableViewCell: UITableViewCell {
    
    var taxiridePassengerDetails: TaxiRidePassengerDetails?
    var fareForVehicleClass: FareForVehicleClass?
    
    func initialiseView(taxiRidePassengerDetails: TaxiRidePassengerDetails?) {
        self.taxiridePassengerDetails = taxiRidePassengerDetails
    }
    @IBAction func cancelBtnTapped(_ sender: Any) {
        
        let rideCancellationAndUnJoinViewController = UIStoryboard(name: StoryBoardIdentifiers.taxi_pool_storyboard,bundle: nil).instantiateViewController(withIdentifier: "CancelTaxiPoolViewController") as! CancelTaxiPoolViewController
        rideCancellationAndUnJoinViewController.initializeDataBeforePresenting(taxiRide: self.taxiridePassengerDetails?.taxiRidePassenger,completionHandler: { [weak self] (cancelReason) in
            
            if let cancelReason = cancelReason,let taxiRide = self?.taxiridePassengerDetails?.taxiRidePassenger {
                QuickRideProgressSpinner.startSpinner()
                TaxiPoolRestClient.cancelTaxiRide(taxiId: taxiRide.id ?? 0, cancellationReason: cancelReason) {   (responseObject, error) in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                        TaxiUtils.sendCancelEvent(taxiRidePassenger: taxiRide, cancelReason: cancelReason)
                        MyActiveTaxiRideCache.getInstance().removeRideFromActiveTaxiCache(taxiId: taxiRide.id ?? 0)
                        TaxiRideDetailsCache.getInstance().clearTaxiRidePassengerDetails(rideId: taxiRide.id ?? 0)
                        taxiRide.status = TaxiRidePassenger.STATUS_CANCELLED
                        MyActiveTaxiRideCache.getInstance().addNewClosedTaxiRides(taxiRidePassenger: taxiRide)
                        NotificationCenter.default.post(name: .reloadMyTrips, object: nil)
                        self?.parentViewController?.navigationController?.popViewController(animated: false)
                    }else{
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                    }
                }
            }
            
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationAndUnJoinViewController)
    }
    

    @IBAction func rescheduleBtnTapped(_ sender: Any) {
        
        NotificationCenter.default.post(name: .scheduleInstantRideLater, object: nil)
    }
}
    
    
   
    

    
    
   
        
       
                                                                               

    

