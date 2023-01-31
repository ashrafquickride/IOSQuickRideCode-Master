//
//  RiderRideInviteStatusListener.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2015 iDisha Info Labs Pvt Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

public class RiderRideInviteStatusListener : TopicListener{
  
  private let RIDER_RIDE_INVITATION_TOPIC : String = "riderride/invite/"
  
  public override func getMessageClassName() -> AnyClass {
    return self.dynamicType
  }
  
  public func subscribeToTopic(riderRideId : Double){
    
    EventServiceProxy.getInstance()?.subscribeAsync(getTopicName(riderRideId), topicListener: self)
  }
  
  func getTopicName(riderRideId : Double) -> String{
    return RIDER_RIDE_INVITATION_TOPIC + String(riderRideId).componentsSeparatedByString(".")[0]
  }
  
  public func subscribeToTopics(riderRideIds : [Double]){
    for rideId in riderRideIds {
      subscribeToTopic(rideId)
    }
  }
  
  public func unsubscribe(rideId : Double){
    EventServiceProxy.getInstance()?.unSubscribe(getTopicName(rideId), topicListener: self)
  }
  
  public override func onMessageRecieved(message: String?, messageObject: AnyObject?) {
    
    if(messageObject != nil){
      let userNotification : UserNotification = Mapper<UserNotification>().map(messageObject as! String)!
      print(messageObject)
      
      AppConfiguration.notification.append(userNotification)
      
      if userNotification.type == UserNotification.NOT_TYPE_RM_RIDER_INVITATION {
        //PassengerRideInvitation by Rider
        let handler:PassengerInvitationNotificationHandlerToRider = PassengerInvitationNotificationHandlerToRider()
        handler.displayNewUserNotification(userNotification)
        
      }else if userNotification.type == UserNotification.NOT_TYPE_RM_PASSENGER_JOIN_RIDE_RIDER {
        //Passenger joined rider ride id
        //rideId
        let passengerJoinNotificationToRiderHandler = PassengerJoinNotificationToRiderHandler()
        passengerJoinNotificationToRiderHandler.displayNewUserNotification(userNotification)
      }else if userNotification.type == UserNotification.NOT_TYPE_RM_RIDER_INVITATION_STATUS {
        //Rider rejected passenger invite
        //passengerRideId
        let passengerRejectedRiderInviteNotificationHandler = PassengerRejectedRiderInviteNotificationHandler()
        passengerRejectedRiderInviteNotificationHandler.displayNewUserNotification(userNotification)
      }
      
    }
  }
}