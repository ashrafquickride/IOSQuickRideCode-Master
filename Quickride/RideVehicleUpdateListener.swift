//
//  RideVehicleUpdateListener.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 28/09/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RideVehicleUpdateListener : TopicListener{
    
    public override func getMessageClassName() -> AnyClass {
        AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
        return type(of: self)
    }
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("onMessageRecieved()")
        let rideVehicle : RideVehicle = Mapper<RideVehicle>().map(JSONString: messageObject as! String)! as RideVehicle
        MyActiveRidesCache.getRidesCacheInstance()?.updateRiderVehicleDetails(rideVehicle: rideVehicle)
}
}
