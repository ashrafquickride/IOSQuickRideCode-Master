//
//  .swift
//  Quickride
//
//  Created by QR Mac 1 on 27/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct ProductLocation: Mappable{
    
    var address: String?
    var areaName: String?
    var cellId = 0
    var city: String?
    var country: String?
    var id: String?
    var lat = 0.0
    var lng = 0.0
    var state: String?
    var streetName: String?
    var listingId: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.address <- map["address"]
        self.areaName <- map["areaName"]
        self.cellId <- map["cellId"]
        self.city <- map["city"]
        self.country <- map["country"]
        self.id <- map["id"]
        self.lat <- map["lat"]
        self.lng <- map["lng"]
        self.state <- map["state"]
        self.streetName <- map["streetName"]
        self.listingId <- map["listingId"]
    }
    
    init(location: Location){
        self.address = location.completeAddress
        self.areaName = location.areaName
        self.city = location.city
        self.country = location.country
        self.id = String(location.id)
        self.lat = location.latitude
        self.lng = location.longitude
        self.state = location.state
        self.streetName = location.streetName
    }
}
