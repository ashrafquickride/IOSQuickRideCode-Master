//
//  UserContactNoMask.swift
//  Quickride
//
//  Created by Admin on 30/08/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserContactNoMask : NSObject,Mappable{
   
    var callerNo : String?
    var recieverNo : String?
    var dialNumber : String?
    var virtualNo : String?
    var virtualNumberStatus : String?
    var timeStamp : String?
    var receiverEnabledMasking: Bool?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        callerNo <- map["callerNo"]
        recieverNo <- map["recieverNo"]
        dialNumber <- map["dialNumber"]
        virtualNo <- map["virtualNo"]
        virtualNumberStatus <- map["virtualNumberStatus"]
        timeStamp <- map["timeStamp"]
        receiverEnabledMasking <- map["receiverEnabledMasking"]
    }
    public override var description: String {
        return "callerNo: \(String(describing: self.callerNo))," + "recieverNo: \(String(describing: self.recieverNo))," + " dialNumber: \( String(describing: self.dialNumber))," + " virtualNo: \(String(describing: self.virtualNo))," + " virtualNumberStatus: \(String(describing: self.virtualNumberStatus))," + " timeStamp: \(String(describing: self.timeStamp))," + " receiverEnabledMasking: \(String(describing: self.receiverEnabledMasking)),"
    }
    
}
