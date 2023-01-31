//
//  EventUpdate.swift
//  Quickride
//
//  Created by iDisha on 22/05/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class EventUpdate: NSObject,Mappable {
    
    var uniqueId : String?
    var time: Double?
    var topic: String?
    var eventObjectType: String?
    var eventObjectJson: String?
    var status: String?
    var isAckRequired = false
    var expirytime: Double?
    var sendTo: Double?
    
    public static let EVENT_STATUS_RECIEVED = "RECIEVED";
    
    public static let Unique_Id = "Unique_Id";
    public static let EVENT_STATUS = "Event_Status"
    public static let send_to = "sendTo"
    
    override init(){
    }
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        uniqueId <- map["uniqueId"]
        time <- map["time"]
        topic <- map["topic"]
        eventObjectType <- map["eventObjectType"]
        eventObjectJson <- map["eventObjectJson"]
        status <- map["status"]
        isAckRequired <- map["isAckRequired"]
        expirytime <- map["expirytime"]
        sendTo <- map["sendTo"]
    }
    public override var description: String {
        return "uniqueId: \(String(describing: self.uniqueId))," + "time: \(String(describing: self.time))," + " topic: \( String(describing: self.topic))," + " eventObjectType: \(String(describing: self.eventObjectType))," + " eventObjectJson: \(String(describing: self.eventObjectJson)),"
            + " status: \(String(describing: self.status))," + "isAckRequired: \(String(describing: self.isAckRequired))," + "expirytime:\(String(describing: self.expirytime))," + "city:\(String(describing: self.expirytime))," + "sendTo:\(String(describing: self.sendTo)),"
    }
}
