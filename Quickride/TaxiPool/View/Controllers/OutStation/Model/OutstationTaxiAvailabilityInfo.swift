//
//  OutstationTaxiAvailabilityInfo.swift
//  Quickride
//
//  Created by Ashutos on 10/18/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class OutstationTaxiAvailabilityInfo: NSObject, Mappable {
    var totalDuration: Int?
    var availableTaxiList: [AvailableOutstationTaxi] = []
    var error: ResponseError?
    
    static let FLD_TAXI_SHARE_UNJOIN_REASON = "taxiUnjoinReason"
    
    required init?(map: Map) {
        
    }
    
    override init() {
        
    }
    
    func mapping(map: Map) {
        totalDuration <- map["totalDuration"]
        availableTaxiList <- map["availableTaxiList"]
        error <- map["error"]
    }
    
    public override var description: String {
        return "totalDuration: \(String(describing: self.totalDuration)),"
            + " availableTaxiList: \( String(describing: self.availableTaxiList)),"
            + " error: \(String(describing: self.error))"
    }
}
