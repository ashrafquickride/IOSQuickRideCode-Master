//
//  RidePass.swift
//  Quickride
//
//  Created by Admin on 19/02/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RidePass : NSObject,Mappable{
    
    var id : Double = 0
    var userId : Double = 0
    var fromLat : Double = 0
    var fromLng : Double = 0
    var fromAddress : String?
    var toLat : Double = 0
    var toLng : Double = 0
    var toAddress : String?
    var validFrom : Double = 0
    var validTo : Double = 0
    var passPrice : Int = 0
    var status : String?
    var totalRides : Int = 0
    var availableRides : Int = 0
    var duration : Int = 0
    var discountPercent : Int = 0
    var unitFare : Double = 0
    var paymentType : String?
    var actualPrice : Int = 0
    var distance : Double = 0
    
    static let PASS_STATUS_ACTIVE = "ACTIVE"
    
    required init?(map: Map) {
        
    }
    override init(){
        
    }
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        fromLat <- map["fromLat"]
        fromLng <- map["fromLng"]
        fromAddress <- map["fromAddress"]
        toLat <- map["toLat"]
        toLng <- map["toLng"]
        toAddress <- map["toAddress"]
        validFrom <- map["validFrom"]
        validTo <- map["validTo"]
        passPrice <- map["passPrice"]
        status <- map["status"]
        totalRides <- map["totalRides"]
        availableRides <- map["availableRides"]
        duration <- map["duration"]
        discountPercent <- map["discountPercent"]
        unitFare <- map["unitFare"]
        paymentType <- map["paymentType"]
        actualPrice <- map["actualPrice"]
        distance <- map["distance"]
 }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "userId: \(String(describing: self.userId))," + " discountPercent: \( String(describing: self.discountPercent))," + " fromLat: \(String(describing: self.fromLat))," + " fromLng: \(String(describing: self.fromLng)),"
            + " toLat: \(String(describing: self.toLat))," + "toLng: \(String(describing: self.toLng))," + "toAddress:\(String(describing: self.toAddress))," + "validFrom:\(String(describing: self.validFrom))," + "validTo:\(String(describing: self.validTo))," + "passPrice:\(String(describing: self.passPrice))," + "status: \(String(describing: self.status))," + "totalRides: \( String(describing: self.totalRides))," + "availableRides: \(String(describing: self.availableRides))," + "duration: \( String(describing: self.duration))," + "discountPercent: \(String(describing: self.discountPercent))," + "unitFare: \( String(describing: self.unitFare))," + "paymentType:\(String(describing: self.paymentType))," + "actualPrice:\(String(describing: self.actualPrice))," + "distance: \(String(describing: self.distance)),"
    }
    
}
