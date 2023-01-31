//
//  UserRides.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 27/01/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserRides : NSObject, Mappable {
   
    var riderRides : [RiderRide] = []
    var passengerRides : [PassengerRide] = []
    var regularRiderRides :[RegularRiderRide] = []
    var regularPassenerRides:[RegularPassengerRide] = []
    
    func mapping(map: Map) {
        riderRides <- map["riderRides"]
        passengerRides <- map["passengerRides"]
        regularRiderRides <- map["regularRiderRides"]
        regularPassenerRides <- map["regularPassenerRides"]
    }
    required init?(map:Map){
        
    }
    override init(){
        super.init()
    }
    
}
