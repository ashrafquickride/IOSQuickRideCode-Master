//
//  ClientConfigurationModuleSessionManager.swift
//  Quickride
//
//  Created by KNM Rao on 18/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class ClientConfigurationModuleSessionManager : ModuleSessionHandler {
  
  init() {
    super.init(moduleName: QRSessionManager.CLIENT_CONFIG_MODULE_NAME)
  }
  
  // Called when new user registered or new user logged in first time
  override public func newUserSession() throws {
    try ConfigurationCache.newUserSession()
  }
  
  // Called when the user was logged in earlier but logged out and relogging in
  override public func reInitializeUserSession() throws {
    try ConfigurationCache.reInitialiseUserSession()
  }
  
  // Called when user logging out
  override public func clearUserSession(){
    ConfigurationCache.clearUserSession()
  }
  //Called when launching app
  public override func clearUserPersistentStore() {
    ConfigurationCache.clearUserPersistentStore()
  }
  // Called when existing logged in user restart the app. Without relogin - direct start
  override public func resumeUserSession() throws {
    try ConfigurationCache.resumeUserSession()
  }

  
  override public func clearLocalMemoryOnSessionInitializationFailure(){
    ConfigurationCache.removeCacheInstance()
  }
  
}
