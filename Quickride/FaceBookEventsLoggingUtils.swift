//
//  FaceBookEventsLoggingUtils.swift
//  Quickride
//
//  Created by Admin on 01/02/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

class FaceBookEventsLoggingUtils{
    
    static func logCompletedRegistrationEvent(registrationMethod : String) {
        let parameters =  [AppEvents.ParameterName.registrationMethod : registrationMethod]
        AppEvents.shared.logEvent(.completedRegistration, parameters: parameters)
    }
    
    static func logFindRideEvent(contentType : String, contentData : String, contentId : String, searchString : String, success : Bool) {
       
        let parameters = [AppEvents.ParameterName.contentType: contentType,AppEvents.ParameterName.content: contentData,AppEvents.ParameterName.contentID: contentId,AppEvents.ParameterName.searchString: searchString,AppEvents.ParameterName.success: "\(success)"]
        AppEvents.shared.logEvent(.searched, parameters: parameters)
    }
    
    static func logOfferRideEvent(contentData : String, contentId : String, contentType : String, currency : String, price : Double) {
        let parameters = [AppEvents.ParameterName.content: contentData,AppEvents.ParameterName.contentID: contentId,AppEvents.ParameterName.contentType: contentType,AppEvents.ParameterName.currency: String(price)]
        AppEvents.shared.logEvent(.addedToWishlist, valueToSum: price, parameters: parameters)
    }
    
    static func logViewedContentEvent(contentType : String, contentData : String, contentId : String, currency : String, price : Double) {
       let parameters = [AppEvents.ParameterName.content: contentData,AppEvents.ParameterName.contentID: contentId,AppEvents.ParameterName.contentType: contentType,AppEvents.ParameterName.currency: String(price)]
        AppEvents.shared.logEvent(.searched, parameters: parameters)
       AppEvents.shared.logEvent(.viewedContent, valueToSum: price, parameters: parameters)
    }
    
    static func logAmountCreditsEvent(contentData : String, contentId : String, contentType : String, totalValue : Double) {
        let parameters = [AppEvents.ParameterName.content: contentData,AppEvents.ParameterName.contentID: contentId,AppEvents.ParameterName.contentType: contentType]
        AppEvents.shared.logEvent(.searched, parameters: parameters)
        AppEvents.shared.logEvent(.spentCredits, valueToSum: totalValue, parameters: parameters)
    }
    
    static func logAmountDebitEvent(amount: Double, currency: String){
        
        AppEvents.shared.logPurchase(amount: amount, currency: currency)
    }
    
    static func logEvent(eventType : String, parameters: [String:Any]){
        var params = [AppEvents.ParameterName:Any]()
        for item in parameters {
            params[AppEvents.ParameterName(item.key)] = item.value
        }
        AppEvents.shared.logEvent(.init(eventType), parameters: params)
    }
}

