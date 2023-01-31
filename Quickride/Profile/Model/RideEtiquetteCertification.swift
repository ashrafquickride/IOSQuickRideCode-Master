//
//  RideEtiquetteCertification.swift
//  Quickride
//
//  Created by Vinutha on 05/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideEtiquetteCertification: Mappable {
    
    var userId: Double?
    var level: String?
    var status: String?
    var createdDate: Double?
    var modifiedDate: Double?
    
    
    static let LEVEL = "level"
    static let STATUS = "status"
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        userId <- map["userId"]
        level <- map["level"]
        status <- map["status"]
        createdDate <- map["createdDate"]
        modifiedDate <- map["modifiedDate"]
    }
    
    
}
