//
//  User.swift
//  Quickride
//
//  Created by KNM Rao on 28/09/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class User : NSObject, Mappable,NSCopying {
    
    static let FLD_PHONE = "phone"
    static let FLD_NAME = "name"
    static let FLD_PWD = "pwd"
    static let FLD_STATUS = "status"
    static let USER_GENDER_MALE : String = "M"
    static let USER_GENDER_FEMALE : String = "F"
    static let USER_GENDER_UNKNOWN : String = "U"
    static let UPDATE_REQUIRED = "update_required";
    static let UPDATE_AVAILABLE = "update_available";
    static let UPDATE_NOT_REQUIRED = "update_not_required";
    
    static let NEW_CONTACT_NO = "newContactNo"
    static let GENDER = "gender"
    static let FLD_USER_ID = "userId"
    static let FLD_USER_ID_BULK = "userIds"
    static let IOS_APP_VERSION_NAME = "iosAppVersionName"
    static let FLD_CLIENT_IOS_KEY = "clientIosKey"
    static let FLD_ACTIVATION_CODE = "activationCode"
    static let FLD_PROMO_CODE = "appliedPromoCode"
    static let FLD_PRIMARY_AREA = "primaryArea"
    static let FLD_APP_NAME = "appName"
    static let FLD_REFERRAL_CODE = "referralcode"
    static let CONTACT_EMAIL = "contactEmail"
    static let PRIMARY_AREA_LAT = "primaryAreaLat"
    static let PRIMARY_AREA_LNG = "primaryAreaLng"
    static let PRIMARY_REGION = "primaryRegion"
    static let PRIMARY_AREA = "primaryArea"
    
    static let APP_NAME_QUICK_RIDE = "Quick Ride"
    static let SUSPEND_STATUS_MESSAGE = "suspendStatusMessage"
    static let SUSPENDED_BY_USER = "suspendedByUser"
    static let PHONE_MODEL = "phoneModel"
    static let FLD_COUNTRY_CODE = "countryCode"
    static let CONTACT_NO = "contactNo"
    static let TIME_ZONE_OFF_SET = "timeZoneOffSet"
    static let FLD_DEVICE_UNIQUE_ID = "deviceUniqueId"
    static let SUBSCRIPTION_STATUS_REQUIRED = "SUBSREQUIRED"
    static let SUBSCRIPTION_STATUS_NOT_REQUIRED = "SUBSNOTREQUIRED"
    static let SUBSCRIPTION_STATUS_ALREADY_DONE = "SUBSCRIPTIONDONE"
    static let STATUS = "status"
    static let SUBS_STATUS_CURRENT = "CURRENT"
    static let SUBS_STATUS_ADVANCE = "ADVANCE"
    static let COUNTRY = "country";
    static let STATE = "state";
    static let CITY = "city";
    static let AREA_NAME = "areaName";
    static let STREET_NAME = "streetName";
    static let ADDRESS = "address";
    static let FAVOURITE_PARTNER_USER_ID = "favouritePartnerUserId"
    static let ENABLE_AUTO_CONFIRM = "enableAutoConfirm"
    static let CALLER_ID = "callerId"
    static let RECIEVER_ID = "recieverId"
    static let ALTERNATE_CONTACT_NO = "alternateContactNumber"
    static let OTP = "otp"
    static let VERFICATION_PROVIDER = "verificationProvider"
    static let OTP_CAPS = "OTP"
    static let APPSFLYER_ID = "appsFlyerId"
    static let CLIENT_DEVICE_TYPE = "clientDeviceType"
    static let FLD_DOB = "dob"
    static let COVID_ASSESSMENT_RESULT = "covidAssessmentResult";
    static let FLD_CALL_PREF = "callPrefData"
    static let FLD_ID = "id";
    static let FLD_OFFERID = "offerId"
    static let FLD_INPUT_TYPE = "inputType"
    static let FLD_IMPRESSION_ID = "offerImpressionId"
    
    var phoneNumber : Double = 0
    var userName : String = ""
    var gender : String = ""
    var password : String = ""
    var status : String = ""
    var referralCode : String = ""
    var appliedPromoCode : String?
    var creationDate : Double = 0
    var clientUniqueDeviceId : String = ""
    var clientIosKey : String = ""
    var appName : String?
    var contactNo : Double?
    var iosAppVersionName : String?
    var email : String?
    var primaryArea :String?
    var primaryAreaLat :Double = 0
    var primaryAreaLng :Double = 0
    var primaryRegion :String?
    var phoneModel : String?
    var countryCode : String?
    var uniqueDeviceId : String?
    var asksCashTransactions = false
    var subscriptionStatus = User.SUBSCRIPTION_STATUS_NOT_REQUIRED
    var freeRideId = 0.0
    var freeRideInitiatedDate : Double?
    var googleAdvertisingId : String?
    var alternateContactNo : Double?
    var suspendedByUser = false
    var appsFlyerId: String?
    var pickupOTP: String?
    
    static let APP_NAME_QUICKRIDE = "Quick Ride"

    
    static let googleAdvertisingId = "googleAdvertisingId"
    
    static let status_registered = "REGISTERED"
    static let status_activated = "ACTIVATED"
    static let status_suspended = "SUSPENDED"
    
    static let FLD_PICKUP_OTP = "pickupOTP"
    
    override init(){
        
    }
    init(user : User) {
        self.phoneNumber  = user.phoneNumber
        
        self.userName = user.userName
        self.gender = user.gender
        self.password = user.password
        self.status = user.status
        self.referralCode = user.referralCode
        self.creationDate = user.creationDate
        self.clientIosKey = user.clientIosKey
        self.contactNo = user.contactNo
        self.iosAppVersionName = user.iosAppVersionName
        self.phoneModel = user.phoneModel
    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        phoneNumber <- map["phone"]
        userName <- map["name"]
        gender <- map["gender"]
        password <- map["pwd"]
        status <- map["status"]
        referralCode <- map["referralCode"]
        creationDate <- map["creationDate"]
        clientIosKey <- map["clientIosKey"]
        appName <- map["appName"]
        contactNo <- map["contactNo"]
        iosAppVersionName <- map["iosAppVersionName"]
        email <- map["email"]
        primaryArea <- map["primaryArea"]
        primaryAreaLat <- map["primaryAreaLat"]
        primaryAreaLng <- map["primaryAreaLng"]
        primaryRegion <- map["primaryRegion"]
        phoneModel <- map["phoneModel"]
        countryCode <- map["countryCode"]
        uniqueDeviceId <- map["uniqueDeviceId"]
        asksCashTransactions <- map["asksCashTransactions"]
        subscriptionStatus <- map["subscriptionStatus"]
        freeRideId <- map["freeRideId"]
        freeRideInitiatedDate <- map["freeRideInitiatedDate"]
        googleAdvertisingId <- map["googleAdvertisingId"]
        alternateContactNo <- map["alternateContactNo"]
        suspendedByUser <- map["suspendedByUser"]
        appsFlyerId <- map["appsFlyerId"]
        pickupOTP <- map["pickupOTP"]
    }
    public func getParams() -> [String : String]{
        
        var params = [String : String]()
        params[User.FLD_PHONE] = StringUtils.getStringFromDouble(decimalNumber : self.phoneNumber)
        params[User.FLD_NAME] = self.userName
        params[User.GENDER] = self.gender
        params[User.FLD_PWD] = self.password
        params[User.FLD_CLIENT_IOS_KEY] = self.clientIosKey
        params[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
        if self.iosAppVersionName == nil{
            params[User.IOS_APP_VERSION_NAME] =  AppConfiguration.APP_CURRENT_VERSION_NO
        }else{
            params[User.IOS_APP_VERSION_NAME] =  self.iosAppVersionName
        }
        if (self.appliedPromoCode != nil) {
            params[User.FLD_PROMO_CODE] = self.appliedPromoCode!
        }
        
        if primaryArea != nil{
            params[User.PRIMARY_AREA] = self.primaryArea!
        }
        if primaryAreaLat != 0{
             params[User.PRIMARY_AREA_LAT] = String(self.primaryAreaLat)
        }
        if primaryAreaLng != 0{
             params[User.PRIMARY_AREA_LNG] = String(self.primaryAreaLng)
        }
        if primaryRegion != nil{
           params[User.PRIMARY_REGION] = self.primaryRegion!
        }
        if (self.phoneModel != nil) {
            params[User.PHONE_MODEL] = self.phoneModel!
        }
        if (self.countryCode != nil) {
            params[User.FLD_COUNTRY_CODE] = self.countryCode!
        }
        if (self.uniqueDeviceId != nil && !self.uniqueDeviceId!.isEmpty) {
            params[User.FLD_DEVICE_UNIQUE_ID] = self.uniqueDeviceId!
        }
        params[User.FLD_STATUS] = self.status
        params[User.googleAdvertisingId] = self.googleAdvertisingId
        params[User.CONTACT_NO] = StringUtils.getStringFromDouble(decimalNumber: contactNo) 
        params[User.APPSFLYER_ID] = appsFlyerId
        return params
    }
     public func copy(with zone: NSZone? = nil) -> Any {
        let user = User()
        user.phoneNumber = self.phoneNumber
        user.userName  = self.userName
        user.gender = self.gender
        user.password = self.password
        user.status = self.status
        user.referralCode = self.referralCode
        user.appliedPromoCode = self.appliedPromoCode
        user.creationDate = self.creationDate
        user.clientUniqueDeviceId = self.clientUniqueDeviceId
        user.clientIosKey = self.clientIosKey
        user.contactNo = self.contactNo
        user.iosAppVersionName = self.iosAppVersionName
        user.phoneModel = self.phoneModel
        user.countryCode = self.countryCode
        user.uniqueDeviceId = self.uniqueDeviceId
        user.freeRideId = self.freeRideId
        user.freeRideInitiatedDate = self.freeRideInitiatedDate
        user.alternateContactNo = self.alternateContactNo
        user.appsFlyerId = self.appsFlyerId
        user.pickupOTP = self.pickupOTP
        return user
    }
    func isUserObjectValid() -> Bool{
        if  self.phoneNumber == 0  ||
            self.contactNo == nil || self.contactNo == 0 ||
            self.userName == "" ||
            self.gender == ""{
            
            return false
        }
        return true
    }
    public override var description: String {
        return "phoneNumber: \(String(describing: self.phoneNumber))," + "userName: \(String(describing: self.userName))," + " gender: \( String(describing: self.gender))," + " password: \(String(describing: self.password))," + " status: \(String(describing: self.status)),"
            + " referralCode: \(String(describing: self.referralCode))," + "appliedPromoCode: \(String(describing: self.appliedPromoCode))," + "creationDate:\(String(describing: self.creationDate))," + "clientUniqueDeviceId:\(String(describing: self.clientUniqueDeviceId))," + "clientIosKey:\(String(describing: self.clientIosKey))," + "appName:\(String(describing: self.appName))," + "contactNo: \(String(describing: self.contactNo))," + "iosAppVersionName: \( String(describing: self.iosAppVersionName))," + "email: \(String(describing: self.email))," + "primaryArea: \( String(describing: self.primaryArea))," + "primaryAreaLat: \(String(describing: self.primaryAreaLat))," + "primaryAreaLng: \( String(describing: self.primaryAreaLng))," + "primaryRegion:\(String(describing: self.primaryRegion))," + "phoneModel:\(String(describing: self.phoneModel))," + "countryCode: \(String(describing: self.countryCode))," + "uniqueDeviceId:\(String(describing: self.uniqueDeviceId))," + "asksCashTransactions: \(String(describing: self.asksCashTransactions))," + "subscriptionStatus\(String(describing: self.subscriptionStatus))," + "freeRideId: \(String(describing: self.freeRideId))," + "freeRideInitiatedDate: \( String(describing: self.freeRideInitiatedDate))," + "googleAdvertisingId:\(String(describing: self.googleAdvertisingId))," + "appsFlyerId:\(String(describing: self.appsFlyerId))," + "pickupOTP: \(String(describing: pickupOTP))"
    }
}
