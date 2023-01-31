//
//  ClearPendingBillsViewModel.swift
//  Quickride
//
//  Created by HK on 22/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ClearPendingBillsViewModel{

    var pendingDues = [PendingDue]()
    var totalPendingAmount = 0.0
    var orderId : String?
    
    init(pendingDues: [PendingDue]) {
        self.pendingDues = pendingDues
    }
    
    init() {}
    
    func getTotalAmount(){
        for pendingDue in pendingDues{
            totalPendingAmount += pendingDue.getDueAmount()
        }
        totalPendingAmount = ceil(totalPendingAmount)
    }
    
    func getPendingDueIdsString() -> String{
        var txnIds = [String]()
        for pendingDue in pendingDues{
            txnIds.append(String(pendingDue.id))
        }
       return txnIds.joined(separator: ",")
    }
}
