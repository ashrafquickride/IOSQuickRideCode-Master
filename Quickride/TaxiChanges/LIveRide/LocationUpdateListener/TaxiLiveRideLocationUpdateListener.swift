//
//  TaxiLiveRideLocationUpdateListener.swift
//  Quickride
//
//  Created by Ashutos on 02/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiLiveRideLocationUpdateListener: TopicListener {
  
    public static let TOPIC_PREFIX = "location/taxiride/"
    
    public override func getMessageClassName() -> AnyClass {
      AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
      return type(of: self)
    }
    
    private func getTopicNameForRideParticipantLocation(taxiGroupId : Double) -> String{
      AppDelegate.getAppDelegate().log.debug("getTopicNameForRideParticipantLocation() \(taxiGroupId)")
      return TaxiLiveRideLocationUpdateListener.TOPIC_PREFIX + StringUtils.getStringFromDouble(decimalNumber : taxiGroupId)
    }
    
    public func subscribeToLocationUpdatesForRide(taxiGroupId : Double) {
      AppDelegate.getAppDelegate().log.debug("subscribeToLocationUpdatesForRide() \(taxiGroupId)")
      let topic = getTopicNameForRideParticipantLocation(taxiGroupId: taxiGroupId)
      let eventServiceProxy = EventServiceProxyFactory.getEventServiceProxy(topicName: topic)
      eventServiceProxy?.subscribe(topicName: topic, topicListener: self)
      if eventServiceProxy != nil && eventServiceProxy != EventServiceProxyFactory.getRMEventServiceProxy(){
          EventServiceProxyFactory.rideMgmtEventServiceProxy?.subscribe(topicName: topic, topicListener: self)
      }
    }
    
    public func unSubscribeToLocationUpdatesForRide(taxiGroupId : Double){
      AppDelegate.getAppDelegate().log.debug("unSubscribeToLocationUpdatesForRide() \(taxiGroupId)")
        let topic = getTopicNameForRideParticipantLocation(taxiGroupId: taxiGroupId)
      let eventServiceProxy = EventServiceProxyFactory.getEventServiceProxy(topicName: topic)
      eventServiceProxy?.unSubscribe(topicName: topic, topicListener: self)
      if eventServiceProxy != nil && eventServiceProxy != EventServiceProxyFactory.getRMEventServiceProxy(){
          EventServiceProxyFactory.rideMgmtEventServiceProxy?.unSubscribe(topicName: topic, topicListener: self)
      }
    }
    
    public override func onMessageRecieved(message: String?, messageObject: Any?) {
      AppDelegate.getAppDelegate().log.debug("onMessageRecieved() \(messageObject)")
      let rideParticipantLocation = Mapper<RideParticipantLocation>().map(JSONString: messageObject as! String)
      AppDelegate.getAppDelegate().log.debug("Taxi location updates through MQTT \(String(describing: rideParticipantLocation))")
        if let rideParticipantLocation = rideParticipantLocation {
            TaxiRideDetailsCache.getInstance().updateTaxiLocation(taxiGroupId: rideParticipantLocation.rideId!, rideParticipantLocation: rideParticipantLocation)
            NotificationCenter.default.post(name: .taxiLocationUpdate, object: nil)
        }
    }
}

