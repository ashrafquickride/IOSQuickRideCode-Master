//
//  RideAssuredIncentive.swift
//  Quickride
//
//  Created by Admin on 03/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideAssuredIncentive : NSObject, Mappable {
    
    var id : Double = 0
    var userId : Double = 0
    var fromLat : Double = 0
    var fromLng : Double = 0
    var fromAddress : String?
    var toLat : Double = 0
    var toLng : Double = 0
    var toAddress : String?
    var startTime : String = ""
    var leaveTime : String = ""
    var validFrom : Double = 0
    var validTo : Double = 0
    var amountAssured : Double = 0
    var amountPaid : Double = 0
    var status = INCENTIVE_STATUS_OPEN
    var creationDate : Double = 0
    var paymentMode = PAYMENT_MODE_MANUAL
    var distance : Double = 0
    var completedRides = 0
    var totalRides = 0
    var lastFetchedTime : Double = 0
    var region : String?
    public static let INCENTIVE_STATUS_OPEN = "OPEN"
    public static let INCENTIVE_STATUS_ACTIVE = "ACTIVE"
    public static let INCENTIVE_STATUS_CLOSED = "CLOSED"
    
    public static let PAYMENT_MODE_MANUAL = "MANUAL"
    public static let PAYMENT_MODE_AUTOMATIC = "AUTOMATIC"
    
    public static let RIDE_ASSURED_INCENTIVE = "rideAssuredIncentive"
    
    public static let INCENTIVE_STATUS_DISPLAYED = "Displayed"
    public static let STATUS = "status"
    
    
  
    required init?(map: Map) {
        
    }
    
    override init() {
        
    }
    
    public init(userId : Double,  fromLat : Double,  fromLng : Double,fromAddress : String,
                toLat :Double ,  toLng : Double, toAddress : String,startTime : String,leaveTime : String,validFrom : Double,validTo : Double,amountAssured : Double,distance : Double)
    {
       self.userId = userId
       self.fromLat  = fromLat
       self.fromLng = fromLng
       self.fromAddress = fromAddress
       self.toLat = toLat
       self.toLng = toLng
       self.toAddress = toAddress
       self.startTime = startTime
       self.leaveTime = leaveTime
       self.validFrom = validFrom
       self.validTo = validTo
       self.amountAssured = amountAssured
       self.distance = distance
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
        startTime <- map["startTime"]
        leaveTime <- map["leaveTime"]
        validFrom <- map["validFrom"]
        validTo <- map["validTo"]
        amountAssured <- map["amountAssured"]
        amountPaid <- map["amountPaid"]
        status <- map["status"]
        creationDate <- map["creationDate"]
        paymentMode <- map["paymentMode"]
        distance <- map["distance"]
        completedRides <- map["completedRides"]
        totalRides <- map["totalRides"]
        lastFetchedTime <- map["lastFetchedTime"]
        self.region <- map["region"]
     }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "userId: \(String(describing: self.userId))," + " fromLat: \(String(describing: self.fromLat))," + " fromLng: \(String(describing: self.fromLng))," + " fromAddress: \(String(describing: self.fromAddress)),"
            + " toLat: \(self.toLat)," + "toLng: \(String(describing: self.toLng))," + "toAddress:\(String(describing: self.toAddress))," + "startTime:\(String(describing: self.startTime))," + "leaveTime:\(String(describing: self.leaveTime))," + "validFrom:\(String(describing: self.validFrom))," + "validTo: \(String(describing: self.validTo))," + "amountAssured: \(String(describing: self.amountAssured))," + "distance: \(String(describing: self.distance)),"
    }
    
}
