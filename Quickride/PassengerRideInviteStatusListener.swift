//
//  PassengerRideInviteStatusListener.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2015 iDisha Info Labs Pvt Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
public class PassengerRideInviteStatusListener : TopicListener{
  
  private let PASSENGER_RIDE_INVITATION_TOPIC : String = "passengerride/invite/"
  
  public override func getMessageClassName() -> AnyClass {
    return self.dynamicType
  }
  
  public func subscribeToTopic(passengerRideId : Double){
    let topicName : String = PASSENGER_RIDE_INVITATION_TOPIC + "\(passengerRideId)".componentsSeparatedByString(".")[0]
    EventServiceProxy.getInstance()?.subscribeAsync(topicName, topicListener: self)
  }
  
  public func subscribeToTopics(passengerRideIds : [Double]){
    for passengerRideId in passengerRideIds{
      subscribeToTopic(passengerRideId)
      
    }
  }
  
  public func unSubscribe(passengerRideId : Double){
    let topicName : String = PASSENGER_RIDE_INVITATION_TOPIC + String(passengerRideId)
    EventServiceProxy.getInstance()?.unSubscribe(topicName, topicListener: self)
  }
  
  public override func onMessageRecieved(message: String?, messageObject: AnyObject?) {
    var notification:UserNotification = Mapper<UserNotification>().map(messageObject as! String)! as UserNotification
    AppConfiguration.notification.append(notification)
    
    if notification.type == UserNotification.NOT_TYPE_RM_PASSENGER_INVITATION{
      // Passenger rider invitation by rider
      var handler:RiderInvitationNotificationHandlerToPassenger = RiderInvitationNotificationHandlerToPassenger()
      handler.displayNewUserNotification(notification)
      
    }else if notification.type == UserNotification.NOT_TYPE_RM_PASSENGER_JOIN_RIDE_PASSENGER{
      //Passenger joined rider ride id
      //rideId
      let passengerJoinNotificationToPassengerHandler = PassengerJoinNotificationToPassengerHandler()
      passengerJoinNotificationToPassengerHandler.displayNewUserNotification(notification)
      
    }else if notification.type == UserNotification.NOT_TYPE_RM_PASSENGER_INVITATION_STATUS{
      let riderRejectedPassengerInviteNotificationHandler = RiderRejectedPassengerInviteNotificationHandler()
      riderRejectedPassengerInviteNotificationHandler.displayNewUserNotification(notification)
    } else {
      var handler:NotificationHandler = NotificationHandler()
      handler.displayNewUserNotification(notification)
    }
    
  }
}