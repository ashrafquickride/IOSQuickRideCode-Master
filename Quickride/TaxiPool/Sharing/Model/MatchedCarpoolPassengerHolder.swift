//
//  MatchedCarpoolPassengerHolder.swift
//  Quickride
//
//  Created by HK on 19/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

struct MatchedCarpoolPassengerHolder {
    
    var queryTime: NSDate?
    var queryResult = [MatchingTaxiPassenger]()
    
    init(queryTime: NSDate,queryResult: [MatchingTaxiPassenger]) {
        self.queryTime = queryTime
        self.queryResult = queryResult
    }
}
