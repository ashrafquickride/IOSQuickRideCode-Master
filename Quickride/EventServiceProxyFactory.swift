//
//  EventServiceProxyFactory.swift
//  Quickride
//
//  Created by KNM Rao on 04/11/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class EventServiceProxyFactory {
  
  static var  rideMgmtEventServiceProxy :  EventServiceProxy?
  
  static func getEventServiceProxy( topicName : String) -> EventServiceProxy? {
    if rideMgmtEventServiceProxy == nil {
      return nil
    }
    
    return rideMgmtEventServiceProxy!
  }
  
  static func getRMEventServiceProxy() -> EventServiceProxy?{
    return rideMgmtEventServiceProxy
  }
  
  static func createEventServiceProxies(eventServiceStatusListener : EventServiceStatusListener?){
    clearEventServiceProxyInstances()
    rideMgmtEventServiceProxy = RideMgmtEventServiceProxy(eventServiceStatusListener: eventServiceStatusListener)
    
   
    establishEventServiceConnections()
  }
  
  static func establishEventServiceConnections() {
    if rideMgmtEventServiceProxy != nil {
      rideMgmtEventServiceProxy!.createConnection()
    }
   
  }
  
  
  
  static func startMessageProcessing() {
    if rideMgmtEventServiceProxy != nil {
      rideMgmtEventServiceProxy!.dispatchAllMessagesArrivedBeforeSessionWasInitialized()
    }
    
  }
  
  
  
  static func clearEventServiceProxyInstances() {
    if rideMgmtEventServiceProxy != nil {
      rideMgmtEventServiceProxy!.clearInstance()
    }
   
  }
  
  static func clearLocalMemoryOnSessionInitializationFailure() {
    if rideMgmtEventServiceProxy != nil {
      rideMgmtEventServiceProxy!.clearLocalMemoryOnSessionInitializationFailure()
    }
    
  }
  
}
