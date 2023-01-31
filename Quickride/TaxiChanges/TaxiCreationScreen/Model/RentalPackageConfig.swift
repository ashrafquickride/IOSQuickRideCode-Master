//
//  RentalPackageConfig.swift
//  Quickride
//
//  Created by Rajesab on 22/02/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RentalPackageConfig: NSObject, Mappable {
    var id: Int?
    var vehicleClass: String?
    var b2bPartnerCode: String?
    var modifiedDateMs: Int?
    var taxiType: String?
    var pkgFare: Int?
    var pkgDistanceInKm: Int?
    var extraKmFare: Double?
    var pkgDurationInMins: Int?
    var extraMinuteFare: Double?
    var cityId: String?
    var creationDateMs: Int?
    
    init(vehicleClass: String?, extraKmFare: Double?,extraMinuteFare: Double?,pkgDistanceInKm: Int?,pkgDurationInMins: Int?){
        self.vehicleClass = vehicleClass
        self.extraKmFare = extraKmFare
        self.extraMinuteFare = extraMinuteFare
        self.pkgDistanceInKm = pkgDistanceInKm
        self.pkgDurationInMins = pkgDurationInMins
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        vehicleClass <- map["vehicleClass"]
        b2bPartnerCode <- map["b2bPartnerCode"]
        modifiedDateMs <- map["modifiedDateMs"]
        taxiType <- map["taxiType"]
        pkgFare <- map["pkgFare"]
        pkgDistanceInKm <- map["pkgDistanceInKm"]
        extraKmFare <- map["extraKmFare"]
        pkgDurationInMins <- map["pkgDurationInMins"]
        extraMinuteFare <- map["extraMinuteFare"]
        cityId <- map["cityId"]
        creationDateMs <- map["creationDateMs"]
    }
}
