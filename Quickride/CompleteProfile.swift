//
//  CompleteProfile.swift
//  Quickride
//
//  Created by KNM Rao on 24/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class CompleteProfile : NSObject, Mappable {
  
  var user : User?
  var userProfile : UserProfile?
  var allowCallsFrom : String?
  var vehicles : [Vehicle]?
  var account : Account?
  var notificationSettings : UserNotificationSetting?
  var blockedUsers : [BlockedUser]?
  var groups : [Group]?
  var userPreferences : UserPreferences?
  var enableChatAndCall : Bool = true
  var profileVerificationData : ProfileVerificationData?
  var userPreferredRoutes : [UserPreferredRoute]?
  var nomineeDetails : NomineeDetails?
  var linkedWallets : [LinkedWallet]?
  var userPreferredPickupDrops = [UserPreferredPickupDrop]()
  var userSelfAssessmentCovid: UserSelfAssessmentCovid?
  var callCreditDetails : CallCreditDetails?
    
    
    init(user : User,userProfile : UserProfile,vehicles : [Vehicle],account : Account,notificationSettings : UserNotificationSetting?,blockedUsers : [BlockedUser]?,groups : [Group]?){
    self.user = user
    self.userProfile = userProfile
    self.vehicles = vehicles
    self.account = account
    self.blockedUsers = blockedUsers
    self.groups = groups
    self.notificationSettings = notificationSettings
  }
  
  public required init?(map: Map) {
    
  }
  
  public func mapping(map: Map) {
    self.user  <- map["user"]
    self.userProfile <- map["userProfile"]
    self.vehicles <- map["vehicles"]
    self.account <- map["account"]
    self.notificationSettings <- map["notificationSettings"]
    self.blockedUsers <- map["blockedUsers"]
    self.userPreferences <- map["userPreferences"]
    self.groups <- map["userGroups"]
    self.allowCallsFrom <- map["allowCallsFrom"]
    self.enableChatAndCall <- map["enableChatAndCall"]
    self.profileVerificationData <- map["profileVerificationData"]
    self.userPreferredRoutes <- map["userPreferredRoutes"]
    self.nomineeDetails <- map["nomineeDetails"]
    self.linkedWallets <- map["linkedWallets"]
    self.userPreferredPickupDrops <- map["userPreferredPickupDrops"]
    self.userSelfAssessmentCovid <- map["userSelfAssessmentCovid"]
      self.callCreditDetails <- map["callCreditDetails"]
  }
    public override var description: String {
        return "user: \(String(describing: self.user))," + "userProfile: \(String(describing: self.userProfile))," + " allowCallsFrom: \( String(describing: self.allowCallsFrom))," + " vehicles: \(String(describing: self.vehicles))," + " account: \(String(describing: self.account)),"
            + " notificationSettings: \(String(describing: self.notificationSettings))," + "blockedUsers: \(String(describing: self.blockedUsers)),"
            + " groups: \(String(describing: self.groups))," + "userPreferences: \(String(describing: self.userPreferences)),"
            + " enableChatAndCall: \(String(describing: self.enableChatAndCall))," + "profileVerificationData: \(String(describing: self.profileVerificationData)),"
        + " linkedWallet: \(String(describing: self.linkedWallets))," + "userPreferredRoutes: \(String(describing: self.userPreferredRoutes))," + "nomineeDetails: \(String(describing: self.nomineeDetails))," + "userPreferredPickupDrop: \(String(describing: self.userPreferredPickupDrops))," + "userSelfAssessmentCovid: \(String(describing: userSelfAssessmentCovid))," + "CallCreditDetails: \(String(describing: callCreditDetails)),"
    }
}
