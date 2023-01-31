//
//  TaxiGroupUpdateTopicListener.swift
//  Quickride
//
//  Created by Quick Ride on 2/4/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiGroupUpdateTopicListener: TopicListener {
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("Taxi Group update status\(String(describing: messageObject))")
        if let taxiGroupUpdateStatus = Mapper<TaxiGroupUpdateStatus>().map(JSONString: messageObject as! String){
            TaxiRideDetailsCache.getInstance().updateTaxiRideGroupStatus(taxiRideGroupId: taxiGroupUpdateStatus.taxiRideGroupId)
        }
    }
}
