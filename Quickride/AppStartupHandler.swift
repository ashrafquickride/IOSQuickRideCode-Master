 //
 //  AppStartupHandler.swift
 //  Quickride
 //
 //  Created by KNM Rao on 22/02/16.
 //  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
 //
 
 import Foundation
 import GoogleMaps
 import ObjectMapper
 import NetCorePush

typealias SessionCompletionHandler = (_ sessionInitializationStarted :Bool?,_ sessionInitializationStopped :Bool?, _ sessionInitializationRestarted :Bool?) -> Void

 class AppStartupHandler : SessionChangeCompletionListener{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let updatedLocation : CLLocation? = nil
    let notificationActionIdentifier : String?
    let targetViewController : UIViewController?
    var isbackGroundStartUp : Bool = false
    var completionHandler: SessionCompletionHandler?
    var sessionType : UserSessionType?

    
    init (targetViewController : UIViewController?,  notificationActionIdentifier : String?,isbackGroundStartUp : Bool, completionHandler: @escaping SessionCompletionHandler) {
        self.targetViewController = targetViewController
        self.notificationActionIdentifier = notificationActionIdentifier
        self.isbackGroundStartUp = isbackGroundStartUp
        self.completionHandler = completionHandler
    }
    
    func resumeUserSessionAndNavigateToAppropriateInitialView(){

        AppDelegate.getAppDelegate().log.debug("resumeUserSessionAndNavigateToAppropriateInitialView()")

        if isValidUserSession(){
           performSessionInitializationTask()
        }else{
            LogOutTask(viewController: ContainerTabBarViewController()).userLogOutTask()
        }
        
    }
    
    func performSessionInitializationTask(){
        
        let userObj = UserCoreDataHelper.getUserObject()
        if userObj == nil || !userObj!.isUserObjectValid(){
            sessionType = UserSessionType.ReinitializeUserSession
            DispatchQueue.global(qos: .userInitiated).async {
                SessionManagerController.sharedInstance.reinitializeUserSession(userId: SharedPreferenceHelper.getLoggedInUserId()!, password: SharedPreferenceHelper.getLoggedInUserPassword()!, contactNo: SharedPreferenceHelper.getLoggedInUserContactNo()!, countryCode: SharedPreferenceHelper.getLoggedInUserCountryCode()!, sessionChangeCompletionListener: self)
            }
        }else{
            sessionType = UserSessionType.ResumeUserSession
            SessionManagerController.sharedInstance.resumeUserSession(sessionChangeCompletionListener: self)
        }
        if let user = userObj {
             updatingUserProfileVersionoForCleverTap(user: user)
        }
    }
    
    func updatingUserProfileVersionoForCleverTap(user: User) {
        if let storeAppVersion = SharedPreferenceHelper.getAppVersionStatusForCleverTap(), storeAppVersion != AppConfiguration.APP_CURRENT_VERSION_NO {
            CleverTapAnalyticsUtils.getInstance().trackProfileEvent(user: user)
            SharedPreferenceHelper.saveAppVersionStatusForCleverTap(status: AppConfiguration.APP_CURRENT_VERSION_NO)
        }
    }
    
    func isValidUserSession() -> Bool{
        if SharedPreferenceHelper.getLoggedInUserId() == nil || SharedPreferenceHelper.getLoggedInUserContactNo() == nil || SharedPreferenceHelper.getLoggedInUserCountryCode() == nil || SharedPreferenceHelper.getLoggedInUserPassword() == nil{
            return false
        }
        else{
            return true
        }
    }
   
    func sessionChangeOperationCompleted() {
        AppDelegate.getAppDelegate().log.debug("sessionChangeOperationCompleted()")
        DispatchQueue.main.async() { () -> Void in
        self.completionHandler!(true,false,false)
        self.updateUserSessionDetails()
        self.pushUserPropertyForNetCoreTracking()
            if let remoteNotification = QuickRideRemoteBackgroundNotificationHandler.remoteNotificationBeforeAppStart{
                QuickRideRemoteBackgroundNotificationHandler().handleRemoteNotifications(userInfo: remoteNotification)
                QuickRideRemoteBackgroundNotificationHandler.remoteNotificationBeforeAppStart = nil
            }else if SharedPreferenceHelper.getViewPrefixForDeepLink() != nil || SharedPreferenceHelper.getDeepLink() != nil
         {
            
            ViewControllerNavigationUtils.openSpecificViewController(viewController: self.targetViewController)
          
         }else{
            AppStartupHandler.checkViewControllerAndNavigate(viewController: self.targetViewController)
        }
        
        self.registerDeviceToken()
        LocationChangeListener.getInstance().refreshLocationUpdateRequirementStatus()
        if self.isbackGroundStartUp == true{
            AppDelegate.getAppDelegate().log.debug("backgrounStartup()")
            return
        }
       
            NotificationStore.getInstance().processRecentNotifiation()
           NotificationStore.getInstance().getAllPendingNotificationsFromServer()
            
         }
    }
    func updateUserSessionDetails()
    {
        let containerTabBarViewController = ContainerTabBarViewController()
        let currentUserSession = QRSessionManager.getInstance()!.getCurrentSession()
        let modelName = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        
        UserRestClient.validateAndUpdateUserActiveSessionDetails(appVersionName: AppUtil.getCurrentAppVersionName(), userId: currentUserSession.contactNo, phoneCode: SharedPreferenceHelper.getLoggedInUserCountryCode(), password: currentUserSession.userPassword, appName : AppConfiguration.APP_NAME, phoneModel: modelName + " " + systemVersion, uiViewController: containerTabBarViewController, completionController:  { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                let responseError = Mapper<ResponseError>().map(JSONObject:  responseObject!["resultData"])
                if responseError?.errorCode == ServerErrorCodes.USER_SUBSCRIPTION_REQUIRED_ERROR{
                    UserDataCache.SUBSCRIPTION_STATUS = true
                }else if responseError?.errorCode == UserMangementException.USER_CREDENTILS_NOT_CORRECT || responseError?.errorCode == UserMangementException.USER_EXISTED_PASSWORD_NOT_CORRECT || responseError?.errorCode == UserMangementException.USER_ACCOUNT_SUSPENDED_ERROR || responseError?.errorCode == UserMangementException.QR_USER_ACCOUNT_SUSPENDED_ERROR || responseError?.errorCode == UserMangementException.USER_NOT_REGISTERED || responseError?.errorCode == UserMangementException.USER_NOT_ACTIVATED || responseError?.errorCode == AccountException.ACCOUNT_DOESNOT_EXIST {
                    SessionManagerController.sharedInstance.clearUserSession()
                    LogOutTask(viewController: ContainerTabBarViewController()).userLogOutTask()
                }
            }
            else {
                if error == QuickRideErrors.NetworkConnectionNotAvailableError{
                    QRSessionManager.getInstance()?.registerToReachbilityAndResumeSessionWhenNetworkIsAvailable()
                }
            }
            
        })
        
       
        
    }
    
    func pushUserPropertyForNetCoreTracking() {
        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        NetCoreInstallation.sharedInstance().netCorePushLogin(SharedPreferenceHelper.getLoggedInUserId(), block: nil)
        
        let profilePushDictionary = ["NAME": userProfile?.userName,"MOBILE": SharedPreferenceHelper.getLoggedInUserContactNo()]
        NetCoreInstallation.sharedInstance().netCoreProfilePush(SharedPreferenceHelper.getLoggedInUserId(), payload:profilePushDictionary as [AnyHashable : Any], block:nil)
    }
    
    func sessionChangeOperationFailed(exceptionCause : SessionManagerOperationFailedException?) {
        AppDelegate.getAppDelegate().log.debug("Error while resuming user session \(String(describing: exceptionCause))")
        
        DispatchQueue.main.async() {
            self.completionHandler!(false,true,false)
        if self.updatedLocation != nil {
          return
        }
            if  self.sessionType == UserSessionType.ResumeUserSession{
                if exceptionCause == SessionManagerOperationFailedException.NetworkConnectionNotAvailable || exceptionCause == SessionManagerOperationFailedException.CouldNotValidateUserSession || exceptionCause == SessionManagerOperationFailedException.SessionChangeOperationTimedOut{
                    QRSessionManager.getInstance()?.registerToReachbilityAndResumeSessionWhenNetworkIsAvailable()
                }else if exceptionCause == SessionManagerOperationFailedException.InvalidUserSession || exceptionCause == SessionManagerOperationFailedException.UserSessionNotFound{
                    
                    LogOutTask(viewController: ContainerTabBarViewController()).userLogOutTask()
                    
                }else {
                    if self.targetViewController != nil {
                        ErrorProcessUtils.displayServerError(viewController: self.targetViewController!)
                    }
                }
            }else{
                if self.targetViewController != nil {
                  ErrorProcessUtils.handleError(responseObject: nil, error: QuickRideErrors.RequestTimedOutError, viewController:  self.targetViewController!, handler: nil)
                  return
                }
            }
        }
      }
 
    private func registerDeviceToken() {
        AppDelegate.getAppDelegate().log.debug("registerDeviceToken()")
        if targetViewController == nil {
            // Indicates session was resumed to handle location updates
            return
        }
        let userDefaults = UserDefaults.standard
        let deviceToken = userDefaults.string(forKey: "deviceTokenString")
        if (deviceToken != nil) {
            let deviceRegistrationHelper = DeviceRegistrationHelper(sourceViewController: self.targetViewController!, phone: QRSessionManager.sharedInstance!.getUserId(), deviceToken: deviceToken!)
            deviceRegistrationHelper.registerDeviceTokenWithQRServer()
        }
    }
    
    static func checkViewControllerAndNavigate(viewController : UIViewController?)
    {
        var status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_FEATURE_SELECTION_DETAILS)
        if status != nil && status == false
        {
            let featureSelectionVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "FeatureSelectionViewController") as! FeatureSelectionViewController
            AppStartUpUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed : featureSelectionVC)
            return
         }
        status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROLE_DETAILS)
        if status != nil && status == false
        {
            let ridePreferencesViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RidePreferenceViewController") as! RidePreferenceViewController
            AppStartUpUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed : ridePreferencesViewController)
            return
        }
        status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROUTE_INFO)
        if status != nil && status == false{
            let rideCreateViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideCreateViewController") as! RideCreateViewController
            AppStartUpUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed : rideCreateViewController)
            return
        }
        status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_PROFILE_PIC_UPLOAD)
        if status != nil && status == false{
            let addProfilePictureViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddProfilePictureViewController") as! AddProfilePictureViewController
            AppStartUpUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed : addProfilePictureViewController)
            return
        }else{
            RideManagementUtils.updateStatusAndNavigate(isFromSignupFlow: false, viewController: viewController, handler: nil)
        }
    }
    
 }
