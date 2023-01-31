//
//  RideSharingCommunityContribution.swift
//  Quickride
//
//  Created by QuickRideMac on 27/09/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class RideSharingCommunityContribution : NSObject, Mappable{
     var category : String?
     var newFriendsMade : Int?
     var numberOfRidesShared : Int?
     var numberOfCarsRemovedFromRoad : Int?
     var co2Reduced : Float = 0.0
     var totalDistanceShared : Double?
     var fuelPointsEarned : Int?
     var fuelPointsRedeemed : Int?
     var amountSaved : Int?
     var amountSavedForOthers : Int?
     static let USER_CATEGORY_GOLD = "GOLD"
     static let USER_CATEGORY_BRONZE = "BRONZE"
     static let USER_CATEGORY_SILVER = "SILVER"
     static let USER_CATEGORY_DIAMOND = "DIAMOND"
     static let USER_CATEGORY_PLATINUM = "PLATINUM"
    
    
    init(category : String, newFriendsMade : Int, numberOfRidesShared : Int, numberOfCarsRemovedFromRoad : Int, co2Reduced : Float, totalDistanceShared : Double, fuelPointsEarned : Int, fuelPointsRedeemed : Int, amountSaved : Int, amountSavedForOthers : Int) {
    self.category = category
    self.newFriendsMade = newFriendsMade
    self.numberOfRidesShared = numberOfRidesShared
    self.numberOfCarsRemovedFromRoad = numberOfCarsRemovedFromRoad
    self.co2Reduced = co2Reduced
    self.totalDistanceShared = totalDistanceShared
    self.fuelPointsEarned = fuelPointsEarned
    self.fuelPointsRedeemed = fuelPointsRedeemed
    self.amountSaved = amountSaved
    self.amountSavedForOthers = amountSavedForOthers
    }
    required internal init?(map:Map){
        
    }
    func mapping(map: Map) {
        newFriendsMade <- map["newFriendsMade"]
        numberOfRidesShared <- map["numberOfRidesShared"]
        numberOfCarsRemovedFromRoad <- map["numberOfCarsRemovedFromRoad"]
        co2Reduced <- map["co2Reduced"]
        
        totalDistanceShared <- map["totalDistanceShared"]
        fuelPointsEarned <- map["fuelPointsEarned"]
        fuelPointsRedeemed <- map["fuelPointsRedeemed"]
        amountSaved <- map["amountSaved"]
        amountSavedForOthers <- map["amountSavedForOthers"]
        category <- map["category"]
    }
    func getParams() -> [String : String] {
        AppDelegate.getAppDelegate().log.debug("getParams()")
        var params : [String : String] = [String : String]()
        params["category"] = self.category
        params["newFriendsMade"] = String(describing: self.newFriendsMade)
        params["numberOfRidesShared"] =  String(describing: self.numberOfRidesShared)
        params["numberOfCarsRemovedFromRoad"] = String(describing: self.numberOfCarsRemovedFromRoad)
        params["co2Reduced"] = String(describing: self.co2Reduced)
        params["totalDistanceShared"] =  String(describing: self.totalDistanceShared)
        params["fuelPointsEarned"] = String(describing: self.fuelPointsEarned)
        params["fuelPointsRedeemed"] = String(describing: self.fuelPointsRedeemed)
        params["amountSaved"] =  String(describing: self.amountSaved)
        params["amountSavedForOthers"] = String(describing: self.amountSavedForOthers)
        return params
    }
    public override var description: String {
        return "category: \(String(describing: self.category))," + "newFriendsMade: \(String(describing: self.newFriendsMade))," + " numberOfRidesShared: \( String(describing: self.numberOfRidesShared))," + " numberOfCarsRemovedFromRoad: \(String(describing: self.numberOfCarsRemovedFromRoad))," + " co2Reduced: \(String(describing: self.co2Reduced)),"
            + " totalDistanceShared: \(String(describing: self.totalDistanceShared))," + "fuelPointsEarned: \(String(describing: self.fuelPointsEarned))," + "fuelPointsRedeemed:\(String(describing: self.fuelPointsRedeemed))," + "amountSaved:\(String(describing: self.amountSaved))," + "amountSavedForOthers:\(String(describing: self.amountSavedForOthers)),"
    }
}
