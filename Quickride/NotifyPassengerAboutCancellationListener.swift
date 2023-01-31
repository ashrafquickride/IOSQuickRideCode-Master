//
//  NotifyPassengerAboutCancellationListener.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2015 iDisha Info Labs Pvt Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

public class NotifyPassengerAboutCancellationListener : TopicListener{
  
  private let RIDER_RIDE_CANCELLED_TOPIC : String = "cancellation/riderride/passenger/"
  private let RIDER_UNJOIN_PASSENGER_RIDE_TOPIC : String = "unjoin/riderride/passenger/"
  
  
  private func getTopicName(topicName : String, rideId : Double) -> String{
    return topicName + String(rideId).componentsSeparatedByString(".")[0]
  }
  
  public override func getMessageClassName() -> AnyClass {
    return self.dynamicType
  }
  
  public func subscribe(rideId : Double, passengerRideId : Double){
    EventServiceProxy.getInstance()?.subscribeAsync(getTopicName(RIDER_RIDE_CANCELLED_TOPIC, rideId: passengerRideId), topicListener: self)
    EventServiceProxy.getInstance()?.subscribeAsync(getTopicName(RIDER_UNJOIN_PASSENGER_RIDE_TOPIC, rideId: passengerRideId), topicListener: self)
  }
  
  public func unSubscribe(rideId : Double, passengerRideId : Double){
    EventServiceProxy.getInstance()?.unSubscribe(getTopicName(RIDER_RIDE_CANCELLED_TOPIC, rideId: rideId), topicListener: self)
    EventServiceProxy.getInstance()?.unSubscribe(getTopicName(RIDER_UNJOIN_PASSENGER_RIDE_TOPIC, rideId: rideId), topicListener: self)
  }
  
  public override func onMessageRecieved(message: String?, messageObject: AnyObject?) {
    var userNotification:UserNotification = Mapper<UserNotification>().map(messageObject as! String)! as UserNotification
    let passengerJoinedRideGotCancelledHandler  = PassengerJoinedRideGotCancelledHandler()
    passengerJoinedRideGotCancelledHandler.displayNewUserNotification(userNotification)
  }
  
}