//
//  UserAttributePopularity.swift
//  Quickride
//
//  Created by Vinutha on 30/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserAttributePopularity: Mappable {
    
    var attributeName = ""
    var type: String?
    var attributePopularityCounter: Int?
    var createdDate: Double?
    var lastModifiedDate: Double?
    var systemDefault: Double?
    
    static let ATTRIBUTE_NAME = "attributeName"
    static let TYPE = "type"
    static let ATTRIBUTE_POPULARITY_COUNTER = "attributePopularityCounter"
    static let TYPE_INTEREST = "INTEREST"
    static let TYPE_SKILL = "SKILL"

    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        attributeName <- map["attributeName"]
        type <- map["type "]
        attributePopularityCounter <- map["attributePopularityCounter"]
        createdDate <- map["createdDate"]
        lastModifiedDate <- map["lastModifiedDate"]
        systemDefault <- map["systemDefault"]
    }
    
    
}
