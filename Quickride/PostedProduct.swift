//
//  PostedProduct.swift
//  Quickride
//
//  Created by Halesh on 17/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct PostedProduct: Mappable{
    
    var address: String?
    var areaName: String?
    var availableDays: String?
    var bookingFee = 0.0
    var categoryCode: String?
    var cellId = 0
    var city: String?
    var country: String?
    var creationDate = 0
    var deposit = 0
    var description: String?
    var endTime = 0.0
    var finalPrice = 0.0
    var id: String?
    var imageList: String?
    var lat = 0.0
    var lng = 0.0
    var locations = [ProductLocation]()
    var ownerId = 0.0
    var pricePerDay = 0.0
    var pricePerMonth = 0.0
    var productCondition: String?
    var manufacturedDate = 0
    var rating = 0
    var startTime = 0.0
    var state: String?
    var status: String?
    var streetName: String?
    var title: String?
    var tradeType: String?
    var updatedTime = 0.0
    var videoURL: String?
    var contactNo: String?
    var contactName: String?
    var categoryType: String?
    
    static let REVIEW = "REVIEW"
    static let ACTIVE = "ACTIVE"
    static let REJECTED = "REJECTED"
    static let EXPIRED = "EXPIRED"
    static let HOLD = "HOLD"
    static let SUSPENDED = "SUSPENDED"
    static let ARCHIVED = "ARCHIVED"
    static let SOLD = "SOLD"
    
    init?(map: Map) {
        
    }
    init() {
        
    }
    
    mutating func mapping(map: Map) {
        self.address <- map["address"]
        self.areaName <- map["areaName"]
        self.availableDays <- map["availableDays"]
        self.bookingFee <- map["bookingFee"]
        self.categoryCode <- map["categoryCode"]
        self.cellId <- map["cellId"]
        self.city <- map["city"]
        self.country <- map["country"]
        self.creationDate <- map["creationDate"]
        self.deposit <- map["deposit"]
        self.description <- map["description"]
        self.endTime <- map["endTime"]
        self.finalPrice <- map["finalPrice"]
        self.id <- map["id"]
        self.imageList <- map["imageList"]
        self.lat <- map["lat"]
        self.lng <- map["lng"]
        self.locations <- map["locations"]
        self.ownerId <- map["ownerId"]
        self.pricePerDay <- map["pricePerDay"]
        self.productCondition <- map["productCondition"]
        self.manufacturedDate <- map["manufacturedDate"]
        self.rating <- map["rating"]
        self.startTime <- map["startTime"]
        self.state <- map["state"]
        self.status <- map["status"]
        self.streetName <- map["streetName"]
        self.title <- map["title"]
        self.tradeType <- map["tradeType"]
        self.updatedTime <- map["updatedTime"]
        self.pricePerMonth <- map["pricePerMonth"]
        self.videoURL <- map["videoURL"]
        self.contactNo <- map["contactNo"]
        self.contactName <- map["contactName"]
        self.categoryType <- map["categoryType"]
    }
}
