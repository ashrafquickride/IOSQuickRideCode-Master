//
//  PayTaxiPendingBillViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 29/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PayTaxiPendingBillViewModel{
    
    var taxiRidePassengerDetails: TaxiRidePassengerDetails?
    var taxiPendingBill: TaxiPendingBill?
    var handler: taxiPendingBillClearComplitionHandler?
    var taxiRideId = 0.0
    var apiCalledTimes = 0
    var taxiRideInvoice: TaxiRideInvoice?
    var estimateFareData = [fareDetailsOutStatioonTaxi]()
    var paymentMode: String?
    var taxiGroupId: Double?
    static let  FARE_TYPE_TRIP_FINAL_SETTLEMENT = "TripFinalSettlement"
    var isRequiredToInitiatePayment = true
    
    init(taxiRideId: Double,taxiPendingBill: TaxiPendingBill?,taxiRideInvoice: TaxiRideInvoice?,paymentMode: String?,taxiGroupId: Double?,isRequiredToInitiatePayment: Bool? ,handler: @escaping taxiPendingBillClearComplitionHandler) {
        self.taxiPendingBill = taxiPendingBill
        self.handler = handler
        self.taxiRideId = taxiRideId
        self.taxiRideInvoice = taxiRideInvoice
        self.paymentMode = paymentMode
        self.taxiGroupId = taxiGroupId
        if let isRequiredToInitiatePayment = isRequiredToInitiatePayment {
            self.isRequiredToInitiatePayment = isRequiredToInitiatePayment
        }
    }
    
    init() {}
    
    func payTaxiBill(hanler: @escaping TaxiPoolRestClient.responseJSONCompletionHandler){
        let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        TaxiPoolRestClient.clearTaxPendingiBill(taxiRidePassengerId: taxiRideId,userId: UserDataCache.getInstance()?.userId ?? "",paymentType: linkedWallet?.type ?? "", completionHandler: hanler)
    }
    
    func getPendingBillToVerify(actionComplitionHandler: actionComplitionHandler?){
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            TaxiPoolRestClient.getTaxiPendingBill(id: self.taxiRideId) { (responseObject, error) in
                if let actionComplitionHandler = actionComplitionHandler {
                    actionComplitionHandler(true)
                }
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    if let taxiPendingBill = Mapper<TaxiPendingBill>().map(JSONObject: responseObject!["resultData"]){
                        self.apiCalledTimes += 1
                        self.checkPendingBillClearedOrNot(taxiPendingBill: taxiPendingBill)
                    }
                }else{
                    NotificationCenter.default.post(name: .taxiPeningPaymentFailed, object: nil)
                }
            }
        })
    }
    func gettaxiRidePassengerDetails(handler : @escaping (_ responseError: ResponseError?, _ error: NSError?) -> Void) {
        TaxiRideDetailsCache.getInstance().getTaxiRideDetailsFromCache(rideId: self.taxiRideId ) { (restResponse) in
            if restResponse.result != nil {
                self.taxiRidePassengerDetails = restResponse.result
                self.paymentMode = self.taxiRidePassengerDetails?.taxiRidePassenger?.paymentMode
                handler(nil,nil)
            }else {
                handler(restResponse.responseError,restResponse.error)
            }
        }
    }
    func checkPendingBillClearedOrNot(taxiPendingBill: TaxiPendingBill){
        if taxiPendingBill.amountPending != 0 && apiCalledTimes < 20{
            getPendingBillToVerify(actionComplitionHandler: nil)
        }else if taxiPendingBill.amountPending != 0 && apiCalledTimes == 20{
            apiCalledTimes = 0
            NotificationCenter.default.post(name: .taxiPeningPaymentFailed, object: nil)
        }else if taxiPendingBill.amountPending == 0{
            NotificationCenter.default.post(name: .taxiBillClearedUpadteUI, object: nil)
        }
    }
    func getTaxiRideInvoice(handler: @escaping(_ response: RestResponse<TaxiRideInvoice>) -> Void ) {
        TaxiPoolRestClient.getTaxiPoolInvoice(refId: taxiRideId) { (responseObject, error) in
            let response = RestResponse<TaxiRideInvoice>(responseObject: responseObject, error: error)
            handler(response)
            if let invoice = response.result{
                self.taxiRideInvoice = invoice
            }
        }
    }
    
    func getFareBrakeUpData() {
        estimateFareData.removeAll()
        guard var estimateData = taxiRideInvoice else { return }
        
        if estimateData.distanceBasedFare != 0 {
            let key = ReviewScreenViewModel.DISTANCE_BASED_FARE
            let distanceBasedFare = fareDetailsOutStatioonTaxi(key: key, value: "₹\(estimateData.distanceBasedFare?.roundToPlaces(places: 2) ?? 0.0)")
            estimateFareData.append(distanceBasedFare)
        }
        
        if estimateData.driverAllowance != 0 {
            let driverAllowance = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.DRIVER_ALLOWANCE, value: "₹\(estimateData.driverAllowance?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(driverAllowance)
        }
        
        if estimateData.extraTravelledKm != 0{
            let key = ReviewScreenViewModel.EXTRA_KM_FARE + " - ₹\(estimateData.extraKmFare?.roundToPlaces(places: 1) ?? 0.0)"
            let extraKmFare = fareDetailsOutStatioonTaxi(key: key, value: "₹\(estimateData.extraTravelledFare?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(extraKmFare)
        }
        
        var value = (estimateData.distanceBasedFare ?? 0) + (estimateData.driverAllowance ?? 0) + (estimateData.extraTravelledFare ?? 0)
        let ridefare = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.RIDE_FARE, value: "₹\(value.roundToPlaces(places: 1) )")
        estimateFareData.append(ridefare)
        
        if estimateData.tax != 0 {
            let serviceTax = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.SERVICE_CHARGES, value: "₹\(estimateData.tax?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(serviceTax)
        }
        var platformFeeWithTax = estimateData.platformFee + estimateData.platformFeeTax
        if platformFeeWithTax > 0 {
            let key = "₹\(platformFeeWithTax.roundToPlaces(places: 1))"
            let platformFeeWithTaxes = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.PLATFORM_FEE_WITH_TAX, value: key)
            estimateFareData.append(platformFeeWithTaxes)
        }
        
        if estimateData.tollCharges != 0 {
            let parkingCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.TOLL_CHARGES, value: "₹\(estimateData.tollCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(parkingCharges)
        }
        
        if estimateData.nightCharges != 0 {
            let nightCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.NIGHT_CHARGES, value: "₹\(estimateData.nightCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(nightCharges)
        }
        
        if estimateData.stateTaxCharges != 0 {
            let stateTaxCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.STATE_TAX_CHARGES, value: "₹\(estimateData.stateTaxCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(stateTaxCharges)
        }
        if estimateData.interStateTaxCharges != 0 {
            let interStateTaxCharges = fareDetailsOutStatioonTaxi(key: ReviewScreenViewModel.INTERCITY_CHARGES, value: "₹\(estimateData.interStateTaxCharges?.roundToPlaces(places: 1) ?? 0.0)")
            estimateFareData.append(interStateTaxCharges)
        }
        if estimateData.amount != 0 {
            let totalVendorFare = fareDetailsOutStatioonTaxi(key: "Total Fare", value: "₹\(Int(estimateData.amount ?? 0.0))")
            estimateFareData.append(totalVendorFare)
        }
        if estimateData.amount != 0 {
            let totalVendorFare = fareDetailsOutStatioonTaxi(key:ReviewScreenViewModel.ADVANCE_AMOUNT, value: "₹\(Int(estimateData.advanceAmount ?? 0.0))")
            estimateFareData.append(totalVendorFare)
        }
    }
    func initiateUPIPayment(paymentInfo: [String: Any]){
        var totalAmount: String?
        if let totalAmountToPay = paymentInfo[ResponseError.TOTAL_PENDING] as? Double, totalAmountToPay != 0 {
            totalAmount = String(totalAmountToPay)
        }
        var orderId: String?
        if paymentInfo.keys.contains("OrderId"){
            orderId = paymentInfo["OrderId"] as? String
        }
        if let amount = totalAmount,let id = orderId,let walletType = UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type, taxiRidePassengerDetails?.taxiRidePassenger?.paymentMode != TaxiRidePassenger.PAYMENT_MODE_CASH {
            QuickRideProgressSpinner.startSpinner()
            AccountRestClient.initiateUPIPayment(userId: QRSessionManager.getInstance()?.getUserId(), orderId: id, amount: amount, paymentType: walletType) { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as? String == "SUCCESS" {
                    var userInfo = [String : String]()
                    userInfo["orderId"] = id
                    userInfo["amount"] = amount
                    NotificationCenter.default.post(name: .initiateUPIPayment, object: self, userInfo: userInfo)
                } else {
                    NotificationCenter.default.post(name: .taxiPeningPaymentFailed, object: nil)
                }
                
            }
        }
    }
    func confirmCashPaidByPassenger(complition: @escaping(_ result: Bool)->()){
        TaxiPoolRestClient.confirmCashPaid(taxiGroupId: taxiGroupId, amount: taxiPendingBill?.amountPending, fareType: PayTaxiPendingBillViewModel.FARE_TYPE_TRIP_FINAL_SETTLEMENT, description: "Cash Paid") { responseObject, error in
            let result = RestResponseParser<TaxiUserAdditionalPaymentDetails>().parse(responseObject: responseObject, error: error)
            if result.1 != nil ||  result.2 != nil {
                var userInfo = [String : Any]()
                userInfo["responseError"] = result.1
                userInfo["error"] = result.2
                NotificationCenter.default.post(name: .handleApiFailureError, object: self, userInfo: userInfo)
            } else{
                complition(true)
            }
        }
    }
    func chandePaymentMode(paymentType: String){
        TaxiPoolRestClient.changePaymentMethod(taxiRideId: StringUtils.getStringFromDouble(decimalNumber: taxiRideId), userId: StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getCurrentUserId()), paymentType: paymentType, paymentMode: paymentMode ?? TaxiRidePassenger.PAYMENT_MODE_ONLINE) {(responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let taxiRidePassenger = Mapper<TaxiRidePassenger>().map(JSONObject: responseObject!["resultData"])
                self.taxiRidePassengerDetails?.taxiRidePassenger = taxiRidePassenger
                if let taxiRidePassengerDetail = self.taxiRidePassengerDetails {
                    TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: self.taxiRideId , taxiRidePassengerDetails: taxiRidePassengerDetail)
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        }
    }
    func getTaxiUserAdditionalPaymentDetailsOfCustomerBasedOnFareType(type: Int?, handler : @escaping (_ isCashHandleInitiated: Bool, _ responseError: ResponseError?, _ error: NSError?) -> Void){
        TaxiPoolRestClient.getTaxiUserAdditionalPaymentDetailsOfCustomerBasedOnFareType(taxiGroupId: taxiGroupId, fareType: PayTaxiPendingBillViewModel.FARE_TYPE_TRIP_FINAL_SETTLEMENT) { responseObject, error in
            let result = RestResponseParser<TaxiUserAdditionalPaymentDetails>().parseArray(responseObject: responseObject, error: error)
            if let taxiUserAdditionalPaymentDetails = result.0, !taxiUserAdditionalPaymentDetails.isEmpty  {
                if taxiUserAdditionalPaymentDetails[0].status == TaxiUserAdditionalPaymentDetails.STATUS_OPEN {
                    handler(true,nil,nil)
                    return
                }
            }
            handler(false,result.1,result.2)
        }
    }
}
struct TaxiPendingBillException: Mappable {
    
    var totalAmount = 0.0
    var taxiDemandManagementException: TaxiDemandManagementException?
    var rideId = 0.0
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        self.totalAmount <- map["totalAmount"]
        self.taxiDemandManagementException <- map["taxiDemandManagementException"]
        self.rideId <- map["rideId"]
    }
}
