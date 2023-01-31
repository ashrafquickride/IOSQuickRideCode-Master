//
//  RouteDeviationInfoViewModel.swift
//  Quickride
//
//  Created by Vinutha on 17/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RouteDeviationInfoViewModel {
    
    //MARK: Properties
    var riderRide: RiderRide?
    var rideParticipantLocation: RideParticipantLocation?
    var timeLeft = 10
    var rideInvites = [RideInvitation]()
    var rideParticipants = [RideParticipant]()
    var newRoute: RideRoute?
    
    //MARK: Initializer
    func initialiseData(riderRide: RiderRide, rideParticipantLocation: RideParticipantLocation) {
        self.riderRide = riderRide
        self.rideParticipantLocation = rideParticipantLocation
    }
    
}
