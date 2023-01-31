//
//  TaxiPoolCreateOrJoinHandler.swift
//  Quickride
//
//  Created by Ashutos on 8/5/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias taxiPoolCreteorJoinCompletionHandler = (_ responcse: TaxiShareRide?,_ error : NSError?) -> Void

class TaxiPoolCreateORJoinHandler {
    var rideId: Double
    var shareType: String
    var taxiRideId: Double?
    var viewController  : UIViewController
    
    init(rideId: Double, shareType: String,taxiRideId: Double?,viewController : UIViewController){
        self.rideId = rideId
        self.shareType = shareType
        self.taxiRideId = taxiRideId
        self.viewController = viewController
    }
    
    func creteORJoinTaxiPool(createORJoinHandler : @escaping taxiPoolCreteorJoinCompletionHandler) {
        TaxiPoolRestClient.createOrJoinTaxiRide(passengerRideId: rideId, taxiRideId: taxiRideId, shareType: shareType) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let taxiShareRide = Mapper<TaxiShareRide>().map(JSONObject: responseObject!["resultData"])
                createORJoinHandler(taxiShareRide,nil)
            }  else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                createORJoinHandler(nil,nil)
                let error = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                if error?.errorCode == RideValidationUtils.PAY_TO_REQUEST_RIDE_ERROR, let extraInfo = error?.extraInfo, !extraInfo.isEmpty{
                    AccountUtils().showPaymentConfirmationView(paymentInfo: extraInfo, rideId: self.rideId) { (result) in
                        if result == Strings.success {
                            self.creteORJoinTaxiPool(createORJoinHandler: createORJoinHandler)
                        }
                    }
                } else if error != nil {
                    createORJoinHandler(nil,nil)
                    RideManagementUtils.handleRiderInviteFailedException(errorResponse: error!, viewController: self.viewController, addMoneyOrWalletLinkedComlitionHanler: nil)
                } else {
                    createORJoinHandler(nil,nil)
                    ErrorProcessUtils.handleResponseError(responseError: error, error: nil, viewController: self.viewController)
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        }
    }
}
