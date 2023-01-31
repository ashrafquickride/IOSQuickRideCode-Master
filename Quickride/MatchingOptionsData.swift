//
//  MatchingOptionsData.swift
//  Quickride
//
//  Created by rakesh on 8/28/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class MatchedRidersResultHolder :NSObject, Mappable{
    
    var matchedRiders = [MatchedRider]()
    var currentMatchBucket : Int?
    var currentRideMatchPercentageAsPassenger : Int?
    
    static let currentBucket = "currentBucket"
    static let CURRENT_MATCH_BUCKET_ALL_MATCH = 1
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.matchedRiders <- map["matchedRiders"]
        self.currentMatchBucket <- map["currentMatchBucket"]
        self.currentRideMatchPercentageAsPassenger <- map["currentRideMatchPercentageAsPassenger"]
    }
    public override var description: String {
        return "matchedRiders: \(String(describing: self.matchedRiders))," + "currentMatchBucket: \(String(describing: self.currentMatchBucket))," + " currentRideMatchPercentageAsPassenger: \( String(describing: self.currentRideMatchPercentageAsPassenger)),"
    }
}
