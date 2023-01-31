//
//  UserBankAccountInfo.swift
//  Quickride
//
//  Created by QR Mac 1 on 02/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct UserBankAccountInfo: Mappable {
    
    var userId = 0.0
    var bankName: String?
    var bankAccountNo: String?
    var accountHolderName: String?
    var mobileNo: String? //optional linked mobileNo
    var nickName: String? //max 6-8 chars
    var branch: String?
    var ifscCode: String? //11 digits
    var accountType: String? //Saving or Current
    var beneficiaryType: String? //Domestic or international
    var nationality: String? //Indian
    var upiId: String?
    var defaultPayment: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        bankName <- map["bankName"]
        bankAccountNo <- map["bankAccountNo"]
        accountHolderName <- map["accountHolderName"]
        ifscCode <- map["ifscCode"]
        mobileNo <- map["mobileNo"]
        userId <- map["userId"]
    }
    init() {}
    init(bankName: String,bankAccountNo: String,accountHolderName: String,mobileNo: String,ifscCode: String) {
        self.bankName = bankName
        self.bankAccountNo = bankAccountNo
        self.accountHolderName = accountHolderName
        self.mobileNo = mobileNo
        self.ifscCode = ifscCode
    }
    
    func  getParamsMap() -> [String : String] {
        var params = [String : String]()
        params["userId"] =  UserDataCache.getInstance()?.userId
        params["bankName"] = bankName
        params["bankAccountNo"] = bankAccountNo
        params["accountHolderName"] = accountHolderName
        params["mobileNo"] = mobileNo
        params["ifscCode"] = ifscCode
        return params
    }
}
