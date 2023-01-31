//
//  TaxiRideCreatedTopicListener.swift
//  Quickride
//
//  Created by Rajesab on 24/05/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiRideCreatedTopicListener: TopicListener {
    
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("Taxi ride created \(String(describing: messageObject))")
        if let taxiRidePassengerUpdate = Mapper<TaxiPassengerStatusUpdate>().map(JSONString: messageObject as! String){
            TaxiPoolRestClient.getTaxiRidePasssengerFromServer(taxiRidePassengerId: taxiRidePassengerUpdate.taxiRidePassengerId) { responseObject, error in
                let result = RestResponseParser<TaxiRidePassenger>().parse(responseObject: responseObject, error: error)
                if let taxiRidePassenger = result.0 {
                    MyActiveTaxiRideCache.getInstance().addNewRideToCache(taxiRidePassenger: taxiRidePassenger)
                    NotificationCenter.default.post(name: .taxiRideCreatedFromTOC, object: nil)
                    RideManagementUtils.NavigateToRespectivePage(oldViewController: nil, handler: nil)
                }
            }
        }
    }
}

