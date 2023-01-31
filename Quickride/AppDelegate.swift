  //
  //  AppDelegate.swift
  //  Quickride
  //
  //  Created by KNM Rao on 17/09/15.
  //  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
  //
  
  import UIKit
  import CoreData
  import GoogleMaps
  import XCGLogger
  import ObjectMapper
  import FirebaseCrashlytics
  import Moscapsule
  import UserNotifications
  import TrueSDK
  import FBSDKCoreKit
  import Firebase
  import FirebaseDynamicLinks
  import FirebaseMessaging
//  import AppsFlyerLib
  import SimplZeroClick
  import NetCorePush
  import UserNotificationsUI
  import AdSupport
  import LoginWithAmazon
  import PWAINSilentPayiOSSDK
  import CleverTapSDK
  import GoogleSignIn
  import IQKeyboardManagerSwift
  import Adjust
  import Branch
  import HyperSnapSDK
  
  typealias AddDismissHandler = () -> Void
  
   @UIApplicationMain  class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate,MessagingDelegate,NetCorePushTaskManagerDelegate,AdjustDelegate{
    
    var window: UIWindow?
    let log = XCGLogger.default
    var application : UIApplication?
    var launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    var anotherLocationManager : CLLocationManager?
    let userDefaults = UserDefaults.standard
    var emergencyInitiator : EmergencyInitiator?
    var emergencyService: EmergencyService?
    var logPath : URL?
    var logPathBackup : URL?
    var adjConfig : ADJConfig?
    var isNotificationNavigationRequired = false
    var googleSignInConfig: GIDConfiguration?
    static let logFileName = "QuickRideLogs.txt"
    static let logFileName_Backup = " QuickRideLogs_Backup.txt"
    
    static var appDelegate :AppDelegate?
    static var gaiURLString = ""
       
//    var interstitial : GADInterstitial!
//    var handler : AddDismissHandler?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool
    {
        AppDelegate.appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        NetworkMonitor.shared.startMonitoring()
        GMSServices.provideAPIKey(AppConfiguration.googleMapsKey)
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        LocationCache.createCacheInstance()
//        if let gai = GAI.sharedInstance(){
//            gai.tracker(withTrackingId: AppConfiguration.GOOGLE_ANALYTICS_ID)
//            gai.defaultTracker.allowIDFACollection = true
//        }
//        GADMobileAds.configure(withApplicationID: AppConfiguration.admod_app_id)
        // Override point for customization after application launch.
        self.application = application
        self.launchOptions = launchOptions

        UINavigationBar.appearance().backgroundColor = UIColor(netHex: 0xF7F7F7)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        initialiseLogger()
       
        if (launchOptions != nil)
        {
            log.debug("opened from a push notification when the app is closed")
        }
        log.debug("Starting Application with logging enabled")
        if  self.launchOptions?[UIApplication.LaunchOptionsKey.location] as? NSObject != nil{
            if (SessionManagerController.sharedInstance.isSessionManagerInitialized()) {
                LocationChangeListener.getInstance().refreshLocationUpdateRequirementStatus()
            }else {
                // Resume session and then handle notification
                let appStartupHandler = AppStartupHandler(targetViewController: self.window!.rootViewController!, notificationActionIdentifier : nil,isbackGroundStartUp: true, completionHandler: {(sessionStart, sessionStop,sessionRestart) in
                    
                })
                appStartupHandler.resumeUserSessionAndNavigateToAppropriateInitialView()
            }
        }
        if TCTrueSDK.sharedManager().isSupported() {
            TCTrueSDK.sharedManager().setup(withAppKey: "vBWHDb55498b652db4466b89de8aec3f78ee0", appLink: "https://sicb8a9de976cd4993856fc6eb0c730d81.truecallerdevs.com")
        }
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        AppLinkUtility.fetchDeferredAppLink({ url, error in
            if url != nil && UIApplication.shared.canOpenURL(url! as URL){
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
            if error != nil {
                print("Received error while fetching deferred app link \(String(describing: error))")
            }
        })
//        AppsFlyerTracker.shared().appsFlyerDevKey = AppConfiguration.APPSFLYER_DEV_KEY
//        AppsFlyerTracker.shared().appleAppID = AppConfiguration.APPLE_APP_ID
//        AppsFlyerTracker.shared().delegate = self
//        #if DEBUG
//         AppsFlyerTracker.shared().isDebug = true
//        #endif
        
        GSManager.initialize(withMerchantID: AppConfiguration.SIMPL_MERCHANT_ID) 
        
        let kSmartechAppID = AppConfiguration.netcore_prod_app_id
        let kAppGroup = "group.com.disha.ios.quickride"
        
        NetCoreSharedManager.sharedInstance().setUpAppGroup(kAppGroup)
        NetCoreSharedManager.sharedInstance().handleApplicationLaunchEvent(launchOptions, forApplicationId: kSmartechAppID)
        NetCorePushTaskManager.sharedInstance().delegate = self
        NetCoreSharedManager.sharedInstance().setAssociateDomain(["quickride.onelink.me","idisha.page.link"])
        googleSignInConfig = GIDConfiguration.init(clientID: AppConfiguration.GOOGLE_CLIENT_ID)
        IQKeyboardManager.shared.enable = true
        CleverTapAnalyticsUtils.getInstance().initializeCleverTap()
        CleverTap.autoIntegrate()
//        AppsFlyerTracker.shared().customerUserID = CleverTap.sharedInstance()?.profileGetAttributionIdentifier()
        setUpAdjustSDK()
        // if you are using the TEST key
        Branch.setUseTestBranchKey(true)
        // listener for Branch Deep Link data
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            // do stuff with deep link data (nav to page, display content, etc)
            self.saveUserDataToBranch(params: params as? [String : AnyObject] ?? [:])
            print(params as? [String: AnyObject] ?? {})
        }
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        //Initialise HyperVerge SDK Credentials here
        HyperSnapSDKConfig.initialize(appId: ConfigurationCache.getObjectClientConfiguration().hyperVergeAppId, appKey: ConfigurationCache.getObjectClientConfiguration().hyperVergeAppKey, region: .India)
        return true
    }
    
   func initialiseLogger() {
        checkAndHandleCurrentLog()
        log.setup(level: .debug, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: logPath, fileLevel: .debug)

        log.debug("Starting Application with logging enabled; Logs path : \(String(describing: self.logPath))")
    }
    func checkAndHandleCurrentLog(){
        
         let availableSpace = deviceRemainingFreeSpaceInBytes()
        if availableSpace! < 200{
            print("available space in device : \(String(describing: availableSpace))")
            return
        }
        let cacheDirectory: NSURL = {
            let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
            return urls[urls.endIndex - 1] as NSURL
        }()
        logPath = cacheDirectory.appendingPathComponent(AppDelegate.logFileName)! as URL
        if logPath == nil {
            return
        }
        let data = NSData(contentsOf: logPath!)
        if data != nil{
            setCurrentLogToBackup(logData: data!)
        }
    }
    func setCurrentLogToBackup(logData : NSData)
    {
        let cacheDirectory: NSURL = {
            let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
            return urls[urls.endIndex - 1] as NSURL
        }()
        logPathBackup = cacheDirectory.appendingPathComponent(AppDelegate.logFileName_Backup)! as URL
        if logPathBackup == nil{
            return
        }
        checkSizeOfBackupLogAndClear(currentLog: logData)
        if let fileHandle = FileHandle(forWritingAtPath: logPathBackup!.path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(logData as Data)
            fileHandle.closeFile()
        }
        else {
            do{
                try logData.write(to: logPathBackup! as URL, options: NSData.WritingOptions.atomic)
            }catch{
                print(error)
            }
        }
    }
    func checkSizeOfBackupLogAndClear(currentLog : NSData?){
        let cacheDirectory: NSURL = {
            let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
            return urls[urls.endIndex - 1] as NSURL
        }()
        let data = NSData(contentsOf: logPathBackup!)
        if (data != nil && data!.length/1024 > AppConfiguration.QuickRideLogCatBackUpSize) || (currentLog != nil && currentLog!.length/1024 > AppConfiguration.QuickRideLogCatBackUpSize) || (data != nil && currentLog != nil && (currentLog!.length+data!.length)/1024 > AppConfiguration.QuickRideLogCatBackUpSize) {
            do {
                try FileManager.default.removeItem(at: logPathBackup! as URL)
                logPathBackup = cacheDirectory.appendingPathComponent(AppDelegate.logFileName_Backup)! as URL
            }catch{
                print(error)
            }
        }
    }
    func deviceRemainingFreeSpaceInBytes() -> Int64? {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        do{
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath:
                documentDirectoryPath.last! as String)
            if let freeSize = systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber {
                return freeSize.int64Value/(1024*1024)
            }
        }catch _ as NSError{
            return nil
        }
        return nil
    }
    func registerForNotifications()
    {
        AppDelegate.getAppDelegate().log.debug("")
        self.setNotificationActionCategories()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(grant, error)  in
            if error == nil {
                if grant {
                    DispatchQueue.main.async() { () -> Void in
                        UIApplication.shared.registerForRemoteNotifications()
                        NotificationStore.isNotificationSettingsRequested = false
                    }

                } else {
                    NotificationStore.isNotificationSettingsRequested = true
                }
            } else {
                AppDelegate.getAppDelegate().log.error("error: \(String(describing: error))")
            }
        })
    }

     @available(iOS 10.0, *)
     func setNotificationActionCategories() {
        // Configure User Notification Center
        UNUserNotificationCenter.current().delegate = self
        
        // Define Actions
        let acceptAction = UNNotificationAction(identifier: NotificationHandler.POSITIVE_ACTION_ID, title: Strings.ACCEPT, options: [.foreground])
        let rejectAction = UNNotificationAction(identifier: NotificationHandler.NEGATIVE_ACTION_ID, title: Strings.REJECT, options: [.destructive])
        let profileAction = UNNotificationAction(identifier: NotificationHandler.NEUTRAL_ACTION_ID, title: Strings.VIEW, options: [.foreground])
        let checkInAction = UNNotificationAction(identifier: NotificationHandler.POSITIVE_ACTION_ID, title: Strings.CHECKIN, options: [.foreground])
        let checkOutAction = UNNotificationAction(identifier: NotificationHandler.POSITIVE_ACTION_ID, title: Strings.CHECKOUT, options: [.foreground])
        let startAction = UNNotificationAction(identifier: NotificationHandler.POSITIVE_ACTION_ID, title: Strings.START, options: [.foreground])
        let stopAction = UNNotificationAction(identifier: NotificationHandler.POSITIVE_ACTION_ID, title: Strings.STOP, options: [.foreground])
        let stop_remind = UNNotificationAction(identifier: NotificationHandler.POSITIVE_ACTION_ID, title: Strings.dont_remind, options: [.foreground])
        let renewAction = UNNotificationAction(identifier: NotificationHandler.POSITIVE_ACTION_ID, title: Strings.renew_pass, options: [.foreground])
        let yesAction = UNNotificationAction(identifier: NotificationHandler.POSITIVE_ACTION_ID, title: Strings.yes_caps, options: [.foreground])
        let noAction = UNNotificationAction(identifier: NotificationHandler.POSITIVE_ACTION_ID, title: Strings.no_caps, options: [.foreground])
        let rescheduleAction = UNNotificationAction(identifier: NotificationHandler.POSITIVE_ACTION_ID, title: Strings.reschedule, options: [.foreground])
        let dont_remind = UNNotificationAction(identifier: NotificationHandler.NEGATIVE_ACTION_ID, title: Strings.dont_remind, options: [.destructive])
        let viewToJoinAction = UNNotificationAction(identifier: NotificationHandler.POSITIVE_ACTION_ID, title: Strings.VIEW_TO_JOIN, options: [.foreground])
        let unsubscribeAction = UNNotificationAction(identifier: NotificationHandler.NEGATIVE_ACTION_ID, title: Strings.unsubscribe, options: [.foreground])
        let disputeAction = UNNotificationAction(identifier: NotificationHandler.POSITIVE_ACTION_ID, title: Strings.Dispute, options: [.foreground])
        // Define Category
        let threeActionCategory = UNNotificationCategory(identifier: NotificationHandler.THREE_ACTION_CATEGORY, actions: [acceptAction, rejectAction, profileAction], intentIdentifiers: [], options: [])
        let OneActionCategory = UNNotificationCategory(identifier: NotificationHandler.ONE_ACTION_CATEGORY, actions: [startAction], intentIdentifiers: [], options: [])
        let riderInviteCategory = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_RM_RIDER_INVITATION, actions: [acceptAction, rejectAction, profileAction], intentIdentifiers: [], options: [])
        let passengerInviteCategory = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_RM_PASSENGER_INVITATION, actions: [acceptAction, rejectAction, profileAction], intentIdentifiers: [], options: [])
        let riderToStartRideCategory = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_RE_RIDER_TO_START_RIDE, actions: [startAction], intentIdentifiers: [], options: [])
        let riderToStopRideCategory = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_RE_RIDER_TO_STOP_RIDE, actions: [stopAction], intentIdentifiers: [], options: [])
        let psgrToCheckinRideCategory = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_RE_PASSENGER_TO_CHECKIN_RIDE, actions: [checkInAction], intentIdentifiers: [], options: [])
        let psgrToCheckoutRideCategory = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_RE_PASSENGER_TO_CHECKOUT_RIDE, actions: [checkOutAction], intentIdentifiers: [], options: [])
        let renewPassActionCategory = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_RIDE_PASS_EXPIRE, actions: [renewAction], intentIdentifiers: [], options: [])

        let customNotification = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_IMAGE_NOTIFICATION, actions: [], intentIdentifiers: [], options: [])
        let locationEnableReminder = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_RE_ENABLE_LOCATION_REMINDER, actions: [stop_remind], intentIdentifiers: [], options: [])
        let recurringRideCancellation = UNNotificationCategory(identifier: UserNotification.RM_RIDE_CANCELLATION_SUGGESTION, actions: [yesAction,noAction], intentIdentifiers: [], options: [])
        let passengerRideRescheduleSuggestions = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_RESCHEDULE_RIDE_TO_PASSEGER, actions: [rescheduleAction, dont_remind], intentIdentifiers: [], options: [])
        let riderRideRescheduleSuggestions = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_RESCHEDULE_RIDE_TO_RIDER, actions: [rescheduleAction, dont_remind], intentIdentifiers: [], options: [])
        let inviteByContactCategory = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_RM_CONTACT_INVITATION, actions: [viewToJoinAction, rejectAction], intentIdentifiers: [], options: [])
        let bestMatchRiderCategory = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_RIDE_MATCHES_FOUND_NOTIFICATION_TO_RIDER, actions: [viewToJoinAction, unsubscribeAction], intentIdentifiers: [], options: [])
        let bestMatchPassengerCategory = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_RIDE_MATCHES_FOUND_NOTIFICATION_TO_PASSEGER, actions: [viewToJoinAction, unsubscribeAction], intentIdentifiers: [], options: [])
        let driverPaymentCategory = UNNotificationCategory(identifier: UserNotification.NOT_TYPE_QT_EXTRA_FARE_DETAILS_ADDED_TO_CUSTOMER, actions: [disputeAction], intentIdentifiers: [], options: [])
        // Register Category
        UNUserNotificationCenter.current().setNotificationCategories([threeActionCategory, OneActionCategory, riderInviteCategory, passengerInviteCategory, riderToStartRideCategory, riderToStopRideCategory, psgrToCheckinRideCategory, psgrToCheckoutRideCategory,customNotification,locationEnableReminder,renewPassActionCategory,recurringRideCancellation,passengerRideRescheduleSuggestions,riderRideRescheduleSuggestions,inviteByContactCategory,bestMatchRiderCategory,bestMatchPassengerCategory,driverPaymentCategory])
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AppDelegate.getAppDelegate().log.debug("")
        Messaging.messaging().apnsToken = deviceToken
//        AppsFlyerTracker.shared().registerUninstall(deviceToken)
        Adjust.setDeviceToken(deviceToken)
        if let userId = SharedPreferenceHelper.getLoggedInUserId(){
            NetCoreInstallation.sharedInstance()?.netCorePushRegisteration(userId, withDeviceToken: deviceToken, block:nil)
        }else{
            NetCoreInstallation.sharedInstance()?.netCorePushRegisteration("", withDeviceToken: deviceToken, block:nil)
        }
  
    	NetCoreSharedManager.sharedInstance().printDeviceToken()
        
      let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        if !deviceTokenString.isEmpty {
            AppDelegate.getAppDelegate().log.debug("\(deviceTokenString)")
            userDefaults.setValue(deviceTokenString, forKey: "deviceTokenString")
            let phone = QRSessionManager.getInstance()?.getUserId()
            if phone != nil && (phone!.count) > 1 && !deviceTokenString.isEmpty{
                
                DeviceRegistrationHelper(sourceViewController: nil, phone: phone!, deviceToken: deviceTokenString).registerDeviceTokenWithQRServer()
            }
        }
  }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AppDelegate.getAppDelegate().log.error("Device token for push notification : FAIL -- \(error.localizedDescription)")
    }
    
    func createUserNotificationAction(identifier : String, title : String, activationMode : UIUserNotificationActivationMode, authenticationRequired : Bool, destructive : Bool) -> UIMutableUserNotificationAction {
        AppDelegate.getAppDelegate().log.debug("\(identifier) \(title)")
        let notificationAction = UIMutableUserNotificationAction()
        notificationAction.identifier = identifier // the unique identifier for this action
        notificationAction.title =  title // title for the action button
        notificationAction.activationMode = activationMode // UIUserNotificationActivationMode.Background - don't bring app to foreground
        notificationAction.isAuthenticationRequired = authenticationRequired // don't require unlocking before performing action
        notificationAction.isDestructive = destructive // display action in red
        return notificationAction
    }
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        AppDelegate.getAppDelegate().log.debug("didReceiveLocalNotification is called for notification : \(notification)")
        let userNotification = self.getUserNotificationFromLocalNotification(localNotification: notification)
        var notificationHandler: NotificationHandler? = nil
        if (userNotification != nil) {
            notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: userNotification!)
        }
        notificationHandler?.handleNewUserNotification(clientNotification: userNotification!)
        if let userInfo = notification.userInfo{
           NetCorePushTaskManager.sharedInstance().didReceiveLocalNotification(userInfo)
        }
    }
    
    private func getUserNotificationFromLocalNotification(localNotification: UILocalNotification) -> UserNotification? {
        AppDelegate.getAppDelegate().log.debug("")
        var userNotification: UserNotification? = nil
        
        let msgClassName = localNotification.userInfo![UserNotification.MSG_CLASS_NAME] as? String
        if (msgClassName == UserNotification.USER_NOTIFICATION_CLASS_NAME) {
            userNotification = Mapper<UserNotification>().map(JSONObject: localNotification.userInfo![UserNotification.MSG_OBJECT_JSON] as! String)! as UserNotification
        }
        else {
            if let userNotificaitonId = localNotification.userInfo!["UUID"] as? String{
               userNotification = NotificationStore.getInstance().getUserNotificationWithId(notificationId: Int(userNotificaitonId)!)
            }
            
        }
        return userNotification
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        AppDelegate.getAppDelegate().log.debug("Received remote notification fetchCompletionHandler :\(notification.description)")
        getUserNotificationFromRemoteNotification(userInfo: notification.request.content.userInfo){ (newUserNotification) in
            if (newUserNotification != nil) {
                if EventServiceStore.getInstanceIfExists() != nil && EventServiceStore.getInstance().isDuplicateMessage(newMessageId: newUserNotification!.uniqueID!){
                    AppDelegate.getAppDelegate().log.debug("Redundant notification ")
                    return
                }
                else
                {
                    self.processRemoteNotification(userInfo: notification.request.content.userInfo)
                    completionHandler(UNNotificationPresentationOptions.badge)
                }
            }else if notification.request.identifier == "smartechPush" || notification.request.content.categoryIdentifier == "smartechPush"{
                completionHandler([.alert, .badge, .sound])
            }else{
                QuickRideRemoteBackgroundNotificationHandler().handleRemoteNotifications(userInfo: notification.request.content.userInfo)
            }
        }
    }
    
   
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        AppDelegate.getAppDelegate().log.debug("Received response for remote notification fetchCompletionHandler :\(response.notification.description)")
        if response.notification.request.content.categoryIdentifier == "smartechPush" || response.notification.request.identifier == "smartechPush"{
          NetCorePushTaskManager.sharedInstance().userNotificationdidReceive(response)
        }else{
           processRemoteNotificationForIOS10(response: response)
        }
        completionHandler()
    }
    
   
    func processRemoteNotificationForIOS10(response : UNNotificationResponse)
    {
        AppDelegate.getAppDelegate().log.debug("")
        if self.launchOptions != nil && self.launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary == nil
        {
            AppDelegate.getAppDelegate().log.debug("Tapped on remote notification when the app is closed & info is nil")
            return
        }
        if (QRSessionManager.getInstance()?.getCurrentSession().userSessionStatus != .User) {
            return
        }
        let notificationResponse = response.notification.request.content.userInfo
            
        getUserNotificationFromRemoteNotification(userInfo: notificationResponse) { (newUserNotification) in
            if (newUserNotification != nil) {
                if response.actionIdentifier == "com.apple.UNNotificationDefaultActionIdentifier"
                {
                    self.handleUserNotification(newUserNotification: newUserNotification!)
                }
                else
                {
                    self.handleUserNotificationAction(clientNotification: newUserNotification!, response : response)
                }
            }else{
                  QuickRideRemoteBackgroundNotificationHandler().handleRemoteNotifications(userInfo: response.notification.request.content.userInfo)
            }
        }
        
    }
    
    func handleUserNotificationAction(clientNotification : UserNotification, response : UNNotificationResponse)
    {
        let notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: clientNotification)
        
        if (SessionManagerController.sharedInstance.isSessionManagerInitialized()) {
            // Session is already initialized, handle notification
            notificationHandler?.handleAction(identifier: response.actionIdentifier, userNotification: clientNotification)
        }
        else {
            //Resume session and then handle notification
            
            SharedPreferenceHelper.saveRecentNotification(notification: clientNotification)
            let appStartupHandler = AppStartupHandler(targetViewController:
                self.window!.rootViewController!, notificationActionIdentifier : response.actionIdentifier,isbackGroundStartUp: false, completionHandler: {(sessionStart, sessionStop,sessionRestart) in
                    
            })
            NotificationStore.notificationAction = response.actionIdentifier
            appStartupHandler.resumeUserSessionAndNavigateToAppropriateInitialView()
        }
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppDelegate.getAppDelegate().log.debug("Received remote notification fetchCompletionHandler :\(userInfo)")
        if application.applicationState == .background || application.applicationState == .inactive{
            isNotificationNavigationRequired = true
        }else{
            isNotificationNavigationRequired = false
        }
        processRemoteNotification(userInfo: userInfo)
        NetCorePushTaskManager.sharedInstance().didReceiveRemoteNotification(userInfo)
        Branch.getInstance().handlePushNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        AppDelegate.getAppDelegate().log.debug("Received remote notification :\(userInfo)")
        if application.applicationState == .background || application.applicationState == .inactive{
            isNotificationNavigationRequired = true
        }else{
            isNotificationNavigationRequired = false
        }
        processRemoteNotification(userInfo: userInfo)
    }
    
    func processRemoteNotification(userInfo : [AnyHashable : Any]){
        AppDelegate.getAppDelegate().log.debug("\(userInfo)")
        if (QRSessionManager.getInstance()?.getCurrentSession().userSessionStatus != .User) {
            QuickRideRemoteBackgroundNotificationHandler().handleRemoteNotifications(userInfo: userInfo)
            return
        }
        getUserNotificationFromRemoteNotification(userInfo: userInfo) {(newUserNotification) in

            if (newUserNotification != nil) {
                self.handleUserNotification(newUserNotification: newUserNotification!)
            }else{
                QuickRideRemoteBackgroundNotificationHandler().handleRemoteNotifications(userInfo: userInfo)
            }
        }
    }
    func getUserNotificationFromRemoteNotification(userInfo: [AnyHashable : Any], handler: CompletionHandlers.notificationRetrievalCompletionHandler?) {
        
        var userNotification: UserNotification?
        if let msgClassName = userInfo[AnyHashable(UserNotification.MSG_CLASS_NAME)] as? String, msgClassName == UserNotification.USER_NOTIFICATION_CLASS_NAME, let aps = userInfo["aps"] as? [String: AnyObject]
        {
            let notificationInfo = userInfo[AnyHashable(UserNotification.MSG_OBJECT_JSON) as NSObject] as? String
            if notificationInfo != nil {
                userNotification = Mapper<UserNotification>().map(JSONString: notificationInfo!)
                if userNotification?.payloadType == QuickRideMessageEntity.PAYLOAD_PARTIAL {
                    CommunicationRestClient.getUserNotificationForId(notificationId: StringUtils.getStringFromDouble(decimalNumber: userNotification?.uniqueId ?? 0), viewController: nil) { (responseObject, error) in
                        if responseObject != nil && responseObject!["result"] as? String == "SUCCESS" {
                            let notification = Mapper<UserNotification>().map(JSONObject: responseObject!["resultData"])
                            handler?(notification)
                        } else {
                            handler?(nil)
                        }
                    }
                } else {
                    let alertBody = aps["alert"]
                    if alertBody != nil{
                        userNotification?.title = alertBody!.value(forKey: "title") as? String
                        userNotification?.description = alertBody!.value(forKey: "body") as? String
                    }
                    if userNotification?.rideStatus != nil{
                        let notificationData = Mapper<NotificationData>().map(JSONString: userInfo[AnyHashable(UserNotification.MSG_OBJECT_JSON) as NSObject] as! String)
                        if notificationData?.rideReschedule != nil{
                            userNotification!.rideStatus!.scheduleTime = AppUtil.createNSDate(dateString: notificationData!.rideReschedule!.scheduleTime)?.getTimeStamp()
                            userNotification!.rideStatus!.rescheduleTime = AppUtil.createNSDate(dateString: notificationData!.rideReschedule!.rescheduleTime)?.getTimeStamp()
                        }
                        
                    }
                    handler?(userNotification)
                }
            } else {
                handler?(nil)
            }
        } else {
            handler?(nil)
        }
    }
    
    func handleUserNotification(newUserNotification: UserNotification){
        AppDelegate.getAppDelegate().log.debug("\(String(describing: newUserNotification.groupName)) \(String(describing: newUserNotification.uniqueId))")
        let notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: newUserNotification)
        if notificationHandler != nil && newUserNotification.uniqueID != nil{
            if (SessionManagerController.sharedInstance.isSessionManagerInitialized()) {
                if EventServiceStore.getInstanceIfExists() != nil && EventServiceStore.getInstance().isDuplicateMessage(newMessageId: newUserNotification.uniqueID!){
                    AppDelegate.getAppDelegate().log.debug("Redundant notification ")
                    return
                }
                // Session is already initialized, handle notification
                notificationHandler?.handleNewUserNotification(clientNotification: newUserNotification)
                NotificationHandler.playTTS = true
            }
            else {
                // Resume session and then handle notification
                
                SharedPreferenceHelper.saveRecentNotification(notification: newUserNotification)
                let appStartupHandler = AppStartupHandler(targetViewController:
                    self.window!.rootViewController!, notificationActionIdentifier : nil,isbackGroundStartUp: false, completionHandler: {(sessionStart, sessionStop,sessionRestart) in
                        
                })
                appStartupHandler.resumeUserSessionAndNavigateToAppropriateInitialView()
            }
        }
    }
    
    private func convertDeviceTokenToString(deviceToken : NSData) -> String{
        AppDelegate.getAppDelegate().log.debug("\(deviceToken)")
        // Convert binary Device Token to a String (and remove the <, > and white space characters).
        var deviceTokenStr = deviceToken.description.replacingOccurrences(of: ">", with: "")
        deviceTokenStr = deviceTokenStr.replacingOccurrences(of: "<", with: "")
        deviceTokenStr = deviceTokenStr.replacingOccurrences(of: " ", with: "")
        deviceTokenStr = deviceTokenStr.uppercased()
        
        return deviceTokenStr
    }
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        AppDelegate.getAppDelegate().log.debug("RemoteNotification is called for identifier : \(String(describing: identifier))")
        self.getUserNotificationFromRemoteNotification(userInfo: userInfo) { (userNotification) in
            if (userNotification != nil) {
                let notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: userNotification!)
                if notificationHandler != nil{
                    if (SessionManagerController.sharedInstance.isSessionManagerInitialized()) {
                        // Session is already initialized, handle notification
                        notificationHandler?.handleAction(identifier: identifier!, userNotification: userNotification!)
                    }
                    else {
                        //Resume session and then handle notification
                        
                        SharedPreferenceHelper.saveRecentNotification(notification: userNotification!)
                        let appStartupHandler = AppStartupHandler(targetViewController:
                            self.window!.rootViewController!, notificationActionIdentifier : identifier,isbackGroundStartUp: false, completionHandler: {(sessionStart, sessionStop,sessionRestart) in
                                
                        })
                        NotificationStore.notificationAction = identifier
                        appStartupHandler.resumeUserSessionAndNavigateToAppropriateInitialView()
                    }
                }
            }else{
                QuickRideRemoteBackgroundNotificationHandler().handleRemoteNotifications(userInfo: userInfo)
            }
            completionHandler() // per developer documentation, app will terminate if we fail to call this
        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        AppDelegate.getAppDelegate().log.debug("LocalNotification is called for identifier : \(String(describing: identifier))")
        let userNotification = self.getUserNotificationFromLocalNotification(localNotification: notification)
        if (userNotification != nil) {
            let notificationHandler:NotificationHandler? = NotificationHandlerFactory.getNotificationHandler(clientNotification: userNotification!)
            notificationHandler?.handleAction(identifier: identifier!, userNotification: userNotification!)
        }
        completionHandler() // per developer documentation, app will terminate if we fail to call this
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        AppDelegate.getAppDelegate().log.debug("RemoteNotification is called for identifier : \(String(describing: identifier)) with \(responseInfo)")
        if identifier != nil{
            // MARKER: Handle netcore notification action as per updated sdk
//            NetCorePushTaskManager.sharedInstance().handleAction(withIdentifier: identifier!, forRemoteNotification: userInfo, withResponseInfo: responseInfo)
        }
        getUserNotificationFromRemoteNotification(userInfo: userInfo){(userNotification) in
            if (userNotification != nil) {
                let notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: userNotification!)
                if notificationHandler != nil{
                    if (SessionManagerController.sharedInstance.isSessionManagerInitialized()) {
                        // Session is already initialized, handle notification
                        notificationHandler?.handleAction(identifier: identifier!, userNotification: userNotification!)
                    }
                    else {
                        //Resume session and then handle notification
                        
                        SharedPreferenceHelper.saveRecentNotification(notification: userNotification!)
                        let appStartupHandler = AppStartupHandler(targetViewController:
                            self.window!.rootViewController!, notificationActionIdentifier : identifier,isbackGroundStartUp: false, completionHandler: {(sessionStart, sessionStop,sessionRestart) in
                                
                        })
                        NotificationStore.notificationAction = identifier
                        appStartupHandler.resumeUserSessionAndNavigateToAppropriateInitialView()
                    }
                }
            }
            else{
                QuickRideRemoteBackgroundNotificationHandler().handleRemoteNotifications(userInfo: userInfo)
            }
            completionHandler() // As per developer documentation, app will terminate if we fail to call this
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AppDelegate.getAppDelegate().log.debug("Application entered background")
        UIApplication.shared.applicationIconBadgeNumber = NotificationStore.getInstance().getActionPendingNotificationCount()
        
        // self.saveContext()
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        AppDelegate.getAppDelegate().log.debug("Application entered foreground")
        LocationChangeListener.getInstance().refreshLocationUpdateRequirementStatus()
        NotificationCenter.default.post(name: Notification.Name("appEnterForeground"), object: nil)
        checkAndHandleCurrentLog()
        getAllPendingEventStatusUpdate()
        //      if ContainerViewController.isHotSpotEnabled == false {
        //        ContainerViewController.isHotSpotEnabled = true
        //      }else {
        //
        //        let windowFrame = CGRect(x:0,y: 0,width: ContainerViewController.previousFrame!.width,height: ContainerViewController.previousFrame!.height-20)
        //
        //        UIApplication.sharedApplication().keyWindow?.frame = windowFrame
        //        ContainerViewController.isHotSpotEnabled = false
        //        UIApplication.sharedApplication().statusBarHidden = false
        //      }
       
    }
    
    func getAllPendingEventStatusUpdate(){
        AppDelegate.getAppDelegate().log.debug("getAllPendingEventStatusUpdate")
        if QRSessionManager.getInstance()!.getUserId() != "0"{
            CommunicationRestClient.getAllPendingStatusUpdate(userId: QRSessionManager.getInstance()!.getUserId(), viewController: nil) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let pendingEventStatus = Mapper<EventUpdate>().mapArray(JSONObject: responseObject!["resultData"])
                    if pendingEventStatus != nil{
                        for eventStatus in pendingEventStatus!{
                            EventServiceProxyFactory.getEventServiceProxy(topicName: eventStatus.topic!)?.onNewMessageArrivedFromRemoteNotification(topicName: eventStatus.topic!, message: eventStatus.eventObjectJson!)
                        }
                    }
                }
            }
        }
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEvents.shared.activateApp()
        Settings.shared.isAdvertiserTrackingEnabled = true
        // Track Installs, updates & sessions(app opens) (You must include this API to enable tracking)
        GMSServices.provideAPIKey(AppConfiguration.googleMapsKey)
//        AppsFlyerTracker.shared().trackAppLaunch()
        NotificationCenter.default.post(name: Notification.Name.init(PaymentAckowledgementViewModel.PAYMENT_STATUS), object: nil, userInfo: nil)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        AppDelegate.getAppDelegate().log.debug("applicationWillTerminate")
        UIApplication.shared.applicationIconBadgeNumber = NotificationStore.getInstance().getActionPendingNotificationCount()

        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        //self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.idisha.applicationiOS.HitList" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Quickride", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Quickride")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        AppDelegate.getAppDelegate().log.debug("Url : \(String(describing: url))")
        var failureReason = "There was an error creating or loading the application's saved data."
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                        NSInferMappingModelAutomaticallyOption: false]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: mOptions)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            let wrappedError = NSError(domain: "QuickRide domain", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            self.log.debug("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return self.managedObjectContext
    }()
    lazy var mainQuueManagedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        self.mainQuueManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        self.mainQuueManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return self.mainQuueManagedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext ()
    {
        AppDelegate.getAppDelegate().log.debug("")
        
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        LocationCache.getCacheInstance().putRecentLocationOfUser(location: locations.last)
        if(SessionManagerController.sharedInstance.isSessionManagerInitialized()) {
            LocationChangeListener.getInstance().processLocationUpdate(location: locations.last!)
        }
    }
    func setEmergencyInitializer(emergencyInitiator: EmergencyInitiator?){
        self.emergencyInitiator = emergencyInitiator
    }
    
    func getEmergencyInitializer() -> EmergencyInitiator?{
        return emergencyInitiator
    }
    
    static func getAppDelegate() -> AppDelegate{
        if appDelegate == nil{
            appDelegate = UIApplication.shared.delegate as? AppDelegate
        }
        return appDelegate!
    }
    deinit {
        anotherLocationManager?.delegate = nil
    }
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        AppDelegate.getAppDelegate().log.error("url open from handleOpen application : "+url.absoluteString)
        
        AppDelegate.gaiURLString = AppDelegate.gaiURLString+" url from handleOpen "+url.absoluteString
        Adjust.appWillOpen(url)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        AppDelegate.getAppDelegate().log.error("url open from source application : "+url.absoluteString)
        AppDelegate.gaiURLString = AppDelegate.gaiURLString+" url open from source application "+url.absoluteString
        if url.absoluteString.contains("utm"){
            handleUniversalLink(url: url)
        }else{
            InstallReferrer.handleReferralCode(shortUrl: url)
            QuickJobsURLHandler.handleJob(shortUrl : url)
            QuickShareUrlHandler.handleProductUrl(shortUrl: url)
            JoinMyRide.handleJoinMyRideRideId(shortUrl: url)
            if !url.absoluteString.contains("link_click_id"){
                checkIfIdfaPresentAndSaveUserRefeferInfo()
            }
        }
        if url.scheme?.caseInsensitiveCompare("com.disha.ios.myride.payments") == .orderedSame {
            NotificationCenter.default.post(name: Notification.Name("PAYMENT_RESPONSE"), object: nil, userInfo: nil)
            return true
        }
//        AppsFlyerTracker.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
        
        Adjust.appWillOpen(url)
        return GIDSignIn.sharedInstance.handle(url)
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        AppDelegate.getAppDelegate().log.error("url open from options : "+url.absoluteString)
        AppDelegate.gaiURLString = AppDelegate.gaiURLString+" from open from options"+url.absoluteString
        Branch.getInstance().application(app, open: url, options: options)
        if url.scheme?.caseInsensitiveCompare("com.disha.ios.myride.payments") == .orderedSame {
            NotificationCenter.default.post(name: Notification.Name("PAYMENT_RESPONSE"), object: nil, userInfo: nil)
            return true
        }

        if ApplicationDelegate.shared.application(app, open: url, options: options){
            return ApplicationDelegate.shared.application(app, open: url, options: options)
        }
        if url.absoluteString.contains("utm"){
           handleUniversalLink(url : url)
        }else{
           InstallReferrer.handleReferralCode(shortUrl: url)
            QuickJobsURLHandler.handleJob(shortUrl : url)
            QuickShareUrlHandler.handleProductUrl(shortUrl: url)
            JoinMyRide.handleJoinMyRideRideId(shortUrl: url)
            if !url.absoluteString.contains("link_click_id"){
              checkIfIdfaPresentAndSaveUserRefeferInfo()
            }
        }
//	    AppsFlyerTracker.shared()?.handleOpen(url, options: options)
         do{
            let regex = try NSRegularExpression(pattern: "amzn-.*")
            let results = regex.matches(in: url.absoluteString,
                                        range: NSRange(url.absoluteString.startIndex..., in: url.absoluteString))
            if(results.count>0){
                return AmazonPay.sharedInstance().handleRedirectURL(url,
                                                                    sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
            }else{
                return false
            }
        }catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        //google
        return GIDSignIn.sharedInstance.handle(url)
        
    }
    func handleUniversalLink(url : URL){
        AppDelegate.getAppDelegate().log.debug("handleUniversalLink()")
        if SharedPreferenceHelper.getUserRefererInfo() != nil{
            return
        }
        let urlString = url.absoluteString

        let tracker = GAI.sharedInstance().defaultTracker

        let hitParams = GAIDictionaryBuilder()
        hitParams.setCampaignParametersFromUrl(urlString)

        tracker?.set(kGAIScreenName, value: "Sign up")
        var params = [AnyHashable : Any]()
        params[kGAICampaignMedium] = hitParams.get(kGAICampaignMedium)
        params[kGAICampaignSource] = hitParams.get(kGAICampaignSource)
        params[kGAICampaignName] = hitParams.get(kGAICampaignName)
        tracker?.send(params)
        let userRefInfo = UserRefererInfo(source: params[kGAICampaignSource] as? String, medium: params[kGAICampaignMedium] as? String, term: params[kGAICampaignKeyword] as? String, content: params[kGAICampaignContent] as? String, campaign: params[kGAICampaignName] as? String, googleAdvertisingId: AppDelegate.getAppDelegate().getIDFA(), deviceUniqueId: DeviceUniqueIDProxy().getDeviceUniqueId())

        SharedPreferenceHelper.saveUserRefererInfo(userRefInfo: userRefInfo)
        if userRefInfo.campaign ==  UserRefererInfo.utm_campaign_shortsignup{
            SharedPreferenceHelper.storeShortSignReqStatus(value: true)
        }
        userRefInfo.userId = "0"
        UserRestClient.saveUserRefererInfo(userRefererInfo: userRefInfo, viewController: nil) { (responseObject, error) in
        }
        saveUserInstallData(userId: 0.0, uniqueDeviceId: DeviceUniqueIDProxy().getDeviceUniqueId(), googleAdvertisingId: AppDelegate.getAppDelegate().getIDFA(), source: params[kGAICampaignSource] as? String, medium: params[kGAICampaignMedium] as? String, term: params[kGAICampaignKeyword] as? String, content: params[kGAICampaignContent] as? String, campaign: params[kGAICampaignName] as? String, installTime: nil, clickTime: nil, appsFlyerId: nil, publisherId: nil, subPublisherId: nil, adInfo: nil)
    }

    func checkIfIdfaPresentAndSaveUserRefeferInfo(){
        var userId : Double?
        if let usrId = SharedPreferenceHelper.getLoggedInUserId() {
            userId = Double(usrId)
        } else {
            userId = 0.0
        }
        
        saveUserInstallData(userId: userId, uniqueDeviceId: DeviceUniqueIDProxy().getDeviceUniqueId(), googleAdvertisingId: AppDelegate.getAppDelegate().getIDFA(), source: SharedPreferenceHelper.getCurrentUserReferralCode(), medium: "referrer", term: UserRefererInfo.organic, content: UserRefererInfo.organic, campaign: UserRefererInfo.organic, installTime: nil, clickTime: nil, appsFlyerId: nil, publisherId: nil, subPublisherId: nil, adInfo: nil)
        
        if SharedPreferenceHelper.getUserRefererInfo() != nil{
            return
        }
        if let idfa = getIDFA(){
            let userRefererInfo = UserRefererInfo(source: UserRefererInfo.organic, medium: UserRefererInfo.organic, term: UserRefererInfo.organic, content: UserRefererInfo.organic, campaign: UserRefererInfo.organic, googleAdvertisingId: idfa, deviceUniqueId: DeviceUniqueIDProxy().getDeviceUniqueId())
            SharedPreferenceHelper.saveUserRefererInfo(userRefInfo: userRefererInfo)
            userRefererInfo.userId = "0"
            UserRestClient.saveUserRefererInfo(userRefererInfo: userRefererInfo, viewController: nil) { (responseObject, error) in
            }
        }
  }
    private func saveUserDataToBranch(params: [String: AnyObject]){
        AppDelegate.getAppDelegate().log.debug("baranch data\(params)")
        guard let isFirstTime = params["+is_first_session"] as? Int else { return }
        guard let isFromBranchLink = params["+clicked_branch_link"] as? Int else { return }
        if isFirstTime == 0 && isFromBranchLink == 0{
            return
        }
        var userId : Double?
        if let usrId = SharedPreferenceHelper.getLoggedInUserId() {
            userId = Double(usrId)
        } else {
            userId = 0.0
        }
        if isFirstTime == 1{
            let userRefInfo = UserRefererInfo(source: params["~channel"] as? String, medium: params["~feature"] as?  String, term: nil, content: params["$marketing_title"] as? String, campaign: params["~campaign"] as? String,googleAdvertisingId : AppDelegate.getAppDelegate().getIDFA(), deviceUniqueId: DeviceUniqueIDProxy().getDeviceUniqueId())
            
            SharedPreferenceHelper.saveUserRefererInfo(userRefInfo: userRefInfo)
            userRefInfo.userId = StringUtils.getStringFromDouble(decimalNumber: userId)
            UserRestClient.saveUserRefererInfo(userRefererInfo: userRefInfo, viewController: nil) { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                   AppDelegate.getAppDelegate().log.debug("userRefInfo Saved")
                }else{
                   AppDelegate.getAppDelegate().log.debug("userRefInfo Not Saved")
                }
            }
        }
        
        saveUserInstallData(userId: userId, uniqueDeviceId: DeviceUniqueIDProxy().getDeviceUniqueId(), googleAdvertisingId: AppDelegate.getAppDelegate().getIDFA(), source: params["~channel"] as? String , medium: params["~feature"] as?  String, term: nil, content: params["$marketing_title"] as? String, campaign: params["~campaign"] as? String, installTime: nil, clickTime: params["+click_timestamp"] as? String, appsFlyerId: nil, publisherId: params["~id"] as? String, subPublisherId: nil, adInfo: nil)
        
    }
    
  func getIDFA() -> String? {

        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
            return nil
        }
        
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
 
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool{
      
        if let incomingURL = userActivity.webpageURL{
            AppDelegate.getAppDelegate().log.debug("UserActivity URl :-\(String(describing: incomingURL))")
            
            if incomingURL.absoluteString.contains("utm"){
                handleUniversalLink(url: incomingURL)
                return true
            }else{
                 InstallReferrer.handleReferralCode(shortUrl: incomingURL)
                 QuickJobsURLHandler.handleJob(shortUrl : incomingURL)
                QuickShareUrlHandler.handleProductUrl(shortUrl: incomingURL)
                JoinMyRide.handleJoinMyRideRideId(shortUrl: incomingURL)
                 if !incomingURL.absoluteString.contains("link_click_id"){
                   checkIfIdfaPresentAndSaveUserRefeferInfo()
                 }
            }
            if incomingURL.absoluteString.contains("quickrides.page.link"){
                SharedPreferenceHelper.storeDeepLink(parameter: incomingURL.absoluteString)
            }
            
            if userActivity.activityType == NSUserActivityTypeBrowsingWeb{
                 Adjust.appWillOpen(incomingURL)
            }
            
        }
        Branch.getInstance().continue(userActivity)
//        AppsFlyerTracker.shared().continue(userActivity, restorationHandler: restorationHandler as? ([Any]?) -> Void)
        
        return TCTrueSDK.sharedManager().application(application, continue: userActivity, restorationHandler: restorationHandler as? ([Any]?) -> Void)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        AppDelegate.getAppDelegate().log.debug("Firebase registration token: \(fcmToken)")
        if let fcmToken = fcmToken {
            let dataDict:[String: String] = ["token": fcmToken]
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        }
    }
    
//    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
//        guard let first_launch_flag = conversionInfo["is_first_launch"] as? Int else { return }
//        guard let status = conversionInfo["af_status"] as? String else { return }
//
//        if(first_launch_flag == 1) {
//            if(status == "Non-organic") {
//                if SharedPreferenceHelper.getUserRefererInfo() != nil{
//                    return
//                }
//                guard let media_source = conversionInfo["media_source"],let campaign = conversionInfo["campaign"] else { return }
//                var params = [AnyHashable : Any]()
//                params[kGAICampaignMedium] = media_source
//                params[kGAICampaignSource] = campaign
//
//                let userRefInfo = UserRefererInfo(source: params[kGAICampaignSource] as? String, medium: params[kGAICampaignMedium] as? String, term: params[kGAICampaignKeyword] as? String, content: params[kGAICampaignContent] as? String, campaign: params[kGAICampaignName] as? String,googleAdvertisingId : AppDelegate.getAppDelegate().getIDFA(), deviceUniqueId: DeviceUniqueIDProxy().getDeviceUniqueId())
//                SharedPreferenceHelper.saveUserRefererInfo(userRefInfo: userRefInfo)
//                userRefInfo.userId = "0"
//                UserRestClient.saveUserRefererInfo(userRefererInfo: userRefInfo, viewController: nil) { (responseObject, error) in
//                }
//                saveUserInstallData(userId: 0.0, uniqueDeviceId: DeviceUniqueIDProxy().getDeviceUniqueId(), googleAdvertisingId: AppDelegate.getAppDelegate().getIDFA(), source: campaign as? String, medium: media_source as? String, term: nil, content: nil, campaign: campaign as? String, installTime: conversionInfo["install_time"] as? String, clickTime: conversionInfo["click_time"] as? String, appsFlyerId: AppsFlyerTracker.shared().getAppsFlyerUID(), publisherId: nil, subPublisherId: nil, adInfo: nil)
//            }
//        }
//    }
    
//    func onConversionDataFail(_ error: Error) {
//
//    }
       
     func saveUserInstallData(userId: Double?,uniqueDeviceId: String?,googleAdvertisingId: String?,source: String?, medium: String?,term: String?,content:String?,campaign:String?,installTime: String?,clickTime: String?,appsFlyerId: String?,publisherId: String?,subPublisherId: String?,adInfo: String?) {
       
        let userAttributionEvent = UserAttributionEvent(userId: userId, uniqueDeviceId: uniqueDeviceId, googleAdvertisingId: googleAdvertisingId, source: source, medium: medium, term: term, content: content, campaign: campaign, installTime: installTime, clickTime: clickTime, appsFlyerId: appsFlyerId, publisherId: publisherId, subPublisherId: subPublisherId, adInfo: adInfo)
        
        var attributionType = ""
        
        if SharedPreferenceHelper.getLoggedInUserId() != nil {
            attributionType = UserAttributionEvent.USER_ATTRIBUTION_TYPE_APP_OPEN
        } else {
            attributionType = UserAttributionEvent.USER_ATTRIBUTION_TYPE_INSTALL
        }
        
        UserRestClient.saveUserInstallEventInfo(userInstallEvent: userAttributionEvent, userAttributionType: attributionType) { (_, _) in
        }
       
        
    }

//    func onConversionDataRequestFailure(_ error: Error!) {
//        if let err = error{
//            AppDelegate.getAppDelegate().log.debug("\(err)")
//        }
//    }
    
//    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]!) {
//        let data = attributionData
//        if data != nil && data!["af_sub1"] != nil{
//            SharedPreferenceHelper.storeViewPrefixForDeepLink(parameter: data!["af_sub1"] as! String)
//        }
//        if SessionManagerController.sharedInstance.isSessionManagerInitialized() && SharedPreferenceHelper.getViewPrefixForDeepLink() != nil{
//
//          ViewControllerNavigationUtils.openSpecificViewController()
//
//        }
//    }
    
    func onAppOpenAttributionFailure(_ error: Error!) {
        if let err = error{
           AppDelegate.getAppDelegate().log.debug("\(err)")
        }
    }
    
    func handleSmartechDeeplink(_ options: SMTDeeplink?) {
        
        if options?.deepLinkType == SMTDeeplinkType.url{
            
            if let deeplink = options?.deepLink{
                let url = NSURL(string :  deeplink)
                if UIApplication.shared.canOpenURL(url! as URL){
                    UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
                }else{
                    UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
                }
            }
        
        }else if options?.deepLinkType == SMTDeeplinkType.universalLink {
            if let deeplink = options?.deepLink!{
                
                let url = NSURLComponents(string: deeplink)
                if let params = url?.queryItems{
                    for param in params{
                        if param.name == "af_sub1"{
                            SharedPreferenceHelper.storeViewPrefixForDeepLink(parameter: param.value)
                        }
                    }
                    if SessionManagerController.sharedInstance.isSessionManagerInitialized() && SharedPreferenceHelper.getViewPrefixForDeepLink() != nil{
                        ViewControllerNavigationUtils.openSpecificViewController(viewController: nil)
                    }
                }
            }
        }
        else if options?.deepLinkType == SMTDeeplinkType.deeplink {
            if let deeplink = options?.deepLink!{
                SharedPreferenceHelper.storeViewPrefixForDeepLink(parameter: NSURL(string: deeplink)?.host)
                if SessionManagerController.sharedInstance.isSessionManagerInitialized() && SharedPreferenceHelper.getViewPrefixForDeepLink() != nil{
                    ViewControllerNavigationUtils.openSpecificViewController(viewController: nil)
                }
            }
        }
    }
    
    
//    func createAddInterstetial() {
//        interstitial = GADInterstitial(adUnitID: AppConfiguration.interstial_ad_id)
//        interstitial.delegate = self
//        interstitial.load(GADRequest())
//    }
//
//    func displayAd(viewController : UIViewController,handler : @escaping AddDismissHandler){
//        self.handler = handler
//
//        if interstitial == nil{
//            createAddInterstetial()
//        }
//
//
//        if interstitial.isReady{
//            interstitial.present(fromRootViewController: viewController)
//        }else{
//            handler()
//        }
//    }
    
//
//    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
//    }
//
//    /// Tells the delegate an ad request failed.
//    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
//    }
//
//    /// Tells the delegate that an interstitial will be presented.
//    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
//    }
//
//    /// Tells the delegate the interstitial is to be animated off the screen.
//    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
//
//
//    }
//
//    /// Tells the delegate the interstitial had been animated off the screen.
//    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
//        createAddInterstetial()
//        handler?()
//        handler = nil
//    }
//
//    /// Tells the delegate that a user click will open another app
//    /// (such as the App Store), backgrounding the current app.
//    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
//         createAddInterstetial()
//        handler?()
//        handler = nil
//    }
    //MARK: AdjustSDKSetUp
    private func setUpAdjustSDK(){
        adjConfig = ADJConfig(appToken: AppConfiguration.ADJUST_APP_TOKEN, environment: ADJEnvironmentProduction)
        adjConfig?.delegate = self
        adjConfig?.setAppSecret(1, info1: 2113457031, info2: 1323498008, info3: 136957815, info4: 1702323865)
        Adjust.appDidLaunch(adjConfig!)
    }
    
    //MARK: AdjustSDK Delegate Methods
    
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        let campaign = attribution?.campaign
        let source = attribution?.network
        let medium = attribution?.trackerName
        CleverTap.sharedInstance()?.pushInstallReferrerSource(source, medium: medium, campaign: campaign)
    }
    
    func adjustEventTrackingSucceeded(_ eventSuccessResponseData: ADJEventSuccess?) {
    }
    
    func adjustEventTrackingFailed(_ eventFailureResponseData: ADJEventFailure?) {
    }
    
    func adjustDeeplinkResponse(_ deeplink: URL?) -> Bool {
        return true
    }

    
  }
  
  class NotificationData : Mappable{
    var rideReschedule : RideRescheduleTimeData?
    func mapping(map: Map) {
        rideReschedule <- map["rideStatus"]
    }
    required init?(map: Map) {
    }
  }
  
 
