//
//  EventModuleSessionMangaer.swift
//  Quickride
//
//  Created by KNM Rao on 10/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class EventModuleSessionManager: ModuleSessionHandler, EventServiceStatusListener{
  
  private var isEventServiceInitialized : Bool = false
  private var eventServiceInitializationFailureCause : SessionManagerOperationFailedException?
  
  init(){
    super.init(moduleName: QRSessionManager.EVENT_MODULE_NAME)
  }
  
  public override func newUserSession() throws {
    AppDelegate.getAppDelegate().log.debug("newUserSession()")
    var clientConfig = ConfigurationCache.getInstance()?.getClientConfiguration()
    if clientConfig == nil{
        clientConfig = ClientConfigurtion()
    }
    try createEventServiceProxyAndWaitForInitializationToComplete()

  }
    public override func resumeUserSession() throws {
        try self.newUserSession()
    }
  
  
  public override func reInitializeUserSession() throws {
    try self.newUserSession()
  }
  
  public override func clearUserSession() {
    AppDelegate.getAppDelegate().log.debug("clearUserSession()")
    EventServiceProxyFactory.clearEventServiceProxyInstances()
  }
  
  public override func clearUserPersistentStore()  {
    AppDelegate.getAppDelegate().log.debug("clearUserPersistentStore()")

    EventServiceProxyFactory.clearEventServiceProxyInstances()
  }
  
  public func eventServiceInitialized() {
    //TODO : Notify that connection is established successfully
    AppDelegate.getAppDelegate().log.debug("eventServiceInitialized()")
    isEventServiceInitialized = true
    eventServiceInitializationFailureCause = nil

  }
  
  public func eventServiceFailed(causeException : EventServiceOperationFailedException?) {
    AppDelegate.getAppDelegate().log.debug("Event service initialization failed due to : \(String(describing: causeException))")

    eventServiceInitializationFailureCause = SessionManagerOperationFailedException.SessionChangeOperationFailed
    if causeException == EventServiceOperationFailedException.NetworkConnectionNotAvailable {
      eventServiceInitializationFailureCause = SessionManagerOperationFailedException.NetworkConnectionNotAvailable
    }
    else if (QRReachability.isConnectedToNetwork() == false) {
      eventServiceInitializationFailureCause = SessionManagerOperationFailedException.NetworkConnectionNotAvailable
    }

  }
  
  public override func performPostSessionInitializationOperations(sessionChangeOperationId : UserSessionType) {
    EventServiceProxyFactory.startMessageProcessing()
    
     DispatchQueue.main.async() { () -> Void in
       NotificationStore.getInstance().removeOlderNotifications()
    }
    
  }
  
  public override func clearLocalMemoryOnSessionInitializationFailure() {
    AppDelegate.getAppDelegate().log.debug("clearLocalMemoryOnSessionInitializationFailure()")
    let notificationStore : NotificationStore? = NotificationStore.getInstanceIfExists()
    if notificationStore != nil {
      notificationStore?.clearLocalMemoryOnSessionInitializationFailure()
    }
    
    EventServiceProxyFactory.clearLocalMemoryOnSessionInitializationFailure()
  }
  
  private func createEventServiceProxyAndWaitForInitializationToComplete() throws {
    AppDelegate.getAppDelegate().log.debug("createEventServiceProxyAndWaitForInitializationToComplete()")
   
    EventServiceProxyFactory.createEventServiceProxies(eventServiceStatusListener: self)
     eventServiceInitialized()
  }
}
