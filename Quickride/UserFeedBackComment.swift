//
//  UserFeedBackComment.swift
//  Quickride
//
//  Created by iDisha on 03/07/19.
//  Copyright © 2019 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

class RideEtiquette : NSObject,Mappable{
   
    var id: Double?
    var guideline: String?
    var severity: Int?
    var imageUri: String?
    var role: String?
    var tolerentCount: Int?
    
    static let FLD_ROLE = "role"
    
    required public init(map:Map){
        
    }
    
    public func mapping(map:Map){
        id <- map["id"]
        guideline <- map["guideline"]
        severity <- map["severity"]
        imageUri <- map["imageUri"]
        role <- map["role"]
        tolerentCount <- map["tolerentCount"]
    }
}
