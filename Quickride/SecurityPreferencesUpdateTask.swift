//
//  SecurityPreferencesUpdateTask.swift
//  Quickride
//
//  Created by KNM Rao on 08/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
protocol SecurityPreferencesUpdateReceiver {
  func securityPreferenceUpdated()
}
class SecurityPreferencesUpdateTask {
  
  var viewController : UIViewController?
  var securityPreferences :SecurityPreferences?
  var securityPreferencesUpdateReceiver : SecurityPreferencesUpdateReceiver?
  
  init(viewController : UIViewController, securityPreferences: SecurityPreferences, securityPreferencesUpdateReceiver :SecurityPreferencesUpdateReceiver?){
    self.viewController = viewController
    self.securityPreferences = securityPreferences
    self.securityPreferencesUpdateReceiver = securityPreferencesUpdateReceiver
  }
  func updateSecurityPreferences(){
    QuickRideProgressSpinner.startSpinner()
    UserRestClient.updatedSecurityPreferences(securityPreferences: securityPreferences!, viewController: viewController) { (responseObject, error) in
        QuickRideProgressSpinner.stopSpinner()
      if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
        self.securityPreferences = Mapper<SecurityPreferences>().map(JSONObject: responseObject!["resultData"])
        UserDataCache.getInstance()?.storeSecurityPreferences(securityPreferences: self.securityPreferences!)
        self.securityPreferencesUpdateReceiver?.securityPreferenceUpdated()
      }else{
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
      }
    }
  }
}
