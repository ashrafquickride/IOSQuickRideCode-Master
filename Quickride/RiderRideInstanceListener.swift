//
//  RiderRideInstanceListener.swift
//  Quickride
//
//  Created by QuickRideMac on 09/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class RiderRideInstanceListener : TopicListener {
    
    
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("onMessageRecieved()")
        let ride:RiderRide = Mapper<RiderRide>().map(JSONString: (messageObject! as? String)!)!
        let rideTimeData: RideTimeData = Mapper<RideTimeData>().map(JSONString: messageObject! as! String)!
        AppDelegate.getAppDelegate().log.debug("\(ride)")
        let startTime = AppUtil.createNSDate(dateString: rideTimeData.startTime)?.getTimeStamp()
        if startTime != nil{
            ride.startTime = startTime!
        }
        ride.expectedEndTime = AppUtil.createNSDate(dateString: rideTimeData.expectedEndTime)?.getTimeStamp()
        RiderRideRestClient.getRiderRide(rideId: ride.rideId, targetViewController: nil) { (responseObject, error) -> Void in
            let result = RestResponseParser<RiderRide>().parse(responseObject: responseObject, error: error)
            MyActiveRidesCache.getRidesCacheInstance()?.addNewRide(ride: result.0 != nil ? result.0! : ride )
        }
    }
}
