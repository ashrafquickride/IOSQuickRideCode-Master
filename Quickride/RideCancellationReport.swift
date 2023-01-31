//
//  RideCancellationReport.swift
//  Quickride
//
//  Created by QR Mac 1 on 25/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct RideCancellationReport: Mappable {
    
    var rideId: Int?
    var passengerRideId: Int?
    var cancelledUserId: Int? // who canceled
    var cancelledFromUserId: Int? // whom you cancel user id
    var cancelledRideType: String?
    var cancelledTime: NSDate?
    var compensationCanBeApplied = false
    var compensationPaid = false
    var fairCancellationReasonScore: Int?
    var compensationPaidUserId: Int? // who paid
    var waveOff: String? 
    var blamedOn: String?
    var cancelReason: String?
    var compensationAppliedReason: String?
    
    static let FLD_WAVEOFF = "waveOff";
    static let WAVEOFF_BY_SYSTEM = "system";
    static let WAVEOFF_BY_FREE_CANCELLATIONS = "freeCancel";
    static let CANCEL_AMOUNT = "CANCEL_AMOUNT"
    static let BLAME_ON_SELF = "self";
    static let BLAME_ON_OTHER = "other";
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map:Map){
        rideId <- map["rideId"]
        passengerRideId <- map["passengerRideId"]
        cancelledUserId <- map["cancelledUserId"]
        cancelledFromUserId <- map["cancelledFromUserId"]
        cancelledRideType <- map["cancelledRideType"]
        cancelledTime <- map["cancelledTime"]
        compensationCanBeApplied <- map["compensationCanBeApplied"]
        compensationPaid <- map["compensationPaid"]
        fairCancellationReasonScore <- map["fairCancellationReasonScore"]
        compensationPaidUserId <- map["compensationPaidUserId"]
        waveOff <- map["waveOff"]
        blamedOn <- map["blamedOn"]
        cancelReason <- map["cancelReason"]
        compensationAppliedReason <- map["compensationAppliedReason"]
    }
}
