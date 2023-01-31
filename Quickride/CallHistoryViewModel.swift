//
//  CallHistoryViewModel.swift
//  Quickride
//
//  Created by Admin on 09/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol CallHistoryViewModelDelegate {
    func receivedCallHistory()
}

class CallHistoryViewModel {
    
    //MARK: Properties
    var delegate: CallHistoryViewModelDelegate?
    var callHistoryList: [CallHistory]?
    
    //MARK: Methods
    func getCallHistory(viewController: UIViewController) {
        UserRestClient.getCallHistory(userId: QRSessionManager.getInstance()?.getUserId() ?? "", targetViewController: viewController) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.callHistoryList = Mapper<CallHistory>().mapArray(JSONObject: responseObject!["resultData"])
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
            self.delegate?.receivedCallHistory()
        }
    }
    
    func getTheReceiverID(callDetail: CallHistory) -> Double?{
        if callDetail.status == CallHistory.INCOMING {
            return callDetail.fromUserId
        } else {
            return callDetail.toUserId
        }
    }
}
