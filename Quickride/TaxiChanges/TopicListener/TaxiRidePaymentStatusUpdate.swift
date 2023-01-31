//
//  TaxiRidePaymentStatusUpdate.swift
//  Quickride
//
//  Created by Rajesab on 27/07/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


class TaxiRidePaymentStatusUpdate: TopicListener {
    
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("Taxi ride created \(String(describing: messageObject))")
        if let paymentStatusUpdate = Mapper<PaymentStatusUpdate>().map(JSONString: messageObject as! String){
            var userInfo = [String: Any]()
            userInfo["PaymentStatusUpdate"] = paymentStatusUpdate
            NotificationCenter.default.post(name: .taxiPaymentStatusUpdated, object: nil, userInfo: userInfo)
        }
    }
}

