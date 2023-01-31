//
//  EventDataForApp.swift
//  Quickride
//
//  Created by Vinutha on 26/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class MqttDataForApp: NSObject,Mappable {

    var mainEventBrokerConnectInfo : RmqBrokerConnectInfo?
    var locationEventBrokerConnectInfo : RmqBrokerConnectInfo?
    var awsIotConnectCredentials : AWSIosConnectCredentials?
    var rideMgmtEventBrokerType : String?
    var locationMgmtEventBrokerType : String?
    var publishMainEventsOnRMQBroker: Bool?
    var publishLocationEventsOnRMQBroker: Bool?
    
    required init?(map: Map) { }
       
    func mapping(map: Map) {
        mainEventBrokerConnectInfo <- map["mainEventBrokerConnectInfo"]
        locationEventBrokerConnectInfo <- map["locationEventBrokerConnectInfo"]
        awsIotConnectCredentials <- map["awsIotConnectCredentials"]
        rideMgmtEventBrokerType <- map["rideMgmtEventBrokerType"]
        locationMgmtEventBrokerType <- map["locationMgmtEventBrokerType"]
        publishMainEventsOnRMQBroker <- map["publishMainEventsOnRMQBroker"]
        publishLocationEventsOnRMQBroker <- map["publishLocationEventsOnRMQBroker"]
    }
    
}
