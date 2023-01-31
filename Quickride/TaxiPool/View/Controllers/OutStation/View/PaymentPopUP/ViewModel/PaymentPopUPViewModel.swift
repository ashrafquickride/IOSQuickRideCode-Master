//
//  PaymentPopUPViewModel.swift
//  Quickride
//
//  Created by Ashutos on 02/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PaymentPopUPViewModel {
    
    var estimateFareAmount: Double = 0.0
    var selectedPayAmountIndex = 0
    
    static var refundAndCancelOutstationURL = "https://quickride.in/outstation_cp.php"
    
    init(estimateFareAmount: Double) {
        self.estimateFareAmount = estimateFareAmount
    }
    
    func isWalletLinked() -> Bool {
        if UserDataCache.getInstance()?.getDefaultLinkedWallet() != nil {
            return true
        }else{
            return false
        }
    }
}
