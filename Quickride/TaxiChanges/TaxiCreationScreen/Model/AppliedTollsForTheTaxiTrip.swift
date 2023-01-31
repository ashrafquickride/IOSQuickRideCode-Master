//
//  AppliedTollsForTheTaxiTrip.swift
//  Quickride
//
//  Created by Quick Ride on 4/26/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AppliedTollsForTheTaxiTrip: Mappable {
    
    var tollType : String?
    var tollId : String?
    var  tollName : String?
    var entryName : String?
    var latitude : Double = 0.0
    var  longitude : Double = 0.0
    var  exitName : String?
    var  exitLatitude : Double = 0.0
    var  exitLongitue : Double = 0.0
    var  tollFare : Double = 0.0
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.tollType <- map["tollType"]
        self.tollId <- map["tollId"]
        self.tollName <- map["tollName"]
        self.entryName <- map["entryName"]
        self.latitude <- map["latitude"]
        self.longitude <- map["longitude"]
        self.exitName <- map["exitName"]
        self.exitLatitude <- map["exitLatitude"]
        self.exitLongitue <- map["exitLongitue"]
        self.tollFare <- map["tollFare"]
    }
    
    
}
