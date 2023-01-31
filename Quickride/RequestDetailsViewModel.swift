//
//  RequestDetailsViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 06/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RequestDetailsViewModel{
    
    //MARK: Variables
    var order: Order?
    
    init(order: Order) {
        self.order = order
    }
    init() {}
    
    func acceptOrder(){
        QuickShareRestClient.acceptRecievedOrder(orderId: order?.productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let productOrder = Mapper<ProductOrder>().map(JSONObject: responseObject!["resultData"])
                self.order?.productOrder = productOrder
               NotificationCenter.default.post(name: .receivedOrderAccepted, object: nil)
            } else {
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: self, userInfo: userInfo)
            }
        }
    }
    func rejectOrder(){
        QuickShareRestClient.rejectRecievedOrder(orderId: order?.productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                NotificationCenter.default.post(name: .receivedOrderRejected, object: nil)
            } else {
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: self, userInfo: userInfo)
            }
        }
    }
}
