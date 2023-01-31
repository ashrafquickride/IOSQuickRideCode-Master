//
//  CurrentCity.swift
//  Quickride
//
//  Created by Halesh on 13/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct CurrentCity: Mappable {
    
    var city: String?
    var creationTime: String?
    var id: String?
    var latitude = 0.0
    var longitude = 0.0
    var modificationTime: String?
    var radius = 0.0
    
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let city = "city"
    
    init?(map: Map) {
        
    }
    init() {
    }
    
    mutating func mapping(map: Map) {
        self.city <- map["city"]
        self.creationTime <- map["creationTime"]
        self.id <- map["id"]
        self.latitude <- map["latitude"]
        self.longitude <- map["longitude"]
        self.modificationTime <- map["modificationTime"]
        self.radius <- map["radius"]
    }
    
    public var description: String {
        return "city: \(String(describing: self.city))," + "creationTime: \(String(describing: self.creationTime))," + "id: \(String(describing: id))," + "latitude: \(String(describing: latitude))," + "longitude: \(String(describing: longitude))," + "modificationTime: \(String(describing: modificationTime))," + "radius: \(String(describing: radius)),"
    }
}
