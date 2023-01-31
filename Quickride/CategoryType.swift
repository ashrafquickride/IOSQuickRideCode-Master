//
//  CategoryType.swift
//  Quickride
//
//  Created by Halesh on 13/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct CategoryType: Mappable {
    
    var code: String?
    var creationDate = 0.0
    var displayName: String?
    var id: String?
    var imageURL: String?
    var bookingAmountForRent = 0
    var bookingAmountForSale = 0
    var cancellationCharge = 0
    var depositForRent = 0
    var modifiedDate = 0.0
    var categoryType: String?
    
    static let CATEGORY_TYPE_MEDICAL = "Medical"
    static let categoryType = "categoryType"
    
    init?(map: Map) {
        
    }
    init() {}
    
    mutating func mapping(map: Map) {
        self.code <- map["code"]
        self.creationDate <- map["creationDate"]
        self.displayName <- map["displayName"]
        self.id <- map["id"]
        self.imageURL <- map["imageURL"]
        self.bookingAmountForRent <- map["bookingAmountForRent"]
        self.bookingAmountForSale <- map["bookingAmountForSale"]
        self.cancellationCharge <- map["cancellationCharge"]
        self.depositForRent <- map["depositForRent"]
        self.modifiedDate <- map["modifiedDate"]
        self.categoryType <- map["categoryType"]
    }
    
    public var description: String {
        return "code: \(String(describing: self.code))," + "creationDate: \(String(describing: self.creationDate))," + "id: \(String(describing: id))," + "displayName: \(String(describing: displayName))," + "imageURL: \(String(describing: imageURL))," + "bookingAmountForRent: \(String(describing: bookingAmountForRent))," + "bookingAmountForSale: \(String(describing: bookingAmountForSale))," + "cancellationCharge: \(String(describing: cancellationCharge))," + "depositForRent: \(String(describing: depositForRent))," + "modifiedDate: \(String(describing: modifiedDate)),"
    }
}
