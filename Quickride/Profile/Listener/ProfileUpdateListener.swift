//
//  ProfileUpdateListener.swift
//  Quickride
//
//  Created by KNM Rao on 23/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class ProfileUpdateListener : TopicListener{
  
    public override func getMessageClassName() -> AnyClass {
      AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
        return type(of: self)
    }
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
      AppDelegate.getAppDelegate().log.debug("onMessageRecieved()")
        let profile : UserProfile = Mapper<UserProfile>().map(JSONString: messageObject as! String)! as UserProfile
            UserDataCache.getInstance()?.storeProfileDynamicChanges(profile: profile)
    }
}
