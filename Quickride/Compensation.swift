//
//  Compensation.swift
//  Quickride
//
//  Created by Anki on 13/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct Compensation: Mappable{
    
    var compensationAmount = 0.0
    var payingUser = 0.0
    var compensationBenificiers: CompensationBeneficiary?
    var freeCancellationsAvailable = 0
    var validityOfFreeCancellations = 0
    var totalFreeCancellations = 0
    var isSystemWaveOff = false
    
    init?(map: Map) {
        
    }
    mutating func mapping(map:Map){
        compensationAmount <- map["compensationAmount"]
        payingUser <- map["payingUser"]
        compensationBenificiers <- map["compensationBenificiers"]
        freeCancellationsAvailable <- map["freeCancellationsAvailable"]
        validityOfFreeCancellations <- map["validityOfFreeCancellations"]
        totalFreeCancellations <- map["totalFreeCancellations"]
        isSystemWaveOff <- map["isSystemWaveOff"]
    }
}
