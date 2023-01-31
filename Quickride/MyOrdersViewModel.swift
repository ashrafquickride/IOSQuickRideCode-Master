//
//  MyOrdersViewModel.swift
//  Quickride
//
//  Created by HK on 08/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class MyOrdersViewModel{
    
    var placedOrders = [Order]()
    var receivedOrders = [Order]()
    var acceptedOrders = [Order]()
    var segmentControl = 0
    
    func getRecievedOrdersList(){
        QuickShareRestClient.getMyReceivedOrders(ownerId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let orders = Mapper<Order>().mapArray(JSONObject: responseObject!["resultData"]) ?? [Order]()
                var receivedOrders = [Order]()
                var acceptedOrders = [Order]()
                for order in orders{
                    if order.productOrder?.status == Order.PLACED{
                        receivedOrders.append(order)
                    }else{
                        acceptedOrders.append(order)
                    }
                }
                self.receivedOrders = receivedOrders
                self.acceptedOrders = acceptedOrders
            }
            NotificationCenter.default.post(name: .myOrdersRecieved, object: self)
        }
    }
    
    func getMyplacedaOrdersList(){
        QuickShareRestClient.getMyPlacedOrders(borrowerId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let requestedOrdesAndRequirement = Mapper<Order>().mapArray(JSONObject: responseObject!["resultData"]) ?? [Order]()
                self.placedOrders.removeAll()
                for requestOrOrders in requestedOrdesAndRequirement{
                    if requestOrOrders.postedRequest?.listingId != nil{
                        self.placedOrders.append(requestOrOrders)
                    }
                }
            }
            NotificationCenter.default.post(name: .myPlacedOrdersRecieved, object: self)
        }
    }
    
    func updateOrderListAndStatus(productOrder: ProductOrder){
        if let userIdStr = UserDataCache.getInstance()?.userId ,let userId = Int(userIdStr),productOrder.sellerId == userId{
            if productOrder.status == Order.PLACED{
                if let index = receivedOrders.index(where: { $0.productOrder?.id == productOrder.id}) {
                    receivedOrders[index].productOrder = productOrder
                    NotificationCenter.default.post(name: .myOrdersRecieved, object: self)
                }else{
                    getRecievedOrdersList()
                }
            }else{
                if let index = acceptedOrders.index(where: { $0.productOrder?.id == productOrder.id}) {
                    acceptedOrders[index].productOrder = productOrder
                    NotificationCenter.default.post(name: .myOrdersRecieved, object: self)
                }else{
                    getRecievedOrdersList()
                }
            }
        }else{
            if let index = placedOrders.index(where: { $0.productOrder?.id == productOrder.id}) {
                placedOrders[index].productOrder = productOrder
                NotificationCenter.default.post(name: .myPlacedOrdersRecieved, object: self)
            }else{
                getMyplacedaOrdersList()
            }
        }
    }
    
}
