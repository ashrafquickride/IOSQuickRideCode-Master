//
//  EncashRequest.swift
//  Quickride
//
//  Created by Anki on 13/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class EncashRequest:NSObject,Mappable{
  
  var id:Double?
  var refId:Double?
  var phonenumber: Double?
  var name: String?
  var email: String?
  var reqDate: NSDate?
  var processedDate:NSDate?
  var comments:String?
  var reviewBy:String?
  var address:String?
  var dispatchRef:String?
  var status:String?
  var value:Int?
  
  //status types
  static var ENCASH_REQUEST_TYPE_OPEN:String = "Open";
  static var ENCASH_REQUEST_TYPE_WAITING:String = "Waiting";
  static var ENCASH_REQUEST_TYPE_REJECTED:String = "Rejected";
  static var ENCASH_REQUEST_TYPE_PROCESSED:String = "Processed";
  
  //Column names
  static var ID:String = "id";
  static var REFID:String = "refId";
  static var PHONE:String = "phone";
  static var NAME:String = "name";
  static var EMAIL:String = "email";
  static var REQDATE:String = "reqDate";
  static var PROCESSEDDATE:String = "processedDate";
  static var COMMENTS:String = "comments";
  static var REVIEWBY:String = "reviewBy";
  static var ADDRESS:String = "address";
  static var DISPATCHREF:String = "dispatchRef";
  static var STATUS:String = "status";
  static var VALUE:String = "value";
  
  required init(map:Map){
    
  }
  
  func mapping(map:Map){
    id <- map["id"]
    refId <- map["refId"]
    phonenumber <- map["phone"]
    name <- map["name"]
    email <- map["email"]
    reqDate <- map["reqDate"]
    processedDate <- map["processedDate"]
    comments <- map["comments"]
    reviewBy <- map["reviewBy"]
    address <- map["address"]
    dispatchRef <- map["dispatchRef"]
    status <- map["status"]
    value <- map["value"]
  }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "refId: \(String(describing: self.refId))," + " phonenumber: \( String(describing: self.phonenumber))," + " name: \(String(describing: self.name))," + " email: \(String(describing: self.email))," + " reqDate: \(String(describing: self.reqDate))," + " processedDate: \(String(describing: self.processedDate))," + "reqDate: \(String(describing: self.reqDate))," + "reqDate: \(String(describing: self.reqDate)),"
    }
}


		
