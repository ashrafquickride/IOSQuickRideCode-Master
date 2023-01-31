//
//  Product.swift
//  Quickride
//
//  Created by Halesh on 13/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct Product: Mappable {
    
    var id: String?
    var ownerId: String?
    var tradeType: String?
    var categoryCode: String?
    var bookingFee = 0.0
    var deposit = 0
    var finalPrice: String?
    var pricePerDay: String?
    var pricePerMonth: String?
    var startTime: String?
    var endTime: String?
    var availableDays: String?
    var location = [Location]()
    var condition: String?
    var title: String?
    var description: String?
    var manufacturedDate = 0
    var imageList: String?
    var videoURL: String?
    var availableFor: String?
    var contactNo: String?
    var contactName: String?
    
    static let RENT = "RENT"
    static let SELL = "SELL"
    static let BOTH = "SELL_OR_RENT"
    static let DONATE = "DONATE"
    static let SHARE = "SHARE"

    init?(map: Map) {
        
    }
    init() {
        
    }
    init(postedProduct: PostedProduct) {
        self.id = postedProduct.id
        self.ownerId = StringUtils.getStringFromDouble(decimalNumber: postedProduct.ownerId)
        self.tradeType = postedProduct.tradeType
        self.categoryCode = postedProduct.categoryCode
        self.bookingFee = postedProduct.bookingFee
        self.finalPrice = StringUtils.getStringFromDouble(decimalNumber: postedProduct.finalPrice)
        self.pricePerDay = StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerDay)
        self.pricePerMonth = StringUtils.getStringFromDouble(decimalNumber: postedProduct.pricePerMonth)
        for location in postedProduct.locations{
            self.location.append(Location(id: Double(location.id ?? "") ?? 0, latitude: location.lat, longitude: location.lng, shortAddress: location.address, completeAddress: location.address, country: location.country, state: location.state, city: location.city, areaName: location.areaName, streetName: location.streetName))
        }
        self.condition = postedProduct.productCondition
        self.title = postedProduct.title
        self.description = postedProduct.description
        self.manufacturedDate = postedProduct.manufacturedDate
        self.imageList = postedProduct.imageList
        self.videoURL = postedProduct.videoURL
        self.deposit = postedProduct.deposit
    }
    
    mutating func mapping(map: Map) {
        
    }
    
    func  getParamsMap() -> [String : String] {
        var params = [String : String]()
        params["ownerId"] =  UserDataCache.getInstance()?.userId
        params["tradeType"] = tradeType
        params["categoryCode"] = categoryCode
        params["bookingFee"] = String(bookingFee)
        params["deposit"] = String(deposit)
        if tradeType == Product.RENT{
            params["pricePerDay"] = pricePerDay
            params["pricePerMonth"] = pricePerMonth
        }else if tradeType == Product.SELL{
            params["finalPrice"] = finalPrice
        }else{
            params["pricePerDay"] = pricePerDay
            params["pricePerMonth"] = pricePerMonth
            params["finalPrice"] = finalPrice
        }
        params["startTime"] = startTime
        params["endTime"] = endTime
        params["availableDays"] = availableDays
        var productLocation = [ProductLocation]()
        for loc in location{
            productLocation.append(ProductLocation(location: loc))
        }
        params["location"] = productLocation.toJSONString()
        if let condition = condition {
            params["condition"] = condition
        }else{
            params["condition"] = "None"
        }
        
        params["title"] = title
        params["description"] = description
        params["manufacturedDate"] = String(manufacturedDate)
        params["imageList"] = imageList
        params["videoURL"] = videoURL
        return params
    }
}
