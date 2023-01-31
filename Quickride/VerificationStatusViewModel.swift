//
//  VerificationStatusViewModel.swift
//  Quickride
//
//  Created by Halesh on 09/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class VerificationStatusViewModel {
    
    //MARK: Variables
    var companyName: String?
    var status: String?
    var companyVerificationStatus: CompanyVerificationStatus?
    var emailDomain: String?
    
    init(companyName: String, status: String,emailDomain: String) {
        self.companyName = companyName
        self.status = status
        self.emailDomain = emailDomain
    }
    init() {
        
    }
    
    func getCompanyDomainStatus(){
        AppDelegate.getAppDelegate().log.debug("getEmailDomains")
        UserRestClient.checkCompanyDomainStatus(emailDomain: emailDomain ?? "") { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.companyVerificationStatus = Mapper<CompanyVerificationStatus>().map(JSONObject: responseObject!["resultData"])
                 NotificationCenter.default.post(name: .companyDomainStatusReceived, object: self)
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .companyDomainStatusFailed, object: self, userInfo: userInfo)
            }
        }
    }
}
