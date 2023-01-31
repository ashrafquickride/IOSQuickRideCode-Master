//
//  RideEtiquetteVideoItem.swift
//  Quickride
//
//  Created by QR Mac 1 on 30/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct RideEtiquetteVideoItem: Mappable {
   
    var rideType: String?
    var imageUrl: String?
    var videoUrl:String?
    
    init?(map: Map){
        
    }
    
    init(rideType: String?,imageUrl: String,videoUrl: String?) {
        self.rideType = rideType
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
    }
    
    mutating func mapping(map: Map) {
        self.rideType <- map["rideType"]
        self.imageUrl <- map["imageUrl"]
        self.videoUrl <- map["videoUrl"]
    }
}
