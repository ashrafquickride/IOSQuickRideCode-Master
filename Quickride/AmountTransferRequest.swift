//
//  AmountTransferRequest.swift
//  Quickride
//
//  Created by KNM Rao on 11/08/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class AmountTransferRequest :NSObject, Mappable {
  
  var id : Double = 0
  var date : Double = 0
  var reason : String?
  var amount : Double = 0
  var requestorId : Double = 0.0
  var requestorName : String?
  var requestorContactNo :  Double?
  var senderId : Double = 0
  var senderName :  String?
  var senderContactNo :  Double = 0
  
  static let FLD_ID = "id"
  static let FLD_DATE = "date"
  static let FLD_REASON = "reason"
  static let FLD_AMOUNT = "amount"
  static let FLD_REQUESTORID = "requestorId"
  static let FLD_REQUESTERNAME = "requestorName"
  static let FLD_REQUESTERCONTACT = "requestorContactNo"
  static let FLD_SENDERID = "senderId"
  static let FLD_SENDERNAME = "senderName"
  static let FLD_SENDERCONTACT = "senderContactNo"
  static let REJECT_REASON = "rejectreason"
  static let IS_TRANSFER = "isTransfer"

  
  required init?(map: Map) {
    
  }
  override init(){
    
  }
  

  func mapping(map: Map) {
    self.id <- map["id"]
    self.date <- map["date"]
    self.reason <- map["reason"]
    self.amount <- map["amount"]
    self.requestorId <- map["requestorId"]
    self.requestorName <- map["requestorName"]
    self.requestorContactNo <- map["requestorContactNo"]
    self.senderId <- map["senderId"]
    self.senderName <- map["senderName"]
    self.senderContactNo <- map["senderContactNo"]
  }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "date: \(String(describing: self.date))," + " reason: \(String(describing: self.reason))," + " amount: \(String(describing: self.amount))," + " requestorId: \(String(describing: self.requestorId)),"
            + "requestorName: \(String(describing: self.requestorName))," + "requestorContactNo: \(String(describing: self.requestorContactNo))," + "senderId: \(String(describing: self.senderId))," + "senderName: \(String(describing: self.senderName))," + "senderContactNo: \(String(describing: self.senderContactNo)),"
    }
}
