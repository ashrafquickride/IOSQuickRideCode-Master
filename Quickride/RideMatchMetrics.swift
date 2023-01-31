//
//  RideMatchMetrics.swift
//  Quickride
//
//  Created by KNM Rao on 25/05/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

import ObjectMapper

class RideMatchMetrics : NSObject, Mappable {
  
  var points = 0.0
  var distanceOnRiderRoute = 0.0
  var distanceOnPassengerRoute = 0.0
  var matchPercentOnRiderRoute = 0
  var matchPercentOnPassengerRoute = 0
  var pickUpTime = 0.0
  var dropTime = 0.0
  
  required init?(map: Map) {
    
  }
    override init(){
    
  }
  func mapping(map: Map) {
    self.points <- map["points"]
    self.distanceOnRiderRoute  <- map["distanceOnRiderRoute"]
    self.distanceOnPassengerRoute <- map["distanceOnPassengerRoute"]
    self.matchPercentOnRiderRoute <- map["matchPercentOnRiderRoute"]
    self.matchPercentOnPassengerRoute <- map["matchPercentOnPassengerRoute"]
    self.dropTime <- map["dropTime"]
    self.pickUpTime <- map["pickUpTime"]
  }
    public override var description: String { 
        return "points: \(String(describing: self.points))," + "distanceOnRiderRoute: \(String(describing: self.distanceOnRiderRoute))," + " distanceOnPassengerRoute: \( String(describing: self.distanceOnPassengerRoute))," + " matchPercentOnRiderRoute: \(String(describing: self.matchPercentOnRiderRoute))," + " matchPercentOnPassengerRoute: \(String(describing: self.matchPercentOnPassengerRoute))," + " dropTime: \(String(describing: self.dropTime))," + " pickUpTime: \(String(describing: self.pickUpTime)),"
    }
  
}
