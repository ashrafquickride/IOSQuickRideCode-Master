//
//  Order.swift
//  Quickride
//
//  Created by QR Mac 1 on 04/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct Order: Mappable {
    
    var borrowerInfo: UserBasicInfo?
    var sellerInfo: UserBasicInfo?
    var paymentResponse: Any?
    var postedProduct: PostedProduct?
    var postedRequest: PostedRequest?
    var productOrder: ProductOrder?
    
    static let orderId = "orderId"
    static let userId = "userId"
    static let reason = "reason"
    static let pickupLat = "pickupLat"
    static let pickupLng = "pickupLng"
    static let pickupAddress = "pickupAddress"
    static let otp = "otp"
    static let handoverImageURL = "handoverImageURL"
    static let damageAmount = "damageAmount"
    static let returnImageURL = "returnImageURL"
    static let listingId = "listingId"
    static let rating = "rating"
    static let comment = "comment"
    static let typeList = "typeList"
    
    static let PLACED = "PLACED"
    static let ACCEPTED = "ACCEPTED"
    static let PICKUP_IN_PROGRESS = "PICKUP_IN_PROGRESS"
    static let PICKUP_COMPETE = "PICKUP_COMPETE"
    static let RETURN_PICKUP_IN_PROGRESS = "RETURN_PICKUP_IN_PROGRESS"
    static let CLOSED = "CLOSED"
    static let CANCELLED = "CANCELLED"
    static let RETURNED = "RETURNED"
    
    static let SELLER = "SELLER"
    static let BUYER = "BUYER"
    
    init?(map: Map) {
         
    }
    init() {}
    mutating func mapping(map: Map) {
        self.borrowerInfo <- map["borrowerInfo"]
        self.sellerInfo <- map["sellerInfo"]
        self.paymentResponse <- map["paymentResponse"]
        self.postedProduct <- map["productListingDto"]
        self.postedRequest <- map["productListingRequestDto"]
        self.productOrder <- map["productOrderDto"]
    }
}
