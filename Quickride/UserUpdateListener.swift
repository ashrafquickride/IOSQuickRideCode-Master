//
//  UserUpdateListener.swift
//  Quickride
//
//  Created by Vinutha on 9/25/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class UserUpdateListener : TopicListener{
    
    public override func getMessageClassName() -> AnyClass {
        AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
        return type(of: self)
    }
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("onMessageRecieved()")
        let user : User = Mapper<User>().map(JSONString: messageObject as! String)! as User
        UserDataCache.getInstance()?.storeUserDynamicChanges(user: user)
    }
}
