//
//  AvailableProduct.swift
//  Quickride
//
//  Created by Halesh on 20/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct AvailableProduct: Mappable{
    
    var additionalDetails: String?
    var bookingFee = 0
    var categoryCode: String?
    var companyName: String?
    var deposit = 0
    var description: String?
    var distance = 0.0
    var finalPrice = 0.0
    var locations = [ProductLocation]()
    var noOfViews = 0
    var pricePerDay = 0.0
    var pricePerMonth = 0.0
    var productId: String?
    var productImgList: String?
    var productListingId: String?
    var profileVerificationData: ProfileVerificationData?
    var rating = 0.0
    var title: String?
    var tradeType: String?
    var userId = 0
    var userImgUri: String?
    var userName: String?
    var verificationStatus = false
    var gender: String?
    var modifiedTime = 0.0
    var noOfReviews = 0
    var manufacturedDate = 0.0
    var productCondition: String?
    var creationDate = 0.0
    var ratingForProduct = 0.0
    var noOfReviewsForProduct = 0
    var categoryType : String?
    var contactNo : String?

    
    static let ownerId = "ownerId"
    static let catCode = "categoryCode"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let offSet = "offSet"
    static let maxDistance = "maxDistance"
    static let id = "id"
    static let status = "status"
    static let query = "query"
    static let entityId = "entityId"
    static let entityType = "entityType"
    static let userId = "userId"
    static let tradeType = "tradeType"
    
    static let LISTING = "LISTING"
    static let REQUEST = "REQUEST"
    static let ORDER = "ORDER"
    
    static let BRAND_NEW = "Brand New"
    static let FREE_CATEGORY = "CT008"

    init?(map: Map) {
        
    }
    init() {
        
    }
    
    init(postedProduct: PostedProduct,sellerInfo: UserBasicInfo) {
        self.bookingFee = Int(postedProduct.bookingFee)
        self.categoryCode = postedProduct.categoryCode
        self.companyName = sellerInfo.companyName
        self.deposit = postedProduct.deposit
        self.description = postedProduct.description
        let location = QuickShareCache.getInstance()?.location
        if !postedProduct.locations.isEmpty {
            self.distance = LocationClientUtils.getDistance(fromLatitude: location?.latitude ?? 0, fromLongitude: location?.longitude ?? 0, toLatitude: postedProduct.locations[0].lat, toLongitude: postedProduct.locations[0].lng)
        }
        self.finalPrice = postedProduct.finalPrice
        self.locations = postedProduct.locations
        self.pricePerDay = postedProduct.pricePerDay
        self.pricePerMonth = postedProduct.pricePerMonth
        self.productImgList = postedProduct.imageList
        self.productListingId = postedProduct.id
        self.profileVerificationData = sellerInfo.profileVerificationData
        self.rating = Double(postedProduct.rating)
        self.title = postedProduct.title
        self.tradeType = postedProduct.tradeType
        self.userId = Int(sellerInfo.userId ?? 0)
        self.userImgUri = sellerInfo.imageURI
        self.userName = sellerInfo.name
        self.verificationStatus = sellerInfo.verificationStatus
        self.gender = sellerInfo.gender
        self.modifiedTime = postedProduct.updatedTime
        self.noOfReviews = sellerInfo.noOfReviews
        self.manufacturedDate = Double(postedProduct.manufacturedDate)
        self.productCondition = postedProduct.productCondition
        self.creationDate = Double(postedProduct.creationDate)
    }
    
    mutating func mapping(map: Map) {
        self.additionalDetails <- map["additionalDetails"]
        self.bookingFee <- map["bookingFee"]
        self.categoryCode <- map["categoryCode"]
        self.companyName <- map["companyName"]
        self.deposit <- map["deposit"]
        self.description <- map["description"]
        self.distance <- map["distance"]
        self.finalPrice <- map["finalPrice"]
        self.locations <- map["locations"]
        self.noOfViews <- map["noOfViews"]
        self.pricePerDay <- map["pricePerDay"]
        self.pricePerMonth <- map["pricePerMonth"]
        self.productId <- map["productId"]
        self.productImgList <- map["productImgList"]
        self.productListingId <- map["productListingId"]
        self.profileVerificationData <- map["profileVerificationData"]
        self.rating <- map["rating"]
        self.title <- map["title"]
        self.tradeType <- map["tradeType"]
        self.userId <- map["userId"]
        self.userImgUri <- map["userImgUri"]
        self.userName <- map["userName"]
        self.verificationStatus <- map["verificationStatus"]
        self.gender <- map["gender"]
        self.modifiedTime <- map["modifiedTime"]
        self.manufacturedDate <- map["manufacturedDate"]
        self.productCondition <- map["productCondition"]
        self.creationDate <- map["creationDate"]
        self.ratingForProduct <- map["ratingForProduct"]
        self.noOfReviewsForProduct <- map["noOfReviewsForProduct"]
        self.categoryType <- map["categoryType"]
        self.contactNo <- map["contactNo"]
    }
}
