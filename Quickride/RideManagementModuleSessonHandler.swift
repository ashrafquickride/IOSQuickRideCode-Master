//
//  RideManagementModuleSessonHandler.swift
//  Quickride
//
//  Created by KNM Rao on 10/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class RideManagementModuleSessionHandler : ModuleSessionHandler, ActiveRidesCacheInitializationStatusListener {
    
    private var isInitializedSuccessfully : Bool = false
    private var initializationFailureCause : SessionManagerOperationFailedException?
    private var dispatchSF  : DispatchSemaphore!
    
    init(){
        super.init(moduleName: QRSessionManager.MYRIDES_CACHE_MODULE_NAME)
    }
    
    override public func newUserSession() {
        AppDelegate.getAppDelegate().log.debug("newUserSession()")
        MyActiveRidesCache.newUserSession(userId: (QRSessionManager.sharedInstance?.getUserId())!)
        MyClosedRidesCache.newUserSession()
        RidesGroupChatCache.createNewInstance()
    }
    
    override public func reInitializeUserSession() throws {
        AppDelegate.getAppDelegate().log.debug("reInitializeUserSession()")
        
        dispatchSF = DispatchSemaphore(value: 0)
        MyActiveRidesCache.reInitialiseUserSession(userId: (QRSessionManager.getInstance()?.getUserId())!, targetViewController: nil, activeRidesCacheListener: self)
        MyActiveTaxiRideCache.getInstance().initializeCache()
        if let home = UserDataCache.getInstance()?.getHomeLocation(), let office = UserDataCache.getInstance()?.getOfficeLocation(){
            CoreDataHelper.getNSMangedObjectContext().perform {
                let userFavouriteRouteAsyncTask = UserFavouriteRouteTask(homeLocation: home, officeLocation: office)
                userFavouriteRouteAsyncTask.getRoutesBetweenHomeAndOfficeLocation()
            }
        }
        // Wait for initialization to complete
        AppDelegate.getAppDelegate().log.debug("Waiting for MyActiveRidesCache to get initialized")
        
        if (!self.isInitializedSuccessfully && initializationFailureCause == nil) {
            dispatchSF.wait(timeout: .distantFuture)
            
        }
        
        AppDelegate.getAppDelegate().log.debug("After waiting")
        if (initializationFailureCause != nil) {
            throw initializationFailureCause!
        }
        RideInvitationsSyncOfRide().syncRideInvitations()
        MyClosedRidesCache.getClosedRidesCacheInstance()
        RidesGroupChatCache.createNewInstance()
        //createLocationListener()
    }
    
    override public func clearUserSession() {
        AppDelegate.getAppDelegate().log.debug("clearUserSession()")
        cleanCache()
        clearRidesFromPersistence()
        
    }
    override public func clearUserPersistentStore() {
        cleanCache()
    }
    func cleanCache(){
        MyActiveRidesCache.clearUserSession()
        MyClosedRidesCache.clearUserSession()
        RidesGroupChatCache.clearUserSession()
        MyActiveTaxiRideCache.clearUserSession()
        RideInviteCache.getInstance().clearLocalMemoryOnSessionInitializationFailure()
        terminateLocationListener()
    }
    
    func clearRidesFromPersistence(){
        MyRidesPersistenceHelper.clearTableForEntity(entityName: MyRidesPersistenceHelper.riderRideTable)
        MyRidesPersistenceHelper.clearTableForEntity(entityName: MyRidesPersistenceHelper.passengerRideTable)
        MyRidesPersistenceHelper.clearTableForEntity(entityName: MyRidesPersistenceHelper.regularRiderRideTable)
        MyRidesPersistenceHelper.clearTableForEntity(entityName: MyRidesPersistenceHelper.regularPassengerRideTable)
        
        MyTaxiRidesPersistenceHelper.clearTableForEntity(entityName: MyTaxiRidesPersistenceHelper.taxiRidePassengerTable)
    }
    
    override public func resumeUserSession() {
        AppDelegate.getAppDelegate().log.debug("resumeUserSession()")
        MyActiveRidesCache.resumeUserSession(userId: (QRSessionManager.sharedInstance?.getUserId())!)
        RideInvitationsSyncOfRide().syncRideInvitations()
        MyActiveTaxiRideCache.getInstance().initializeCache()
        
        //createLocationListener()
        RidesGroupChatCache.createNewInstance()
        MyClosedRidesCache.resumeUserSession()
        
    }
    
    public func initializationCompleted() {
        AppDelegate.getAppDelegate().log.debug("initializationCompleted()")
        self.isInitializedSuccessfully = true
        self.initializationFailureCause = nil
        if (dispatchSF != nil) {
            dispatchSF.signal()
        }
    }
    
    public func initializationFailed(error causeException : ResponseError?) {
        AppDelegate.getAppDelegate().log.debug("initializationFailed \(String(describing: causeException))")
        self.isInitializedSuccessfully = false
        self.initializationFailureCause = SessionManagerOperationFailedException.SessionChangeOperationFailed
        if (causeException?.errorCode == QuickRideErrors.NetworkConnectionNotAvailable) {
            self.initializationFailureCause = SessionManagerOperationFailedException.NetworkConnectionNotAvailable
        }
        else if (causeException?.errorCode == QuickRideErrors.RequestTimedOut) {
            self.initializationFailureCause = SessionManagerOperationFailedException.SessionChangeOperationTimedOut
        }
        if (dispatchSF != nil) {
            dispatchSF.signal()
        }
    }
    
    //  public func createLocationListener(){
    //    LocationChangeListener.getInstance().refreshLocationUpdateRequirementStatus()
    //  }
    
    public func terminateLocationListener(){
        AppDelegate.getAppDelegate().log.debug("terminateLocationListener()")
        LocationChangeListener.removeInstance()
    }
    
    public override func clearLocalMemoryOnSessionInitializationFailure(){
        AppDelegate.getAppDelegate().log.debug("clearLocalMemoryOnSessionInitializationFailure()")
        let chatCache : RidesGroupChatCache? = RidesGroupChatCache.getInstance()
        if chatCache != nil {
            chatCache?.clearLocalMemoryOnSessionInitializationFailure()
        }
        
        let closedRideCache : MyClosedRidesCache? = MyClosedRidesCache.getClosedRidesCacheInstanceIfExists()
        if closedRideCache != nil {
            MyClosedRidesCache.clearLocalMemoryOnSessionInitializationFailure()
        }
        
        let activeRidesCache : MyActiveRidesCache? = MyActiveRidesCache.getRidesCacheInstance()
        if activeRidesCache != nil {
            activeRidesCache?.clearLocalMemoryOnSessionInitializationFailure()
        }
        let activeTaxiCache = MyActiveTaxiRideCache.getClosedTaxiRidesCacheInstanceIfExists()
        if activeTaxiCache != nil{
            activeTaxiCache?.clearLocalMemoryOnSessionInitializationFailure()
        }
        super.clearLocalMemoryOnSessionInitializationFailure()
    }
    
    public override func performPostSessionInitializationOperations(sessionChangeOperationId : UserSessionType) {
        AppDelegate.getAppDelegate().log.debug("performPostSessionInitializationOperations()")
        if (sessionChangeOperationId == .ReinitializeUserSession) {
            RideManagementMqttProxy.getInstance().subscribeToTopicsForExistingRides()
            RidesGroupChatCache.createNewInstance()
            RidesGroupChatCache.getInstance()?.loadAllRideChatMessages()
            MyClosedRidesCache.reinitializeUserSession()
        }
        else if (sessionChangeOperationId == .ResumeUserSession) {
            RideManagementMqttProxy.getInstance().subscribeToTopicsForExistingRides()
            RidesGroupChatCache.getInstance()?.loadAllRideChatMessages()
        }
    }
}
