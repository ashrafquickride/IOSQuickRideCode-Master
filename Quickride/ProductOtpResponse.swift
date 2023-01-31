//
//  ProductOtpResponse.swift
//  Quickride
//
//  Created by QR Mac 1 on 06/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct ProductOtpResponse: Mappable {
    
    var otp: String?
    var paymentResponse: PaymentResponse?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.otp <- map["otp"]
        self.paymentResponse <- map["paymentResponse"]
    }
}
