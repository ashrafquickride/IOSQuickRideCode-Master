//
//  TaxipoolInviteStatusUpdate.swift
//  Quickride
//
//  Created by HK on 28/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxipoolInviteStatusUpdate: TopicListener {
    
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("Taxi pool invite status\(String(describing: messageObject))")
        if let taxiInvite = Mapper<TaxiPoolInvite>().map(JSONString: messageObject as! String){
            MyActiveTaxiRideCache.getInstance().updateTaxipoolInvite(taxiInvite: taxiInvite)
        }
    }
}
