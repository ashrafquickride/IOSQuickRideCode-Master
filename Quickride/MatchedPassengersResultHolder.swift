//
//  MatchedPassengersResultHolder.swift
//  Quickride
//
//  Created by Vinutha on 11/3/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class MatchedPassengersResultHolder : Mappable{
    
    var matchedPassengers = [MatchedPassenger]()
    var currentMatchBucket : Int?
    var currentRideMatchPercentageAsRider : Int?
    
    static let currentBucket = "currentBucket"
    static let CURRENT_MATCH_BUCKET_ALL_MATCH = 1
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.matchedPassengers <- map["matchedPassengers"]
        self.currentMatchBucket <- map["currentMatchBucket"]
        self.currentRideMatchPercentageAsRider <- map["currentRideMatchPercentageAsRider"]
    }
}

