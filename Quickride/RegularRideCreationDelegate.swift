//
//  RegularRideCreationDelegate.swift
//  Quickride
//
//  Created by QuickRideMac on 19/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
protocol RegularRideCreationDelegate{
    func newRegularPassengerRideCreated(regularPassengerRide : RegularPassengerRide)
    func newRegularRiderRideCreated(regularRiderRide : RegularRiderRide)
    func newRegularRiderRideCreationFailed(responseError : ResponseError?,NSError : NSError?)
    func newRegularPassengerRideCreationFailed(responseError : ResponseError?,NSError : NSError?)
}
