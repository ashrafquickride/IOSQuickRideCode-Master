//
//  RideParticipantUpdateListener.swift
//  Quickride
//
//  Created by KNM Rao on 04/10/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideParticipantUpdateListener : TopicListener{
  
   override func getMessageClassName() -> AnyClass {
    return type(of: self)
  }
  
    override func onMessageRecieved(message: String?, messageObject: Any?) {
    AppDelegate.getAppDelegate().log.debug("\(String(describing: messageObject))")
    let rideParticipant = Mapper<RideParticipant>().map(JSONString: (messageObject as? String)!)
    if rideParticipant == nil{
      return
    }
    let myActiveRidesCache =  MyActiveRidesCache.getRidesCacheInstance()
    if myActiveRidesCache == nil{
      return
    }
    let rescheduleTimeData = Mapper<RescheduleTimeData>().map(JSONString: messageObject as! String)
    rideParticipant!.pickUpTime = AppUtil.createNSDate(dateString: rescheduleTimeData?.pickUpTime)?.getTimeStamp()
    rideParticipant!.dropTime = AppUtil.createNSDate(dateString: rescheduleTimeData?.dropTime)?.getTimeStamp()
    myActiveRidesCache?.updateRideParticipantDetails(rideParticipant: rideParticipant!)
  }
}

public class RescheduleTimeData :NSObject, Mappable{
    var pickUpTime : String?
    var dropTime : String?
    
    public required init?(map: Map) {
        
    }
    public func mapping(map: Map) {
        self.pickUpTime <- map["pickUpTime"]
        self.dropTime <- map["dropTime"]
    }
    public override var description: String {
        return "pickUpTime: \(String(describing: self.pickUpTime))," + "dropTime: \(String(describing: self.dropTime)),"
    }
}
