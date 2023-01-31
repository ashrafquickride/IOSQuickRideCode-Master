//
//  AddPaymentConfirmationViewModel.swift
//  Quickride
//
//  Created by Rajesab on 12/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class AddPaymentConfirmationViewModel{
    
    var driverAddedPaymentNotification: DriverAddedPaymentNotification?
    var requiredTaxiTrip: TaxiRidePassenger?
    
    init(driverAddedPaymentNotification: DriverAddedPaymentNotification){
        self.driverAddedPaymentNotification = driverAddedPaymentNotification
    }
    init() {}
    func getActiveTaxiRides(){
         requiredTaxiTrip = MyActiveTaxiRideCache.getInstance().getTaxiRidePassenger(taxiRideId: Double(driverAddedPaymentNotification?.taxiRidePassengerId ?? "") ?? 0.0)
    }
    func updateAddedChargesStatus(status: String, complitionHandler: @escaping TaxiPoolRestClient.responseJSONCompletionHandler){
        TaxiPoolRestClient.updateAddedPaymentStatus(id: driverAddedPaymentNotification?.id ?? "", customerId: UserDataCache.getInstance()?.userId ?? "", status: status,completionHandler: complitionHandler)
    }
}

