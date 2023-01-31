//
//  AnalyticsUtils.swift
//  Quickride
//
//  Created by Admin on 12/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import FirebaseAnalytics

class AnalyticsUtils{
  
    static var analyticsUtils : AnalyticsUtils?
    static let deviceId = "DeviceId"
   
    static func getInstance() -> AnalyticsUtils{
        if analyticsUtils == nil{
            analyticsUtils = AnalyticsUtils()
        }
      return analyticsUtils!
    }
    
    func triggerEvent(eventType: String, params: [String: Any],uniqueField: String){
            UserRestClient.sendEventToServer(eventType: eventType, params: params, uniqueField:uniqueField ) { (_, _) in
        }
        var paramsNew = params
        paramsNew["androidVersion"] = "0"
        paramsNew["iosVersion"] = AppConfiguration.APP_CURRENT_VERSION_NO
        for element in paramsNew {
            if let value = element.value as? String , value.count > 40 {
                paramsNew[element.key] = value.prefix(35)
            }
        }
        Analytics.logEvent(eventType, parameters: paramsNew)
        FaceBookEventsLoggingUtils.logEvent(eventType: eventType, parameters: paramsNew)
    }
    
}
