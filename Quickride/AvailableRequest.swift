//
//  AvailableRequest.swift
//  Quickride
//
//  Created by Halesh on 20/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct AvailableRequest: Mappable{
    
    var address: String?
    var bookingFee: String?
    var borrowerId = 0.0
    var categoryCode: String?
    var categoryImageURL: String?
    var companyName: String?
    var deposit = 0
    var description: String?
    var distance = 0.0
    var fromTime = 0.0
    var id: String?
    var imageURI: String?
    var latitude = 0
    var listingId: String?
    var name: String?
    var pricePerDay = 0
    var productId: String?
    var profileVerificationData: ProfileVerificationData?
    var requestedTime = 0.0
    var requestingPricePerDay = 0
    var requestingSellingPrice = 0
    var sellerId = 0
    var sellingPrice = 0
    var status: String?
    var title: String?
    var toTime = 0.0
    var tradeType: String?
    var updatedTime = 0.0
    var userId = 0
    var verificationStatus = true
    var gender: String?
    var rating = 0
    var noOfReviews = 0
    var categoryType: String?
    
    static let ownerId = "ownerId"
    static let catCode = "categoryCode"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let offSet = "offSet"
    static let maxDistance = "maxDistance"
    static let borrowerId = "borrowerId"
    static let productId = "productId"
    static let sellerId = "sellerId"
    static let id = "id"
    static let listingId = "listingId"
    
    init?(map: Map) {
        
    }
    init() {
        
    }
    mutating func mapping(map: Map) {
        self.address <- map["address"]
        self.bookingFee <- map["bookingFee"]
        self.borrowerId <- map["borrowerId"]
        self.categoryCode <- map["categoryCode"]
        self.categoryImageURL <- map["categoryImageURL"]
        self.companyName <- map["companyName"]
        self.deposit <- map["deposit"]
        self.description <- map["description"]
        self.distance <- map["distance"]
        self.fromTime <- map["fromTime"]
        self.id <- map["id"]
        self.imageURI <- map["imageURI"]
        self.latitude <- map["latitude"]
        self.listingId <- map["listingId"]
        self.name <- map["name"]
        self.pricePerDay <- map["pricePerDay"]
        self.productId <- map["productId"]
        self.profileVerificationData <- map["profileVerificationData"]
        self.requestedTime <- map["requestedTime"]
        self.requestingPricePerDay <- map["requestingPricePerDay"]
        self.requestingSellingPrice <- map["requestingSellingPrice"]
        self.sellerId <- map["sellerId"]
        self.sellingPrice <- map["sellingPrice"]
        self.status <- map["status"]
        self.title <- map["title"]
        self.toTime <- map["toTime"]
        self.tradeType <- map["tradeType"]
        self.updatedTime <- map["updatedTime"]
        self.userId <- map["userId"]
        self.verificationStatus <- map["verificationStatus"]
        self.gender <- map["gender"]
        self.categoryType <- map["categoryType"]
    }
}
