//
//  SystemCouponCode.swift
//  Quickride
//
//  Created by Admin on 25/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class SystemCouponCode : NSObject,Mappable{
 
    var id : Double = 0
    var couponCode : String = ""
    var discountPercent : Double = 0
    var cashbackPercent : Double = 0
    var freeRide = false
    var cashDeposit : Double = 0
    var maxDiscount : Double = 0
    var maxCashback : Double = 0
    var maxFreeRidePoints : Double = 0
    var activationTime : NSDate?
    var expiryTime : NSDate?
    var status : String = ""
    var offerName : String = ""
    var maxAllowedTimes : Int = 0
    var validityPeriod : Int = 0
    var preOpApplicable = false
    var couponType : String = ""
    var usageContext : String = ""
    var applicableUserStatus : String = ""
    var applicableUserRole : String = ""
    var companyCodes : String = ""
    var applicableRegions : String = ""
    var location : String = ""
    var locationLat : Double = 0
    var locationLng : Double = 0
    var radius : Double = 0
    var userCreationDateStart : NSDate?
    var userCreationDateEnd : NSDate?
    var lastLoggedInDateStart : NSDate?
    var lastLoggedInDateEnd : NSDate?
    var imageUrl : String = ""
    var autoApply = false
    var mutuallyExclusiveCodes : String = ""
    var creationDate : NSDate?
    var communicationTemplate : String = ""
    var reminderFrequency : Int = 0
    
    static let COUPON_STATUS_ACTIVE="Active"
    static let COUPON_STATUS_EXPIRED="Expired"
    static let COUPON_STATUS_USED="Used"
    static let COUPON_STATUS_CANCELLED="Cancelled"
    
    static let COUPON_TYPE_FREE_RIDE="FreeRide"
    static let COUPON_TYPE_FARE_DISCOUNT="FareDiscount"
    static let COUPON_TYPE_SERVICEFEE_DISCOUNT="ServiceFeeDiscount"
    static let COUPON_TYPE_CASH_BACK="Cashback"
    static let COUPON_TYPE_CASH_DEPOSIT="CashDeposit"
    
    static let COUPON_USUAGE_CONTEXT_REGISTER="Register"
    static let COUPON_USUAGE_CONTEXT_SHARE_RIDE="ShareRide"
    static let COUPON_USUAGE_CONTEXT_RECHARGE="Recharge"
    static let COUPON_USUAGE_CONTEXT_REDEEM="Redeem"
    static let COUPON_USUAGE_CONTEXT_REFER="Refer"
    static let COUPON_USUAGE_CONTEXT_VERIFIY_PROFILE="VerifyProfile"
    static let COUPON_USUAGE_CONTEXT_ROUTE_DETAILS_ADDED="RouteDetailsAdded"
    static let COUPON_USUAGE_CONTEXT_ADDED_PICTURE="AddedPicture"
    static let COUPON_USUAGE_CONTEXT_ACTIVATED="Activated"
    static let COUPON_USUAGE_CONTEXT_ADDED_VALID_COMPANY="AddedValidCompany"
    
    static let COUPON_APPLICABLE_STATUS_REGISTERED="Registered"
    static let COUPON_APPLICABLE_STATUS_ACTIVATED="Activated"
    static let COUPON_APPLICABLE_STATUS_VERIFIED="Verified"
    
    static let COUPON_APPLICABLE_ROLE_RIDER="Rider"
    static let COUPON_APPLICABLE_ROLE_PASSENGER="Passenger"
    static let COUPON_APPLICABLE_ROLE_BOTH="Both"
    static let COUPON_APPLICABLE_ROLE = "role"
    static let COUPON_APPLICABLE_SCHEME = "scheme"
    static let COUPON_APPLICABLE_ROLE_TAXI_PASSENGER="TaxiRidePassenger"
    static let COUPON_APPLICABLE_REFERRAL = "Referral"
    
    
    required init?(map: Map) {
    }
    
    override init() {
        
    }
    
    func mapping(map: Map) {
      id <- map["id"]
      couponCode <- map["couponCode"]
      discountPercent <- map["discountPercent"]
      cashbackPercent <- map["cashbackPercent"]
      freeRide <- map["freeRide"]
      cashDeposit <- map["cashDeposit"]
      maxDiscount <- map["maxDiscount"]
      maxCashback <- map["maxCashback"]
      maxFreeRidePoints <- map["maxFreeRidePoints"]
      activationTime <- map["activationTime"]
      expiryTime <- map["expiryTime"]
      status <- map["status"]
      offerName <- map["offerName"]
      maxAllowedTimes <- map["maxAllowedTimes"]
      validityPeriod <- map["validityPeriod"]
      preOpApplicable <- map["preOpApplicable"]
      couponType <- map["couponType"]
      usageContext <- map["usageContext"]
      applicableUserStatus <- map["applicableUserStatus"]
      applicableUserRole <- map["applicableUserRole"]
      companyCodes <- map["companyCodes"]
      applicableRegions <- map["applicableRegions"]
      location <- map["location"]
      locationLat <- map["locationLat"]
      locationLng <- map["locationLng"]
      radius <- map["radius"]
      userCreationDateStart <- map["userCreationDateStart"]
      userCreationDateEnd <- map["userCreationDateEnd"]
      lastLoggedInDateStart <- map["lastLoggedInDateStart"]
      lastLoggedInDateEnd <- map["lastLoggedInDateEnd"]
      imageUrl <- map["imageUrl"]
      autoApply <- map["autoApply"]
      mutuallyExclusiveCodes <- map["mutuallyExclusiveCodes"]
      creationDate <- map["creationDate"]
      communicationTemplate <- map["communicationTemplate"]
      reminderFrequency <- map["reminderFrequency"]
    }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "couponCode: \(String(describing: self.couponCode))," + " discountPercent: \( String(describing: self.discountPercent))," + " cashbackPercent: \(String(describing: self.cashbackPercent))," + " freeRide: \(String(describing: self.freeRide)),"
            + " cashDeposit: \(String(describing: self.cashDeposit))," + "maxDiscount: \(String(describing: self.maxDiscount))," + "maxCashback:\(String(describing: self.maxCashback))," + "maxFreeRidePoints:\(String(describing: self.maxFreeRidePoints))," + "activationTime:\(String(describing: self.activationTime))," + "expiryTime:\(String(describing: self.expiryTime))," + "status: \(String(describing: self.status))," + "offerName: \( String(describing: self.offerName))," + "maxAllowedTimes: \(String(describing: self.maxAllowedTimes))," + "validityPeriod: \( String(describing: self.validityPeriod))," + "preOpApplicable: \(String(describing: self.preOpApplicable))," + "couponType: \( String(describing: self.couponType))," + "usageContext:\(String(describing: self.usageContext))," + "applicableUserStatus:\(String(describing: self.applicableUserStatus))," + "applicableUserRole: \(String(describing: self.applicableUserRole))," + "companyCodes:\(String(describing: self.companyCodes))," + "applicableRegions: \(String(describing: self.applicableRegions))," + "location\(String(describing: self.location))," + "locationLat: \(String(describing: self.locationLat))," + "locationLng: \( String(describing: self.locationLng))," + "radius: \( String(describing: self.radius))," + "userCreationDateStart: \(String(describing: self.userCreationDateStart))," + "userCreationDateEnd: \( String(describing: self.userCreationDateEnd))," + "lastLoggedInDateStart: \(String(describing: self.lastLoggedInDateStart))," + "lastLoggedInDateEnd: \( String(describing: self.lastLoggedInDateEnd))," + " imageUrl: \( String(describing: self.imageUrl))," + " autoApply: \(String(describing: self.autoApply))," + " mutuallyExclusiveCodes: \(String(describing: self.mutuallyExclusiveCodes)),"
            + " creationDate: \(String(describing: self.creationDate))," + "communicationTemplate: \(String(describing: self.communicationTemplate))," + "reminderFrequency: \(String(describing: self.reminderFrequency)),"
    }
    
}
