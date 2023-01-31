//
//  RelayRideMatch.swift
//  Quickride
//
//  Created by Vinutha on 18/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct RelayRideMatch: Mappable{
    
    var firstLegMatch: MatchedRider?
    var secondLegMatch: MatchedRider?
    var midLocationLat = 0.0
    var midLocationLng = 0.0
    var midLocationAddress: String?
    var totalPoints = 0.0
    var timeDeviationInMins = 0
    var totalMatchingPercent = 0
    
    static let SHOW_FIRST_RELAY_RIDE = "SHOW_FIRST_RELAY_RIDE"
    static let SHOW_SECOND_RELAY_RIDE = "SHOW_SECOND_RELAY_RIDE"
    
    static let RELAY_LEG_ONE = 1
    static let RELAY_LEG_TWO = 2
    
    init?(map: Map) {
        
    }
    
    init(firstLegMatch: MatchedRider?,secondLegMatch: MatchedRider,midLocationLat: Double,midLocationLng: Double,midLocationAddress: String,totalPoints: Double,timeDeviationInMins: Int,totalMatchingPercent: Int) {
        self.firstLegMatch = firstLegMatch
        self.secondLegMatch = secondLegMatch
        self.midLocationLat = midLocationLat
        self.midLocationLng = midLocationLng
        self.midLocationAddress = midLocationAddress
        self.totalPoints = totalPoints
        self.timeDeviationInMins = timeDeviationInMins
        self.totalMatchingPercent = totalMatchingPercent
    }
    
    mutating func mapping(map: Map) {
        self.firstLegMatch <- map["firstLegMatch"]
        self.secondLegMatch <- map["secondLegMatch"]
        self.midLocationLat <- map["midLocationLat"]
        self.midLocationLng <- map["midLocationLng"]
        self.midLocationAddress <- map["midLocationAddress"]
        self.totalPoints <- map["totalPoints"]
        self.timeDeviationInMins <- map["timeDeviationInMins"]
        self.totalMatchingPercent <- map["totalMatchingPercent"]
    }
    
    public var description: String {
        return "firstLegMatch: \(String(describing: self.firstLegMatch))," + "secondLegMatch: \(String(describing: self.secondLegMatch))," + " midLocationLat: \( String(describing: self.midLocationLat))," + " midLocationLng: \(String(describing: self.midLocationLng))," + " midLocationAddress: \(String(describing: self.midLocationAddress)),"
            + " totalPoints: \(String(describing: self.totalPoints))," + "timeDeviationInMins: \(String(describing: self.timeDeviationInMins))," + "totalMatchingPercent: \(String(describing: self.totalMatchingPercent)),"
    }
}
