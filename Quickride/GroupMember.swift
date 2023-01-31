//
//  CircleMember.swift
//  Quickride
//
//  Created by KNM Rao on 23/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class GroupMember : NSObject, Mappable {
  
  var id : Double = 0
  var userId : Double = 0
  var groupId : Double = 0
  var groupName :String?
  var type :String?
  var status : String?
  var email :String?
  var requestedUserId : Double?
  var gender :String?
  var imageURI : String?
  var userName : String?
  var supportCall  = UserProfile.SUPPORT_CALL_ALWAYS
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
  static let GROUP_ID="groupId"
  static let GROUP_NAME="groupName"
  static let MEMBER_TYPE="memberType"
  static let MEMBER_STATUS="memberStatus"
  
  required init?(map: Map) {
    
  }
  
    override init(){
        
  }
  init(userId : Double,groupId : Double,groupName : String,type : String,status : String){
       self.userId = userId
       self.groupId = groupId
       self.groupName = groupName
       self.type = type
       self.status = status
  }

  
  func mapping(map: Map) {
    self.id <- map["id"]
    self.userId <- map["userId"]
    self.groupId <- map["groupId"]
    self.groupName <- map["groupName"]
    self.type <- map["type"]
    self.status <- map["status"]
    self.email <- map["email"]
    self.requestedUserId <- map["requestedUserId"]
    self.gender <- map["gender"]
    self.imageURI <- map["imageURI"]
    self.userName <- map["userName"]
    self.supportCall <- map["supportCall"]
    self.verificationStatus <- map["verificationStatus"]
  }
  
  func getParams() -> [String: String]{
    
    var params = [String: String]()
		params[GroupMember.ID] = StringUtils.getStringFromDouble(decimalNumber: id)
    params[GroupMember.USER_ID] = StringUtils.getStringFromDouble(decimalNumber: userId)
    params[GroupMember.GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber: groupId)
		params[GroupMember.GROUP_NAME] = groupName
		params[GroupMember.MEMBER_TYPE] = type
		params[GroupMember.MEMBER_STATUS] = status
		params[UserProfile.FLD_EMAIL] = email
    params[GroupMember.REQUESTED_USERID] = StringUtils.getStringFromDouble(decimalNumber: requestedUserId)
		return params
  }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "userId: \(String(describing: self.userId))," + " groupId: \( String(describing: self.groupId))," + " groupName: \(String(describing: self.groupName))," + " type: \(String(describing: self.type)),"
            + " status: \(String(describing: self.status))," + "email: \(String(describing: self.email))," + " requestedUserId: \(String(describing: self.requestedUserId))," + " gender: \(String(describing: self.gender)),"
            + " imageURI: \(String(describing: self.imageURI))," + "userName: \(String(describing: self.userName)),"
            + " supportCall: \(String(describing: self.supportCall))," + "verificationStatus: \(String(describing: self.verificationStatus)),"
    }
}
