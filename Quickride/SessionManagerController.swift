//
//  SessionManagerController.swift
//  Quickride
//
//  Created by KNM Rao on 09/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import FirebaseCrashlytics

public enum SessionManagerStatus {
  case SessionManagerNotInitialized
  case SessionManagerInitializationStarted
  case SessionManagerInitializationCompleted
  case SessionManagerInitializationFailed
}


public class SessionManagerController : SessionChangeCompletionListener{
  
  var sessionManagerInitializationStatus : SessionManagerStatus = SessionManagerStatus.SessionManagerNotInitialized
  private var sessionchangeCompletionListener : SessionChangeCompletionListener?
  private var sessionMgrInitializationFailureCause : SessionManagerOperationFailedException?
  private var sessionChangeCompletionListenerList : [SessionChangeCompletionListener]
  
  // TODO : Check creating cuncrrnet disaptch queue in swift 3
  
  
  private static let CONCURRENT_SMC_QUEUE_NAME : String = "com.disha.quickride.SMCQueue"
  private let concurrentSMCQueue = DispatchQueue(label: CONCURRENT_SMC_QUEUE_NAME, attributes: .concurrent)
  class var sharedInstance : SessionManagerController {
    struct Static {
      static let instance : SessionManagerController = SessionManagerController()
    }
    return Static.instance
  }
  
  private init(){
    sessionChangeCompletionListenerList = [SessionChangeCompletionListener]()
  }
  
  
  public func resumeUserSession(sessionChangeCompletionListener : SessionChangeCompletionListener?) {
    AppDelegate.getAppDelegate().log.debug("resumeUserSession()")
    Crashlytics.crashlytics().setUserID(SharedPreferenceHelper.getLoggedInUserId() ?? "")
    
    if (self.sessionManagerInitializationStatus == .SessionManagerInitializationStarted) {
      AppDelegate.getAppDelegate().log.debug("User session is already being initialized, will notify once it completes")
      if (sessionChangeCompletionListener != nil) {
        sessionChangeCompletionListenerList.append(sessionChangeCompletionListener!)
      }
      return
    }
    
    if (!canSessionManagerInitializationContinue(userId: nil, sessionChangeCompletionListener: sessionChangeCompletionListener)) {
      return
    }
      self.sessionManagerInitializationStatus = .SessionManagerInitializationStarted
    
    let sessionManager : QRSessionManager = QRSessionManager.createNewSessionManager()
    if (sessionManager.getCurrentSession().userSessionStatus != UserSessionStatus.User) {
      
      // If this session corresponds to new user registering for first time or an existing user
      // re-logging into app after previous logout, take no action here. The corresponding activity
      // will invoke appropriate initialize methods with user data like userId and password.
        
      self.sessionManagerInitializationStatus = .SessionManagerNotInitialized
      sessionChangeCompletionListener?.sessionChangeOperationFailed(exceptionCause: SessionManagerOperationFailedException.UserSessionNotFound)
      return
    }
    
    // If the app was closed by user or the app or any of its activities were removed by Android
    // to claim memory, either when the phone is idle or when the user is using other apps, then
    // when user re-opens the app or comes back to previously opened app, we need to resume the
    // user session.
    if (sessionChangeCompletionListener != nil) {
      sessionChangeCompletionListenerList.append(sessionChangeCompletionListener!)
    }
    var sessionChangeOpFailureCause : SessionManagerOperationFailedException? = nil
      do {
        try sessionManager.onResumeUserSession()
        self.sessionManagerInitializationStatus = .SessionManagerInitializationCompleted
      }
      catch let error as SessionManagerOperationFailedException {
        self.sessionManagerInitializationStatus = .SessionManagerInitializationFailed
        sessionChangeOpFailureCause = error
      }
      catch let error {
        sessionChangeOpFailureCause = self.getAppropriateInitializationFailureCause(error: error)
      }
    if (sessionChangeOpFailureCause == nil) {
      self.sessionChangeOperationCompleted()
    }
    else {
      self.sessionChangeOperationFailed(exceptionCause: sessionChangeOpFailureCause!)
    }
    
  }
  
  public func newUserSession(userId : String, password : String, userProfie : UserProfile, user: User, sessionChangeCompletionListener : SessionChangeCompletionListener?) {
    AppDelegate.getAppDelegate().log.debug("newUserSession() \(userId) \(password)")
    Crashlytics.crashlytics().setUserID(userId)
    
    if (self.sessionManagerInitializationStatus == .SessionManagerInitializationStarted) {
      AppDelegate.getAppDelegate().log.debug("User session is already being initialized, will notify once it completes")
      if (sessionChangeCompletionListener != nil) {
        sessionChangeCompletionListenerList.append(sessionChangeCompletionListener!)
      }
      return
    }
    
    if (!canSessionManagerInitializationContinue(userId: userId, sessionChangeCompletionListener: sessionChangeCompletionListener)) {
      return
    }
    
    if (sessionChangeCompletionListener != nil) {
      sessionChangeCompletionListenerList.append(sessionChangeCompletionListener!)
    }
    
    var sessionChangeOpFailureCause : SessionManagerOperationFailedException? = nil
    concurrentSMCQueue.sync() {
      self.sessionManagerInitializationStatus = SessionManagerStatus.SessionManagerInitializationStarted
      let sessionManager : QRSessionManager = QRSessionManager.createNewSessionManager()
      
      do {
        try sessionManager.newUserSession(userId: userId, password: password, userProfile: userProfie, user: user)
        self.sessionManagerInitializationStatus = .SessionManagerInitializationCompleted
      }
      catch let error as SessionManagerOperationFailedException {
        self.sessionManagerInitializationStatus = .SessionManagerInitializationFailed
        sessionChangeOpFailureCause = error
      }
      catch let error {
        sessionChangeOpFailureCause = self.getAppropriateInitializationFailureCause(error: error)
      }
    }
    
    if (sessionChangeOpFailureCause == nil) {
      self.sessionChangeOperationCompleted()
    }
    else {
      self.sessionChangeOperationFailed(exceptionCause: sessionChangeOpFailureCause!)
    }
   
  }
  
  public func reinitializeUserSession(userId : String, password : String, contactNo : String, countryCode : String,sessionChangeCompletionListener :SessionChangeCompletionListener?) {
          AppDelegate.getAppDelegate().log.debug("reinitializeUserSession() \(userId) \(password)")
    Crashlytics.crashlytics().setUserID(userId)
    if (!isNetworkConnectionAvailable(sessionChangeCompletionListener: sessionChangeCompletionListener)) {
       sessionChangeCompletionListener?.sessionChangeOperationFailed(exceptionCause: SessionManagerOperationFailedException.NetworkConnectionNotAvailable)
      return
    }
    
    if (self.sessionManagerInitializationStatus == .SessionManagerInitializationStarted) {
      AppDelegate.getAppDelegate().log.debug("User session is already being initialized, will notify once it completes")
      if (sessionChangeCompletionListener != nil) {
        sessionChangeCompletionListenerList.append(sessionChangeCompletionListener!)
      }
      return
    }
    
    if (!canSessionManagerInitializationContinue(userId: userId, sessionChangeCompletionListener: sessionChangeCompletionListener)) {
      return
    }
    
    if (sessionChangeCompletionListener != nil) {
      sessionChangeCompletionListenerList.append(sessionChangeCompletionListener!)
    }
    
    var sessionChangeOpFailureCause : SessionManagerOperationFailedException?

    concurrentSMCQueue.sync(){
      self.sessionManagerInitializationStatus = SessionManagerStatus.SessionManagerInitializationStarted
      let sessionManager = QRSessionManager.createNewSessionManager()
      
      do {
        try sessionManager.onReinitializeUserSession(userId: userId, password: password, contactNo: contactNo,countryCode: countryCode)
        self.sessionManagerInitializationStatus = .SessionManagerInitializationCompleted
      }
      catch let error as SessionManagerOperationFailedException {
        self.sessionManagerInitializationStatus = .SessionManagerInitializationFailed
        sessionChangeOpFailureCause = error
      }
      catch let error {
        sessionChangeOpFailureCause = self.getAppropriateInitializationFailureCause(error: error)
      }
    }
    
    
    if (sessionChangeOpFailureCause == nil) {
      self.sessionChangeOperationCompleted()
    }
    else {
      self.sessionChangeOperationFailed(exceptionCause: sessionChangeOpFailureCause!)
    }
  }
  
 
  public func clearUserSession(){
    AppDelegate.getAppDelegate().log.debug("clearUserSession()")
    concurrentSMCQueue.sync()
    {
      let sessionManager : QRSessionManager? = QRSessionManager.getInstance()
      if sessionManager != nil {
        do {
          try sessionManager!.onClearUserSession()
        }
        catch {
          AppDelegate.getAppDelegate().log.error("Error while clearing user session : \(error)")
        }
      }
      self.sessionManagerInitializationStatus = SessionManagerStatus.SessionManagerNotInitialized
    }
  }
  
  private func canSessionManagerInitializationContinue (userId : String?, sessionChangeCompletionListener : SessionChangeCompletionListener?) -> Bool {
    AppDelegate.getAppDelegate().log.debug("canSessionManagerInitializationContinue() \(String(describing: userId))")
    // Check if user session is already initialized
    if (self.sessionManagerInitializationStatus == .SessionManagerInitializationCompleted) {
      let sessionMgr = QRSessionManager.getInstance()
      if (sessionMgr != nil) {
        let currentUserSession = sessionMgr?.getCurrentSession()
        if (currentUserSession?.userSessionStatus == .User) {
          if (userId == nil || currentUserSession?.userId == userId) {
            AppDelegate.getAppDelegate().log.debug("Session Manager is already initialized with same user session")
            sessionChangeCompletionListener?.sessionChangeOperationCompleted()
            return false
          }
          else {
            AppDelegate.getAppDelegate().log.debug("Session Manager is already initialized with different user session ... clearing the existing session")
            clearUserSession()
            return true
          }
        }
      }
    }
    
    if (self.sessionManagerInitializationStatus == .SessionManagerInitializationStarted) {
      return false
    }
    else {
      return true
    }
  }
  
    public func sessionChangeOperationCompleted() {
        AppDelegate.getAppDelegate().log.debug("sessionChangeOperationCompleted()")
        Crashlytics.crashlytics().setUserID(SharedPreferenceHelper.getLoggedInUserId() ?? "")
        self.notifyListenerAboutSessionChangeOpCompletion()
        
        // handle watch dog service
        
    }
  
  public func sessionChangeOperationFailed(exceptionCause : SessionManagerOperationFailedException?){
    AppDelegate.getAppDelegate().log.debug("sessionChangeOperationFailed()")
    notifyListenerAboutSessionChangeOpFailure(exceptionCause: exceptionCause)
  }
  
  public func notifyListenerAboutSessionChangeOpCompletion(){
    AppDelegate.getAppDelegate().log.debug("notifyListenerAboutSessionChangeOpCompletion()")
    for sessionChangeListener in sessionChangeCompletionListenerList {
      sessionChangeListener.sessionChangeOperationCompleted()
    }
    
    sessionChangeCompletionListenerList.removeAll()
  }
  
  public func notifyListenerAboutSessionChangeOpFailure(exceptionCause : SessionManagerOperationFailedException?){
    AppDelegate.getAppDelegate().log.debug("notifyListenerAboutSessionChangeOpFailure()")
    for sessionChangeListener in sessionChangeCompletionListenerList {
      sessionChangeListener.sessionChangeOperationFailed(exceptionCause: exceptionCause)
    }
    
    sessionChangeCompletionListenerList.removeAll()
  }
  
  func isSessionManagerInitialized() -> Bool {
    AppDelegate.getAppDelegate().log.debug("\(self.sessionManagerInitializationStatus)")
    return self.sessionManagerInitializationStatus == SessionManagerStatus.SessionManagerInitializationCompleted
  }
  
  private func isNetworkConnectionAvailable(sessionChangeCompletionListener : SessionChangeCompletionListener?) -> Bool {
    AppDelegate.getAppDelegate().log.debug("isNetworkConnectionAvailable()")
    let isNetworkAvailable = QRReachability.isConnectedToNetwork()
    if (isNetworkAvailable) {
      return true
    }
    else {
     return false
    }
   
  }
  
  private func getAppropriateInitializationFailureCause(error : Error) -> SessionManagerOperationFailedException {
    AppDelegate.getAppDelegate().log.debug("getAppropriateInitializationFailureCause()")
    if (!QRReachability.isConnectedToNetwork()) {
      return SessionManagerOperationFailedException.NetworkConnectionNotAvailable
    }
    else {
      return SessionManagerOperationFailedException.SessionChangeOperationFailed
    }
  }
}
