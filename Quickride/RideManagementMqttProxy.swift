//
//  RideManagementMqttProxy.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class RideManagementMqttProxy{
    
    private static var singleInstanceProxy : RideManagementMqttProxy?
  
    let rideGroupChatMqttListener : RideGroupChatMqttListener?
    
    private init(){
        self.rideGroupChatMqttListener = RideGroupChatMqttListener()
    }
    
    public static func getInstance() -> RideManagementMqttProxy {
      AppDelegate.getAppDelegate().log.debug("getInstance()")
        if singleInstanceProxy == nil {
            singleInstanceProxy = RideManagementMqttProxy()
        }
        return singleInstanceProxy!
    }
    
    public func subscribeToTopicsForExistingRides(){
      AppDelegate.getAppDelegate().log.debug("subscribeToTopicsForExistingRides()")
        subscribeToTopicsForExistingPassengerRides()
        subscribeToTopicsForExistingRiderRides()
    }
    
    private func subscribeToTopicsForExistingRiderRides(){
      AppDelegate.getAppDelegate().log.debug("subscribeToTopicsForExistingRiderRides()")
      let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
      if myActiveRidesCache == nil {
        return
      }
        let riderRides : [Double : RiderRide]? = myActiveRidesCache!.getActiveRiderRides()
      
        let riderRideIds : [Double] = Array(riderRides!.keys)
        rideGroupChatMqttListener?.subscribeToRides(riderRideIds: riderRideIds)
    }
    
    private func subscribeToTopicsForExistingPassengerRides(){
      AppDelegate.getAppDelegate().log.debug("subscribeToTopicsForExistingPassengerRides()")
      let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
      if myActiveRidesCache == nil {
        return
      }
        let passengerRidesMap : [Double : PassengerRide]? = myActiveRidesCache!.getActivePassengerRides()
      if passengerRidesMap == nil{
        return
      }
        var passengerRidesScheduledStatus : [Double] = [Double]()
        let passengers : [PassengerRide] = Array(passengerRidesMap!.values)
        
        for passenger in passengers {
            if Ride.RIDE_STATUS_REQUESTED != passenger.status {
                passengerRidesScheduledStatus.append(passenger.riderRideId)
            }
        }
        rideGroupChatMqttListener?.subscribeToRides(riderRideIds: passengerRidesScheduledStatus)
    }
  
    
    public func riderRideCreated(riderRideId : Double){
      AppDelegate.getAppDelegate().log.debug("riderRideCreated() \(riderRideId)")
        rideGroupChatMqttListener?.subscribeToRide(riderRideId: riderRideId)
    }
    
    public func userJoinedRiderRide(riderRideId : Double, passengerRideId : Double){
      AppDelegate.getAppDelegate().log.debug("userUnJoinedRiderRide() \(riderRideId) \(passengerRideId)")
       rideGroupChatMqttListener?.subscribeToRide(riderRideId: riderRideId)
        
    }
    
    public func userUnJoinedRiderRide(riderRideId : Double, passengerRideId : Double){
       AppDelegate.getAppDelegate().log.debug("userUnJoinedRiderRide() \(riderRideId) \(passengerRideId)")
        rideGroupChatMqttListener?.unSubscribeToRide(riderRideId: riderRideId)
    }
    
    public func riderRideClosed(riderRideId : Double){
      AppDelegate.getAppDelegate().log.debug("riderRideClosed() \(riderRideId)")
        rideGroupChatMqttListener?.unSubscribeToRide(riderRideId: riderRideId)
    }
}
