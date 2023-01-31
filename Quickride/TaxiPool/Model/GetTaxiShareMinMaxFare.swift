//
//  GetTaxiShareMinMaxFare.swift
//  Quickride
//
//  Created by Ashutos on 5/6/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

class GetTaxiShareMinMaxFare: NSObject, Mappable {
    
    var bookingType: String?
    var shareType: String?
    var minFare: Int?
    var maxFare: Int?
    var defaultShareType: Int?
    static let EXCLUSIVE_TAXI = "Exclusive Taxi"
    
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        bookingType <- map["bookingType"]
        shareType <- map["shareType"]
        minFare <- map["minFare"]
        maxFare <- map["maxFare"]
        defaultShareType <- map["defaultShareType"]
    }
    
    public override var description: String {
        
        return "bookingType: \(String(describing: self.bookingType)),"
        + "shareType: \(String(describing: self.shareType)),"
        + " minFare: \( String(describing: self.minFare)),"
        + " maxFare: \(String(describing: self.maxFare)),"
        + " defaultShareType: \(String(describing: self.defaultShareType))"
    }
}
