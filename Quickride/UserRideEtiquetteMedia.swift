//
//  UserRideEtiquetteMedia.swift
//  Quickride
//
//  Created by Quick Ride on 3/30/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserRideEtiquetteMedia : Mappable, Codable {
    
    
    static let MEDIA_TYPE_VIDEO = "VIDEO"
    static let MEDIA_TYPE_IMAGE = "IMAGE"
    
    var id : Int = 0
    var rideType: String?
    var smallMediaUrl: String?
    var bigMediaUrl: String?
    var mediaType: String?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        self.id <- map["id"]
        self.rideType <- map["rideType"]
        self.smallMediaUrl <- map["smallMediaUrl"]
        self.bigMediaUrl <- map["bigMediaUrl"]
        self.mediaType <- map["mediaType"]
    }
}
