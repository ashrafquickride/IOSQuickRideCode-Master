//
//  RideContribution.swift
//  Quickride
//
//  Created by QuickRideMac on 3/17/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class RideContribution : NSObject, Mappable{
    var userId : Double?
    var co2Reduced : Double?
    var distanceShared : Double?
    var petrolSaved : Double?
    
    override init() {
        
    }
    required internal init?(map:Map){
        
    }
    func mapping(map: Map) {
        userId <- map["userId"]
        co2Reduced <- map["co2Reduced"]
        distanceShared <- map["distanceShared"]
        petrolSaved <- map["petrolSaved"]
    }
    func getParams() -> [String : String] {
        AppDelegate.getAppDelegate().log.debug("getParams()")
        var params : [String : String] = [String : String]()
        params["userId"] = StringUtils.getStringFromDouble(decimalNumber : self.userId)
        params["co2Reduced"] = StringUtils.getStringFromDouble(decimalNumber : self.co2Reduced)
        params["distanceShared"] =  StringUtils.getStringFromDouble(decimalNumber : self.distanceShared)
        params["petrolSaved"] = StringUtils.getStringFromDouble(decimalNumber : self.petrolSaved)
        return params
    }
    static func petrolSavedForDistance(distance : Double) -> Double{
        return 0.1 * distance
    }
    static func co2ReducedForDistance(distance : Double) -> Double{
        return 0.24 * distance
    }
    public override var description: String { 
        return "userId: \(String(describing: self.userId))," + "co2Reduced: \(String(describing: self.co2Reduced))," + " distanceShared: \( String(describing: self.distanceShared))," + " petrolSaved: \(String(describing: self.petrolSaved)),"
    }
}
