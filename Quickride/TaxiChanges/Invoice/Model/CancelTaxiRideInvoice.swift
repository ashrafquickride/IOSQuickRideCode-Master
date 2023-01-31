//
//  CancelTaxiRideInvoice.swift
//  Quickride
//
//  Created by HK on 23/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class CancelTaxiRideInvoice: Mappable {
    
    var id: String?
    var taxiGroupId = 0
    var taxiPassengerId = 0
    var userId = 0
    var cancelledBy: String?
    var taxiPartnerCode: String?
    var taxiBookingId: String?
    var cancelReason: String?
    var penalizedReason: String?
    var penalizedTo: String?
    var penaltyAmount = 0.0
    var creationTimeMs = 0
    var modifiedTimeMs = 0
    var penaltyCredited = false
    var penaltyAmountCredited = 0.0
    var driverName: String?
    var driverImgUri: String?
    var driverContactNo: String?
    var vehicleNo: String?
    var vehicleModel: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        self.id <- map["id"]
        self.taxiGroupId <- map["taxiGroupId"]
        self.taxiPassengerId <- map["taxiPassengerId"]
        self.userId <- map["userId"]
        self.cancelledBy <- map["cancelledBy"]
        self.taxiPartnerCode <- map["taxiPartnerCode"]
        self.taxiBookingId <- map["taxiBookingId"]
        self.cancelReason <- map["cancelReason"]
        self.penalizedReason <- map["penalizedReason"]
        self.penalizedTo <- map["penalizedTo"]
        self.penaltyAmount <- map["penaltyAmount"]
        self.creationTimeMs <- map["creationTimeMs"]
        self.modifiedTimeMs <- map["modifiedTimeMs"]
        self.penaltyCredited <- map["penaltyCredited"]
        self.penaltyAmountCredited <- map["penaltyAmountCredited"]
        self.driverName <- map["driverName"]
        self.driverImgUri <- map["driverImgUri"]
        self.driverContactNo <- map["driverContactNo"]
        self.vehicleNo <- map["vehicleNo"]
        self.vehicleModel <- map["vehicleModel"]
    }
}
