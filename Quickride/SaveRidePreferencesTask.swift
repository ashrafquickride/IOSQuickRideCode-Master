//
//  SaveRidePreferencesTask.swift
//  Quickride
//
//  Created by KNM Rao on 10/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol SaveRidePreferencesReceiver {
    func ridePreferencesSaved()
    func ridePreferencesSavingFailed()
}
class SaveRidePreferencesTask{
  var ridePreferences : RidePreferences?
  var viewController : UIViewController?
  var receiver : SaveRidePreferencesReceiver?
  
  init(ridePreferences : RidePreferences,viewController : UIViewController?,receiver : SaveRidePreferencesReceiver?){
    self.ridePreferences = ridePreferences
    self.viewController = viewController
    self.receiver = receiver
  }
    func saveRidePreferences(){
        UserRestClient.updateRidePreferences(ridePreferences: ridePreferences!, viewController: viewController) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.ridePreferences = Mapper<RidePreferences>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeLoggedInUserRidePreferences(ridePreferences: self.ridePreferences!)
                self.receiver?.ridePreferencesSaved()
            }else{
                self.receiver?.ridePreferencesSavingFailed()
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            }
        }
  }
}
