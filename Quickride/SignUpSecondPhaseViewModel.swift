//
//  SignUpSecondPhaseViewModel.swift
//  Quickride
//
//  Created by Admin on 14/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class SignUpSecondPhaseViewModel {
    
    var mobileNo: String?
    var enableWhatsAppPreferences = false
    
    func sendOTPToUser(contactNo : String,viewController : UIViewController?,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        UserRestClient.createProbableUser(contactNo: contactNo, countryCode: AppConfiguration.DEFAULT_COUNTRY_CODE_IND, appName: AppConfiguration.APP_NAME, status: SocialUserStatus.status_new, verificationProvider: User.OTP_CAPS, viewController: viewController, handler: handler)
    }
    
    func getUserObject(responseObject: NSDictionary?,contactNo : String?) -> User?{
        if let resultData = responseObject?["resultData"],let status = resultData as? String,status != SocialUserStatus.status_new{
            let user = User()
            user.contactNo = Double(contactNo ?? "")
            user.countryCode = AppConfiguration.DEFAULT_COUNTRY_CODE_IND
            user.status = status
            user.appName = AppConfiguration.APP_NAME
            return user
        }else{
            return nil
        }
    }
}
