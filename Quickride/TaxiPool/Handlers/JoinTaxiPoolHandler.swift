//
//  JoinTaxiPoolHandler.swift
//  Quickride
//
//  Created by Ashutos on 6/13/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias taxiPoolJoinCompletionHandler = (_ responcse: TaxiShareRide?,_ error : NSError?) -> Void

class JoinTaxiPoolHandler {
    var rideId: Double
    var matchedShareTaxiId: Double
    var paymentType: String?
    var taxiInviteId: String?
    var viewController: UIViewController?
    var taxiShareRide : TaxiShareRide?
    var isRideNeedToCancel = false
    
    init(rideId: Double,matchedShareTaxiId: Double,paymentType: String?,taxiInviteId: String?,isRideNeedToCancel: Bool, viewController: UIViewController?) {
        self.rideId = rideId
        self.matchedShareTaxiId = matchedShareTaxiId
        self.paymentType = paymentType
        self.taxiInviteId = taxiInviteId
        self.viewController = viewController
        self.isRideNeedToCancel = isRideNeedToCancel
    }
    
    func joinTaxiPool(joinHandlerTaxiPool : @escaping taxiPoolJoinCompletionHandler) {
        
        let userId = QRSessionManager.sharedInstance?.getUserId() ?? "0"
        let taxiId = StringUtils.getStringFromDouble(decimalNumber: matchedShareTaxiId)
        TaxiPoolRestClient.joinedTaxiRide(id: taxiId, userId: userId, passengerRideId: StringUtils.getStringFromDouble(decimalNumber: rideId), paymentType: self.paymentType,taxiInviteId: taxiInviteId, viewController: nil, completionHandler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let taxiShareRideresponse = Mapper<TaxiShareRideResponse>().map(JSONObject: responseObject!["resultData"])
                if let error = taxiShareRideresponse?.quickRideException?.error {
                    joinHandlerTaxiPool(nil,nil)
                    if error.errorCode == RideValidationUtils.PAY_TO_REQUEST_RIDE_ERROR, let extraInfo = error.extraInfo, !extraInfo.isEmpty{
                        self.taxiShareRide = taxiShareRideresponse?.taxiShareRide
                        AccountUtils().showPaymentConfirmationView(paymentInfo: extraInfo, rideId: self.rideId) { (result) in
                            if result == Strings.dismissed {
                                TaxiPoolRestClient.unJoinInCaseOfUPICancel(taxiRideId: self.matchedShareTaxiId, passengerRideId: self.rideId, cancelPassengerRide: self.isRideNeedToCancel) { (responseObject, error) in
                                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                                        return
                                    }
                                }
                            }else{
                                if let taxiShareRide = self.taxiShareRide {
                                    joinHandlerTaxiPool(taxiShareRide,nil)
                                }
                            }
                        }
                    }
                }else{
                    if let taxiShareRide = taxiShareRideresponse?.taxiShareRide {
                        joinHandlerTaxiPool(taxiShareRide,nil)
                    }
                }
            }  else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                joinHandlerTaxiPool(nil,nil)
                let error = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                if error != nil {
                    joinHandlerTaxiPool(nil,nil)
                    RideManagementUtils.handleRiderInviteFailedException(errorResponse: error!, viewController: self.viewController!, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                        self.joinTaxiPool(joinHandlerTaxiPool: joinHandlerTaxiPool)
                    })
                } else {
                    joinHandlerTaxiPool(nil,nil)
                    ErrorProcessUtils.handleResponseError(responseError: error, error: nil, viewController: self.viewController!)
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        })
    }
}
