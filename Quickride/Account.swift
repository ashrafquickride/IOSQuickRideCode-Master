//
//  Account.swift
//  Quickride
//
//  Created by KNM Rao on 04/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public  class Account : NSObject,Mappable {
  
  var userId : Double?
  var balance : Double?
  var reserved : Double?
  var status : String?
  var rewardsPoints = 0.0
  var purchasedPoints = 0.0
  var earnedPoints = 0.0
  
  static var TRANSFER_USER : String = "transferUserId"
  static var TRANSFEREE_USER : String = "transfereeUserId"
  static var POINTS : String = "points"
  
  static var TRANSFEREE_NAME = "transfereeName"
  static var REASON = "reason"
  static var ACTIVE : String = "ACTIVE";
  static var INACTIVE : String = "INACTIVE";
  static var LOCKED : String = "LOCKED";
  static var ID : String = "id";
  static var BALANCE : String = "balance";
  static var RESERVED : String = "reserved";
  static var STATUS : String = "status";
  static let FLD_ACCOUNT_ID = "accountid"
  static let FLD_USER_ID = "userId"
  static let FLD_POINTS = "points"
  static let ORDERID = "orderid"
  static let RECHARGE_SOURCE_TYPE = "source"
  static let CONTACT_NO = "contactNo"
  static let DEBIT = "Debit"
  
  static let REQUEST_DATE = "date"
  static let REQUESTOR_USER_ID = "requestorUserId"
  static let REQUESTER_NAME = "requestorName"
  static let REQUESTER_CONTACT_NO = "requestorContactNo"
  static let SENDER_USER_ID = "SenderUserId"
  static let SENDER_NAME = "senderName"
  static let SENDER_CONTACT_NO = "senderContactNo"
  static let RECHARGED_AMOUNT = "rechargedamount"
  static let PASS = "pass"
  static let simplData = "sessionKey"
  static let codeVerifier = "codeVerifier"
  static let authCode = "authCode"
  static let clientId = "clientId"
  static let redirectUri = "redirectUri"
  static let amount = "amount"
  static let orderId = "orderId"
  static let channelIdentifier = "channelIdentifier"
  static let iosUser = "iosUser"
  static let MOBILE_NO = "mobileNo"
  static let OTP = "otp"
  static let firstName = "firstName"
  static let lastName = "lastName"
  static let mobile = "mobile"
  static let email_id = "email_id"
  static let addr_1 = "addr_1"
  static let addr_2 = "addr_2"
  static let addr_3 = "addr_3"
  static let city = "city"
  static let state = "state"
  static let pinCode = "pinCode"
  static let emp_code = "emp_code"
  static let fromDate = "fromDate"
  static let toDate = "toDate"
  static let email = "email"
  static let vpaAddress = "vpaAddress"
  static let txnIds = "txnIds"
  static let type = "type"
  static let salutation = "salutation"
  static let dob = "dob"
  static let newprofile = "newprofile"
  
    public override init(){
    
  }
  
  required public init?(map: Map) {
    
  }
  
  public func mapping(map: Map) {
    userId <- map["userId"]
    balance <- map["balance"]
    status <- map["status"]
    reserved <- map["reserved"]
    rewardsPoints <- map["rewardsPoints"]
    earnedPoints <- map["earnedPoints"]
    purchasedPoints <- map["purchasedPoints"]
  }
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "balance: \(String(describing: self.balance))," + " reserved: \( String(describing: self.reserved))," + " status: \(String(describing: self.status))," + " rewardsPoints: \(String(describing: self.rewardsPoints)),"
            + " purchasedPoints: \(String(describing: self.purchasedPoints))," + "earnedPoints: \(String(describing: self.earnedPoints)),"
    }
}
