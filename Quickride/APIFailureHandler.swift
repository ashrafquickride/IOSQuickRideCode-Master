//
//  APIFailureHandler.swift
//  Quickride
//
//  Created by apple on 4/3/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class APIFailureHandler {
    
    static let API_FAILURE_SERVICE_PATH = "/apifailure"
    
    static func validateResponseAndReportFailure( errorCode : String?, errorMessage : String?, apiKey : String, apiName : String, params : [String :String]?){
        if APIFailureReport.STATUS_OK != errorCode && APIFailureReport.STATUS_ZERO_RESULTS != errorCode{
            
            
            
            let apiFailureReport = APIFailureReport(userId: QRSessionManager.getInstance()!.getUserId(), failedAPI: apiName, apiKey: apiKey, errorMessage: errorMessage, errorCode: errorCode, timeOfOccuranceInMillis: NSDate().getTimeStamp())
            if params != nil{
                apiFailureReport.prepareAndSetReferenceData(params: params!)
            }
            var postParams = [String : String]()
            postParams["report"] = apiFailureReport.toJSONString()
            let url = AppConfiguration.routeRepositoryServerUrl + AppConfiguration.ROUTE_REPOSITORY_serverPort + AppConfiguration.routeRepositoryServerPath +  APIFailureHandler.API_FAILURE_SERVICE_PATH
            HttpUtils.postRequestWithBody(url: url, targetViewController: nil, handler: { (responseObject, error) in
                 AppDelegate.getAppDelegate().log.debug("responseObject : \(responseObject) and error : \(error)")
            }, body: postParams)
        }
    }

}
