//
//  BankAccountRegistrationViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 10/02/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class BankAccountRegistrationViewModel{
    
    var handler: bankAccountRegistrationComplitionHandler?
    var userBankAccountInfo = UserBankAccountInfo()
    var isRequiredToEditBankDetails = false
    
    init(isRequiredToEditBankDetails: Bool,handler: @escaping bankAccountRegistrationComplitionHandler) {
        self.handler = handler
        self.isRequiredToEditBankDetails = isRequiredToEditBankDetails
    }
    
    init() {}
    func getBankDetails(handler: @escaping (_ isDetailsReceived: Bool) -> Void){
        AccountRestClient.getBankRegistrationDetails(userId: UserDataCache.getInstance()?.userId ?? "") { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS",responseObject!["resultData"] != nil {
                self.userBankAccountInfo = Mapper<UserBankAccountInfo>().map(JSONObject: responseObject!["resultData"]) ?? UserBankAccountInfo()
                handler(true)
            }
        }
    }
    
    func registerProvidedBankDetails(){
        AccountRestClient.registerForBankAccount(userBankInfo: userBankAccountInfo) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                SharedPreferenceHelper.setBankRegistration(status: true)
                NotificationCenter.default.post(name: .stopSpinner, object: nil)
            }else{
                var userInfo = [String: Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
}
