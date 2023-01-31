//
//  MatchingTaxiPassenger.swift
//  Quickride
//
//  Created by QR Mac 1 on 11/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class MatchingTaxiPassenger: MatchedPassenger{
    
    var taxiRoutePolyline: String?
    var taxiRouteId = 0
    var minPoints = 0.0
    var maxPoints = 0.0
    var deviation = 0.0
    var invitationStatus: String?
    var inviteInProgress = false
    
    static let TAXI_PASSENGER_ID = "taxiRidePassengerId"
    static let TAXI_GROUP_ID = "taxiGroupId"
    static let FILTER_PASSENGER_RIDE_ID = "filterPassengerRideId"
    
    public override func mapping(map: Map) {
      super.mapping(map: map)
        taxiRoutePolyline <- map["taxiRoutePolyline"]
        taxiRouteId <- map ["taxiRouteId"]
        minPoints <- map["minPoints"]
        maxPoints <- map["maxPoints"]
        deviation <- map["deviation"]
        invitationStatus <- map["invitationStatus"]
        inviteInProgress <- map["inviteInProgress"]
    }
}
