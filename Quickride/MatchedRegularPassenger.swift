//
//  MatchedRegularPassenger.swift
//  Quickride
//
//  Created by QuickRideMac on 19/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class MatchedRegularPassenger: MatchedRegularUser,NSCopying {
    
    var noOfSeats = 1
    override init() {
        super.init()
        userRole = MatchedUser.REGULAR_PASSENGER
    }

    required init(_ map: Map) {
        super.init()
        userRole = MatchedUser.REGULAR_PASSENGER
    }
    
    required public init(map: Map) {
        super.init(map: map)
    }
    
   
    override func mapping(map: Map) {
        super.mapping(map: map)
    }
    override func getParams() -> [String: String]{
        
        var params = super.getParams()
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: rideid)
        params[Ride.FLD_PASSENGERID] = StringUtils.getStringFromDouble(decimalNumber: userid)
        params[Ride.FLD_PICKUP_ADDRESS] = pickupLocationAddress
        params[Ride.FLD_NO_OF_SEATS] = String(noOfSeats)
        return params
    }
    public func copy(with zone: NSZone? = nil) -> Any {
        
        let matchedPassenger = MatchedRegularPassenger()
        initialise(matchedUser: matchedPassenger)
        matchedPassenger.noOfSeats = self.noOfSeats
        return matchedPassenger
    }
}
