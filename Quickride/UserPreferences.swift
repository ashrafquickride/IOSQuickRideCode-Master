//
//  UserPreferences.swift
//  Quickride
//
//  Created by KNM Rao on 07/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserPreferences: NSObject, Mappable {
  var userId : Double?
  var securityPreferences :SecurityPreferences?
  var ridePreferences : RidePreferences?
  var communicationPreferences : CommunicationPreferences?
  var favouriteLocations : [UserFavouriteLocation]?
  var favouriteRidePartners = [PreferredRidePartner]()
  var userRouteGroups : [UserRouteGroup]?
  var userVacation : UserVacation?
  
  static let USER_ID = "userId"
  
  func mapping(map: Map) {
    self.userId <- map["userId"]
    self.securityPreferences <- map["securityPreferences"]
    self.ridePreferences <- map["ridePreferences"]
    self.communicationPreferences <- map["communicationPreferences"]
    self.favouriteLocations <- map["favouriteLocations"]
    self.favouriteRidePartners <- map["favouritePartners"]
    self.userRouteGroups <- map["userRouteGroups"]
    self.userVacation <- map["userVacation"]
  }
    override init(){
    
  }
  required init?(map: Map) {
    
  }
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "securityPreferences: \(String(describing: self.securityPreferences))," + " ridePreferences: \(String(describing: self.ridePreferences))," + " communicationPreferences: \(String(describing: self.communicationPreferences))," + " favouriteLocations: \(String(describing: self.favouriteLocations)),"
            + " favouriteRidePartners: \(String(describing: self.favouriteRidePartners))," + "userRouteGroups: \(String(describing: self.userRouteGroups))," + "userVacation:\(String(describing: self.userVacation)),"
    }
}
