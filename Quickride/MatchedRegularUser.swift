//
//  MatchedRegularUser.swift
//  Quickride
//
//  Created by QuickRideMac on 19/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class MatchedRegularUser: MatchedUser {
    
    var matchedFromDate : Double = 0
    var matchedToDate : Double?  = 0
    var sunday : String?
    var monday : String?
    var tuesday : String?
    var wednesday : String?
    var thursday : String?
    var friday : String?
    var saturday : String?
    
    override init() {
        super.init()
    }

    required init(_ map: Map) {
        super.init()
    }
    
    required public init(map: Map) {
        super.init(map: map)
    }
    
  
    override func mapping(map: Map) {
        super.mapping(map: map)
        self.matchedFromDate <- map["matchedFromDate"]
        self.matchedToDate <- map["matchedToDate"]
        self.sunday <- map["sunday"]
        self.monday <- map["monday"]
        self.tuesday <- map["tuesday"]
        self.wednesday <- map["wednesday"]
        self.thursday <- map["thursday"]
        self.friday <- map["friday"]
        self.saturday <- map["saturday"]
    }
    func parseTime(time : String?) -> Double?{
        if time  == nil{
            return nil
        }else{
            return DateUtils.getTimeStampFromString(dateString: time, dateFormat: "HH:mm:ss")
        }
    }
    func getParams()-> [String: String]{
        var params :[String: String] = [String: String]()
      if pickupLocationAddress?.isEmpty == false{
        params[Ride.FLD_PICKUP_ADDRESS] = pickupLocationAddress
      }
        params[Ride.FLD_PICKUP_LATITUDE] = String(pickupLocationLatitude!)
        params[Ride.FLD_PICKUP_LONGITUDE] = String(pickupLocationLongitude!)
        if pickupTime != nil
        {
            params[Ride.FLD_PICKUP_TIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: pickupTime!))
        }
      if dropLocationAddress?.isEmpty == false{
        params[Ride.FLD_DROP_ADDRESS] = dropLocationAddress!
      }
      
        params[Ride.FLD_DROP_LATITUDE] = String(dropLocationLatitude!)
        params[Ride.FLD_DROP_LONGITUDE] = String(dropLocationLongitude!)
        if dropTime != nil
        {
            params[Ride.FLD_DROP_TIME] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: dropTime!))
        }
        params[Ride.FLD_DISTANCE] = String(distance!)
        params[Ride.FLD_POINTS] = String(points!)
        return params
    }
}
