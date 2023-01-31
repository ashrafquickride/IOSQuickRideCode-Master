//
//  RideRouteUpdateListener.swift
//  Quickride
//
//  Created by Vinutha on 21/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideRouteUpdateListener: TopicListener {
    public override func getMessageClassName() -> AnyClass {
        AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
        return type(of: self)
    }
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("\(String(describing: messageObject))")
        if let messageObjectString = messageObject as? String, let rideUpdate = Mapper<RideUpdate>().map(JSONString: messageObjectString) {
            MyActiveRidesCache.getRidesCacheInstance()?.rideRouteUpdate(rideUpdate: rideUpdate)
        }
    }
}
