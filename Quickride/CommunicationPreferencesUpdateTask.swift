//
//  CommunicationPreferencesUpdateTask.swift
//  Quickride
//
//  Created by KNM Rao on 01/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import Foundation
import ObjectMapper
protocol SaveCommunicationPreferences{
  func communicationPreferencesUpdated()
}

class CommunicationPreferencesUpdateTask {
  
    var emailPreferences : EmailPreferences?
    var smsPreferences : SMSPreferences?
    var whatsAppPreferences : WhatsAppPreferences?
    var callPreferences : CallPreferences?
    var emailPreferencesUpdated = false
    var smsPreferencesUpdated = false
    var whatsAppPreferencesUpdated = false
    var callPreferencesUpdated = false
    var viewController : UIViewController?
    var receiver : SaveCommunicationPreferences?
    
    init(emailPreferences : EmailPreferences,smsPreferences : SMSPreferences, whatsAppPreferences: WhatsAppPreferences, callPreferences: CallPreferences,emailPreferencesUpdated : Bool,smsPreferencesUpdated : Bool,whatsAppPreferencesUpdated:Bool,callPreferencesUpdated:Bool,viewController : UIViewController,receiver : SaveCommunicationPreferences?){
      self.emailPreferences = emailPreferences
      self.smsPreferences = smsPreferences
      self.whatsAppPreferences = whatsAppPreferences
      self.callPreferences = callPreferences
      self.viewController = viewController
      self.emailPreferencesUpdated = emailPreferencesUpdated
      self.smsPreferencesUpdated = smsPreferencesUpdated
      self.whatsAppPreferencesUpdated = whatsAppPreferencesUpdated
      self.callPreferencesUpdated = callPreferencesUpdated
      self.receiver = receiver
    }
    func saveCommunicationPreferences(){
      
      if emailPreferencesUpdated{
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.updatedEmailPreferences(emailPreferences: emailPreferences!, viewController: viewController, responseHandler: { (responseObject, error) in
          if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            QuickRideProgressSpinner.stopSpinner()
            self.emailPreferencesUpdated = false
            self.emailPreferences = Mapper<EmailPreferences>().map(JSONObject: responseObject!["resultData"])
            UserDataCache.getInstance()?.emailPreferences = self.emailPreferences
            if self.emailPreferencesUpdated == false && self.smsPreferencesUpdated == false && self.whatsAppPreferencesUpdated == false &&  self.callPreferencesUpdated == false{
              self.receiver?.communicationPreferencesUpdated()
            }
            
          }else{
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
          }
        })
      }
      if smsPreferencesUpdated{
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.updatedSMSPreferences(smsPreferences: smsPreferences!, viewController: viewController, responseHandler: { (responseObject, error) in
          if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            QuickRideProgressSpinner.stopSpinner()
            self.smsPreferencesUpdated = false
            self.smsPreferences = Mapper<SMSPreferences>().map(JSONObject: responseObject!["resultData"])
            UserDataCache.getInstance()?.smsPreferences = self.smsPreferences
            if self.emailPreferencesUpdated == false && self.smsPreferencesUpdated == false && self.whatsAppPreferencesUpdated == false &&  self.callPreferencesUpdated == false{
              self.receiver?.communicationPreferencesUpdated()
            }
            
          }else{
              ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
          }
        })
      }
        if whatsAppPreferencesUpdated{
            QuickRideProgressSpinner.startSpinner()
            self.whatsAppPreferences = WhatsAppPreferences(userId: Double(QRSessionManager.getInstance()!.getUserId())!, enableWhatsAppPreferences: whatsAppPreferences!.enableWhatsAppPreferences)
            UserRestClient.updatedWhatsAppPreferences(whatsAppPreferences: whatsAppPreferences!, viewController: viewController, responseHandler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    QuickRideProgressSpinner.stopSpinner()
                    self.whatsAppPreferencesUpdated = false
                    self.whatsAppPreferences = Mapper<WhatsAppPreferences>().map(JSONObject: responseObject!["resultData"])
                    UserDataCache.getInstance()?.storeUserWhatsAppPreferences(userWhatsAppPreference: self.whatsAppPreferences!)
                    if self.emailPreferencesUpdated == false && self.smsPreferencesUpdated == false && self.whatsAppPreferencesUpdated == false && self.callPreferencesUpdated == false{
                        self.receiver?.communicationPreferencesUpdated()
                    }
                    
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                }
            })
        }
        if callPreferencesUpdated{
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.updatedCallPreferences(callPreferences: callPreferences!, viewController: viewController, responseHandler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    QuickRideProgressSpinner.stopSpinner()
                    self.callPreferencesUpdated = false
                    UserDataCache.getInstance()?.storeUserCallPreferences(userCallPreferences: self.callPreferences!)
                    if self.emailPreferencesUpdated == false && self.smsPreferencesUpdated == false && self.whatsAppPreferencesUpdated == false && self.callPreferencesUpdated == false{
                        self.receiver?.communicationPreferencesUpdated()
                    }
                    
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                }
            })
        }
    }
}
