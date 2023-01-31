//
//  SecurityPreferencesUpdateListener.swift
//  Quickride
//
//  Created by iDisha on 24/05/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class SecurityPreferencesUpdateListener : TopicListener{
    
    public override func getMessageClassName() -> AnyClass {
        AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
        return type(of: self)
    }
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("onMessageRecieved()")
        let securityPreferences = Mapper<SecurityPreferences>().map(JSONString: messageObject as! String)! as SecurityPreferences
        UserDataCache.getInstance()?.storeSecurityPreferences(securityPreferences: securityPreferences)
        
    }
    
}
