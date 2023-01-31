//
//  SellerOrderDetailsViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 07/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class SellerOrderDetailsViewModel{
    
    var order: Order?
    var isFromMyOrder = false
    var returnOtp: String?
    var invoice: ProductOrderInvoice?
    var showCancelOption = true
    
    init(order: Order,isFromMyOrder: Bool) {
        self.order = order
        self.isFromMyOrder = isFromMyOrder
    }
    
    init() {}
    
    func getInvoice(){
        QuickShareRestClient.getInvoiceForOrder(orderId: order?.productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.invoice = Mapper<ProductOrderInvoice>().map(JSONObject: responseObject!["resultData"])
                NotificationCenter.default.post(name: .invoiceRecieved, object: nil)
            }
        }
    }
    
    func cancelOrder(reason: String){
        QuickShareRestClient.rejectRecievedOrder(orderId: order?.productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                var userInfo = [String : Any]()
                userInfo["order"] = self.order
                NotificationCenter.default.post(name: .receivedOrderRejected, object: nil, userInfo: userInfo)
            } else {
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
}
