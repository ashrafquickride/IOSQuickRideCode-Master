//
//  FreezeRideTopicListener.swift
//  Quickride
//
//  Created by Admin on 29/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class FreezeRideTopicListener : TopicListener{
    public override func getMessageClassName() -> AnyClass {
        AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
        return type(of: self)
    }
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("onMessageRecieved()")
        let freezeRideStatusObj = Mapper<FreezeRideStatus>().map(JSONString: messageObject as! String)
        if freezeRideStatusObj != nil{
            MyActiveRidesCache.getRidesCacheInstance()?.handleFreezeRide(freezeRideStatusObj: freezeRideStatusObj!)
        }
     }
 }
