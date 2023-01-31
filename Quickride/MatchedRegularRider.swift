//
//  MatchedRegularRider.swift
//  Quickride
//
//  Created by QuickRideMac on 19/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class MatchedRegularRider: MatchedRegularUser,NSCopying {
    var model : String?
    var fare : Double = 0
  var vehicleType : String?
  var vehicleNumber : String?
  var vehicleMakeAndCategory : String?
  var additionalFacilities : String?
  var vehicleImageURI : String?
  var riderHasHelmet = false
  var capacity : Int = 0
    
    override init() {
        super.init()
        userRole = MatchedUser.REGULAR_RIDER
    }

    required init(_ map: Map) {
        super.init()
    }
    
    required public init(map: Map) {
        super.init(map: map)
    }
    
   
    override func mapping(map: Map) {
        super.mapping(map: map)
        self.model <- map["model"]
        self.fare <- map["fare"]
        self.vehicleType <- map["vehicleType"]
        if vehicleType == nil || vehicleType!.isEmpty{
          vehicleType = Vehicle.checkVehicleTypeFromModel(vehicleModel: self.model)
        }
        self.vehicleNumber <- map["vehicleNumber"]
        self.vehicleMakeAndCategory <- map["vehicleMakeAndCategory"]
        self.additionalFacilities <- map["additionalFacilities"]
        self.capacity <- map["capacity"]
        self.vehicleImageURI <- map["vehicleImageURI"]
        self.riderHasHelmet <- map["riderHasHelmet"]
    }
    
    override func getParams() -> [String : String]{
        var params = super.getParams()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideid)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber: userid)
        return params
    }
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let matchedUser = MatchedRegularRider()
        initialise(matchedUser: matchedUser)
        matchedUser.model = self.model
        matchedUser.fare = self.fare
        matchedUser.capacity = self.capacity
        matchedUser.vehicleType  = self.vehicleType
        matchedUser.vehicleNumber  = self.vehicleNumber
        matchedUser.vehicleMakeAndCategory = self.vehicleMakeAndCategory
        matchedUser.vehicleImageURI = self.vehicleImageURI
        matchedUser.additionalFacilities = self.additionalFacilities
        matchedUser.riderHasHelmet  = self.riderHasHelmet
        return matchedUser
    }
}
