//
//  RiderBill.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 11/9/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class TripReport: NSObject, Mappable {
  
  var rideid:Double?
  var riderid:Double?
  var riderName:String?
  var totalEarnings:Double?
  var bills:[Bill]?
  var fromlocation:String?
  var tolocation:String?
  var accountBalance:Double?
  var actualEndTime:Double?
  var actualStartTime:Double?
  var netEarnings:Double?
  var totalTax : Double?
  
  override init() {
    
  }
  
  required init?(map: Map) {
    
  }
  
  init( bill : Bill) {
    rideid = bill.rideId
    riderid = bill.billByUserId
    riderName = bill.billByUserName
    totalEarnings = bill.netAmountPaid
    actualEndTime = bill.date
    fromlocation = bill.startLocation
    tolocation = bill.endLocation
    accountBalance = bill.accountBalance
    bills = [Bill]()
    bills!.append(bill)
    netEarnings = bill.amount
    totalTax = bill.tax
  }
  
  func mapping(map: Map) {
    rideid <- map["rideid"]
    riderid <- map["riderid"]
    riderName <- map["riderName"]
    totalEarnings <- map["totalEarnings"]
    fromlocation <- map["fromlocation"]
    bills <- map["bills"]
    tolocation <- map["tolocation"]
    accountBalance <- map["accountBalance"]
    actualEndTime <- map["actualEndTime"]
    actualStartTime <- map["actualStartTime"]
    netEarnings <- map["netEarnings"]
    totalTax <- map["totalTax"]
  }
    public override var description: String {
        return "rideid: \(String(describing: self.rideid))," + "riderid: \(String(describing: self.riderid))," + " riderName: \( String(describing: self.riderName))," + " totalEarnings: \(String(describing: self.totalEarnings))," + " bills: \(String(describing: self.bills)),"
            + " fromlocation: \(String(describing: self.fromlocation))," + "tolocation: \(String(describing: self.tolocation))," + "accountBalance:\(String(describing: self.accountBalance))," + "actualEndTime:\(String(describing: self.actualEndTime))," + "actualStartTime:\(String(describing: self.actualStartTime))," + "netEarnings:\(String(describing: self.netEarnings))," + "totalTax: \(String(describing: self.totalTax)),"
    }
}
