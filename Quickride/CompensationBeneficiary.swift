//
//  CompensationBeneficiary.swift
//  Quickride
//
//  Created by Anki on 13/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct CompensationBeneficiary: Mappable{
  
  private var beneficiaryID: Double?
  private var amount: Double?
  
    init?(map: Map) {
        
    }
    
  mutating func mapping(map:Map){
    beneficiaryID  <- map["beneficiaryID"]
    amount <- map["amount"]
  }
    public var description: String {
        return "beneficiaryID: \(String(describing: self.beneficiaryID))," + "amount: \(String(describing: self.amount)),"
    }
}
