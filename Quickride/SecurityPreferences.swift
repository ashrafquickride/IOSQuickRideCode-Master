//
//  SecurityPreferences.swift
//  Quickride
//
//  Created by KNM Rao on 07/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class SecurityPreferences: NSObject, Mappable,NSCopying{
  
  var blockedUsers :[BlockedUser]?
  var userId : Double?
  var allowCallsFrom : String?
  var shareRidesWithUnVeririfiedUsers : Bool?
  var shareRidesWithSameGenderUsersOnly : Bool?
  var shareRidesWithUsersFromMyCompanyOnly : Bool?
  var shareRidesWithUsersFromSameComapnyGroupOnly : Bool?
  var emergencyOnNonCompletionOfRideOnTime = false
  var emergencyOnRideGiverDeviatesRoute = false
  var allowChatAndCallFromUnverifiedUsers = true
  var emergencyContact :String?
  var numSafeguard : String?
    
  static let USER_ID = "userId"
  static let ALLOW_CALLS_FROM = "allowCallsFrom"
  static let SHARE_RIDES_WITH_UNVERIRIFIED_USERS = "shareRidesWithUnVeririfiedUsers"
  static let SHARE_RIDES_WITH_SAME_GENDER_USERS_ONLY = "shareRidesWithSameGenderUsersOnly"
  static let SHARE_RIDES_WITH_USERS_FROM_MY_COMPANY_ONLY = "shareRidesWithUsersFromMyCompanyOnly"
  static let SHARE_RIDES_WITH_USERS_FROM_SAME_COMAPNY_GROUP_ONLY = "shareRidesWithUsersFromSameComapnyGroupOnly"
  static let EMERGENCY_CONTACT = "emergencyContact"
  static let ALLOW_CALL_ALWAYS = "1"
  static let ALLOW_CALL_AFTER_JOINED = "2"
  static let ALLOW_CALL_NEVER = "0"
  static let SAFEGAURD_STATUS_DEFAULT = "default"
  static let SAFEGAURD_STATUS_DIRECT = "direct"
  static let SAFEGAURD_STATUS_VIRTUAL = "virtual"
  static let VIRTUAL_CALL_STATUS = "virtualCallStatus"
  
  required init?(map: Map) {
    
  }
  override init() {
    if QRSessionManager.getInstance()?.getUserId() != nil{
        userId = Double(QRSessionManager.getInstance()!.getUserId())
    }
   let user = UserDataCache.getInstance()?.currentUser
    if user != nil{
        if User.USER_GENDER_FEMALE == user!.gender
        {
            allowCallsFrom = SecurityPreferences.ALLOW_CALL_AFTER_JOINED
            shareRidesWithUnVeririfiedUsers = false
        }
        else
        {
            allowCallsFrom = SecurityPreferences.ALLOW_CALL_ALWAYS
            shareRidesWithUnVeririfiedUsers = true
        }
    }else{
        allowCallsFrom = SecurityPreferences.ALLOW_CALL_AFTER_JOINED
        shareRidesWithUnVeririfiedUsers = false
    }
   
    shareRidesWithUsersFromMyCompanyOnly = false
    shareRidesWithUsersFromMyCompanyOnly = false
    shareRidesWithSameGenderUsersOnly = false
    shareRidesWithUsersFromSameComapnyGroupOnly = false
  }
  
  func mapping(map: Map) {
    self.blockedUsers <- map["blockedUsers"]
    self.userId <- map["userId"]
    self.allowCallsFrom <- map["allowCallsFrom"]
    self.shareRidesWithUnVeririfiedUsers <- map["shareRidesWithUnVeririfiedUsers"]
    self.shareRidesWithSameGenderUsersOnly <- map["shareRidesWithSameGenderUsersOnly"]
    self.shareRidesWithUsersFromMyCompanyOnly <- map["shareRidesWithUsersFromMyCompanyOnly"]
    self.shareRidesWithUsersFromSameComapnyGroupOnly <- map["shareRidesWithUsersFromSameComapnyGroupOnly"]
    self.emergencyContact <- map["emergencyContact"]
    self.emergencyOnNonCompletionOfRideOnTime <- map["emergencyOnNonCompletionOfRideOnTime"]
    self.emergencyOnRideGiverDeviatesRoute <- map["emergencyOnRideGiverDeviatesRoute"]
    self.allowChatAndCallFromUnverifiedUsers <- map["allowChatAndCallFromUnverifiedUsers"]
    self.numSafeguard <- map["numSafeguard"]
  }
  func  getParamsMap() -> [String : String] {
    var params : [String : String] = [String : String]()
    params["userId"] =  StringUtils.getStringFromDouble(decimalNumber: userId)
    params["allowCallsFrom"] = allowCallsFrom
    params["shareRidesWithUnVeririfiedUsers"] = String(shareRidesWithUnVeririfiedUsers!)
    params["shareRidesWithSameGenderUsersOnly"] = String(shareRidesWithSameGenderUsersOnly!)
    params["shareRidesWithUsersFromMyCompanyOnly"] = String(shareRidesWithUsersFromMyCompanyOnly!)
    params["shareRidesWithUsersFromSameComapnyGroupOnly"] = String(shareRidesWithUsersFromSameComapnyGroupOnly!)
    params["emergencyOnNonCompletionOfRideOnTime"] = String(emergencyOnNonCompletionOfRideOnTime)
    params["emergencyOnRideGiverDeviatesRoute"] = String(emergencyOnRideGiverDeviatesRoute)
    params["allowChatAndCallFromUnverifiedUsers"] = String(allowChatAndCallFromUnverifiedUsers)
    if self.emergencyContact != nil{
       params["emergencyContact"] = self.emergencyContact!
    }else{
       params["emergencyContact"] = nil
    }
    params["numSafeguard"] = numSafeguard
    return params
  }
   func copy(with zone: NSZone? = nil) -> Any {
    let securityPreferences = SecurityPreferences()
    securityPreferences.blockedUsers = self.blockedUsers
    securityPreferences.userId = self.userId
    securityPreferences.allowCallsFrom = self.allowCallsFrom
    securityPreferences.shareRidesWithUnVeririfiedUsers = self.shareRidesWithUnVeririfiedUsers
    securityPreferences.shareRidesWithSameGenderUsersOnly = self.shareRidesWithSameGenderUsersOnly
    securityPreferences.shareRidesWithUsersFromMyCompanyOnly = self.shareRidesWithUsersFromMyCompanyOnly
    securityPreferences.shareRidesWithUsersFromSameComapnyGroupOnly = self.shareRidesWithUsersFromSameComapnyGroupOnly
    securityPreferences.emergencyContact = self.emergencyContact
    securityPreferences.emergencyOnNonCompletionOfRideOnTime = self.emergencyOnNonCompletionOfRideOnTime
    securityPreferences.emergencyOnRideGiverDeviatesRoute = self.emergencyOnRideGiverDeviatesRoute
    securityPreferences.allowChatAndCallFromUnverifiedUsers = self.allowChatAndCallFromUnverifiedUsers
    securityPreferences.numSafeguard = self.numSafeguard
    return securityPreferences
  }
    public override var description: String {
        return "blockedUsers: \(String(describing: self.blockedUsers))," + "userId: \(String(describing: self.userId))," + " allowCallsFrom: \(String(describing: self.allowCallsFrom))," + " shareRidesWithUnVeririfiedUsers: \(String(describing: self.shareRidesWithUnVeririfiedUsers))," + " shareRidesWithSameGenderUsersOnly: \(String(describing: self.shareRidesWithSameGenderUsersOnly)),"
            + " shareRidesWithUsersFromMyCompanyOnly: \(String(describing: self.shareRidesWithUsersFromMyCompanyOnly))," + "shareRidesWithUsersFromSameComapnyGroupOnly: \(String(describing: self.shareRidesWithUsersFromSameComapnyGroupOnly))," + "emergencyOnNonCompletionOfRideOnTime:\(String(describing: self.emergencyOnNonCompletionOfRideOnTime))," + "emergencyOnRideGiverDeviatesRoute:\(String(describing: self.emergencyOnRideGiverDeviatesRoute))," + "allowChatAndCallFromUnverifiedUsers:\(String(describing:self.allowChatAndCallFromUnverifiedUsers))," + "emergencyContact:\(String(describing: self.emergencyContact))," + "numSafeguard:\(String(describing: self.numSafeguard))"
    }
}
