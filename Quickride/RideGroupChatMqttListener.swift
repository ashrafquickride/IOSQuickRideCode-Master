//
//  RideGroupChatMqttListener.swift
//  Quickride
//
//  Created by KNM Rao on 20/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import UIKit



public class RideGroupChatMqttListener : TopicListener{
  
  static let RIDE_GROUP_CHAT_TOPIC : String = "riderride/chat/"

  
  public override func getMessageClassName() -> AnyClass {
    AppDelegate.getAppDelegate().log.debug("")
    return type(of: self)
  }
  
  public func subscribeToRide(riderRideId : Double){
    AppDelegate.getAppDelegate().log.debug("riderRideId: \(riderRideId)")
    let topicName = RideGroupChatMqttListener.RIDE_GROUP_CHAT_TOPIC + "\(riderRideId)".components(separatedBy: ".")[0]
    EventServiceProxyFactory.getEventServiceProxy(topicName : topicName)?.subscribe(topicName : topicName, topicListener: self)
  }
  
  public func subscribeToRides(riderRideIds : [Double]){
    AppDelegate.getAppDelegate().log.debug("riderRideIds: \(riderRideIds)")
    for rideId in riderRideIds {
        let topicName = RideGroupChatMqttListener.RIDE_GROUP_CHAT_TOPIC + "\(rideId)".components(separatedBy: ".")[0]
      EventServiceProxyFactory.getEventServiceProxy(topicName : topicName)?.subscribe(topicName : topicName, topicListener: self)
    }
  }
  
  public func unSubscribeToRide(riderRideId : Double){
    AppDelegate.getAppDelegate().log.debug("riderRideId: \(riderRideId)")
    let topicName = RideGroupChatMqttListener.RIDE_GROUP_CHAT_TOPIC + "\(riderRideId)".components(separatedBy: ".")[0]
    EventServiceProxyFactory.getEventServiceProxy(topicName : topicName)?.unSubscribe(topicName : topicName, topicListener: self)
  }
  
  public override func onMessageRecieved(message: String?, messageObject: Any?) {
    
    AppDelegate.getAppDelegate().log.debug("\(String(describing: message))")
    if messageObject != nil{
      
      var groupChatMessage : GroupChatMessage = GroupChatMessage()
      groupChatMessage  = Mapper<GroupChatMessage>().map(JSONString: (messageObject as! NSString) as String)!
        CommunicationRestClient.updateEventStatus(uniqueId: groupChatMessage.uniqueID!, sendTo : QRSessionManager.getInstance()!.getUserId(),viewController: nil) { (responseObject, error) in
            
        }
      RidesGroupChatCache.getInstance()?.receivedNewGroupChatMessage(newMessage: groupChatMessage)
      self.checkRideStatusAndSpeakMessageForGroupChat(groupChatMessage: groupChatMessage)
      
    }
  }
    
    func checkRideStatusAndSpeakMessageForGroupChat(groupChatMessage: GroupChatMessage){
        let state = UIApplication.shared.applicationState
        if state == .background  || state == .inactive{
            let riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: groupChatMessage.rideId)
            if riderRide != nil && riderRide!.status == Ride.RIDE_STATUS_STARTED && StringUtils.getStringFromDouble(decimalNumber: groupChatMessage.phonenumber) != QRSessionManager.getInstance()?.getUserId(){
                let text = groupChatMessage.userName + " says " + groupChatMessage.message
                ConversationCache.speakTextIfRideStarted(msgText: text)
            }
        }
    }
  
}
