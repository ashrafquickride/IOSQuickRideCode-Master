//
//  UpdateRegularPassengerRideTask.swift
//  Quickride
//
//  Created by QuickRideMac on 26/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class UpdateRegularPassengerRideTask : UpdateRegularRideTask{
    
    override init(regularRide: RegularRide?, rideRoute : RideRoute?,delegate: UpdateRegularRideDelegate?, viewController: UIViewController?) {
        super.init(regularRide: regularRide, rideRoute: rideRoute, delegate: delegate, viewController: viewController)
    }
    override func updateRegularRide() {
      AppDelegate.getAppDelegate().log.debug("updateRegularRide()")
        QuickRideProgressSpinner.startSpinner()
        RegularPassengerRideServiceClient.updateRegularPassengerRide(regularPassengerRide: regularRide as! RegularPassengerRide, rideRoute: rideRoute, completionHander: { (responseObject, error) -> Void in
            self.handleResponse(responseObject: responseObject,error: error)
        })
    }
    override func processSuccessResponse(updatedRide: RegularRide) {
      AppDelegate.getAppDelegate().log.debug("processSuccessResponse()")
        delegate?.updateRegularPassengerRide(ride: updatedRide as! RegularPassengerRide)
    }
}
