//
//  TaxiPoolRideUpdateTopicListener.swift
//  Quickride
//
//  Created by Ashutos on 28/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

extension NSNotification.Name {
    static let taxiRideStatusReceived = Notification.Name("TaxiRideStatusReceived")
    static let reloadMyTrips = Notification.Name("reloadMyTrips")
    static let taxiRideCreatedFromTOC = Notification.Name("taxiRideCreatedFromTOC")
}
class TaxiPoolRideUpdateTopicListener: TopicListener {
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("\(String(describing: messageObject))")
        if let taxiRidePassengerUpdate = Mapper<TaxiPassengerStatusUpdate>().map(JSONString: messageObject as! String){
            AppDelegate.getAppDelegate().log.debug("Taxi passenger ride update status\(taxiRidePassengerUpdate.status),Taxi ride group Status \(taxiRidePassengerUpdate.taxiRideGroupStatus)")
            TaxiRideDetailsCache.getInstance().updateTaxiRidePassengerStatus(taxiRidePassengerUpdate: taxiRidePassengerUpdate)
        }
    }
}


