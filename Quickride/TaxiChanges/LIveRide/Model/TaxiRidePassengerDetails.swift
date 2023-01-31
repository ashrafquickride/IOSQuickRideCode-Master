//
//  TaxiRidePassengerDetails.swift
//  Quickride
//
//  Created by Ashutos on 23/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiRidePassengerDetails: Mappable {
    var taxiRidePassenger: TaxiRidePassenger?
    var taxiRideGroup: TaxiRideGroup?
    var otherPassengersInfo: [TaxiRidePassengerBasicInfo]?
    var exception: TaxiDemandManagementException?
    var taxiRideDriverChangeInfo: TaxiTripChangeDriverInfo?
    var taxiRideCommutePassengerDetails: TaxiRideCommutePassengerDetails?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.taxiRidePassenger <- map["taxiRidePassenger"]
        self.taxiRideGroup <- map["taxiRideGroup"]
        self.otherPassengersInfo <- map["otherPassengersInfo"]
        self.exception <- map["exception"]
        self.taxiRideDriverChangeInfo <- map["taxiRideDriverChangeInfo"]
        self.taxiRideCommutePassengerDetails <- map["taxiRideOtherCommuterDetails"]
    }
    var description: String {
        return "taxiRidePassenger: \(String(describing: self.taxiRidePassenger)),"
        + "taxiRideGroup: \(String(describing: self.taxiRideGroup)),"
        + "otherPassengersInfo: \(String(describing: self.otherPassengersInfo)),"
        + "exception: \(String(describing: self.exception)),"
        + "taxiRideDriverChangeInfo: \(String(describing: self.taxiRideDriverChangeInfo)),"
        + "taxiRideCommutePassengerDetails: \(String(describing: self.taxiRideCommutePassengerDetails)),"
    }
    
    func isTaxiAllotted() -> Bool{
        
        
        guard let  taxiRideGroup = taxiRideGroup,let taxiRidePassenger = taxiRidePassenger else {
            return false
        }
        return TaxiRideGroup.STATUS_ALLOTTED == taxiRideGroup.status ||
            TaxiRideGroup.STATUS_RE_ALLOTTED == taxiRideGroup.status ||
            TaxiRideGroup.STATUS_DELAYED == taxiRideGroup.status ||
            TaxiRideGroup.STATUS_STARTED == taxiRideGroup.status ||
            TaxiRidePassenger.STATUS_DRIVER_EN_ROUTE_PICKUP == taxiRidePassenger.status
    }

    func isTaxiPending() -> Bool{
        guard let  taxiRideGroup = taxiRideGroup else {
            return true
        }
        return TaxiRideGroup.STATUS_OPEN == taxiRideGroup.status ||
            TaxiRideGroup.STATUS_FROZEN == taxiRideGroup.status ||
            TaxiRideGroup.STATUS_CONFIRMED == taxiRideGroup.status
    }

    func isTaxiStarted() -> Bool{
        guard let taxiRidePassenger = taxiRidePassenger else {
            return false
        }
        return TaxiRidePassenger.STATUS_STARTED == taxiRidePassenger.status
    }
    
    func isTaxiReached() -> Bool{
       
        guard let taxiRidePassenger = taxiRidePassenger else {
            return false;
        }
        return TaxiRidePassenger.STATUS_DRIVER_REACHED_PICKUP == taxiRidePassenger.status
    }
    
    func isPaymentPending() -> Bool {
        guard let error = exception?.error else {
            return false
        }
        return error.errorCode == TaxiDemandManagementException.PAYMENT_REQUIRED_BEFORE_JOIN_TAXI
    }
    
    func isTaxiConfirmed() -> Bool{
        guard let taxiRideGroup = taxiRideGroup else {
            return false
        }
        return TaxiRideGroup.STATUS_CONFIRMED == taxiRideGroup.status ||
            TaxiRideGroup.STATUS_FROZEN == taxiRideGroup.status
    }
    func isDriverStartedToPickup() -> Bool{
        guard let taxiRidePassenger = taxiRidePassenger else {
            return false
        }
        return TaxiRidePassenger.STATUS_DRIVER_EN_ROUTE_PICKUP == taxiRidePassenger.status
    }
}
