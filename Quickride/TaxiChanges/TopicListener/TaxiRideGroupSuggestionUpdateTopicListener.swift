//
//  TaxiRideGroupSuggestionUpdateTopicListener.swift
//  Quickride
//
//  Created by QR Mac 1 on 26/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiRideGroupSuggestionUpdateTopicListener: TopicListener {
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("\(String(describing: messageObject))")
        if let taxiGroupSuggestionUpdate = Mapper<TaxiRideGroupSuggestionUpdate>().map(JSONString: messageObject as! String),taxiGroupSuggestionUpdate.action == TaxiRideGroupSuggestionUpdate.DRIVER_WITH_HIGHER_FARE_AVAILABLE{
            TaxiRideDetailsCache.getInstance().updateTaxiGroupSuggestionStatus(taxiRideGroupSuggestionUpdate: taxiGroupSuggestionUpdate)
        }
    }
}
