//
//  RideViewDetails.swift
//  Quickride
//
//  Created by Quick Ride on 7/21/20.
//  Copyright © 2014-2020. Quick Ride [www.quickride.in]. All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideViewDetails : Mappable {
    
    var rideDetailInfo : RideDetailInfo?
    var currentUserRideType : String?
    var  currentUserRiderRide : RiderRide?
    var  currentUserPsgrRide : PassengerRide?
    
    func mapping(map: Map) {
        self.rideDetailInfo <- map["rideDetailInfo"]
        self.currentUserRideType <- map["currentUserRideType"]
        self.currentUserRiderRide <- map["currentUserRiderRide"]
        self.currentUserPsgrRide <- map["currentUserPsgrRide"]
    }
    required init?(map: Map) {
        
    }
}
