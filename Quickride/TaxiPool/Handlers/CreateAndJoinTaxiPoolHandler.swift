//
//  CreateAndJoinTaxiPoolHandler.swift
//  Quickride
//
//  Created by Ashutos on 6/13/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias taxiPoolCreteAndJoinCompletionHandler = (_ responcse: TaxiShareRide?,_ error : NSError?) -> Void

class CreateAndJoinTaxiPoolHandler {
    var rideId: Double
    var shareType: String
    var paymentType: String?
    var tripType: String?
    var journeyType: String?
    var toTime: Double?
    var carType: String?
    var viewController  : UIViewController
    var selectedPaymentPercentage: Int?
    var taxiShareRide : TaxiShareRide?
    var isRideNeedToCancel = false
    
    init(rideId: Double, shareType: String, paymentType: String?,tripType: String?,journeyType: String? ,toTime: Double?,carType: String?,selectedPaymentPercentage: Int?,isRideNeedToCancel: Bool,viewController : UIViewController){
        self.rideId = rideId
        self.shareType = shareType
        self.paymentType = paymentType
        self.tripType = tripType
        self.journeyType = journeyType
        self.toTime = toTime
        self.carType = carType
        self.selectedPaymentPercentage = selectedPaymentPercentage
        self.isRideNeedToCancel = isRideNeedToCancel
        self.viewController = viewController
    }
    
    func creteAndJoinTaxiPool(createAndJoinHandler : @escaping taxiPoolCreteAndJoinCompletionHandler) {
        let rideIdString = StringUtils.getStringFromDouble(decimalNumber: rideId)
        TaxiPoolRestClient.createNewTaxiPool(passengerRideId: rideIdString, shareType: shareType, taxiBookingType: "AUTO-BOOKING" , paymentType: paymentType, userId: QRSessionManager.getInstance()?.getUserId() ?? "",tripType: tripType,journeyType: journeyType ,toTime: toTime,carType: carType, percentageAmount: selectedPaymentPercentage, viewController: self.viewController, completionHandler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let taxiShareRideresponse = Mapper<TaxiShareRideResponse>().map(JSONObject: responseObject!["resultData"])
                if let error = taxiShareRideresponse?.quickRideException?.error {
                    createAndJoinHandler(nil,nil)
                    if error.errorCode == RideValidationUtils.PAY_TO_REQUEST_RIDE_ERROR, let extraInfo = error.extraInfo, !extraInfo.isEmpty{
                        self.taxiShareRide = taxiShareRideresponse?.taxiShareRide
                        AccountUtils().showPaymentConfirmationView(paymentInfo: extraInfo, rideId: self.rideId) { (result) in
                            if result == Strings.dismissed {
                                TaxiPoolRestClient.unJoinInCaseOfUPICancel(taxiRideId: self.taxiShareRide?.id ?? 0, passengerRideId: self.rideId, cancelPassengerRide: self.isRideNeedToCancel) { (responseObject, error) in
                                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                                        return
                                    }
                                }
                            }else{
                                if let taxiShareRide = self.taxiShareRide {
                                    createAndJoinHandler(taxiShareRide,nil)
                                }
                            }
                        }
                    }
                }else{
                    if let taxiShareRide = taxiShareRideresponse?.taxiShareRide {
                        createAndJoinHandler(taxiShareRide,nil)
                    }
                }
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                createAndJoinHandler(nil,nil)
                let error = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                if error != nil {
                    createAndJoinHandler(nil,nil)
                    RideManagementUtils.handleRiderInviteFailedException(errorResponse: error!, viewController: self.viewController, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                        self.creteAndJoinTaxiPool(createAndJoinHandler: createAndJoinHandler)
                    })
                } else {
                    createAndJoinHandler(nil,nil)
                    ErrorProcessUtils.handleResponseError(responseError: error, error: nil, viewController: nil)
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            }
        })
    }
}
