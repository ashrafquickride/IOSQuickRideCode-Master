//
//  NotifyRiderAboutCancellationListener.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2015 iDisha Info Labs Pvt Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

public class NotifyRiderAboutCancellationListener : TopicListener {
  
  private let PASSENGER_UNJOIN_RIDER_RIDE_TOPICNAME : String = "passengerunjoin/riderride/"
  private let RIDER_RIDE_SYSTEM_CANCELLED_TOPIC : String = "cancellation/riderride/"
  
  private func getTopicName(topicName : String, rideId : Double) -> String{
    return topicName + String(rideId).componentsSeparatedByString(".")[0]
  }
  
  public override func getMessageClassName() -> AnyClass {
    return self.dynamicType
  }
  
  public func subscribeToTopic(rideId : Double){
    EventServiceProxy.getInstance()?.subscribeAsync(getTopicName(PASSENGER_UNJOIN_RIDER_RIDE_TOPICNAME, rideId: rideId), topicListener: self)
    EventServiceProxy.getInstance()?.subscribeAsync(getTopicName(RIDER_RIDE_SYSTEM_CANCELLED_TOPIC, rideId: rideId), topicListener: self)
  }
  
  public func subscribeToTopics(rideIds : [Double]){
    if rideIds.isEmpty == true {return}
    for rideId in rideIds{
      EventServiceProxy.getInstance()?.subscribeAsync(getTopicName(PASSENGER_UNJOIN_RIDER_RIDE_TOPICNAME, rideId: rideId), topicListener: self)
      EventServiceProxy.getInstance()?.subscribeAsync(getTopicName(PASSENGER_UNJOIN_RIDER_RIDE_TOPICNAME, rideId: rideId), topicListener: self)
    }
  }
  
  public func unSubscribe(rideId : Double){
    EventServiceProxy.getInstance()?.unSubscribe(getTopicName(PASSENGER_UNJOIN_RIDER_RIDE_TOPICNAME, rideId: rideId), topicListener: self)
    EventServiceProxy.getInstance()?.unSubscribe(getTopicName(RIDER_RIDE_SYSTEM_CANCELLED_TOPIC, rideId: rideId), topicListener: self)
  }
  
  public override func onMessageRecieved(message: String?, messageObject: AnyObject?) {
    let userNotification : UserNotification = Mapper<UserNotification>().map(messageObject as! String)!
    
    AppConfiguration.notification.append(userNotification)
    
    if UserNotification.NOT_TYPE_RM_RIDE_CANCELLED_BY_SYSTEM == userNotification.type{
      let myRiderRideCancelledNotificationHandler = MyRiderRideCancelledNotificationHandler()
      myRiderRideCancelledNotificationHandler.displayNewUserNotification(userNotification)
    }
    else if UserNotification.NOT_TYPE_RM_PASSENGER_UNJOIN == userNotification.type{
      let rideCancelledByPassengerHandler = RideCancelledByPassengerHandler()
      rideCancelledByPassengerHandler.displayNewUserNotification(userNotification)
    }
  }
  
}