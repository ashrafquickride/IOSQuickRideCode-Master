//
//  RequestProduct.swift
//  Quickride
//
//  Created by Halesh on 16/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct RequestProduct: Mappable{
    
    var id: String?
    var borrowerId: String?
    var listingId: String?
    var location: Location? //Not using
    var fromTime = 0.0
    var toTime = 0.0
    var requestingPricePerDay: String?
    var requestingPricePerWeek: String?
    var requestingSellingPrice: String?
    var requestLocationInfo: ProductLocation?
    var categoryCode: String?
    var title: String?
    var description: String?
    var tradeType: String?
    var deliveryType: String?
    var paymentMode: String?
    var contactNo: String?
    var postAsReq = true
    
    
    static let HOME_DELIVERY = "HOME_DELIVERY"
    static let SELF_PICKUP = "SELF_DELIVERY"
    static let PAY_BOOKING_OR_DEPOSITE_FEE = "BOOKING_OR_DEPOSIT_ONLY"
    static let PAY_FULL_AMOUNT = "FULL_PAYMENT"
    
    init?(map: Map) {
        
    }
    init(borrowerId: String?,listingId: String?,fromTime: Double?,toTime: Double?,requestingPricePerDay: Double?,requestingPricePerWeek: Double?,requestingSellingPrice: Double?,locations: [ProductLocation]?,categoryCode: String?,title: String?,description: String?,tradeType: String?,deliveryType: String?) {
        self.borrowerId = borrowerId
        self.listingId = listingId
        self.fromTime = fromTime ?? 0
        self.toTime = toTime ?? 0
        if tradeType == Product.RENT{
            self.requestingPricePerDay = StringUtils.getStringFromDouble(decimalNumber: requestingPricePerDay)
            self.requestingPricePerWeek = StringUtils.getStringFromDouble(decimalNumber: requestingPricePerWeek)
        }else{
            self.requestingSellingPrice = StringUtils.getStringFromDouble(decimalNumber: requestingSellingPrice)
        }
        if locations?.isEmpty == false{
            requestLocationInfo = locations?[0]
        }
        self.categoryCode = categoryCode
        self.title = title
        self.description = description
        self.tradeType = tradeType
        self.deliveryType = deliveryType
    }
    
    init() {
        
    }
    init(postedRequest: PostedRequest) {
        self.id = postedRequest.id
        self.borrowerId = String(postedRequest.borrowerId)
        self.listingId = postedRequest.listingId
        self.requestingPricePerDay = String(postedRequest.requestingPricePerDay)
        self.requestingSellingPrice = String(postedRequest.requestingSellingPrice)
        if !postedRequest.pickUpLocations.isEmpty{
           self.requestLocationInfo = postedRequest.pickUpLocations[0]
            requestLocationInfo?.address = postedRequest.address
        }
        self.categoryCode = postedRequest.categoryCode
        self.title = postedRequest.title
        self.description = postedRequest.description
        self.tradeType = postedRequest.tradeType
        self.contactNo = postedRequest.contactNo
    }
    mutating func mapping(map: Map) {
        
    }
    
    func  getParamsMap() -> [String : String] {
        var params : [String : String] = [String : String]()
        params["id"] = id
        params["borrowerId"] = UserDataCache.getInstance()?.userId
        params["listingId"] = listingId
        params["requestLocationInfo"] = requestLocationInfo?.toJSONString()
        if tradeType == Product.RENT && fromTime != 0 && toTime != 0{
            params["fromTime"] = StringUtils.getStringFromDouble(decimalNumber: fromTime)
            params["toTime"] = StringUtils.getStringFromDouble(decimalNumber: toTime)
        }
        params["requestingPricePerDay"] = requestingPricePerDay
        params["requestingSellingPrice"] = requestingSellingPrice
        params["requestingPricePerWeek"] = requestingPricePerWeek
        params["categoryCode"] = categoryCode
        params["title"] = title
        params["description"] = description
        params["tradeType"] = tradeType
        params["deliveryType"] = deliveryType
        params["paymentMode"] = paymentMode
        params["contactNo"] = contactNo
        params["postAsReq"] = String(postAsReq)
        return params
    }
}
