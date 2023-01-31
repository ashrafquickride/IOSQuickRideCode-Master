//
//  RideModeratorStatusUpdateListener.swift
//  Quickride
//
//  Created by Vinutha on 17/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideModeratorStatusUpdateListener: TopicListener {
    
    public override func getMessageClassName() -> AnyClass {
        AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
        return type(of: self)
    }
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("\(String(describing: messageObject))")
        let rideModeratorStatus = Mapper<RideModeratorStatus>().map(JSONString: messageObject as! String)
        MyActiveRidesCache.getRidesCacheInstance()?.updateAndNotifyRideModeratorStatus(rideModeratorStatus: rideModeratorStatus)
    }
}
