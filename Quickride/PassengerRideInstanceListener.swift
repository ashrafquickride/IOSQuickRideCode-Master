//
//  PassengerRideInstanceListener.swift
//  Quickride
//
//  Created by QuickRideMac on 09/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class PassengerRideInstanceListener : TopicListener{
    
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("onMessageRecieved()")
        let ride:PassengerRide = Mapper<PassengerRide>().map(JSONString: (messageObject! as? String)!)!
        let rideTimeData: RideTimeData = Mapper<RideTimeData>().map(JSONString: (messageObject! as? String)!)!
        AppDelegate.getAppDelegate().log.debug("\(ride)")
        AppDelegate.getAppDelegate().log.debug("\(rideTimeData)")
        let startTime = AppUtil.createNSDate(dateString: rideTimeData.startTime)?.getTimeStamp()
        if startTime != nil{
            ride.startTime = startTime!
        }
        ride.expectedEndTime = AppUtil.createNSDate(dateString: rideTimeData.expectedEndTime)?.getTimeStamp()
        PassengerRideServiceClient.getPassengerRide(rideId: ride.rideId, targetViewController: nil) { (responseObject, error) -> Void in
            let result = RestResponseParser<PassengerRide>().parse(responseObject: responseObject, error: error)
            MyActiveRidesCache.getRidesCacheInstance()?.addNewRide(ride: result.0 != nil ? result.0! : ride )
        }
        
    }
}
public class RideTimeData : NSObject,Mappable {
    var startTime : String?
    var expectedEndTime : String?
    var pickupTime : String?
    var dropTime : String?
    var startDate : String?
    var passengerReachTimeTopickup : String?
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        startTime <- map["startTime"]
        startDate <- map["startDate"]
        expectedEndTime <- map["expectedEndTime"]
        pickupTime <- map["pickupTime"]
        dropTime <- map["dropTime"]
        passengerReachTimeTopickup <- map["passengerReachTimeToPickup"]
    }
    public override var description: String {
        return "startTime: \(String(describing: self.startTime))," + "expectedEndTime: \(String(describing: self.expectedEndTime))," + " pickupTime: \( String(describing: self.pickupTime))," + " dropTime: \(String(describing: self.dropTime))," + " startDate: \(String(describing: self.startDate)),"
            + " passengerReachTimeTopickup: \(String(describing: self.passengerReachTimeTopickup)),"
    }
}
