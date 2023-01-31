//
//  ResponseError.swift
//  Quickride
//
//  Created by KNM Rao on 18/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class ResponseError : NSObject,Mappable{
  
  var errorCode : Int?
  var httpStatusCode : Int?
  var developerMessage : String?
  var userMessage : String?
  var hintForCorrection : String?
  var extraInfo: [String: Any]?
  
    static var TOTAL_PENDING = "Total"
    static var TOTAL_RIDE_POINTS = "Total Ride Points"
    static var PAID_POINTS = "Paid Points"
    static var DISCOUNT_POINTS = "Discount Points"
    static var ORDER_ID = "OrderId"
    static var INSURANCE_POINTS = "InsurancePoints"
    
    override init(){
    
  }
  
  init(errorCode : Int?, userMessage : String?) {
    self.errorCode = errorCode
    self.userMessage = userMessage
  }
  init(userMessage : String) {
    self.userMessage = userMessage
  }
  
  public required init?(map: Map) {
    
  }
  
  public func mapping(map: Map) {
    errorCode <- map["errorCode"]
    httpStatusCode <- map["httpStatusCode"]
    developerMessage <- map["developerMsg"]
    userMessage <- map["userMsg"]
    hintForCorrection <- map["hintForCorrection"]
    extraInfo <- map["extraInfo"]
  }
    public override var description: String {
        return "errorCode: \(String(describing: self.errorCode))," + "httpStatusCode: \(String(describing: self.httpStatusCode))," + " developerMessage: \( String(describing: self.developerMessage))," + " userMessage: \(String(describing: self.userMessage))," + " hintForCorrection: \(String(describing: self.hintForCorrection))," + "extraInfo: \(String(describing: self.extraInfo))"
    }
}
