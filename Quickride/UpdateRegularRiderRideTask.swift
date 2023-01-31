//
//  UpdateRegularRiderRideTask.swift
//  Quickride
//
//  Created by QuickRideMac on 26/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UpdateRegularRiderRideTask : UpdateRegularRideTask{
    
    override init(regularRide: RegularRide?, rideRoute : RideRoute?, delegate: UpdateRegularRideDelegate?, viewController: UIViewController?) {
        super.init(regularRide: regularRide, rideRoute: rideRoute, delegate: delegate, viewController: viewController)
    }
    override func updateRegularRide() {
      AppDelegate.getAppDelegate().log.debug("updateRegularRide()")
        QuickRideProgressSpinner.startSpinner()
        RegularRiderRideServiceClient.updateRegularRiderRide(ride: regularRide as! RegularRiderRide, rideRoute: rideRoute) { (responseObject, error) -> Void in
            self.handleResponse(responseObject: responseObject,error: error)
        }
    }
    override func processSuccessResponse(updatedRide: RegularRide) {
      AppDelegate.getAppDelegate().log.debug("processSuccessResponse()")
       delegate?.updateRegularRiderRide(ride: updatedRide as! RegularRiderRide)
    }
}
