//
//  RidePreferencesUpdateListener.swift
//  Quickride
//
//  Created by QuickRideMac on 4/17/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RidePreferencesUpdateListener : TopicListener{
    
    public override func getMessageClassName() -> AnyClass {
        AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
        return type(of: self)
    }
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("onMessageRecieved()")
        let ridePreferences : RidePreferences = Mapper<RidePreferences>().map(JSONString: messageObject as! String)! as RidePreferences
        UserDataCache.getInstance()?.storeLoggedInUserRidePreferences(ridePreferences: ridePreferences)
    }

}
