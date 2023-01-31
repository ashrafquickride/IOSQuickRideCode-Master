//
//  NewUserDetailsViewModel.swift
//  Quickride
//
//  Created by Admin on 06/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import GoogleSignIn


typealias newUserDetailsCompletionHandler = (_ error : NSError?) -> Void

class NewUserDetailsViewModel {
    
    //MARK: Properties
    var fbSocialUserProfile : FBSocialUserProfile?
    var googleSocialUserProfile : GoogleSocialUserProfile?
    var appleSocialUserProfile : AppleSocialUserProfile?
    var socialNetworkType : String?
    var contactNo : String?
    var otp : String?
    var gender : String?
    var promocode : String?
    var password : String?
    var enableWhatsAppPreferences: Bool?
    
    //MARK: Initializer Method
    init(contactNo : String?,otp : String?,enableWhatsAppPreferences: Bool?) {
        self.contactNo = contactNo
        self.otp = otp
        self.enableWhatsAppPreferences = enableWhatsAppPreferences
    }
    
    //MARK: Methods
    func verifyReferralCode(promoCode : String,viewController : UIViewController?,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        UserRestClient.verifyReferral(referralCode: promoCode, uiViewController: viewController, completionHandler: handler)
    }
    
    func getResponseError(responseObject : NSDictionary?) -> ResponseError?{
        return Mapper<ResponseError>().map(JSONObject: responseObject?["resultData"])
    }
    
    
    func registerNewSocialUser(otp : String,gender : String,name : String,promocode : String?,email : String,viewController : UIViewController, actionComplitionHandler: @escaping actionComplitionHandler){
        
        let user = getUserObjForSocialUser(gender: gender, name: name, promocode: promocode)
        var params = user.getParams()
        params["email"] = email
        params[User.TIME_ZONE_OFF_SET] = StringUtils.getStringFromDouble(decimalNumber: DateUtils.getTimeZoneOffSet())
        params[User.CLIENT_DEVICE_TYPE] = Strings.ios
        if socialNetworkType == FBSocialUserProfile.socialNetworkTypeFB{
            if let id = fbSocialUserProfile?.id{
                params["socialnetworktype"] = FBSocialUserProfile.socialNetworkTypeFB
                params["socialnetworkid"] = id
            }
        }else if socialNetworkType == AppleSocialUserProfile.socialNetworkTypeApple{
            if let id = appleSocialUserProfile?.id{
                params["socialnetworktype"] = AppleSocialUserProfile.socialNetworkTypeApple
                params["socialnetworkid"] = id
            }
        }else{
            if let id = googleSocialUserProfile?.userId{
                params["socialnetworktype"] = FBSocialUserProfile.socialNetworkTypeGoogle
                params["socialnetworkid"] = id
            }
        }
        let userRefInfo = SharedPreferenceHelper.getUserRefererInfo()
        if userRefInfo != nil && userRefInfo!.isValid(){
            for item in userRefInfo!.getParams(){
                params[item.0] = item.1
            }
        }
        
        UserRestClient.createSocialUser(userPostDictionary: params, targetViewController: viewController) { [weak self](responseObject, error) in
            if responseObject != nil {
                if responseObject!["result"] as! String == "SUCCESS" {
                    self?.performServerCallToGetUser(otp: otp, viewController: viewController, actionComplitionHandler: actionComplitionHandler)
                } else {
                    actionComplitionHandler(true)
                    self?.handleUserCreationFailureResponse(responseObject: responseObject, error: error, viewController: viewController)
                }
            } else {
                actionComplitionHandler(true)
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
    
    
   private func getUserObj(gender : String,name : String,promocode : String?) -> User{
        let newUser = User()
        newUser.phoneNumber = Double(contactNo!)!
        newUser.password = StringUtils.randomString(length: 5)
        password = newUser.password
        newUser.userName = name
        newUser.gender = gender
        
        if promocode != nil && promocode!.isEmpty == false {
            newUser.appliedPromoCode = promocode
        }
        let versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        if versionName == nil || versionName!.isEmpty {
            newUser.iosAppVersionName = AppConfiguration.APP_CURRENT_VERSION_NO
        }
        else
        {
            newUser.iosAppVersionName = versionName
        }
        let modelName = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        var phoneModel = "\(modelName)-\(systemVersion)"
        if let cellProvider = QRReachability.getCellularData() {
            phoneModel = "\(phoneModel):\(cellProvider)"
        }
        newUser.phoneModel = phoneModel
        newUser.countryCode = AppConfiguration.DEFAULT_COUNTRY_CODE_IND
        newUser.uniqueDeviceId = DeviceUniqueIDProxy().getDeviceUniqueId()
        newUser.googleAdvertisingId = AppDelegate.getAppDelegate().getIDFA()
        newUser.status = User.status_activated
        return newUser
    }
    
    private func getUserObjForSocialUser(gender : String,name : String,promocode : String?) -> User{
          let newUser = User()

           newUser.phoneNumber = Double(contactNo!)!
           newUser.password = StringUtils.randomString(length: 5)
           password = newUser.password
           newUser.userName = name
           newUser.gender = gender
           
           if promocode != nil && promocode!.isEmpty == false {
               newUser.appliedPromoCode = promocode
           }
           let versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
           if versionName == nil || versionName!.isEmpty {
               newUser.iosAppVersionName = AppConfiguration.APP_CURRENT_VERSION_NO
           }
           else
           {
               newUser.iosAppVersionName = versionName
           }
          let modelName = UIDevice.current.model
          let systemVersion = UIDevice.current.systemVersion
          var phoneModel = "\(modelName)-\(systemVersion)"
          if let cellProvider = QRReachability.getCellularData() {
              phoneModel = "\(phoneModel):\(cellProvider)"
          }
           newUser.phoneModel = phoneModel
           newUser.countryCode = AppConfiguration.DEFAULT_COUNTRY_CODE_IND
           newUser.uniqueDeviceId = DeviceUniqueIDProxy().getDeviceUniqueId()
           newUser.googleAdvertisingId = AppDelegate.getAppDelegate().getIDFA()
           newUser.status = User.status_activated
           return newUser
    }
    
    func registerNewUser(otp : String,gender : String,name : String,promocode : String?,email : String,viewController : UIViewController,actionComplitionHandler: @escaping actionComplitionHandler){
        let user = getUserObj(gender: gender, name: name, promocode: promocode)
        var params = user.getParams()
        params["emailforcommunication"] = email
        params[User.TIME_ZONE_OFF_SET] = StringUtils.getStringFromDouble(decimalNumber: DateUtils.getTimeZoneOffSet())
        params[User.CLIENT_DEVICE_TYPE] = Strings.ios
        let userRefInfo = SharedPreferenceHelper.getUserRefererInfo()
        if userRefInfo != nil && userRefInfo!.isValid(){
            for item in userRefInfo!.getParams(){
                params[item.0] = item.1
            }
        }
        UserRestClient.createUser(userPostDictionary: params, targetViewController: viewController) { [weak self](responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let userObj = Mapper<User>().map(JSONObject: responseObject!["resultData"]){
                    self?.getUserProfileAndInitializeUserSession(user: userObj, otp: otp, userId: StringUtils.getStringFromDouble(decimalNumber: userObj.phoneNumber), viewController: viewController, actionComplitionHandler: actionComplitionHandler)
                    AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.USER_SIGNED_UP, params: [
                        "userId" : "\(userObj.phoneNumber)","contactNo": userObj.contactNo ?? 0,"DeviceId": DeviceUniqueIDProxy().getDeviceUniqueId() ?? "","advertisingId": AppDelegate.getAppDelegate().getIDFA() ?? ""], uniqueField: User.FLD_USER_ID)
                    self?.storeUserWhatsAppPreferences(userId: userObj.phoneNumber)
                }
            } else {
                actionComplitionHandler(true)
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
        
        
    private func handleUserCreationFailureResponse(responseObject: NSDictionary?,error: NSError?,viewController: UIViewController) {
        let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
        if responseError?.errorCode == ServerErrorCodes.EMAIL_ALREADY_EXISTS_ERROR{
            MessageDisplay.displayInfoViewAlert(title: Strings.email_already_registered, titleColor: nil, message: responseError?.userMessage ?? "", infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.login_caps) { [weak self] in
                self?.navigateToLoginScreen(viewController: viewController)
            }
        } else {
            ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: viewController)
        }
    }
    
    
    func performServerCallToGetUser(otp : String,viewController : UIViewController, actionComplitionHandler: @escaping actionComplitionHandler){
        UserRestClient.getCurrentUser(phoneNo: contactNo ?? "", countryCode: AppConfiguration.DEFAULT_COUNTRY_CODE_IND, appName: AppConfiguration.APP_NAME, viewController: viewController) { [weak self](responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let userObj = Mapper<User>().map(JSONObject: responseObject!["resultData"]){
                    self?.getUserProfileAndInitializeUserSession(user: userObj, otp: otp, userId: StringUtils.getStringFromDouble(decimalNumber: userObj.phoneNumber), viewController: viewController, actionComplitionHandler: actionComplitionHandler)
                    self?.storeUserWhatsAppPreferences(userId: userObj.phoneNumber)
                }
            }else{
                actionComplitionHandler(true)
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
    
    private func getUserProfileAndInitializeUserSession(user : User,otp : String,userId : String,viewController : UIViewController,actionComplitionHandler: @escaping actionComplitionHandler){
        
        UserRestClient.getProfile(userId: userId, targetViewController: viewController, completionHandler: {[weak self](responseObject, error) -> Void in
            AppDelegate.getAppDelegate().log.debug("Get user profile() \(responseObject) Error \(error)")
            actionComplitionHandler(true)
            if responseObject != nil {
                if responseObject!["result"] as! String == "SUCCESS" {
                    if let userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"]){
                        self?.initializeUserSession(userProfile: userProfile, userId: userId, user: user, otp: otp, viewController:viewController)
                        SharedPreferenceHelper.storeUserProfileObject(userProfileObj: userProfile)
                    }
                }
                else if responseObject!["result"] as! String == "FAILURE" {
                    DispatchQueue.main.async {
                        let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                        MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: viewController,handler: nil)
                    }
                }
            }
            else {
                ErrorProcessUtils.handleError(responseObject: responseObject,error : error, viewController: viewController, handler: nil)
            }
        })
    }
    
    
    private func initializeUserSession(userProfile : UserProfile?,userId : String,user : User,otp : String,viewController : UIViewController){
        updateAppVersionToServer(userId: userId)
        updateUserDeviceIdToServer(viewController: viewController, userId: userId)
       
        DispatchQueue.global(qos: .userInitiated).async {
            UserSessionInitialiser(phoneNo: StringUtils.getStringFromDouble(decimalNumber: user.contactNo), countryCode: user.countryCode, password: self.password ?? "", newUser: user, userProfile: userProfile, isSuspendedUser: false, viewController: viewController).getUserAndInitializeSession()
            
        }
    }
    
    
    private func updateAppVersionToServer(userId : String) {
        var versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        if versionName == nil || versionName!.isEmpty {
            versionName = AppConfiguration.APP_CURRENT_VERSION_NO
        }
        UserRestClient.updateAppVersion(userid: userId, versionName: versionName!, viewController: nil, handler: { (responseObject, error) in
        })
    }
    
    private func updateUserDeviceIdToServer(viewController : UIViewController,userId : String) {
        let userDefaults = UserDefaults.standard
        let deviceToken = userDefaults.string(forKey: "deviceTokenString")
        if (deviceToken != nil) {
            let deviceRegistrationHelper = DeviceRegistrationHelper(sourceViewController: viewController, phone: userId, deviceToken: deviceToken!)
            deviceRegistrationHelper.registerDeviceTokenWithQRServer()
        }
    }
    
    private func navigateToLoginScreen(viewController: UIViewController?) {
        let signUpSecondPhaseVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SignUpSecondPhaseViewController") as! SignUpSecondPhaseViewController
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: signUpSecondPhaseVC, animated: false)
    }
    
 
    
    func getSocialLoginUserStatus(userSocialNetworkId : String, userSocialNetworkType : String,viewController : UIViewController?,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        UserRestClient.getSocialUserStatus(userSocialNetworkId: userSocialNetworkId, userSocialNetworkType: userSocialNetworkType, viewController: viewController, handler: handler)
    }
    
    func getSocialUserStatusObject(responseObject: NSDictionary?) -> SocialUserStatus? {
        return Mapper<SocialUserStatus>().map(JSONObject: responseObject?["resultData"])
    }
    
    func fetchUserProfileFromFB(onCompletion : @escaping FacebookLoginCompletionBlock){
        FacebookLoginManager.fetchUserProfile(onCompletion: onCompletion)
    }
    
    func getSocialUserProfile(responseObject: NSDictionary?) -> FBSocialUserProfile?{
        return Mapper<FBSocialUserProfile>().map(JSONObject: responseObject)
    }
    func storeUserWhatsAppPreferences(userId: Double){
        let whatsAppPreferences = WhatsAppPreferences(userId: userId ,enableWhatsAppPreferences: enableWhatsAppPreferences ?? false)
        UserRestClient.updatedWhatsAppPreferences(whatsAppPreferences: whatsAppPreferences, viewController: nil, responseHandler: {(responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let whatsAppPreferences = Mapper<WhatsAppPreferences>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserWhatsAppPreferences(userWhatsAppPreference: whatsAppPreferences!)
            }
        })
    }
}

