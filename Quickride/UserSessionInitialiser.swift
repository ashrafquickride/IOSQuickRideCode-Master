//
//  NewUserSessionInitialisationViewController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 18/04/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserSessionInitialiser : SessionChangeCompletionListener
{
    //MARK: Properties
    private var isSuspendedUser = false
    private var phoneNo : String?
    private var password : String!
    private var countryCode : String?
    private var userObj : User?
    private var userProfile : UserProfile!
    private var userId: Double = 0
    private var viewController : UIViewController?
    private var sessionIntialisationInProgress = false
    
    //MARK: Initializer
    init(phoneNo : String,countryCode : String?,password : String, newUser: User?, userProfile: UserProfile?, isSuspendedUser : Bool,viewController : UIViewController)
    {
        self.phoneNo = phoneNo
        self.countryCode = countryCode
        self.password = password
        self.userObj = newUser
        self.userProfile = userProfile
        self.isSuspendedUser = isSuspendedUser
        self.viewController = viewController
    }
    //MARK: Methods
    func getUserAndInitializeSession()
    {
        if SharedPreferenceHelper.getShortSignReqStatus() && !isSuspendedUser{
            setNewUserInfoUpdateStatus(status: true)
        }else if !isSuspendedUser{
            setNewUserInfoUpdateStatus(status: false)
        }
        SharedPreferenceHelper.storeLoggedInUserContactNo(contactNo: phoneNo!)
        SharedPreferenceHelper.storeLoggedInUserCountryCode(countryCode: countryCode)
        if let user = userObj,user.phoneNumber != 0{
            userId = user.phoneNumber
            initializeUserSession()
        }else{
            handleIfUserNotAvailable()
        }
    }
    
    private func setNewUserInfoUpdateStatus(status : Bool){
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_PROFILE_PIC_UPLOAD, value: status)
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROLE_DETAILS, value: status)
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_VEHICLE_DETAILS, value: status)
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ORGANIZATION_DETAILS, value: status)
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ROUTE_INFO, value: status)
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ACTIVATED_STATUS, value: status)
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_FEATURE_SELECTION_DETAILS, value: status)
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_CARPOOL_ONBORDING_DETAILS, value: status)
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_TAXI_ONBORDING_DETAILS, value: status)
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_BAZAARY_ONBORDING_DETAILS, value: status)
    }
    
     private func updateUserDeviceIdToServer() {
        let userDefaults = UserDefaults.standard
        let deviceToken = userDefaults.string(forKey: "deviceTokenString")
        if (deviceToken != nil) {
            let deviceRegistrationHelper = DeviceRegistrationHelper(sourceViewController: viewController, phone: StringUtils.getStringFromDouble(decimalNumber: userId), deviceToken: deviceToken!)
            deviceRegistrationHelper.registerDeviceTokenWithQRServer()
        }
    }
    
    private func handleIfUserNotAvailable(){
        UserRestClient.getUserIdForPhoneNo(phoneNo: phoneNo!,countryCode : countryCode, uiViewController: viewController, completionController: { [weak self](responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self?.userId = responseObject!["resultData"] as? Double ?? 0
                self?.retrieveUserAndProfileInfoFromServerAndInitializeSession()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self?.viewController, handler: nil)
            }
        })
    }
    private func updateAppVersionToServer(userId : String) {
        var versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        if versionName == nil || versionName!.isEmpty {
            versionName = AppConfiguration.APP_CURRENT_VERSION_NO
        }
        UserRestClient.updateAppVersion(userid: userId, versionName: versionName!, viewController: nil, handler: { (responseObject, error) in
        })
    }
    private func retrieveUserAndProfileInfoFromServerAndInitializeSession()
    {
        getUser()
        getUserProfile()
    }
    
    private func getUser(){
        let userId = StringUtils.getStringFromDouble(decimalNumber : self.userId)
        UserRestClient.getUser(userId: userId, targetViewController: viewController, completionHandler: { [weak self](responseObject, error) -> Void in
            guard let self = `self` else{
                return
            }
            if responseObject != nil {
                if responseObject!["result"] as! String == "SUCCESS" {
                    self.userObj = Mapper<User>().map(JSONObject: responseObject!["resultData"])
                    if (self.userProfile != nil) {
                        self.initializeUserSession()
                    }
                }
                else if responseObject!["result"] as! String == "FAILURE" {
                    DispatchQueue.main.async {
                        let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                        MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: self.viewController,handler: nil)
                    }
                }
            }
            else {

                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
            }
        })
    }
    
    private func getUserProfile(){
        let userId = StringUtils.getStringFromDouble(decimalNumber : self.userId)
        UserRestClient.getProfile(userId: userId, targetViewController: self.viewController, completionHandler: { [weak self] (responseObject, error) -> Void in
            guard let self = `self` else{
                return
            }
            if responseObject != nil {
                if responseObject!["result"] as! String == "SUCCESS" {
                    self.userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"])
                    if (self.userObj != nil) {
                        self.initializeUserSession()
                    }
                }
                else if responseObject!["result"] as! String == "FAILURE" {
                    DispatchQueue.main.async {
                        let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                        MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: self.viewController,handler: nil)
                    }
                }
            }
            else {
                
                ErrorProcessUtils.handleError(responseObject: responseObject,error : error, viewController: self.viewController, handler: nil)
            }
        })
    }
    
    private func initializeUserSession()
    {
        updateAppVersionToServer(userId: StringUtils.getStringFromDouble(decimalNumber : userId))
        updateUserDeviceIdToServer()
        if sessionIntialisationInProgress{
            return
        }
        sessionIntialisationInProgress = true
        DispatchQueue.global(qos: .userInitiated).async {
            if self.isSuspendedUser
            {
                SessionManagerController.sharedInstance.reinitializeUserSession(userId: StringUtils.getStringFromDouble(decimalNumber: self.userId), password: self.password!, contactNo: StringUtils.getStringFromDouble(decimalNumber: self.userObj!.contactNo!),countryCode: self.userObj!.countryCode!, sessionChangeCompletionListener: self)
            }else
            {
                SessionManagerController.sharedInstance.newUserSession(userId: StringUtils.getStringFromDouble(decimalNumber: self.userId), password: self.password!, userProfie: self.userProfile!, user: self.userObj!, sessionChangeCompletionListener: self)
            }
        }
    }
    func sessionChangeOperationCompleted() {
        AppDelegate.getAppDelegate().log.debug("")
        DispatchQueue.main.async {
            DeviceUniqueIDProxy().checkAndUpdateUniqueDeviceID()
            if self.isSuspendedUser{
                self.makeContainerViewController()
                return
            }
            AppStartUpUtils.checkViewControllerAndNavigate(viewController: self.viewController)
        }
    }
    
    func sessionChangeOperationFailed(exceptionCause : SessionManagerOperationFailedException?) {
        AppDelegate.getAppDelegate().log.debug("")
        if (exceptionCause == SessionManagerOperationFailedException.NetworkConnectionNotAvailable) {
            ErrorProcessUtils.displayNetworkError(viewController: self.viewController!, handler: nil)
            
            return
        }
        else if (exceptionCause == SessionManagerOperationFailedException.SessionChangeOperationTimedOut) {
            DispatchQueue.main.async {
                ErrorProcessUtils.displayRequestTimeOutError(viewController: self.viewController!, handler: nil)
            }
        }
        else {
            ErrorProcessUtils.displayServerError(viewController: self.viewController!)
        }
    }
    private func makeContainerViewController()
    {
        let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        let centerNavigationController = UINavigationController(rootViewController: routeViewController)
        AppDelegate.getAppDelegate().window!.rootViewController = centerNavigationController
        BaseRouteViewController.SHOULD_DISPLAY_RIDE_CREATION_LINK = true
    }
}
