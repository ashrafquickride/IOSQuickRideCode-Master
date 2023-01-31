//
//  LocationUpdateEventServiceProxy.swift
//  Quickride
//
//  Created by KNM Rao on 04/11/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class LocationUpdateEventServiceProxy: EventServiceProxy {
    
    override init(eventServiceStatusListener: EventServiceStatusListener?) {
        super.init(eventServiceStatusListener: eventServiceStatusListener)
    }
    
    override func getClientId() -> String{
        return "l"+clientIdPrefix+QRSessionManager.getInstance()!.getUserId()
    }
    override func getCleanSession() -> Bool {
        return true
    }
    
    override func getEventBrokerType() -> String? {
        return ConfigurationCache.getInstance()?.getRideMgmtEventBrokerType()
    }
    
    override func getRmqBrokerConnectInfo() -> RmqBrokerConnectInfo? {
        return ConfigurationCache.getInstance()?.getLocationEventBrokerConnectInfo()
    }
    
    override func getAwsIotConnectCredentials() -> AWSIosConnectCredentials? {
        return ConfigurationCache.getInstance()?.getAwsIotConnectCredentials()
    }
}
