//
//  RideParticipantLocation.swift
//  Quickride
//
//  Created by Anki on 18/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RideParticipantLocation:QuickRideMessageEntity{
  
  var rideId:Double?
  var userId:Double?
  var latitude:Double?
  var longitude:Double?
  var bearing:Double?
  var lastUpdateTime : Double?
  var sequenceNo : Int = 0
    var participantETAInfos : [ParticipantETAInfo]?
  
  static let RIDER_RIDE_ID = "riderRideId"
  static let USER_ID = "userId"
  static let LATITUDE = "latitude"
  static let LONGITUDE = "longitude"
  static let BEARING = "bearing"
  static let SEQUENCE_NO = "sequenceNo"
    static let FLD_PARTICIPANT_ETA_INFO = "participantETAInfo"
  
    init(rideId : Double, userId : Double, latitude : Double, longitude : Double, bearing : Double , participantETAInfos : [ParticipantETAInfo]?) {
    super.init()
    self.msgObjType = QuickRideMessageEntity.LOCATION_ENTITY
    self.rideId = rideId
    self.userId = userId
    self.latitude = latitude
    self.longitude = longitude
    self.bearing = bearing
        self.participantETAInfos = participantETAInfos
    }
    init(userId : Double, latitude : Double, longitude : Double, bearing : Double ,participantETAInfos : [ParticipantETAInfo]?) {
        super.init()
        self.msgObjType = QuickRideMessageEntity.LOCATION_ENTITY
        self.userId = userId
        self.latitude = latitude
        self.longitude = longitude
        self.bearing = bearing
        self.participantETAInfos = participantETAInfos

    }
  
  required public init?(map: Map) {
    super.init(map: map)
  }
  
  public override func mapping(map: Map) {
    super.mapping(map: map)
    rideId <- map["rideId"]
    userId <- map["userId"]
    latitude <- map["latitude"]
    longitude <- map["longitude"]
    bearing <- map["bearing"]
    lastUpdateTime <- map["lastUpdateTime"]
    if lastUpdateTime == nil {
        lastUpdateTime <- map["lastUpdateTimeMillis"]
    }
    sequenceNo <- map["sequenceNo"]
    participantETAInfos <- map["participantETAInfos"]
  }
    public override var description: String {
        return "rideId: \(String(describing: self.rideId)),"
            + "userId: \(String(describing: self.userId)),"
            + "latitude: \(String(describing: self.latitude)),"
            + "longitude: \(String(describing: self.longitude)),"
            + "bearing: \(String(describing: self.bearing)),"
            + "lastUpdateTime: \(String(describing: self.lastUpdateTime)),"
            + "sequenceNo: \(String(describing: self.sequenceNo)),"
            + "participantETAInfos: \(String(describing: self.participantETAInfos)),"
    }
  
}
