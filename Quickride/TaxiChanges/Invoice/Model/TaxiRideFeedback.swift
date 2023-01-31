//
//  TaxiRideFeedback.swift
//  Quickride
//
//  Created by Ashutos on 29/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiRideFeedback: Mappable {
    var taxiGroupId = 0.0
    var userId = 0.0
    var taxiRideId = 0.0
    var rating = 0.0
    var feedback: String?
    var creationTimeMs = 0.0
    var updatedTimeMs = 0.0
    
    static let FIELD_TAXI_GROUP_ID = "taxiGroupId"
    static let FIELD_USER_ID = "userId"
    static let FIELD_TAXI_RIDE_ID = "taxiRideId"
    static let FIELD_RATING = "rating"
    static let FIELD_FEEDBACK = "feedback"
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.taxiGroupId <- map["taxiGroupId"]
        self.userId <- map["userId"]
        self.taxiRideId <- map["taxiRideId"]
        self.rating <- map["rating"]
        self.feedback <- map["feedback"]
        self.creationTimeMs <- map["creationTimeMs"]
        self.updatedTimeMs <- map["updatedTimeMs"]
    }
    
    var description: String {
        return "taxiGroupId: \(String(describing: self.taxiGroupId)),"
            + "userId: \(String(describing: self.userId)),"
            + "taxiRideId: \(String(describing: self.taxiRideId)),"
            + "rating: \(String(describing: self.rating)),"
            + "feedback: \(String(describing: self.feedback)),"
            + "creationTimeMs: \(String(describing: self.creationTimeMs)),"
            + "updatedTimeMs: \(String(describing: self.updatedTimeMs))"
    }
}
