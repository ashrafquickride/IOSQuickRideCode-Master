//
//  CleverTapAnalyticsUtils.swift
//  Quickride
//
//  Created by Admin on 30/08/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CleverTapSDK

class CleverTapAnalyticsUtils {
    static var cleverTapAnalyticsUtils : CleverTapAnalyticsUtils?
    
    static func getInstance() -> CleverTapAnalyticsUtils{
        if cleverTapAnalyticsUtils == nil{
            cleverTapAnalyticsUtils = CleverTapAnalyticsUtils()
        }
        return cleverTapAnalyticsUtils!
    }
    
    func initializeCleverTap() {
        CleverTap.autoIntegrate()
        #if DEBUG
            CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
        #else
            CleverTap.setDebugLevel(CleverTapLogLevel.off.rawValue)
        #endif
    }
    
    func trackEvent(eventType: String, params: [String: Any]){
        let keys = params.keys
        let details = NSMutableDictionary()
        for key in keys{
            details.setValue(params[key], forKey: key)
        }
        if let analyticsDetails = details as? [AnyHashable : Any]{
            CleverTap.sharedInstance()?.recordEvent(eventType, withProps: analyticsDetails)
        }
        
    }
    
    func trackProfileEvent(user : User){
        let profile: Dictionary<String, AnyObject> = [
            "Name": user.userName as AnyObject ,
            "Identity":  String(format: "%.f", user.phoneNumber) as AnyObject,
            "Email": user.email as AnyObject,
            "Phone": "+91\(Int64(user.contactNo ?? 0))" as AnyObject,
            "Gender": user.gender as AnyObject,
            "MSG-email": false as! AnyObject,
            "MSG-push": true  as! AnyObject,
            "MSG-sms": false  as! AnyObject,
            "MSG-whatsapp": true  as! AnyObject,
        ]
        CleverTap.sharedInstance()?.onUserLogin(profile)
    }
    
    func trackRemoteNotificationWith(deviceToken: Data) {
       CleverTap.sharedInstance()?.setPushToken(deviceToken)
    }
    
    func trackPushNotificationDataEvent(userInfo: [AnyHashable: Any]) {
        CleverTap.sharedInstance()?.handleNotification(withData: userInfo)
    }
    
    func trackDeepLinkURLEvent(url: URL, sourceApplication: String?) {
        CleverTap.sharedInstance()?.handleOpen(url, sourceApplication: sourceApplication)
    }
}
