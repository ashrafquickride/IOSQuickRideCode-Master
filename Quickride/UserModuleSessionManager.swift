//
//  UserModuleSessionHandler.swift
//  Quickride
//
//  Created by KNM Rao on 09/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class UserModuleSessionManager : ModuleSessionHandler {
    
    public var isUserServiceInitialized : Bool = false
    private var userServiceInitializationFailureCause : SessionManagerOperationFailedException?
    
    init(){
        super.init(moduleName: QRSessionManager.USER_MODULE_NAME)
    }
    
    override public func newUserSession() throws {
      AppDelegate.getAppDelegate().log.debug("newUserSession()")
        UserDataCache.newUserSession()
    }
    
    override public func reInitializeUserSession() throws {
      AppDelegate.getAppDelegate().log.debug("reInitializeUserSession()")
        self.isUserServiceInitialized = false
        userServiceInitializationFailureCause = nil
        // Create semaphore to wait until user data cache is initialized
        let semaphore = DispatchSemaphore(value: 0)
        
        UserDataCache.reInitialiseUserSession(completionHandler: { (responseObject, error) -> Void in
            if responseObject == true {
                self.isUserServiceInitialized = true
                self.userServiceInitializationFailureCause = nil
            }
            else{
                self.isUserServiceInitialized = false
                self.userServiceInitializationFailureCause = SessionManagerOperationFailedException.SessionChangeOperationFailed
                if (error != nil) {
                    if (error?.errorCode == QuickRideErrors.NetworkConnectionNotAvailable) {
                        self.userServiceInitializationFailureCause = SessionManagerOperationFailedException.NetworkConnectionNotAvailable
                    }
                    else if (error?.errorCode == QuickRideErrors.RequestTimedOut) {
                        self.userServiceInitializationFailureCause = SessionManagerOperationFailedException.SessionChangeOperationTimedOut
                    }
                }
            }
            semaphore.signal()
        })
        
        // Wait till UserDataCache is initialized
        AppDelegate.getAppDelegate().log.debug("Waiting for UserDataCache to get initialized")
        
        if (!isUserServiceInitialized && userServiceInitializationFailureCause == nil) {
            semaphore.wait(timeout: .distantFuture)
           // semaphore.wait(timeout: dispatch_time_t(DispatchTime.distantFuture))
        }
        
        AppDelegate.getAppDelegate().log.debug("After waiting")
        if (userServiceInitializationFailureCause != nil) {
            throw userServiceInitializationFailureCause!
        }
        
       
    }
    
    override public func resumeUserSession() throws {
      AppDelegate.getAppDelegate().log.debug("resumeUserSession()")
        try UserDataCache.resumeUserSession()
        ConversationCache.getInstance()
        UserGroupChatCache.createNewInstance()
        
    }
    
    override public func clearUserSession(){
      AppDelegate.getAppDelegate().log.debug("clearUserSession()")
        UserDataCache.removeUserDataCache()
        ConversationCache.clearCacheInstance()
        UserGroupChatCache.getInstance()?.removeCacheInstance()
        let tipsFactory : TipsFactory = TipsFactory.getInstance()
        tipsFactory.removeCache()
    }
  override public func clearUserPersistentStore(){
    AppDelegate.getAppDelegate().log.debug("clearUserPersistentStore()")
    UserDataCache.removeUserDataCachePersistence()
    ConversationCache.clearCacheInstance()
    UserGroupChatCache.getInstance()?.removeCacheInstance()
  }
  
    public override func clearLocalMemoryOnSessionInitializationFailure(){
        AppDelegate.getAppDelegate().log.debug("clearLocalMemoryOnSessionInitializationFailure()")
        let userDataCache : UserDataCache? = UserDataCache.sharedInstance
        if userDataCache != nil {
            userDataCache?.clearLocalMemoryOnSessionInitializationFailure()
        }
        ConversationCache.clearCacheInstance()
        
        super.clearLocalMemoryOnSessionInitializationFailure()
    }
    
    public override func performPostSessionInitializationOperations(sessionChangeOperationId : UserSessionType) {
      AppDelegate.getAppDelegate().log.debug("performPostSessionInitializationOperations()")
        switch (sessionChangeOperationId) {
        case .ClearUserSession:
            break
        case .ClearUserPersistence:
          break
        default:
            UserManagementTopicSubscriber.getInstance()?.subscribeToTopics()

            if sessionChangeOperationId == .NewUserSession || sessionChangeOperationId == .ResumeUserSession || sessionChangeOperationId == .ReinitializeUserSession{
              var versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
              if versionName == nil || versionName!.isEmpty{
                versionName = AppConfiguration.APP_CURRENT_VERSION_NO
              }
              UserRestClient.updateAppVersion(userid: (QRSessionManager.getInstance()?.getUserId())!, versionName: versionName!, viewController: nil, handler: { (responseObject, error) in
                    })
            }
            
        }
    }
}
