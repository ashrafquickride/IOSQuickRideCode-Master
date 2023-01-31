//
//  ChangeDriverRequestViewModel.swift
//  Quickride
//
//  Created by Rajesab on 13/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ChangeDriverRequestViewModel {
    
    var taxiRidePassenger: TaxiRidePassenger?
    var complitionHandler: complitionHandler?
    
    init() {}
    init(taxiRidePassenger: TaxiRidePassenger?, complitionHandler: @escaping complitionHandler ){
        self.taxiRidePassenger = taxiRidePassenger
        self.complitionHandler = complitionHandler
    }
    
    func cancelRequestedChangeDriver(driverChangeReason: String, taxiGroupId: Double, taxiRidePassengerId: Double, customerId: Double, status: String, complition: @escaping complitionHandler){
        TaxiPoolRestClient.changeTaxiDriver(driverChangeReason: driverChangeReason, taxiGroupId: taxiGroupId, taxiRidePassengerId: taxiRidePassengerId, customerId: customerId, status: status){  (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let taxiRidePassengerDetails = Mapper<TaxiRidePassengerDetails>().map(JSONObject: responseObject!["resultData"])
                if let taxiRidePassengerDetail = taxiRidePassengerDetails {
                complition(taxiRidePassengerDetails)
                TaxiRideDetailsCache.getInstance().updateTaxiRideDetails(rideId: self.taxiRidePassenger?.id ?? 0, taxiRidePassengerDetails: taxiRidePassengerDetail)
                }
            }else {
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
}
