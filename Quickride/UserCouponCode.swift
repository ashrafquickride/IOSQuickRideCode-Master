//
//  UserCouponCode.swift
//  Quickride
//
//  Created by Admin on 25/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserCouponCode : NSObject, Mappable{
    
    var id : Double = 0
    var couponCode : String = ""
    var userId : Double = 0
    var discountPercent : Double = 0
    var cashbackPercent : Double = 0
    var freeRide = false
    var cashDeposit : Double = 0
    var maxDiscount : Double = 0
    var maxCashback : Double = 0
    var maxFreeRidePoints : Double = 0
    var activationTime : Double?
    var expiryTime : Double?
    var lastUpdatedTime : Double?
    var status : String = ""
    var offerName : String = ""
    var couponType : String = ""
    var usageContext : String = ""
    var applicableUserStatus : String?
    var preOpApplicable = false
    var lastReminderTime : Double?
    var nextReminderTime : Double?
    var autoApply = false
    var maxAllowedTimes : Int = 0
    var usedTimes : Int = 0
    var mutuallyExclusiveCodes : String = ""
    var communicationTemplate : String = ""
    var reminderFrequency : Int = 0
    
    
    required init?(map: Map) {
        
    }
    
    override init() {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        couponCode <- map["couponCode"]
        userId <- map["userId"]
        discountPercent <- map["discountPercent"]
        cashbackPercent <- map["cashbackPercent"]
        freeRide <- map["freeRide"]
        cashDeposit <- map["cashDeposit"]
        maxDiscount <- map["maxDiscount"]
        maxCashback <- map["maxCashback"]
        maxFreeRidePoints <- map["maxFreeRidePoints"]
        activationTime <- map["activationTime"]
        expiryTime <- map["expiryTime"]
        lastUpdatedTime <- map["lastUpdatedTime"]
        status <- map["status"]
        offerName <- map["offerName"]
        couponType <- map["couponType"]
        usageContext <- map["usageContext"]
        applicableUserStatus <- map["offerName"]
        preOpApplicable <- map["preOpApplicable"]
        lastReminderTime <- map["lastReminderTime"]
        nextReminderTime <- map["nextReminderTime"]
        autoApply <- map["autoApply"]
        maxAllowedTimes <- map["maxAllowedTimes"]
        usedTimes <- map["usedTimes"]
        mutuallyExclusiveCodes <- map["mutuallyExclusiveCodes"]
        communicationTemplate <- map["communicationTemplate"]
        reminderFrequency <- map["reminderFrequency"]

    }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "couponCode: \(String(describing: self.couponCode))," + " userId: \( String(describing: self.userId))," + " discountPercent: \(String(describing: self.discountPercent))," + " cashbackPercent: \(String(describing: self.cashbackPercent)),"
            + " freeRide: \(String(describing: self.freeRide))," + "cashDeposit: \(String(describing: self.cashDeposit))," + "maxDiscount:\(String(describing: self.maxDiscount))," + "maxCashback:\(String(describing: self.maxCashback))," + "maxFreeRidePoints:\(String(describing: self.maxFreeRidePoints))," + "activationTime:\(String(describing: self.activationTime))," + "expiryTime: \(String(describing: self.expiryTime))," + "lastUpdatedTime: \( String(describing: self.lastUpdatedTime))," + "status: \(String(describing: self.status))," + "offerName: \( String(describing: self.offerName))," + "couponType: \(String(describing: self.couponType))," + "usageContext: \( String(describing: self.usageContext))," + "applicableUserStatus:\(String(describing: self.applicableUserStatus))," + "preOpApplicable:\(String(describing: self.preOpApplicable))," + "lastReminderTime: \(String(describing: self.lastReminderTime))," + "nextReminderTime:\(String(describing: self.nextReminderTime))," + "autoApply: \(String(describing: self.autoApply))," + "maxAllowedTimes\(String(describing: self.maxAllowedTimes))," + "usedTimes: \(String(describing: self.usedTimes))," + "mutuallyExclusiveCodes: \( String(describing: self.mutuallyExclusiveCodes))," + "communicationTemplate: \( String(describing: self.communicationTemplate))," + "reminderFrequency: \(String(describing: self.reminderFrequency)),"
    }
    
}
