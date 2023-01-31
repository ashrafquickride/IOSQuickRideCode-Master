//
//  ProductComment.swift
//  Quickride
//
//  Created by QR Mac 1 on 20/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct ProductComment: Mappable{
    
    var comment: String?
    var creationDateInMs = 0.0
    var id: String?
    var listingId: String?
    var modificationDateInMs = 0.0
    var parentId: String?
    var userBasicInfo: UserBasicInfo?
    var userId: String?

    static let commentId = "commentId"
    static let comment = "comment"
    static let parentId = "parentId"
    static let type = "type"
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.comment <- map["comment"]
        self.creationDateInMs <- map["creationDate"]
        self.id <- map["id"]
        self.listingId <- map["listingId"]
        self.modificationDateInMs <- map["modificationDate"]
        self.parentId <- map["parentId"]
        self.userBasicInfo <- map["userBasicInfo"]
        self.userId <- map["userId"]
    }
}
