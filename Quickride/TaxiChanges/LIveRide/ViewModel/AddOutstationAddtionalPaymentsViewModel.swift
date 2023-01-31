//
//  AddOutstationAddtionalPaymentsViewModel.swift
//  Quickride
//
//  Created by HK on 13/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AddOutstationAddtionalPaymentsViewModel {
    
    var addedPaymentsList = [TaxiUserAdditionalPaymentDetails]()
    var selectedFareType = "Paid by cash"
    var taxiRidePassengerDetails: TaxiRidePassengerDetails?
    
    func addAdditionalPayment(amount: String,paymentType: String,fareType: String,description: String){
        TaxiPoolRestClient.addAdditionalPaymentOntheWay(taxiGroupId: taxiRidePassengerDetails?.taxiRideGroup?.id ?? 0, customerId: UserDataCache.getInstance()?.userId ?? "", amount: amount, paymentType: paymentType, fareType: fareType, description: description) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                if let addedPayment = Mapper<TaxiUserAdditionalPaymentDetails>().map(JSONObject: responseObject!["resultData"]){
                    self.addedPaymentsList.append(addedPayment)
                    NotificationCenter.default.post(name: .refreshOutStationFareSummary, object: nil)
                    NotificationCenter.default.post(name: .passengerCashAdded, object: nil)
                }
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: self, userInfo: userInfo)
            }
        }
    }
    
    func getAddedPaymentsForThisTrip(){
        TaxiPoolRestClient.getAdditionalPaymentDetails(taxiGroupId: taxiRidePassengerDetails?.taxiRideGroup?.id ?? 0) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.addedPaymentsList = Mapper<TaxiUserAdditionalPaymentDetails>().mapArray(JSONObject: responseObject!["resultData"]) ?? [TaxiUserAdditionalPaymentDetails]()
                NotificationCenter.default.post(name: .recievedAddedCashPayments, object: nil)
            }
        }
    }
}
