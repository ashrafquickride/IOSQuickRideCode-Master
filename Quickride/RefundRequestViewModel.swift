//
//  RefundRequestViewModel.swift
//  Quickride
//
//  Created by Vinutha on 07/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol RefundRequestApproved {
    func refundApproved()
    func refundApprovalFailed(responseObject: NSDictionary?,error: NSError?)
}

protocol RefundRequestReject {
    func refundRequestRejected()
    func refundRejectionFailed(responseObject: NSDictionary?,error: NSError?)
}

protocol GetRequestedUserDetails {
    func recievedRequestedUserInfo()
}

class RefundRequestViewModel{
    
    var refundRequest: RefundRequest?
    var ride: Ride?
    var userBasicInfo: UserBasicInfo?
    
    init(refundRequest: RefundRequest) {
        self.refundRequest = refundRequest
    }
    init() {
        
    }
    
    func getRefundRideAndParticipants(){
        guard let closedRides = MyClosedRidesCache.getClosedRidesCacheInstance().getClosedRiderRides()?.values else { return }
        for riderRide in closedRides{
            if riderRide.noOfPassengers != 0 && StringUtils.getStringFromDouble(decimalNumber: riderRide.rideId) == refundRequest?.sourceRefId{
                ride = riderRide
                break
            }
        }
    }
    
    func getUserbasicInfo(delegate: GetRequestedUserDetails){
        UserRestClient.getUserBasicInfo(userId: Double(refundRequest?.fromUserId ?? 0), viewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.userBasicInfo = Mapper<UserBasicInfo>().map(JSONObject: responseObject!["resultData"])
                delegate.recievedRequestedUserInfo()
            }
        }
    }
    
    func refundToRequestedUser(delagte: RefundRequestApproved){
        AccountRestClient.riderRefundToPassenger(accountTransactionId: Double(refundRequest?.fromUserId ?? 0), points: String(refundRequest?.points ?? 0), rideId: Double(refundRequest?.sourceRefId ?? ""), invoiceId: String(refundRequest?.invoiceId ?? 0), viewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                delagte.refundApproved()
            }else{
                delagte.refundApprovalFailed(responseObject: responseObject,error: error)
            }
        }
    }
    
    func rejectRequest(reason: String,delegate: RefundRequestReject){
        AccountRestClient.requestReject(requestorUserId: Double(refundRequest?.fromUserId ?? 0), senderContactNo: String(refundRequest?.toUserId ?? 0), reason: reason, isTransfer: false, passengerRideId: refundRequest?.refId ?? "", viewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                delegate.refundRequestRejected()
            }else{
                delegate.refundRejectionFailed(responseObject: responseObject,error: error)
            }
        }
    }
}
