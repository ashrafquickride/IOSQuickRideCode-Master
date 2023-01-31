//
//  PassengersPickupViewModel.swift
//  Quickride
//
//  Created by Vinutha on 29/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PassengersPickupViewModel {
    
    var passengerToBePickup = [RideParticipant]()
    var pickedUpPassengers: [Int : Bool] = [Int : Bool]()
    var riderRideId: Double?
    var isOTPVerified = [Double : Bool]()
    var ride: Ride?
    
    func initializeData(passengerToBePickup: [RideParticipant], ride: Ride?, riderRideId: Double?) {
        self.passengerToBePickup = passengerToBePickup
        self.ride = ride
        self.riderRideId = riderRideId
    }
    
    
}
