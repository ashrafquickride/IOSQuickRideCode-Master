//
//  ParticipantETAInfo.swift
//  Quickride
//
//  Created by Quick Ride on 10/30/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ParticipantETAInfo :NSObject, Mappable{
    var participantId: Double = 0
    var destinationLatitude: Double = 0
    var destinationLongitude: Double = 0
    var durationInTraffic: Int = 0
    var routeDistance : Double = 0
    var duration: Int = 0
    var lastUpdateTime : Double = 0
    var error: ResponseError?
    
    init(participantId : Double , destinationLatitude : Double , destinationLongitude : Double ,routeDistance :Double, durationInTraffic : Int ,duration : Int, error : ResponseError?) {
        self.participantId = participantId
        self.destinationLatitude = destinationLatitude
        self.destinationLongitude = destinationLongitude
        self.routeDistance = routeDistance
        self.durationInTraffic = durationInTraffic
        self.duration = duration
        self.error = error
    }
    required init?(map: Map) {
        
    }
    override init() {
        
    }
    func mapping(map: Map) {
        self.participantId <- map["participantId"]
        self.destinationLatitude <- map["destinationLatitude"]
        self.destinationLongitude <- map["destinationLongitude"]
        self.routeDistance <- map["routeDistance"]
        self.durationInTraffic <- map["durationInTraffic"]
        self.duration <- map["duration"]
        self.error <- map["error"]
        
    }
    public override var description: String {
        return "participantId: \(String(describing: self.participantId))," + "destinationLatitude: \(String(describing: self.destinationLatitude))," + " destinationLongitude: \( String(describing: self.destinationLongitude))," + "durationInTraffic: \(String(describing: self.durationInTraffic))," + "routeDistance: \(String(describing: self.routeDistance))," + " duration: \( String(describing: self.duration))," + "error: \(String(describing: self.error)),"
    }
}
