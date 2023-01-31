//
//  PotentialRiderDetails.swift
//  Quickride
//
//  Created by Ashutos on 8/5/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PotentialRiderDetails: NSObject, Mappable  {
    var userId: Double?
    var name: String?
    var imageURI: String?
    var gender: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        userId <- map["userId"]
        name <- map["name"]
        imageURI <- map["imageURI"]
        gender <- map["gender"]
    }
    
    public override var description: String {
        return "userId: \(String(describing: self.userId)),"
            + " name: \(String(describing: self.name)),"
            + "imageURI: \(String(describing: self.imageURI)),"
            + "gender: \(String(describing: self.gender))"
    }
}
