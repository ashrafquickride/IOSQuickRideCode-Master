//
//  DeviceUniqueIDProxy.swift
//  Quickride
//
//  Created by QuickRideMac on 2/5/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
//import AppsFlyerLib


class DeviceUniqueIDProxy{
    func getDeviceUniqueId() -> String? {
        let uuid = AppDelegate.getAppDelegate().getIDFA()
        AppDelegate.getAppDelegate().log.debug("UUID : \(String(describing: uuid))")
        return uuid
    }
    func checkAndUpdateUniqueDeviceID(){
        guard let userDataCache = UserDataCache.getInstance(), let user = userDataCache.currentUser else { return }
        
        if user.uniqueDeviceId != nil && user.uniqueDeviceId!.isEmpty == false{
            return
        }
        let uniqueID = getDeviceUniqueId()
        if uniqueID == nil || uniqueID!.isEmpty{
            return
        }
//        guard let appsFlyerId = AppsFlyerTracker.shared()?.getAppsFlyerUID() else { return }
        UserRestClient.updateDeviceUniqueId(userid: user.phoneNumber, uniqueID: uniqueID!,appsFlyerId: nil, viewController: nil) { (reponse, error) in
            AppDelegate.getAppDelegate().log.debug("\(String(describing: reponse)), Error : \(String(describing: error))")
        }
    }
}
