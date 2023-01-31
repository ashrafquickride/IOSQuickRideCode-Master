//
//  CreateTaxiPoolHandler.swift
//  Quickride
//
//  Created by Ashutos on 23/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias taxiPoolCreateCompletionHandler = (_ responcse: TaxiRidePassengerDetails?,_ error : NSError?) -> Void

class CreateTaxiPoolHandler {
    private var startLocation : Location?
    private var endLocation: Location?
    private var tripType: String?
    private var routeId: Double?
    private var startTime: Double?
    private var endTime: Double?
    private var journeyType: String?
    private var selectedVehicleDetails : FareForVehicleClass?
    private var advancePercentageForOutstation: Int?
    private var refRequestId: Double?
    private var viewController : UIViewController
    private var couponCode: String?
    private var taxiGroupId: Double?
    private var refInviteId: String?
    private var paymentMode: String?
    private var commuteContactNo: String?
    private var commutePassengerName: String?

    init(startLocation : Location?,endLocation: Location?,tripType: String?,routeId: Double?,startTime: Double?,selectedVehicleDetails : FareForVehicleClass?, endTime: Double?, journeyType: String?,advancePercentageForOutstation: Int? , refRequestId: Double?,viewController : UIViewController,couponCode: String?,paymentMode: String?,taxiGroupId: Double?,refInviteId: String?, commuteContactNo: String?, commutePassengerName: String?){
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.tripType = tripType
        self.routeId = routeId
        self.startTime = startTime
        self.selectedVehicleDetails = selectedVehicleDetails
        self.endTime = endTime
        self.journeyType = journeyType
        self.advancePercentageForOutstation = advancePercentageForOutstation
        self.refRequestId = refRequestId
        self.viewController = viewController
        self.couponCode = couponCode
        self.taxiGroupId = taxiGroupId
        self.refInviteId = refInviteId
        self.paymentMode = paymentMode
        self.commuteContactNo = commuteContactNo
        self.commutePassengerName = commutePassengerName
    }

    func createTaxiPool(createTaxiHandler : @escaping taxiPoolCreateCompletionHandler) {
        var paymentType: String?
        if paymentMode != TaxiRidePassenger.PAYMENT_MODE_CASH {
            paymentType = UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type
        }
        TaxiPoolRestClient.bookNewTaxi(startTime: startTime ?? 0.0, expectedEndTime: endTime, startAddress: startLocation?.shortAddress ?? "", startLatitude: startLocation?.latitude ?? 0.0, startLongitude: startLocation?.longitude ?? 0.0, endLatitude: endLocation?.latitude ?? 0.0, endLongitude: endLocation?.longitude ?? 0.0, endAddress: endLocation?.shortAddress ?? "", tripType: tripType ?? "", journeyType: self.journeyType, vehicleCategory: selectedVehicleDetails?.vehicleClass ?? "", taxiType: selectedVehicleDetails?.taxiType ?? "", routeId: routeId, maxFare: selectedVehicleDetails?.selectedMaxFare, advPaymentPercent: advancePercentageForOutstation, paymentType: paymentType, fixedfareID: selectedVehicleDetails?.fixedFareId ?? "0", shareType: selectedVehicleDetails?.shareType ?? "", refRequestId: refRequestId,enablePayLater: true, couponCode: couponCode,startCity: startLocation?.city,startState: startLocation?.state,endCity: endLocation?.city,endState: endLocation?.state, paymentMode: paymentMode, taxiGroupId: taxiGroupId,refInviteId: refInviteId, commuteContactNo: commuteContactNo, commutePassengerName: commutePassengerName) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let taxiPassengerDetails = Mapper<TaxiRidePassengerDetails>().map(JSONObject: responseObject!["resultData"])
                if taxiPassengerDetails?.exception?.error?.errorCode == TaxiDemandManagementException.PAYMENT_REQUIRED_BEFORE_JOIN_TAXI, let extraInfo = taxiPassengerDetails?.exception?.error?.extraInfo, !extraInfo.isEmpty{
                    AccountUtils().showPaymentConfirmationView(paymentInfo: extraInfo, rideId: nil){ (result) in
                        if result == Strings.success {
                            TaxiUtils.sendTaxiBookedEvent(taxiRidePassenger: taxiPassengerDetails?.taxiRidePassenger,routeCategory: taxiPassengerDetails?.taxiRideGroup?.routeCategory)
                          createTaxiHandler(taxiPassengerDetails,nil)
                        }else{
                            self.cancelTaxiRide(taxiRidePassenger: taxiPassengerDetails?.taxiRidePassenger, createTaxiHandler: createTaxiHandler)
                        }
                    }
                }else{
                    TaxiUtils.sendTaxiBookedEvent(taxiRidePassenger: taxiPassengerDetails?.taxiRidePassenger,routeCategory: taxiPassengerDetails?.taxiRideGroup?.routeCategory)
                   createTaxiHandler(taxiPassengerDetails,nil)
                }
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                createTaxiHandler(nil,nil)
                let error = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                if error != nil {
                    RideManagementUtils.handleRiderInviteFailedException(errorResponse: error!, viewController: self.viewController, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                        self.createTaxiPool(createTaxiHandler: createTaxiHandler)
                    })
                } else{
                    createTaxiHandler(nil,nil)
                    ErrorProcessUtils.handleResponseError(responseError: error, error: nil, viewController: self.viewController)
                }
            }else{
                createTaxiHandler(nil,nil)
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            }
        }
    }

    private func cancelTaxiRide(taxiRidePassenger: TaxiRidePassenger?,createTaxiHandler : @escaping taxiPoolCreateCompletionHandler){
        TaxiPoolRestClient.cancelTaxiRide(taxiId: taxiRidePassenger?.id ?? 0, cancellationReason: "Payment cancelled by user") { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                TaxiUtils.sendCancelEvent(taxiRidePassenger: taxiRidePassenger, cancelReason: "Payment cancelled by user")
                UIApplication.shared.keyWindow?.makeToast(Strings.payment_failed)
                createTaxiHandler(nil,nil)
            }else{
                createTaxiHandler(nil,nil)
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            }
        }
    }
}
