//
//  RideStatusUpdateListener.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RideStatusUpdateListener : TopicListener{
    
  
  
  public override func getMessageClassName() -> AnyClass {
    AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
    return type(of: self)
  }
  
  

  public override func onMessageRecieved(message: String?, messageObject: Any?) {
     AppDelegate.getAppDelegate().log.debug("onMessageRecieved()")
          AppDelegate.getAppDelegate().log.debug("\(String(describing: messageObject))")
    let rideStatus =  Mapper<RideStatus>().map(JSONString: messageObject! as! String)!
    
    if rideStatus.scheduleTime == nil || rideStatus.rescheduleTime == nil{
        let rideRescheduleTimeData = Mapper<RideRescheduleTimeData>().map(JSONString: messageObject as! String)
        rideStatus.scheduleTime = AppUtil.createNSDate(dateString: rideRescheduleTimeData?.scheduleTime)?.getTimeStamp()
        rideStatus.rescheduleTime = AppUtil.createNSDate(dateString: rideRescheduleTimeData?.rescheduleTime)?.getTimeStamp()
    }

          AppDelegate.getAppDelegate().log.debug("rideStatus")
    if rideStatus.rideType == Ride.REGULAR_RIDER_RIDE || rideStatus.rideType == Ride.REGULAR_PASSENGER_RIDE{
        MyRegularRidesCache.getInstance().updateRideStatus(rideStatus: rideStatus)
        return
    }
    let myActiveRidesCache : MyActiveRidesCache? =  MyActiveRidesCache.getRidesCacheInstance()
    if myActiveRidesCache != nil{
        
        if rideStatus.status == Ride.RIDE_STATUS_RESCHEDULED{
            //Current user reschedule already reflected locally.
            if Double((QRSessionManager.getInstance()?.getUserId())!) == rideStatus.userId{
                return
            }
          
          if rideStatus.scheduleTime == nil || rideStatus.rescheduleTime == nil{
            let rideRescheduleTimeData = Mapper<RideRescheduleTimeData>().map(JSONString: messageObject as! String)!
            rideStatus.scheduleTime = AppUtil.createNSDate(dateString: rideRescheduleTimeData.scheduleTime)?.getTimeStamp()
            rideStatus.rescheduleTime = AppUtil.createNSDate(dateString: rideRescheduleTimeData.rescheduleTime)?.getTimeStamp()
            rideStatus.pickupTime = AppUtil.createNSDate(dateString: rideRescheduleTimeData.pickupTime)?.getTimeStamp()
            rideStatus.dropTime = AppUtil.createNSDate(dateString: rideRescheduleTimeData.dropTime)?.getTimeStamp()
         }
          if rideStatus.scheduleTime != nil && rideStatus.rescheduleTime != nil{
            myActiveRidesCache!.rescheduleRide(rideStatus: rideStatus)
          }
          

        }else{
            myActiveRidesCache!.updateRideStatus(newRideStatus: rideStatus)
        }
    }
  }
   
}
public class RideRescheduleTimeData : NSObject, Mappable{
    var scheduleTime : String?
    var rescheduleTime : String?
    var pickupTime : String?
    var dropTime : String?
    
    public required init?(map: Map) {
        
    }
    public func mapping(map: Map) {
        self.scheduleTime <- map["scheduleTime"]
        self.rescheduleTime <- map["rescheduleTime"]
        self.pickupTime <- map["pickupTime"]
        self.dropTime <- map["dropTime"]
    }
    public override var description: String {
        return "scheduleTime: \(String(describing: self.scheduleTime))," + "rescheduleTime: \(String(describing: self.rescheduleTime))," + "pickupTime: \(String(describing: self.pickupTime))," + "dropTime: \(String(describing: self.dropTime)),"
    }
}
