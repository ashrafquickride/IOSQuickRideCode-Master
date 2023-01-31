//
//  OTPToPickupViewModel.swift
//  Quickride
//
//  Created by Vinutha on 29/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol RideUpdateDelegate {
    func rideUpdatedSucceded()
    func rideUpdatedFailed(_ responseObject: NSDictionary?, _ error: NSError?)
}

class OTPToPickupViewModel {
    
    var rideParticipant: RideParticipant?
    var rideUpdateDelegate: RideUpdateDelegate?
    var riderRideId: Double?
    var isFromMultiPickup = false
    
    func initializeData(rideParticipant: RideParticipant?, riderRideId: Double, isFromMultiPickup: Bool, rideUpdateDelegate: RideUpdateDelegate) {
        self.rideParticipant = rideParticipant
        self.riderRideId = riderRideId
        self.isFromMultiPickup = isFromMultiPickup
        self.rideUpdateDelegate = rideUpdateDelegate
    }
    
    func updatePassengerRide(otp: String, viewController : UIViewController) {
        PassengerRideServiceClient.updatePassengerRideStatus(passengerRideId: rideParticipant!.rideId, joinedRiderRideId: riderRideId!, passengerId: rideParticipant!.userId, status: Ride.RIDE_STATUS_STARTED, fromRider: true, otp: otp, viewController: viewController, completionHandler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.rideUpdateDelegate?.rideUpdatedSucceded()
            } else {
                self.rideUpdateDelegate?.rideUpdatedFailed(responseObject, error)
            }
        })
    }
}
