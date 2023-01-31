//
//  UserPreferencesUpdateTask.swift
//  Quickride
//
//  Created by KNM Rao on 14/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class UserPreferencesUpdateTask {
    
    var viewController : UIViewController?
    var userPreferences :UserPreferences?
    var securityPreferencesUpdated = false
    var ridePreferencesUpdated = false
    var smsPreferencesUdpated = false
    var emailPreferencesUpdated = false
    var whatsAppPreferencesUpdated = false
    var callPreferencesUpdated = false
    var userNotificationSettingsUpdated = false
    
    init(viewController : UIViewController,userPreferences :UserPreferences){
        self.userPreferences = userPreferences
        self.viewController = viewController
    }
    func updatePreferences(){
        QuickRideProgressSpinner.startSpinner()
        if userPreferences?.ridePreferences != nil{
            UserRestClient.updateRidePreferences(ridePreferences: userPreferences!.ridePreferences!, viewController: viewController, responseHandler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let ridePreferences = Mapper<RidePreferences>().map(JSONObject: responseObject!["resultData"])
                    self.userPreferences?.ridePreferences = ridePreferences
                    
                    self.ridePreferencesUpdated = true
                    self.checkAndProcessSuccess()
                }else{
                     ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                }
            })
        }
        if userPreferences!.securityPreferences != nil{
            UserRestClient.updatedSecurityPreferences(securityPreferences: userPreferences!.securityPreferences!, viewController: viewController, responseHandler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.securityPreferencesUpdated = true
                    let securityPreferences = Mapper<SecurityPreferences>().map(JSONObject: responseObject!["resultData"])
                    self.userPreferences?.securityPreferences = securityPreferences
                    self.checkAndProcessSuccess()
                }else{
                     ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                }
            })
        }
        if userPreferences?.communicationPreferences?.smsPreferences != nil{
            UserRestClient.updatedSMSPreferences(smsPreferences: userPreferences!.communicationPreferences!.smsPreferences!, viewController: viewController, responseHandler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.smsPreferencesUdpated = true
                    let smsPreferences = Mapper<SMSPreferences>().map(JSONObject: responseObject!["resultData"])
                    self.userPreferences?.communicationPreferences?.smsPreferences = smsPreferences
                    self.checkAndProcessSuccess()
                }else{
                     ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                }
            })
        }
        if userPreferences?.communicationPreferences?.emailPreferences != nil{
            UserRestClient.updatedEmailPreferences(emailPreferences: userPreferences!.communicationPreferences!.emailPreferences!, viewController: viewController, responseHandler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.emailPreferencesUpdated = true
                    let emailPreferences = Mapper<EmailPreferences>().map(JSONObject: responseObject!["resultData"])
                    self.userPreferences?.communicationPreferences?.emailPreferences = emailPreferences
                    self.checkAndProcessSuccess()
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                }
            })
        }
        if userPreferences?.communicationPreferences?.whatsAppPreferences != nil{
            UserRestClient.updatedWhatsAppPreferences(whatsAppPreferences: userPreferences!.communicationPreferences!.whatsAppPreferences!, viewController: viewController,responseHandler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.whatsAppPreferencesUpdated = true
                    let whatsAppPreferences = Mapper<WhatsAppPreferences>().map(JSONObject:
                    responseObject!["resultData"])
                    UserDataCache.getInstance()?.storeUserWhatsAppPreferences(userWhatsAppPreference: whatsAppPreferences!)
                    self.checkAndProcessSuccess()
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                }
            })
        }
        if userPreferences?.communicationPreferences?.callPreferences != nil{
            UserRestClient.updatedCallPreferences(callPreferences: userPreferences!.communicationPreferences!.callPreferences!, viewController: viewController,responseHandler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.callPreferencesUpdated = true
                    UserDataCache.getInstance()?.storeUserCallPreferences(userCallPreferences: self.userPreferences!.communicationPreferences!.callPreferences!)
                    self.checkAndProcessSuccess()
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                }
            })
        }
        if userPreferences?.communicationPreferences?.userNotificationSetting != nil{
            UserRestClient.updateUserUserNotificationSetting(targetViewController: viewController!, params: userPreferences!.communicationPreferences!.userNotificationSetting!.getParams(), completionHandler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.userNotificationSettingsUpdated = true
                    let notificationSettings = Mapper<UserNotificationSetting>().map(JSONObject: responseObject!["resultData"])
                    self.userPreferences?.communicationPreferences?.userNotificationSetting = notificationSettings
                    self.checkAndProcessSuccess()
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                }
            })
        }
    }
    func checkAndProcessSuccess(){
        if securityPreferencesUpdated &&
            ridePreferencesUpdated &&
            smsPreferencesUdpated &&
            emailPreferencesUpdated &&
            whatsAppPreferencesUpdated && callPreferencesUpdated &&
            userNotificationSettingsUpdated{
            QuickRideProgressSpinner.stopSpinner()
            userPreferences!.favouriteLocations = UserDataCache.getInstance()?.getFavoriteLocations()
            userPreferences?.userVacation = UserDataCache.getInstance()?.getLoggedInUserVacation()
            UserDataCache.getInstance()?.storeLoggedInUserPreferences(userPreferences: userPreferences!)
            UIApplication.shared.keyWindow?.makeToast( Strings.preferencesUpdated)
        }
    }
}
