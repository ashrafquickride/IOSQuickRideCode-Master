//
//  UserPreferredPickupDrop.swift
//  Quickride
//
//  Created by Vinutha on 13/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserPreferredPickupDrop: NSObject, Mappable{
    var id = 0.0
    var userId: Double?
    var latitude: Double?
    var longitude: Double?
    var type: String?
    var note: String?
    var createdDate: Double?
    
    static var FLD_UER_PREFERRED_PICKUP_DROP = "userPreferredPickupDrop"
    
    override init() { }
    
    init(userId: Double?, latitude: Double?, longitude: Double?, type: String?,note: String?) {
        self.userId  = userId
        self.latitude = latitude
        self.longitude = longitude
        self.type = type
        self.note = note
    }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        note <- map["note"]
        type <- map["type"]
        createdDate <- map["createdDate"]
    }
}
