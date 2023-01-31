//
//  TaxiTnCData.swift
//  Quickride
//
//  Created by Ashutos on 07/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiTnCData: Mappable {
    var id: Int?
    var taxiType: String?
    var tncType: String? // Inclusion, Exclusion, Facility, Extra
    var imageUri: String?
    var desc: String?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.taxiType <- map["taxiType"]
        self.tncType <- map["tncType"]
        self.imageUri <- map["imageUri"]
        self.desc <- map["description"]
    }
    
    var description: String {
        return "id: \(String(describing: self.id)),"
            + "taxiType: \(String(describing: self.taxiType)),"
            + "tncType: \(String(describing: self.tncType)),"
            + "imageUri: \(String(describing: self.imageUri)),"
            + "description: \(String(describing: self.desc))"
    }
}
