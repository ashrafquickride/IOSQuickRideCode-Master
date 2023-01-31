//
//  PostedRequest.swift
//  Quickride
//
//  Created by Halesh on 20/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct PostedRequest: Mappable {
    
    var address: String?
    var bookingFee = 0
    var borrowerId = 0
    var categoryCode: String?
    var deposit = 0
    var description: String?
    var fromTime = 0.0
    var id: String?
    var listingId: String?
    var latitude = 0.0
    var longitude = 0.0
    var modifiedDate = 0.0
    var pickUpLocations = [ProductLocation]()
    var pricePerDay = 0.0
    var productId: String?
    var requestedTime = 0.0
    var requestingPricePerDay = 0
    var requestingSellingPrice = 0
    var sellerId = 0
    var sellingPrice = 0.0
    var status: String?
    var title: String?
    var toTime = 0.0
    var tradeType: String?
    var paymentMode: String?
    var deliveryType: String?
    var contactNo: String?
    var categoryType: String?

    
    init?(map: Map) {
        
    }
    
    init() {
        
    }
    
    mutating func mapping(map: Map) {
        self.address <- map["address"]
        self.borrowerId <- map["borrowerId"]
        self.bookingFee <- map["bookingFee"]
        self.categoryCode <- map["categoryCode"]
        self.deposit <- map["deposit"]
        self.description <- map["description"]
        self.fromTime <- map["fromTime"]
        self.id <- map["id"]
        self.listingId <- map["listingId"]
        self.latitude <- map["latitude"]
        self.longitude <- map["longitude"]
        self.modifiedDate <- map["modifiedDate"]
        self.pickUpLocations <- map["pickUpLocations"]
        self.pricePerDay <- map["pricePerDay"]
        self.productId <- map["productId"]
        self.requestedTime <- map["requestedTime"]
        self.requestingPricePerDay <- map["requestingPricePerDay"]
        self.requestingSellingPrice <- map["requestingSellingPrice"]
        self.sellerId <- map["sellerId"]
        self.sellingPrice <- map["sellingPrice"]
        self.status <- map["status"]
        self.title <- map["title"]
        self.toTime <- map["toTime"]
        self.tradeType <- map["tradeType"]
        self.paymentMode <- map["paymentMode"]
        self.deliveryType <- map["deliveryType"]
        self.contactNo <- map["contactNo"]
        self.categoryType <- map["categoryType"]
    }
}
