//
//  MyReferralsReportViewModel.swift
//  Quickride
//
//  Created by Halesh on 27/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol MyReferralsReportViewModelDelegate {
    func handleSuccessResponse()
}

class MyReferralsReportViewModel{
    
    //MARK: Variables
    var referralStats: ReferralStats?
    var referredUserInfoList = [ReferredUserInfo]()
    var referredUserInfoListFetched = false
    
    func getReferredUserInfoList(delagate: MyReferralsReportViewModelDelegate,viewController: UIViewController){
        UserRestClient.getReferredUserInfo(userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.referredUserInfoList = Mapper<ReferredUserInfo>().mapArray(JSONObject: responseObject!["resultData"]) ?? [ReferredUserInfo]()
                delagate.handleSuccessResponse()
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
}
