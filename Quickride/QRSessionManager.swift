//
//  SessionManager.swift
//  Quickride
//
//  Created by KNM Rao on 10/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import Reachability

public class QRSessionManager {
  
  private var currentSession : UserSession?
  public static let CLIENT_CONFIG_MODULE_NAME : String = "clientConfig"
  public static let EVENT_MODULE_NAME : String = "eventListenerService";
  public static let USER_MODULE_NAME : String  = "user";
  public static let MYRIDES_CACHE_MODULE_NAME : String = "myRidesCache";
  var reachability : Reachability?

  // Module List
  private var moduleSessionHandlerList : Array<ModuleSessionHandler> = [ModuleSessionHandler]()
  
  static var sharedInstance : QRSessionManager?
  
  private init(){
    populateModuleSessionHandlers()
    initializePersistentSessionIfAny()
  }
  
  public static func createNewSessionManager() -> QRSessionManager{
    AppDelegate.getAppDelegate().log.debug("createNewSessionManager()")
    if self.sharedInstance != nil{
      self.destorySesssionManager()
    }
    self.sharedInstance = QRSessionManager()
    return self.sharedInstance!
  }
  
  public static func destorySesssionManager(){
    AppDelegate.getAppDelegate().log.debug("destorySesssionManager()")
    if self.sharedInstance != nil {
      self.sharedInstance!.onSessionManagerDestroyed()
    }
    self.sharedInstance = nil
  }
  
  public func onSessionManagerDestroyed(){
    AppDelegate.getAppDelegate().log.debug("onSessionManagerDestroyed()")
    for moduleSessionHandler in moduleSessionHandlerList{
      moduleSessionHandler.onSessionManagerDestroyed()
    }
  }
  
  public static func getInstance() -> QRSessionManager?{
    AppDelegate.getAppDelegate().log.debug("getInstance()")
    if self.sharedInstance != nil{
      return sharedInstance!
    }else{
      return self.createNewSessionManager()
    }
  }
  
  public func updateUserContactNo(phoneNo : String)
  {
    if(currentSession != nil)
    {
      currentSession?.contactNo = phoneNo
    }
    SharedPreferenceHelper.storeLoggedInUserContactNo(contactNo: phoneNo)
  }
  
    public func updateUserCountryCode(countryCode : String?)
    {
        if(currentSession != nil && countryCode != nil)
        {
            currentSession!.countryCode = countryCode
        }
        SharedPreferenceHelper.storeLoggedInUserCountryCode(countryCode: countryCode)
    }

  public func populateModuleSessionHandlers(){
    AppDelegate.getAppDelegate().log.debug("populateModuleSessionHandlers()")
    let clientConfigModuleSessionManager : ClientConfigurationModuleSessionManager = ClientConfigurationModuleSessionManager()
    let eventModuleSessionManager : EventModuleSessionManager = EventModuleSessionManager()
    let userModuleSessionManager : UserModuleSessionManager = UserModuleSessionManager()
    let rideManagementModuleSessionManger : RideManagementModuleSessionHandler = RideManagementModuleSessionHandler()
    
    moduleSessionHandlerList.append(clientConfigModuleSessionManager)
    moduleSessionHandlerList.append(eventModuleSessionManager)
    moduleSessionHandlerList.append(userModuleSessionManager)
    moduleSessionHandlerList.append(rideManagementModuleSessionManger)
    
  }
  
  public func initializePersistentSessionIfAny(){
    AppDelegate.getAppDelegate().log.debug("initializePersistentSessionIfAny()")
    let userId : String? = SharedPreferenceHelper.getLoggedInUserId()
    let countryCode = SharedPreferenceHelper.getLoggedInUserCountryCode()
    let password = SharedPreferenceHelper.getLoggedInUserPassword()
    if userId != nil && userId!.isEmpty == false && password != nil && password?.isEmpty == false {
          AppDelegate.getAppDelegate().log.debug("Found persistent session for user \(String(describing: userId))")
          
          var contactNo = SharedPreferenceHelper.getLoggedInUserContactNo()
            if(contactNo == nil || contactNo!.isEmpty){
              contactNo = userId
            }
    
            self.currentSession = UserSession(userId: userId!, userPassword: password!, userSessionStatus: UserSessionStatus.User,contactNo: contactNo!,countryCode :countryCode)
        }
        else {
          self.currentSession = UserSession()
        }
  }
  
  public func getCurrentSession() -> UserSession{
    return self.currentSession!
  }
  
  public func getCurrentSessionStatus() -> UserSessionStatus{
    return (self.currentSession?.userSessionStatus)!
  }
  
  public func newUserSession(userId : String, password: String, userProfile: UserProfile, user: User) throws {
    AppDelegate.getAppDelegate().log.debug("newUserSession() \(userId) \(password)")
    self.currentSession = UserSession(userId: userId, userPassword: password, userSessionStatus: UserSessionStatus.User, contactNo: StringUtils.getStringFromDouble(decimalNumber: user.contactNo), countryCode:  user.countryCode)

    self.saveUserDefaultData(newUser: user, userProfile: userProfile)
    
    try callSessionChangeOperationOnAllModules(sessionChangeOperationId: UserSessionType.NewUserSession, isShutdownSequence: false)
    
    // Store user Id and Pwd only on successful session initialization
    self.saveUserIDAndPassword(userId: userId, password: password, contactNo: StringUtils.getStringFromDouble(decimalNumber: user.contactNo), countryCode: user.countryCode)
  }
  
  public func onReinitializeUserSession(userId : String, password : String, contactNo : String,countryCode : String?) throws {
    AppDelegate.getAppDelegate().log.debug("onReinitializeUserSession() \(userId) \(password)")
    self.currentSession = UserSession(userId: userId, userPassword: password, userSessionStatus: UserSessionStatus.User, contactNo: contactNo,countryCode: countryCode)
    try callSessionChangeOperationOnAllModules(sessionChangeOperationId: UserSessionType.ReinitializeUserSession, isShutdownSequence: false)
    
    // Store user Id and Pwd only on successful session initialization
    self.saveUserIDAndPassword(userId: userId, password: password, contactNo: contactNo, countryCode: countryCode)
  }
  
    public func handleSessionResumption(userId : String, password : String, contactNo : String,countryCode : String?) throws {
        AppDelegate.getAppDelegate().log.debug("resumeSession() \(userId) \(password)")
        self.currentSession = UserSession(userId: userId, userPassword: password, userSessionStatus: UserSessionStatus.User, contactNo: contactNo,countryCode: countryCode)
        try callSessionChangeOperationOnAllModules(sessionChangeOperationId: UserSessionType.ResumeUserSession, isShutdownSequence: false)
        
        // Store user Id and Pwd only on successful session initialization
        self.saveUserIDAndPassword(userId: userId, password: password, contactNo: contactNo, countryCode: countryCode)
    }
    
  public func onClearUserSession() throws {
    try callSessionChangeOperationOnAllModules(sessionChangeOperationId: UserSessionType.ClearUserSession, isShutdownSequence: true)
  }
  public func onClearUserPersistence() throws {
    try callSessionChangeOperationOnAllModules(sessionChangeOperationId: UserSessionType.ClearUserPersistence, isShutdownSequence: true)
  }
  
  public func onResumeUserSession() throws{

        // TODO : Currently we don't have a solution to keep our app running in the background always and hence we would have missed out on some updates while the app was not running. So till we find a solution, take an alternative approach : whenever the app is opened, validate for existing session and if found valid, reinitialize the session (after clearing the existing session) instead of resuming. This will ensure that we read all data from the server instead of local persistence. Once we find the right solution, revert this change and uncomment the above line
        let userId = currentSession!.userId
        let userPassword = currentSession!.userPassword
        let contactNo = currentSession?.contactNo
        
        let countryCode = currentSession?.countryCode
        
        // Get the deviceToken stored in userDefaults before clearing the session and restore later
    
        let deviceToken = UserDefaults.standard.string(forKey: "deviceTokenString")
        
        
        do {
            try onClearUserPersistence()
        }
        catch let error as NSError {
            AppDelegate.getAppDelegate().log.error("Error while clearing user session : \(error)")
        }
        
        if (deviceToken != nil) {
            UserDefaults.standard.setValue(deviceToken, forKey: "deviceTokenString")
        }
        do {
            try self.handleSessionResumption(userId: userId, password: userPassword, contactNo: contactNo!, countryCode: countryCode)
        }
        catch let error {
            // Restore the user ID and password so that the same can be reused to resume user session in next attempt
            self.saveUserIDAndPassword(userId: userId, password: userPassword, contactNo: contactNo!, countryCode: countryCode)
            throw error
        }


  }

  private func callSessionChangeOperationOnAllModules(sessionChangeOperationId : UserSessionType, isShutdownSequence : Bool) throws {
    AppDelegate.getAppDelegate().log.debug("callSessionChangeOperationOnAllModules \(sessionChangeOperationId)")
    var sessionChangeModuleIndex : Int = 0
    if(isShutdownSequence){
      sessionChangeModuleIndex = moduleSessionHandlerList.count - 1
    }
    
    var moduleSessionHandler : ModuleSessionHandler?
    while (sessionChangeModuleIndex >= 0 && sessionChangeModuleIndex < moduleSessionHandlerList.count) {
      moduleSessionHandler = moduleSessionHandlerList[sessionChangeModuleIndex]
      if (moduleSessionHandler == nil) {
        break
      }
      AppDelegate.getAppDelegate().log.debug("Performing session change operation on \(String(describing: moduleSessionHandler?.getModuleName()))")
      do {
        try performSessionChangeOperationOnModule(moduleSessionHandler: moduleSessionHandler!, sessionChangeOperationId: sessionChangeOperationId)
        sessionChangeModuleIndex = getNextModuleIndex(sessionChangeModuleIndex: sessionChangeModuleIndex, isShutdownSequence: isShutdownSequence)
      }
      catch let error as SessionManagerOperationFailedException {
        AppDelegate.getAppDelegate().log.debug("Session change operation failed on \(String(describing: moduleSessionHandler?.getModuleName()))")
        rollbackSessionChangeOperationOnAllModules(sessionChangeOperationId: sessionChangeOperationId, causeException: error)
        throw error
      }
    }
    performPostSessionChangeOperation(sessionChangeOperationId: sessionChangeOperationId, causeException: nil)
  }
  
  private func getNextModuleIndex(sessionChangeModuleIndex : Int, isShutdownSequence: Bool) -> Int {
    AppDelegate.getAppDelegate().log.debug("getNextModuleIndex()")
    if (isShutdownSequence) {
      return sessionChangeModuleIndex - 1
    }
    else {
      return sessionChangeModuleIndex + 1
    }
  }
  
    private func saveUserIDAndPassword(userId : String, password : String, contactNo : String,countryCode : String?){
        SharedPreferenceHelper.storeLoggedInUserId(userId: userId)
        SharedPreferenceHelper.storeLoggedInUserPwd(password: password)
        SharedPreferenceHelper.storeLoggedInUserContactNo(contactNo: contactNo)
        SharedPreferenceHelper.storeLoggedInUserCountryCode(countryCode: countryCode)
    }
  
  func performSessionChangeOperationOnModule(moduleSessionHandler : ModuleSessionHandler, sessionChangeOperationId : UserSessionType) throws {
    AppDelegate.getAppDelegate().log.debug("performSessionChangeOperationOnModule()")
    switch sessionChangeOperationId {
      
    case UserSessionType.NewUserSession :
      try moduleSessionHandler.newUserSession()
      break
    case .ReinitializeUserSession :
      try moduleSessionHandler.reInitializeUserSession()
      break
    case .ClearUserSession :
      moduleSessionHandler.clearUserSession()
      break
    case .ResumeUserSession :
      try moduleSessionHandler.resumeUserSession()
      break
    case .ClearUserPersistence :
      try moduleSessionHandler.clearUserPersistentStore()
      break
      
    default :
      break
      
    }
  }
  
  func performPostSessionChangeOperation(sessionChangeOperationId : UserSessionType, causeException : SessionManagerOperationFailedException?) {
    AppDelegate.getAppDelegate().log.debug("performPostSessionChangeOperation()")
    if (sessionChangeOperationId == .ClearUserSession) {
      SharedPreferenceHelper.clearSharedPreferences()
      self.currentSession = UserSession()
    }else if (sessionChangeOperationId == .ClearUserPersistence) {
      self.currentSession = UserSession()
    }
    else {
      if (causeException == nil) {
        performPostSessionChangeOperationOnAllModulesAfterDelay(sessionChangeOperationId: sessionChangeOperationId)
      }
    }
  }
  
  func performPostSessionChangeOperationOnAllModulesAfterDelay(sessionChangeOperationId : UserSessionType) {
    AppDelegate.getAppDelegate().log.debug("performPostSessionChangeOperationOnAllModulesAfterDelay()")
    
    DispatchQueue.main.asyncAfter(deadline: .now()+AppConfiguration.waitTimeBeforeStartingPostSessionInitialization , execute: {
      if (self.currentSession != nil && self.currentSession?.userSessionStatus == .User) {
        for moduleSessionHandler in self.moduleSessionHandlerList {
          moduleSessionHandler.performPostSessionInitializationOperations(sessionChangeOperationId: sessionChangeOperationId)
        }
      }
    })
  }
  
  private func rollbackSessionChangeOperationOnAllModules(sessionChangeOperationId : UserSessionType, causeException : SessionManagerOperationFailedException?){
    
    AppDelegate.getAppDelegate().log.debug("rollbackSessionChangeOperationOnAllModules()")
    // no need to roll back if the last session change operation was clearsession
    if UserSessionType.ClearUserSession != sessionChangeOperationId && UserSessionType.ClearUserPersistence != sessionChangeOperationId {
      for moduleSessionHandler in moduleSessionHandlerList {
        moduleSessionHandler.clearLocalMemoryOnSessionInitializationFailure()
      }
    }
    
    performPostSessionChangeOperation(sessionChangeOperationId: sessionChangeOperationId, causeException: causeException)
  }
  
  public func onGuestSession(){
    self.currentSession = UserSession(userId: "0", userPassword: "", userSessionStatus: UserSessionStatus.Guest, contactNo: "",countryCode: "")
  }
  
  public func getUserId() -> String {
    return (currentSession?.userId)!
  }
  
    private func saveUserDefaultData(newUser : User, userProfile : UserProfile){
        UserCoreDataHelper.saveUserObject(userObject: newUser)
        UserCoreDataHelper.saveUserProfileObject(userProfile: userProfile)
        SharedPreferenceHelper.storeLoggedInUserId(userId: StringUtils.getStringFromDouble(decimalNumber : newUser.phoneNumber))
        SharedPreferenceHelper.storeLoggedInUserName(userName: newUser.userName)
        SharedPreferenceHelper.storeCurrentUserGender(gender: newUser.gender)
        SharedPreferenceHelper.storeLoggedInUserContactNo(contactNo: StringUtils.getStringFromDouble(decimalNumber : newUser.contactNo))
        SharedPreferenceHelper.storeLoggedInUserCountryCode(countryCode: newUser.countryCode)
    }
  
  public func isUserLoggedIn(userId : String) -> Bool{
    return userId.components(separatedBy: ".")[0] == self.currentSession?.userId
  }
    
    func registerToReachbilityAndResumeSessionWhenNetworkIsAvailable(){
        
        if reachability != nil{
            return
        }
        reachability = Reachability()!
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability!.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
    }
    
    func resumeUserSession(){
        let appStartupHandler = AppStartupHandler(targetViewController: nil,  notificationActionIdentifier : nil,isbackGroundStartUp: false, completionHandler: {(sessionStart, sessionStop,sessionRestart) in
            
        })
        appStartupHandler.resumeUserSessionAndNavigateToAppropriateInitialView()
    }
    
    func stopReachabilityNotifier() {
        reachability!.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachabilityNotification = note.object as! Reachability
        
        switch reachabilityNotification.connection {
        case .wifi:
            QRReachability.isInternetAvailable { (status) in
                if status {
                    self.resumeUserSession()
                    self.stopReachabilityNotifier()
                }
            }
        case .cellular:
            self.resumeUserSession()
            self.stopReachabilityNotifier()
        case .none:
            AppDelegate.getAppDelegate().log.error("Network not reachable")
        }
    }
}
