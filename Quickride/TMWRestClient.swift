//
//  TMWRestClient.swift
//  Quickride
//
//  Created by QuickRideMac on 11/11/17.
//  Copyright © 2017 iDisha. All rights reserved.
//

import Foundation

class TMWRestClient{
    
    public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
    
    private static let baseServerUrl = "https://staging.themobilewallet.com/TMWServices/api/"
    private static let balanceCheckUrl = "GetUserBalance"
    private static let validateCustomerAPIUrl = "ValidateCustomerByMobileNo"
    private static let loadWalletAPIUrl = "LoadCustomerWallet"

    static let USER_ID = "UserId"
    static let STORE_ID = "StoreId"
    static let MOBILE_NO = "MobileNo"
    static let AMOUNT = "Amount"
    static let TRANSACTION_ID = "RefTransactionID"
    
    public static func partnerBalanceCheck(UserId : String, targetViewController : UIViewController? , completionHandler : @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("\(UserId)")
        let url = baseServerUrl + balanceCheckUrl
        var params = [String : String]()
        params[TMWRestClient.USER_ID] = UserId
        HttpUtils.postRequestWithBody(url: url, targetViewController: targetViewController, handler: completionHandler, body : params)
    }
    public static func validateCustomerAPI(StoreId : String, MobileNo : String, targetViewController : UIViewController? , completionHandler : @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("\(StoreId)")
        let url = baseServerUrl + validateCustomerAPIUrl
        var params = [String : String]()
        params[TMWRestClient.STORE_ID] = StoreId
        params[TMWRestClient.MOBILE_NO] = MobileNo
        HttpUtils.postRequestWithBody(url: url, targetViewController: targetViewController, handler: completionHandler, body : params)
    }
    public static func customerLoadWalletAPI(StoreId : String, MobileNo : String, Amount : String, RefTransactionID : String, targetViewController : UIViewController? , completionHandler : @escaping responseJSONCompletionHandler){
        AppDelegate.getAppDelegate().log.debug("\(StoreId)")
        let url = baseServerUrl + loadWalletAPIUrl
        var params = [String : String]()
        params[TMWRestClient.STORE_ID] = StoreId
        params[TMWRestClient.MOBILE_NO] = MobileNo
        params[TMWRestClient.AMOUNT] = Amount
        params[TMWRestClient.TRANSACTION_ID] = RefTransactionID
        HttpUtils.postRequestWithBody(url: url, targetViewController: targetViewController, handler: completionHandler, body : params)
    }
}
