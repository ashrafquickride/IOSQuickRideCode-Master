//
//  CircleMember.swift
//  Quickride
//
//  Created by KNM Rao on 23/02/17.
//  Copyright © 2017 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

class GroupMember : Mappable {
  
  var id : Double = 0
  var userId : Double = 0
  var circleId : Double = 0
  var circleName :String?
  var type :String?
  var status : String?
  var email :String?
  var requestedUserId : Double?
  var gender :String?
  var imageURI : String?
  var userName : String?
  var supportCall : String?
  var verificationStatus : Bool = false
  
  
  static let MEMBER_TYPE_MEMBER="MEMBER";
  static let MEMBER_TYPE_ADMIN="ADMIN";
  static let REQUESTED_USERID="requestedUserId";
  static let MEMBER_STATUS_PENDING="PENDING";
  static let MEMBER_STATUS_CONFIRMED="CONFIRMED";
  static let MEMBER_STATUS_REMOVED="REMOVED";
  static let MEMBER_STATUS_LEFT="LEFT";
  static let MEMBER_STATUS_REJECTED="REJECTED";
		
  
  static let ID="id"
  static let USER_ID="userId"
  static let CIRCLE_ID="groupId"
  static let CIRCLE_NAME="groupName"
  static let MEMBER_TYPE="memberType"
  static let MEMBER_STATUS="memberStatus"
  
  required init?(map: Map) {
    
  }
  
  func mapping(map: Map) {
    self.id <- map["id"]
    self.userId <- map["id"]
    self.circleId <- map["id"]
    self.circleName <- map["id"]
    self.type <- map["id"]
    self.status <- map["id"]
    self.email <- map["id"]
    self.requestedUserId <- map["id"]
    self.gender <- map["id"]
    self.imageURI <- map["id"]
    self.userName <- map["id"]
    self.supportCall <- map["id"]
    self.verificationStatus <- map["id"]
  }
  
  func getParams() -> [String: String]{
    
    var params = [String: String]()
		params[CircleMember.ID] = StringUtils.getStringFromDouble(decimalNumber: id)
    params[CircleMember.USER_ID] = StringUtils.getStringFromDouble(decimalNumber: userId)
    params[CircleMember.CIRCLE_ID] = StringUtils.getStringFromDouble(decimalNumber: circleId)
		params[CircleMember.CIRCLE_NAME] = circleName
		params[CircleMember.MEMBER_TYPE] = type
		params[CircleMember.MEMBER_STATUS] = status
		params[UserProfile.FLD_EMAIL] = email
    params[CircleMember.REQUESTED_USERID] = StringUtils.getStringFromDouble(decimalNumber: requestedUserId)
		return params
  }
}
