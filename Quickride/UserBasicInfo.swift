//
//  UserBasicInfo.swift
//  Quickride
//
//  Created by QuickRideMac on 10/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserBasicInfo : NSObject,Mappable{
  
  var userId : Double?
  var imageURI : String?
  var gender : String?
  var name : String?
  var companyName : String?
  var rating : Float = 0
  var noOfReviews : Int = 0
  var callSupport = UserProfile.SUPPORT_CALL_ALWAYS
  var verificationStatus = false
  var contactNoString : String?
  var enableChatAndCall : Bool = true
  var profileVerificationData : ProfileVerificationData?
  
  override init() {
    
  }
  init( userId : Double, gender : String?,userName : String, imageUri : String?,  companyName : String?, rating : Float, noOfReviews : Int, callSupport : String, verificationStatus : Bool) {
    self.userId = userId
    if gender == nil{
      self.gender = User.USER_GENDER_UNKNOWN
    }else{
      self.gender = gender
    }
    self.name = userName
    self.imageURI = imageUri
    self.companyName = companyName
    self.rating = rating
    self.noOfReviews = noOfReviews
    self.callSupport = callSupport
    self.verificationStatus = verificationStatus
  }
    init( userId : Double, gender : String?,userName : String, imageUri : String?, callSupport : String) {
        self.userId = userId
        if  gender == nil{
            self.gender = User.USER_GENDER_UNKNOWN
        }else{
            self.gender = gender
        }
        self.name = userName
        self.imageURI = imageUri
        self.callSupport = callSupport
    }


    required init?(map: Map) {
    
  }
  func mapping(map: Map) {
    self.userId <- map["userId"]
    self.imageURI <- map["imageURI"]
    self.gender <- map["gender"]
    self.name <- map["name"]
    self.companyName <- map["companyName"]
    self.rating <- map["rating"]
    self.noOfReviews <- map["noOfReviews"]
    self.callSupport <- map["callSupport"]
    self.verificationStatus <- map["verificationStatus"]
    self.enableChatAndCall <- map["enableChatAndCall"]
    self.profileVerificationData <- map["profileVerificationData"]
  }
    static func validateUserBasicInfo(userBasicInfo : UserBasicInfo?) -> Bool
    {
        if userBasicInfo == nil || userBasicInfo!.name == nil || userBasicInfo!.gender == nil || userBasicInfo!.userId == nil
        {
            return false
        }
        return true
    }
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "imageURI: \(String(describing: self.imageURI))," + " gender: \( String(describing: self.gender))," + " name: \(String(describing: self.name))," + " companyName: \(String(describing: self.companyName)),"
            + " rating: \(String(describing: self.rating))," + "noOfReviews: \(String(describing: self.noOfReviews))," + "callSupport:\(String(describing: self.callSupport))," + "verificationStatus:\(String(describing: self.verificationStatus))," + "enableChatAndCall: \(String(describing: self.enableChatAndCall))," + " profileVerificationData: \( String(describing: self.profileVerificationData)),"
    }
}
