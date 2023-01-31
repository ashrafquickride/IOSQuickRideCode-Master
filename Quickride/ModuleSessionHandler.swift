//
//  SessionModuleController.swift
//  Quickride
//
//  Created by KNM Rao on 24/10/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public enum UserSessionType{
  
  case NewUserSession
  case ReinitializeUserSession
  case ClearUserSession
  case ResumeUserSession
  case ClearUserPersistence
  case PassiveUserSession
  case SessionNotDefined
  
}

public class ModuleSessionHandler{
  
  public typealias sessionCompletionHandler = (_ moduleName: String?, _ error: NSError?) -> Void

  var moduleName : String = ""
  
  init(moduleName : String?){
    self.moduleName = moduleName!
  }
  
  public func getModuleName() -> String{
    return self.moduleName
  }
  
  // Called when new user registered or new user logged in first time
  public func newUserSession() throws {

  }
  
  // Called when the user was logged in earlier but logged out and relogging in
  public func reInitializeUserSession() throws {

  }
  
  // Called when user logging out
  public func clearUserSession(){

  }
  public func clearUserPersistentStore() throws {
    
  }
  
  // Called when existing logged in user restart the app. Without relogin - direct start
  public func resumeUserSession() throws {

  }
  
  // Blocking call
  public func onSessionManagerDestroyed(){
    return
  }
  
  public func performPostSessionInitializationOperations(sessionChangeOperationId : UserSessionType){
    return
  }
  
  public func clearLocalMemoryOnSessionInitializationFailure(){
    return
  }
}
