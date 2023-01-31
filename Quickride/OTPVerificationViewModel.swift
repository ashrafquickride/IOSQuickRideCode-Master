//
//  OTPVerificationViewModel.swift
//  Quickride
//
//  Created by Admin on 14/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import CleverTapSDK
import NetCorePush
import CoreLocation


protocol OTPVerificationViewModelDelegate: class {
   
    func startSpinning()
    func stopSpinning()
}


class OTPVerificationViewModel : SessionChangeCompletionListener{
    
    //MARK: Properties
    var contactNo : String?
    var user : User?
    var delegate : OTPVerificationViewModelDelegate?
    let INCORRECT_VERIFICATION_CODE = "incorrect verification code"
    var password : String?
    var enableWhatsAppPreferences: Bool?
    
    //MARK: Initializer Method
    func initializeData(user : User?,contactNo : String?,enableWhatsAppPreferences: Bool?){
        self.user = user
        self.contactNo = contactNo
        self.enableWhatsAppPreferences = enableWhatsAppPreferences
    }
    
    //MARK: Methods
    
    func resendOTPToNewUser(contactNo : String,appName : String,countryCode : String,viewController : UIViewController?,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        UserRestClient.resendOTPToNewUser(contactNo: contactNo, appName: appName, countryCode: countryCode, viewController: viewController, handler: handler)
    }
    
    func sendVerificationCodeToUser(viewController : UIViewController,user : User?,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: viewController, handler: nil)
            return
        }
        var putBodyDictionary = ["phone" : StringUtils.getStringFromDouble(decimalNumber: user?.contactNo)]
        putBodyDictionary[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
        putBodyDictionary[User.FLD_COUNTRY_CODE] = user?.countryCode
        
        UserRestClient.resendVerficiationCode(putBodyDictionary: putBodyDictionary, uiViewController: viewController, completionHandler: handler)
    }
    
    func verifyOtpForNewUser(contactNo : String,otp : String,countryCode : String,viewController : UIViewController?,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        UserRestClient.verifyOTPForNewUser(contactNo: contactNo, otp: otp, countryCode: countryCode, viewController: viewController, handler: handler)
    }
    
    func loginWithOTP(userObj : User,activationCodeText : String,viewController : UIViewController,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        
        password = StringUtils.randomString(length: 5)
        
        UserRestClient.loginWithOTP(contactNo: userObj.contactNo, otp: activationCodeText, appName: AppConfiguration.APP_NAME, countryCode: userObj.countryCode, appVersionName: userObj.iosAppVersionName ?? "", phoneModel: userObj.phoneModel ?? "", uiViewController: viewController, password: password, completionController: handler)
    }
    
    func getUserObj(responseObject : NSDictionary?) -> User?{
        return Mapper<User>().map(JSONObject: responseObject?["resultData"])
    }
    
    func handleSuccessResponseForOTPLogin(otp : String,user : User,viewController : UIViewController?){
        let userId = user.phoneNumber
        if let deviceToken = UserDefaults.standard.string(forKey: "deviceTokenString"){
            DeviceRegistrationHelper(sourceViewController: viewController, phone: StringUtils.getStringFromDouble(decimalNumber : userId), deviceToken: deviceToken).registerDeviceTokenWithQRServer()
        }
        SharedPreferenceHelper.saveAppVersionStatusForCleverTap(status: AppConfiguration.APP_CURRENT_VERSION_NO)
        CleverTapAnalyticsUtils.getInstance().trackProfileEvent(user: user)
        NetCoreInstallation.sharedInstance().netCorePushLogin(StringUtils.getStringFromDouble(decimalNumber: userId), block: nil)
        let profilePushDictionary = ["NAME": user.userName,"MOBILE": StringUtils.getStringFromDouble(decimalNumber: user.contactNo)]
        NetCoreInstallation.sharedInstance().netCoreProfilePush(StringUtils.getStringFromDouble(decimalNumber: userId), payload:profilePushDictionary as [AnyHashable : Any], block:nil)
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.startSpinning()
        }
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.USER_MOBILE_VERIFIED, params: [
            "mobileNumber" : "\(user.contactNo)","attributionType" : "otp","status" : "Activated","DeviceId": DeviceUniqueIDProxy().getDeviceUniqueId()], uniqueField: AnalyticsUtils.deviceId)
        
        GCDUtils.GlobalUserInitiatedQueue.async(execute: { () -> Void in
            SessionManagerController.sharedInstance.reinitializeUserSession(userId: StringUtils.getStringFromDouble(decimalNumber: userId), password: self.password!, contactNo: StringUtils.getStringFromDouble(decimalNumber: user.contactNo),countryCode: user.countryCode ?? AppConfiguration.DEFAULT_COUNTRY_CODE_IND, sessionChangeCompletionListener: self)
        })
        self.savePhoneData(userId: userId, viewController: viewController)
        
    }
    
    
    func handleFailureResponseForOTPLogin(otp : String,responseObject : NSDictionary?,countryCode : String?,viewController : UIViewController?){
        if let responseError = Mapper<ResponseError>().map(JSONObject:  responseObject?["resultData"]){
            if responseError.errorCode == ServerErrorCodes.VERIFICATION_CODE_INCORRECT_ERROR{
                NotificationCenter.default.post(name: Notification.Name.init(INCORRECT_VERIFICATION_CODE), object: nil, userInfo: nil)
            }else if responseError.errorCode == ServerErrorCodes.USER_SUBSCRIPTION_REQUIRED_ERROR{
                UserDataCache.SUBSCRIPTION_STATUS = true
                continueToApplication(otp: otp, deviceToken: UserDefaults.standard.string(forKey: "deviceTokenString"), viewController: viewController)
            }else if responseError.errorCode == ServerErrorCodes.ACCOUNT_SUSPENDED_FOR_ETIQUETTE_VIOLATION{
                MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: viewController,handler: nil)
            }else {
                MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: viewController,handler: nil)
            }
        }
    }
    
    func sessionChangeOperationCompleted() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init(INCORRECT_VERIFICATION_CODE), object: nil)
        GCDUtils.GlobalMainQueue.async(execute: { [weak self]() -> Void in
          self?.delegate?.stopSpinning()
          let greetingsViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GreetingsViewController") as! GreetingsViewController
           ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: greetingsViewController, animated: false)
        })
    }
    
    func sessionChangeOperationFailed(exceptionCause: SessionManagerOperationFailedException?) {
          AppDelegate.getAppDelegate().log.debug("")
             
              GCDUtils.GlobalMainQueue.async(execute: { [weak self]() -> Void in
                self?.delegate?.stopSpinning()
              })
              
              
              if (exceptionCause == SessionManagerOperationFailedException.NetworkConnectionNotAvailable) {
                ErrorProcessUtils.displayNetworkError(viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
              }
              else if (exceptionCause == SessionManagerOperationFailedException.SessionChangeOperationTimedOut) {
                  GCDUtils.GlobalMainQueue.async() { () -> Void in
                      ErrorProcessUtils.displayRequestTimeOutError(viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
                  }
              }
              else {
                  ErrorProcessUtils.displayServerError(viewController: ViewControllerUtils.getCenterViewController())
              }
    }
    
    
    func getDecryptedPassword(userId : Double?,countryCode : String?,appName : String?,handler : @escaping UserRestClient.responseJSONCompletionHandler){
        UserRestClient.getDecryptedPassword(userId: userId, countryCode: countryCode, appName: appName, viewController: nil, handler: handler)
    }
    
     
    private func savePhoneData(userId: Double,viewController : UIViewController?) {
        var phoneModel = ""
        let cellProvider = QRReachability.getCellularData()
        let modelName = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        if cellProvider != "" {
            phoneModel = "\(modelName)-\(systemVersion):\(cellProvider)"
        } else {
            phoneModel = "\(modelName)-\(systemVersion)"
        }
        UserRestClient.updateUserPhoneModel(userId: StringUtils.getStringFromDouble(decimalNumber : userId), phoneModal: phoneModel, uiViewController: viewController, completionController: { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                AppDelegate.getAppDelegate().log.debug("Updating PhoneModel \(modelName)\(systemVersion)")
            }
        })
    }
    
    func continueToApplication(otp : String,deviceToken : String?,viewController : UIViewController?){
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.getCurrentUser(phoneNo: StringUtils.getStringFromDouble(decimalNumber:  user?.contactNo), countryCode: user?.countryCode ?? AppConfiguration.DEFAULT_COUNTRY_CODE_IND, appName: AppConfiguration.APP_NAME, viewController: viewController) { [weak self](responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                if let user = Mapper<User>().map(JSONObject: responseObject!["resultData"]){
                    let userId = user.phoneNumber
                    if deviceToken != nil {
                        let deviceRegistrationHelper = DeviceRegistrationHelper(sourceViewController: viewController, phone: StringUtils.getStringFromDouble(decimalNumber : userId), deviceToken: deviceToken!)
                        deviceRegistrationHelper.registerDeviceTokenWithQRServer()
                    }
                    let phoneCode = StringUtils.getStringFromDouble(decimalNumber: user.contactNo)
                    let countryCode = user.countryCode
                    
                    GCDUtils.GlobalUserInitiatedQueue.async(execute: { () -> Void in
                        SessionManagerController.sharedInstance.reinitializeUserSession(userId: StringUtils.getStringFromDouble(decimalNumber: userId), password: self?.password ?? "", contactNo: phoneCode,countryCode: countryCode ?? AppConfiguration.DEFAULT_COUNTRY_CODE_IND, sessionChangeCompletionListener: self)
                    })
                    self?.savePhoneData(userId: userId, viewController: viewController)
                }
           }else{
                QuickRideProgressSpinner.stopSpinner()
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
    
    func navigateToUserDetailsScreen(otp : String,viewController : UIViewController){
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init(INCORRECT_VERIFICATION_CODE), object: nil)
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .denied{
            let turnLocationOnVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LocationPermissionViewController") as! LocationPermissionViewController
            turnLocationOnVC.initialiseData { (isEnabled) in
                if isEnabled{
                    let newUserDetailsVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NewUserDetailsViewController") as! NewUserDetailsViewController
                    newUserDetailsVC.initializeDataBeforePresenting(contactNo: self.contactNo, otp: otp, enableWhatsAppPreferences: self.enableWhatsAppPreferences)
                    viewController.navigationController?.pushViewController(newUserDetailsVC, animated: false)
                }
            }
            viewController.navigationController?.pushViewController(turnLocationOnVC, animated: false)
        }else{
            let newUserDetailsVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NewUserDetailsViewController") as! NewUserDetailsViewController
            newUserDetailsVC.initializeDataBeforePresenting(contactNo: contactNo, otp: otp, enableWhatsAppPreferences: enableWhatsAppPreferences )
            viewController.navigationController?.pushViewController(newUserDetailsVC, animated: false)
        }
    }
    
    func getResponseError(responseObject : NSDictionary?) -> ResponseError?{
        return Mapper<ResponseError>().map(JSONObject: responseObject?["resultData"])
    }
    func storeUserWhatsAppPreferences(){
        let whatsAppPreferences = WhatsAppPreferences(userId: user?.phoneNumber ?? 0 ,enableWhatsAppPreferences: enableWhatsAppPreferences ?? false)
        UserRestClient.updatedWhatsAppPreferences(whatsAppPreferences: whatsAppPreferences, viewController: nil, responseHandler: {(responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let whatsAppPreferences = Mapper<WhatsAppPreferences>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserWhatsAppPreferences(userWhatsAppPreference: whatsAppPreferences!)
            }
        })
    }
}
