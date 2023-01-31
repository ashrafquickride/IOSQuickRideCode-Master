//
//  TaxiRideCommutePassengerDetails.swift
//  Quickride
//
//  Created by Rajesab on 25/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//


import Foundation
import ObjectMapper

class TaxiRideCommutePassengerDetails: Mappable {
    
    var refRideId: Double?
    var passengerName: String?
    var passengerContactNo: String?
    var modifiedTimeInMs: Double?
    var creationTimeInMs: Double?
    
    required init?(map: Map) {

    }
    init() {}
    
    func mapping(map: Map) {
        self.refRideId <- map["refRideId"]
        self.passengerName <- map["passengerName"]
        self.passengerContactNo <- map["passengerContactNo"]
        self.modifiedTimeInMs <- map["modifiedTimeInMs"]
        self.creationTimeInMs <- map["creationTimeInMs"]
   
    }
    
    
}
