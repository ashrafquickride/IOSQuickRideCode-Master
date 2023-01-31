//
//  DeviceRegistrationHelper.swift
//  Quickride
//
//  Created by KNM Rao on 21/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
//import AppsFlyerLib

class DeviceRegistrationHelper{
  let sourceViewController : UIViewController?
  let phone : String
  let deviceToken : String?
  static var isDeviceTokenRegistered = false
  init (sourceViewController : UIViewController?, phone : String, deviceToken : String?) {
    self.sourceViewController = sourceViewController
    self.phone = phone
    self.deviceToken = deviceToken
  }
  
  func registerDeviceTokenWithQRServer() {
    AppDelegate.getAppDelegate().log.debug("registerDeviceTokenWithQRServer()")
    if DeviceRegistrationHelper.isDeviceTokenRegistered{
        AppDelegate.getAppDelegate().log.debug("deviceToken is already registered successful")
        return
    }
    var requestbody = [String : String]()
    requestbody["phone"] = phone
    requestbody["clientIosKey"] =  deviceToken
//    requestbody["appsFlyerId"] = AppsFlyerTracker.shared()?.getAppsFlyerUID()
          AppDelegate.getAppDelegate().log.debug("Registering device token : \(requestbody)")
    UserRestClient.saveDeviceToken(targetViewController: sourceViewController, requestBody: requestbody, completionHandler: { (registrationResponseObject, registrationError) -> Void in
      if registrationResponseObject != nil && registrationResponseObject!["result"] as! String == "SUCCESS"{
        
                AppDelegate.getAppDelegate().log.debug("Device token registered successfully")
        DeviceRegistrationHelper.isDeviceTokenRegistered = true
        }
        
    })
  }
}
