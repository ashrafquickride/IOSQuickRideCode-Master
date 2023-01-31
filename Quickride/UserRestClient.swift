//
//  UserUtils.swift
//  Quickride
//
//  Created by KNM Rao on 28/09/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import Alamofire
import UIKit
import ObjectMapper

public class UserRestClient{
 
    // A generic defination for completion handler closure
    public typealias responseJSONCompletionHandler = (_ responseObject: NSDictionary?, _ error: NSError?) -> Void
    public typealias responseStringCompletionHandler = (_ responseObject: String?, _ error: NSError?) -> Void
  
    static let USER_FAVOURITE_LOCATIONS_SERVICE_PATH="QrUserPreferences/favouriteLocations"
    private static let baseServerUrl: String = AppConfiguration.serverUrl + AppConfiguration.serverPort
    private static let getUserConfig : String = "QRClient/config"
    private static let getReferralCode : String = "QRUser/referralCode"
    private static let getProfile : String = AppConfiguration.apiServerPath + "QRUserProfile?"
    private static let  USER_FEEDBACK_SERVICE_PATH : String = "QRFeedback"
    private static let getUserConfigUrl : String = baseServerUrl + getUserConfig
    private static let RESEND_VERIFICATION_EMAIL_SERVICE_PATH = "/QRUserProfile/verificationMail"
    static let UPDATING_APP_VERSION_NAME_SERVICE_PATH = "/QRUser/updateIosAppVersionName"
    static let SEND_SMS = "/QRUser/sms"
    static let USER_BASIC_INFO_GETTING_SERVICE_PATH = "/QRUserProfile/basicInfo/new"
    static let USER_INFO_GETTING_SERVICE_PATH = "/QRUser/userInfo/new"
    static let SAVE_UPDATE_USER_IMAGE = "/QRUserProfile/saveUserImage"
    static let SAVE_UPDATE_VEHICLE_IMAGE = "/QRVehicle/saveVehicleImage"
    static let USER_OFFICIAL_EMAIL_VERIFICATION_SERVICE_PATH = "/QRUserProfile/passUserOfficeEmailVerification/new"
    static let RIDE_PREFERENCES_UPDATE_SERVICE_PATH = "/QrUserPreferences/RidePreferences/update"
    static let SECURITY_PREFERENCES_UPDATE_SERVICE_PATH = "/QrUserPreferences/SecurityPreferences/update";
    static let EMAIL_PREFERENCES_UPDATE_SERVICE_PATH = "/QRCommunicationPreference/EmailPreferences/update"
    static let SMS_PREFERENCES_UPDATE_SERVICE_PATH = "/QRCommunicationPreference/SMSPreferences/update"
    static let WHATSAPP_PREFERENCES_UPDATE_SERVICE_PATH = "/QRCommunicationPreference/whatsappreferences/update"
    static let CALL_PREFERENCES_UPDATE_SERVICE_PATH = "QRCommunicationPreference/callPref"
    static let CHANGE_MOBILE_NO_SERVICE_PATH = "QRUser/change/contactno"
    static let BLOCKED_USERS_SERVICE_PATH = "/QRBlockUser"
    static let UPDATE_MOBILE_NO_SERVICE_PATH = "/QRUser/update/contactno"
    static let CONTACT_EMAIL_UPDATE_SERVICE_PATH = "/QRUserProfile/update/contactEmail"
    static let USER_VACATION_UPDATE_SERVICE_PATH = "/QRUserVacation/update/utc"
    static let UPDATING_REGION_NAME_SERVICE_PATH = "/QRUser/regionname"
    static let USER_ACCOUNT_SUSPEND_SERVICE_PATH = "/QRUser/suspend"
    static let EXISTED_FEEDBACK_GETTING_SERVICE_PATH = "/QRFeedback/existedFeedback";
    static let PASSENGER_TRIP_BILL_SERVICE_RESOURCE_PATH = "/QRInvoiceQuery/passengerBill";
    static let RIDER_REPORT_SERVICE_RESOURCE_PATH = "/QRInvoiceQuery/riderReport/utc";
    static let UPDATING_PHONE_MODAL_SERVICE_PATH = "/QRUser/phoneModal"
    static let DIRECT_USER_FEEDBACK_SERVICE_PATH = "/QRFeedback"
    static let GETTING_REVERIFICATION_MAIL_SENT_STATUS_SERVICE_PATH="/QRUserProfile/reVerificationMailSent"

    static let FAVOURITE_PARTNERS_SERVICE_PATH = "/QRFavouritePartner/new"
    static let REMOVE_FAVOURITE_PARTNERS_SERVICE_PATH = "/QRFavouritePartner"
    static let UPDATING_DEVICE_UNIQUE_ID_SERVICE_PATH = "/QRUser/deviceuniqueid"
    static let USERS_SEARCH_PATH = "/QRUser/search_user"
    static let USER_OFFER_STATUS_PATH = "/QRUser/offerstatus"
    static let SUBSCRIBE_TO_CASH_TRANSACTIONS_PATH = "/QRUser/penaltyforcashtrans"
    static let GET_CURRENT_USER_SERVICE_PATH = "/QRUser/getCurrentUser"
    static let GET_ONTIMECOMPLIANCE_PATH = "/QROnTimeCompliance"
    static let REMOVE_RIDE_PARTICIPANTS = "/QRRide/removeContact"
    static let SUBSCRIPTION_MAIL_FROM_SUPPORT_PATH = "/subscription/subscriptionMail"
    static let SEND_REGISTRATION_MAIL_PATH = "/QRUserProfile/sendRegistrationMails"
    static let UPDATE_SPECIFIC_USER_FOR_AUTO_CONFIRM = "QRFavouritePartner/update/autoConfirm"
    static let UPDATE_AUTOCONFIRMPARTNERSTATUS = "/AutoConfirmPartner/all"
    static let REGISTER_SYSTEM_COUPONS_GETTING_SERVICE_PATH = "/QRPromotion/register/coupons"
    static let APPLY_USER_COUPON_SERVICE_PATH = "/QRPromotion/apply"
    static let GET_DISPLAYABLE_RIDE_ETIQUETTE_SERVICE_PATH = "/QRRideEtiquette/forDisplay"
    static let Update_DISPLAYED_RIDE_ETIQUETTE_SERVICE_PATH = "/QRRideEtiquette/updateDisplayedTime"
    static let USER_FEEDBACK_IN_BULK_SERVICE_PATH = "/QRFeedback/saveUserFeedback"
    static let UPDATE_GOOGLE_ADVERTISING_ID_PATH = "/QRUser/updateGoogleAdvertizingId"
    static let NOMINEE_DETAILS_PATH = "/QRNomineeDetails"
    static let CLAIM_INSURANCE_PATH = "/QRRideInsurance/claimPolicy"
    static let UPDATE_POLICY_PATH = "/QRRideInsurance/updatePolicy"
    static let SAVE_USER_REF_INFO_SERVICE_PATH = "/QRUser/userrefinfo"
    static let FETCH_DL_DETAILS_PATH = "/QRUserVerification/personalid/link/dl"
    static let COMPLETE_DL_VERIFICATION_PATH = "/QRUserVerification/personalid/verify/dl"
    static let VIRTUAL_NUMBER_PATH = "QRNumberMasking/assignVirtualNumberUsingUserId"
    static let ADD_ALTERNATE_CONTACT_NUM_PATH = "QRUser/update/alternatecontactno"
    static let GET_REFFERAL_COUPONS = "/QRPromotion/referral/coupons"
    static let SOCIAL_LOGIN_PATH = "/QRUserProfile/sociallogin"
    static let CREATE_PROBABLE_USER_PATH = "/QRProbableUser/create/new"
    static let RESEND_OTP_TO_NEW_USER_PATH = "/QRProbableUser/resendOtp"
    static let NEW_USER_OTP_VERIFICATION_PATH = "QRProbableUser/verifyOtp"
    static let LOGIN_WITH_OTP_PATH = "/QRProbableUser/login/otp"
    static let GET_DECRYPTED_PASSWORD_PATH = "QRUser/password/decrypt"
    static let CREATE_SOCIAL_USER_PATH = "QRUser/create/socialUser"
    static let USER_ACTIVE_SESSION_DETAILS_UPDATE_TROUGH_OTP_SERVICE_PATH = "/QRUser/loginAndUpdate/otp"
    static let OTP_FROM_PWD_SERVICE_PATH = "QRUser/otpFromPwd"
    static let UPDATE_RECENT_LOCATION_PATH = "QRUser/recentLocation"
    static let SAVE_OR_UPDATE_PREFERRED_PICKUP_DROP_PATH = "/UserPreferredPickupDrop/saveOrUpdate"
    static let USER_NOTIFICATION_SETTINGS_SERVICE_PATH = "/QRUserNotificationSettings/utc"
  static let USER_INSTALL_EVENT_PATH = "/UserActivityMonitor/installEvent"
  static let USER_EVENT_PATH = "/UserActivityMonitor/Events"
  static let CALL_HISTORY_PATH = "QRNumberMasking/history"
  static let CONTACT_NUMBER_PATH = "/QRUser/contactForDeviceId"
    static let SAVE_CALL_LOG_PATH = "/QRCallLog/save"
  static let APPLY_RIDELEVEL_USER_COUPON_SERVICE_PATH = "/QRPromotion/rideLevelPromo"
    static let SAVE_SAFE_KEEPER_SERVICE_PATH = "/QRUserSelfAssessment/covid19"
  static let GET_USER_WITH_PICKUP_OTP_PATH = "/QRUser/withPickupOtp"
    static let REFERRAL_STATS = "referral/referralStatistics"
  static let REFERRAL_LEADER_LIST = "referral/referralLeaderList"
  static let REFERRED_USER_LIST = "referral/referredUserList"
  static let REFERRAL_CONTACT_REGISTRATION_STATUS = "referral/contactRegistrationStatus"
    static let GET_USER_CONTACT_REG_INFO_SERVICE_PATH = "/QRUser/contactRegistrationInfo"

  static let INVITE_CONTACTS_TO_REFER = "referral/inviteContactForReferral"
  static let BEST_MATCH_ALERT_REGISTRATION = "/QRRideMatchAlertRegistration"
  static let GET_COMPANY_DOMAINS = "company/emailDomain/search"
  static let CHECK_COMPANY_EXISTANCE = "/company/companyDomain"
  static let GET_USER_PROFILE_NEW = "/QRUserProfile/new"
  static let GET_ADS_LIST = "/CTCampaign/all/user"
  static let UPDATE_AD_IMPRESSION = "/CTImpression"
  static let OFFER_IMPRESSION_RECORD = "QROffer/offerImpression/record"
  static let BEST_MATCH_ALERT_UPDATE_STATUS = "QRRideMatchAlertRegistration/update/status"
  static let GET_SYSTEM_COUPONS = "/QRPromotion/systemcoupons/rolescheme"
    static let DELETE_ACCOUNT = "/QRUser/delete";
    
  private static let PHOTO_STRING = "userphoto"
    
    static let communicationServerUrl = AppConfiguration.communicationServerUrlIP+AppConfiguration.CM_serverPort+AppConfiguration.communicationServerPath

    public static func createUser(userPostDictionary : [String : String], targetViewController : UIViewController?, completionHandler: @escaping responseJSONCompletionHandler) {
    AppDelegate.getAppDelegate().log.debug("createUser() \(userPostDictionary)")
    let createUserUrl =  baseServerUrl + AppConfiguration.userServiceUrl
        HttpUtils.performJSONRequestWithBodyAndStoreAuthToken(url: createUserUrl, params: userPostDictionary, requestType: .post, encodingType: URLEncoding.httpBody, targetViewController: targetViewController, handler: completionHandler)
  }
  

    public static func validateAndUpdateUserActiveSessionDetails(appVersionName : String, userId: String,phoneCode : String?, password: String , appName : String,phoneModel : String,uiViewController: UIViewController?, completionController: @escaping responseJSONCompletionHandler){

        AppDelegate.getAppDelegate().log.debug("userId: \(userId)")
        let loginUserUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.USER_ACTIVE_SESSION_DETAILS_UPDATE_SERVICE_PATH
        
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        if phoneCode != nil && !phoneCode!.isEmpty
        {
            params[User.FLD_COUNTRY_CODE] = phoneCode
        }
        params[User.FLD_PWD] = password
        params[User.IOS_APP_VERSION_NAME] = appVersionName
        params[User.FLD_APP_NAME] = appName
        params[User.TIME_ZONE_OFF_SET] = StringUtils.getStringFromDouble(decimalNumber: DateUtils.getTimeZoneOffSet())
        params[User.PHONE_MODEL] = phoneModel
        params[User.CLIENT_DEVICE_TYPE] = Strings.ios
        HttpUtils.performJSONRequestWithBodyAndStoreAuthToken(url: loginUserUrl, params: params, requestType: .put, encodingType: URLEncoding.httpBody, targetViewController: uiViewController, handler: completionController)
  }
  

  public static func getValidateUserLogin (userId : String, password : String,countryCode :String?, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){

    AppDelegate.getAppDelegate().log.debug("getValidateUserLogin() \(userId)")
    let getValidateUserLoginUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.userLoginUrl
    
    var params = [String : String]()
    params[Ride.FLD_USERID] = userId
    params[User.FLD_PWD] = password
    if countryCode != nil{
      params[User.FLD_COUNTRY_CODE] = countryCode
    }
    params[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
    
    HttpUtils.performJSONRequestWithBodyAndStoreAuthToken(url: getValidateUserLoginUrl, params: params, requestType: .get, encodingType: URLEncoding.methodDependent, targetViewController: targetViewController, handler: completionHandler)

  }
  

  public static func getUserIdForPhoneNo(phoneNo : String,countryCode : String?, uiViewController: UIViewController?, completionController: @escaping responseJSONCompletionHandler)

  {
    let userIdUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.USER_ID_GETTING_SERVICE_PATH
    
    var params = [String : String]()
    params[User.FLD_PHONE] = phoneNo
    params[User.FLD_APP_NAME] = AppConfiguration.APP_NAME

    if countryCode != nil && countryCode!.isEmpty == false{
      params[User.FLD_COUNTRY_CODE] = countryCode!
      
    }
    HttpUtils.performJSONRequestWithBodyAndStoreAuthToken(url: userIdUrl, params: params, requestType: .get, encodingType: URLEncoding.methodDependent, targetViewController: uiViewController, handler: completionController)

  }
    
    public static func updateUserPhoneModel(userId : String,phoneModal : String,uiViewController: UIViewController?, completionController: @escaping responseJSONCompletionHandler)
    {
        let updateUserPhoneModalUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UPDATING_PHONE_MODAL_SERVICE_PATH
        var params = [String : String]()
        params[User.FLD_PHONE] = userId
        params[User.PHONE_MODEL] = phoneModal
        HttpUtils.putRequestWithBody(url: updateUserPhoneModalUrl, targetViewController: uiViewController, handler: completionController, body: params)
    }
    
  public static func blockUser(userId : String,blockUserId : Double, reason : String?, viewController : UIViewController?,completionHandler : @escaping responseJSONCompletionHandler)
  {
    let blockedUsersUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + BLOCKED_USERS_SERVICE_PATH
    var params = [String : String]()
    params[BlockedUser.USER_ID] = userId
    params[BlockedUser.BLOCKED_USER_ID] = StringUtils.getStringFromDouble(decimalNumber: blockUserId)
    if reason != nil
    {
        params[BlockedUser.BLOCKED_REASON] = reason!
    }
    HttpUtils.postRequestWithBody(url: blockedUsersUrl, targetViewController: viewController  , handler: completionHandler, body : params)
  }
  public static func unBlockUser(userId : String,unBlockUserId : Double,viewController :UIViewController?,completionHandler: @escaping responseJSONCompletionHandler)
  {
    let blockedUsersUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + BLOCKED_USERS_SERVICE_PATH
    var params = [String : String]()
    params[BlockedUser.USER_ID] = userId
    params[BlockedUser.BLOCKED_USER_ID] = StringUtils.getStringFromDouble(decimalNumber: unBlockUserId)
    HttpUtils.deleteJSONRequest(url: blockedUsersUrl,params: params, targetViewController: viewController, handler: completionHandler)
  }
    
    public static func getAllFavouritePartners(userId : String, viewController: UIViewController?, completionController: @escaping responseJSONCompletionHandler)
    {
        let favouritePartnerUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + FAVOURITE_PARTNERS_SERVICE_PATH
        var params = [String : String]()
        params[User.FLD_PHONE] = userId
        HttpUtils.getJSONRequestWithBody(url: favouritePartnerUrl, targetViewController: viewController, params: params, handler: completionController)
    }
 
    public static func addFavouritePartner(userId : String,favouritePartnerIds : [Double],viewController :UIViewController?,completionHandler: @escaping responseJSONCompletionHandler){
        let favouritePartnerUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + FAVOURITE_PARTNERS_SERVICE_PATH
        var params = [String : String]()
        params[PreferredRidePartner.USER_ID] = userId
        params[PreferredRidePartner.FAVOURITE_PARTNER_IDS] = String(describing: favouritePartnerIds)
        
        HttpUtils.postRequestWithBody(url: favouritePartnerUrl, targetViewController: viewController, handler: completionHandler, body: params)
        
    }
    public static func removeFavouritePartner(userId : String,removeFavouritePartnerId : Double,viewController :UIViewController?,completionHandler: @escaping responseJSONCompletionHandler){
    let favouritePartnerUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REMOVE_FAVOURITE_PARTNERS_SERVICE_PATH
        var params = [String : String]()
        params[PreferredRidePartner.USER_ID] = userId
        params[PreferredRidePartner.FAVOURITE_PARTNER_USER_ID] = StringUtils.getStringFromDouble(decimalNumber: removeFavouritePartnerId)
    HttpUtils.deleteJSONRequest(url: favouritePartnerUrl, params: params, targetViewController: viewController, handler: completionHandler)
    }

  public static func getUserContactNo(userId : String,uiViewController: UIViewController?, completionController: @escaping responseJSONCompletionHandler)
  {
    let contactNoUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.USER_CONTACT_NO_SERVICE_PATH
    var params = [String : String]()
    params[User.FLD_PHONE] = userId
    HttpUtils.getJSONRequestWithBody(url: contactNoUrl, targetViewController: uiViewController, params: params, handler: completionController)
  }
  
    public static func changePassword(putBodyParams : [String : String] ,isSecure : Bool,uiViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
    
    AppDelegate.getAppDelegate().log.debug("changePassword()")
    
    let changePasswordUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.userResetPasswordUrl
    HttpUtils.performJSONRequestWithBodyAndStoreAuthToken(url: changePasswordUrl, params: putBodyParams, requestType: .put, encodingType: URLEncoding.httpBody, targetViewController: uiViewController, handler: completionHandler)
 }
  
    public static func resetPassword(phoneNumber: String, phoneCode : String?, uiViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
    
    AppDelegate.getAppDelegate().log.debug("resetPassword() \(phoneNumber)")
    
    let resetPasswordUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.userResetPasswordUrl
    
    var params = [String : String]()
    params[User.FLD_PHONE] = phoneNumber
    if phoneCode != nil && !phoneCode!.isEmpty
    {
        params[User.FLD_COUNTRY_CODE] = phoneCode
    }
    params[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
    HttpUtils.performJSONRequestWithBodyAndStoreAuthToken(url: resetPasswordUrl, params: params, requestType: .get, encodingType: URLEncoding.methodDependent, targetViewController: uiViewController, handler: completionHandler)
  }
  
  public static func verifyReferral(referralCode: String, uiViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("verifyReferral() \(referralCode)")
    let verifyReferralUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.userReferalVerifyUrl
    var params = [String : String]()
    params["referralCode"] =  referralCode
    HttpUtils.performJSONRequestWithBodyAndStoreAuthToken(url: verifyReferralUrl, params: params, requestType: .get, encodingType: URLEncoding.methodDependent, targetViewController: uiViewController, handler: completionHandler)
  }
  public static func applyProcode(promoCode: String,userId : String, uiViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("applyProcode() \(promoCode)")
    let applyPromoCodeUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + APPLY_RIDELEVEL_USER_COUPON_SERVICE_PATH
    var params : [String : String] = [String : String]()
    params[User.FLD_PROMO_CODE] =  promoCode
    params[User.FLD_PHONE] = userId
    HttpUtils.putJSONRequestWithBody(url: applyPromoCodeUrl, targetViewController: uiViewController, handler: completionHandler, body: params)
  }
  
  public static func resendVerficiationCode(putBodyDictionary : [String : String], uiViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
    
    AppDelegate.getAppDelegate().log.debug("resendVerficiationCode()")
    let resendCodeUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.userResendVerificationCode
    
    HttpUtils.performJSONRequestWithBodyAndStoreAuthToken(url: resendCodeUrl, params: putBodyDictionary, requestType: .put, encodingType: URLEncoding.httpBody, targetViewController: uiViewController, handler: completionHandler)

  }
  
  public static func getUser(userId : String, targetViewController : UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getUser() \(userId)")
    let getUserUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.userServiceUrl
    
    var params = [String : String]()
    params[User.FLD_PHONE] = userId
    HttpUtils.getJSONRequestWithBody(url: getUserUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
  public static func getUserName(userId : String, targetViewController : UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getUser() \(userId)")
    let getUserUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.getUserName
    
    var params = [String : String]()
    params[User.FLD_PHONE] = userId
    HttpUtils.getJSONRequestWithBody(url: getUserUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
    public static func getUserNameUsingContactNo(phoneNo : String, phoneCode : String?, targetViewController : UIViewController?, completionHandler: @escaping responseJSONCompletionHandler)
  {
    let getUserNameUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.USER_NAME_USING_CONTACT_NO_GETTING_SERVICE_PATH
    var params = [String : String]()
    params[User.FLD_PHONE] = phoneNo
    if phoneCode != nil && !phoneCode!.isEmpty
    {
        params[User.FLD_COUNTRY_CODE] = phoneCode!
    }
    params[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
    HttpUtils.getJSONRequestWithBody(url: getUserNameUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
  public static func getProfile(userId : String, targetViewController : UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
    
    AppDelegate.getAppDelegate().log.debug("getProfile() \(userId)")
    
    let getUserUrl = baseServerUrl + getProfile
    
    var params = [String : String]()
    params[Ride.FLD_ID] = userId
    HttpUtils.getJSONRequestWithBody(url: getUserUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
  
  public static func getCompleteProfile(userId : String, targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getCompleteProfile() \(userId)")
    
    let getCompleteProfilelUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.userCompleteProfile
    var params = [String : String]()
    params[Ride.FLD_USERID] = userId
    
    
    HttpUtils.getJSONRequestWithBody(url: getCompleteProfilelUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
  public static func getUserInformation(userId : String, targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getCompleteProfile() \(userId)")
    
    let getCompleteProfilelUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.USER_INFO_GETTING_SERVICE_PATH
    var params = [String : String]()
    params[User.FLD_PHONE] = userId
    
    
    HttpUtils.getJSONRequestWithBody(url: getCompleteProfilelUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
  
  public static func getVehicle(ownerId : String, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getVehicle() \(ownerId)")
    
    let getVehicleUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.vehicle
    var params = [String : String]()
    params[Vehicle.FLD_OWNER_ID] = ownerId
    HttpUtils.getJSONRequestWithBody(url: getVehicleUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }

  public static func changeMobileNumber(userId : String,newMobileNo : String,countryCode : String?, viewController :UIViewController?,completionHandler: @escaping responseJSONCompletionHandler)

  {
    let changeMobileNumberUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.CHANGE_MOBILE_NO_SERVICE_PATH
    var params = [String : String]()
    params[User.FLD_PHONE] = userId
    params[User.NEW_CONTACT_NO] = newMobileNo
    HttpUtils.putJSONRequestWithBody(url: changeMobileNumberUrl, targetViewController: viewController, handler: completionHandler, body: params)
  }
    
   static func updateAutoConfirmPartnerStatus(userId : Double, partners: String, viewController :UIViewController?,completionHandler: @escaping responseJSONCompletionHandler) {
        let upadteAutoConfirmUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.UPDATE_AUTOCONFIRMPARTNERSTATUS
      var params = [String : String]()
    params[User.FLD_USER_ID] = StringUtils.getPointsInDecimal(points: userId)
    params["partners"] = partners
     HttpUtils.postRequestWithBody(url: upadteAutoConfirmUrl, targetViewController: viewController, handler: completionHandler, body: params)
    }

    public static func updateMobileNumber(userId : String,newMobileNo : String,countryCode : String?,activationCode : String?,activationStatus: String?, appName : String, viewController :UIViewController?,completionHandler: @escaping responseJSONCompletionHandler)
  {
    let updateMobileNumberUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.UPDATE_MOBILE_NO_SERVICE_PATH
    
    var params = [String : String]()
    params[User.FLD_PHONE] = userId
    params[User.NEW_CONTACT_NO] = newMobileNo
    if countryCode != nil && countryCode!.isEmpty == false{
      params[User.FLD_COUNTRY_CODE] = countryCode!
    }
    
    params["verificationCode"] = activationCode
    if activationStatus != nil && activationStatus!.isEmpty == false{
      params[User.FLD_STATUS] = activationStatus
    }
    params[User.FLD_APP_NAME] = appName
    HttpUtils.putJSONRequestWithBody(url: updateMobileNumberUrl, targetViewController: viewController, handler: completionHandler, body: params)
  }
  
  public static func getUserFavoriteLocation (phone : String, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getUserFavoriteLocation() \(phone)")
    
    let getUserFavoriteLocationUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.getUserFavoriteLocation
    var params = [String : String]()
    params[User.FLD_PHONE] = phone
    HttpUtils.getJSONRequestWithBody(url: getUserFavoriteLocationUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
  
  public static func getDefaultVehicle (ownerid : String, targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getDefaultVehicle() \(ownerid)")
    
    let getDefaultVehicleUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.vehicle
    var params = [String : String]()
    params[Vehicle.FLD_OWNER_ID] = ownerid
    params[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
    HttpUtils.getJSONRequestWithBody(url: getDefaultVehicleUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
  
  public static func getClientConfiguration(targetViewController : UIViewController?, completionHandler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getClientConfiguration()")
    let getDefaultConfigurationUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + getUserConfig
    HttpUtils.getJSONRequestWithBody(url: getDefaultConfigurationUrl, targetViewController: targetViewController, params: [String : String](), handler: completionHandler)
  }
  
  public static func getReferralCode(phone : String, targetViewController : UIViewController? , completionHandler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("getReferralCode() \(phone)")
    let getReferralCodeUrl = AppConfiguration.serverUrl + AppConfiguration.serverUrl + baseServerUrl + getReferralCode
    var params = [String : String]()
    params[User.FLD_PHONE] = phone
    
    HttpUtils.getJSONRequestWithBody(url: getReferralCodeUrl, targetViewController: targetViewController, params: params, handler: completionHandler)
  }
  
  public static func saveFeedback(targetViewController: UIViewController, body : String? , completionHandler: @escaping responseJSONCompletionHandler ){
    AppDelegate.getAppDelegate().log.debug("saveFeedback()")
    var params = [String : String]()
    params["userFeedbacks"] = body
    let postUserFeedbackWithBodyUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.USER_FEEDBACK_IN_BULK_SERVICE_PATH
    HttpUtils.postRequestWithBody(url: postUserFeedbackWithBodyUrl, targetViewController: targetViewController, handler: completionHandler, body : params)
  }
  
  public static func saveDeviceToken(targetViewController : UIViewController?, requestBody : Dictionary<String, String>, completionHandler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("saveDeviceToken()")
    let updateDeviceTokenUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.createDeviceToken
    HttpUtils.putJSONRequestWithBody(url: updateDeviceTokenUrl, targetViewController: targetViewController, handler: completionHandler, body: requestBody)
  }
  public static func createUserFavouriteLocation(userFavouriteLocation :UserFavouriteLocation,viewController : UIViewController,completionHandler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("createUserFavouriteLocation()")
    let postUserFavouriteLocationWithBodyUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.USER_FAVOURITE_LOCATIONS_SERVICE_PATH
    HttpUtils.postRequestWithBody(url: postUserFavouriteLocationWithBodyUrl, targetViewController: viewController  , handler: completionHandler, body : userFavouriteLocation.getParams())
  }
  public static func deleteFavouriteLocations(id: Double,viewController :UIViewController,completionHandler: @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("deleteFavouriteLocations() \(id)")
    let deleteUserFavouriteLocationUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.USER_FAVOURITE_LOCATIONS_SERVICE_PATH
    
    
    var params = [String : String]()
    params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: 
        id)
    
    HttpUtils.deleteJSONRequest(url: deleteUserFavouriteLocationUrl,params: params, targetViewController: viewController, handler: completionHandler)
  }
  public static func resendVerificationEmail( userId : String, viewController :UIViewController?,completionHandler: @escaping responseJSONCompletionHandler)
  {
    AppDelegate.getAppDelegate().log.debug("resendVerificationEmail() \(userId)")
    var params :[String : String] = [String : String]()
    params[User.FLD_USER_ID] = userId
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.RESEND_VERIFICATION_EMAIL_SERVICE_PATH
    HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: completionHandler, body: params)
  }
  public static func updateFavouriteLocation(favouriteLocation :UserFavouriteLocation,viewController :UIViewController?,handler : @escaping responseJSONCompletionHandler){
    AppDelegate.getAppDelegate().log.debug("updateFavouriteLocation()")
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.USER_FAVOURITE_LOCATIONS_SERVICE_PATH
    HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: favouriteLocation.getParams())
  }
  public static func updateAppVersion( userid :  String, versionName : String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler ){
    AppDelegate.getAppDelegate().log.debug("updateAppVersion() \(userid)")
    var params : [String : String] = [String : String]()
    params[User.FLD_PHONE] = userid
    params[User.IOS_APP_VERSION_NAME] = versionName
    params[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
    params[User.TIME_ZONE_OFF_SET] = StringUtils.getStringFromDouble(decimalNumber: DateUtils.getTimeZoneOffSet())

    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.UPDATING_APP_VERSION_NAME_SERVICE_PATH
    HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body:params)
  }
  public static func sendSMS(phoneNumber : String,message : String){
    AppDelegate.getAppDelegate().log.debug("sendSMS() \(phoneNumber) \(message)")
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.SEND_SMS
    var params = [String: String]()
    params["message"] = message
    params[User.FLD_PHONE] = phoneNumber
    HttpUtils.putRequestWithBody(url: url, targetViewController: nil, handler: { (responseObject, error) in
      
      }, body: params)
  }
  public static func getUserBasicInfo(userId : Double, viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler)
  {
    AppDelegate.getAppDelegate().log.debug("getUserBasicInfo() \(userId)")
    var params = [String: String]()
    params[User.FLD_PHONE] = StringUtils.getStringFromDouble(decimalNumber: userId)
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + USER_BASIC_INFO_GETTING_SERVICE_PATH
    HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
  }
  public static func saveOrUpdateUserImage(userId : Double,photo : String,imageURI : String?,viewController : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler){
    var params = [String : String]()
    params[Image.USER_PHOTO_STRING] = photo
    params[Image.IMAGE_URI] = imageURI
    params[User.FLD_PHONE] = StringUtils.getStringFromDouble(decimalNumber: userId)
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort  + AppConfiguration.apiServerPath+SAVE_UPDATE_USER_IMAGE
    HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: responseHandler, body: params)
  }
    public static func saveOrUpdateVehicleImage(userId : String,photo : String,imageURI : String?, vehicleId : Double, viewController : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler){
    var params = [String : String]()
    params[Image.USER_PHOTO_STRING] = photo
    params[Image.IMAGE_URI] = imageURI
    params[User.FLD_PHONE] = userId
    params[Vehicle.FLD_VEHICLE_ID] = StringUtils.getStringFromDouble(decimalNumber: vehicleId)
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath+SAVE_UPDATE_VEHICLE_IMAGE
    HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: responseHandler, body: params)
  }
  public static func passUserOfficeEmailVerification(userId : Double,email : String,verificationCode : String?,viewController : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler){
    var params = [String : String]()
    params[User.FLD_PHONE] = StringUtils.getStringFromDouble(decimalNumber: userId)
    params[UserProfile.FLD_EMAIL] = email
    params[VerificationData.VERIFICATION_DATA_FIELD_VERIFYCODE] = verificationCode
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath+USER_OFFICIAL_EMAIL_VERIFICATION_SERVICE_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: responseHandler, body: params)
  }
  static func updateRidePreferences(ridePreferences : RidePreferences,viewController : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler){
    let params = ridePreferences.getParamsMap();
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath+RIDE_PREFERENCES_UPDATE_SERVICE_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: responseHandler, body: params)
  }
  
  
  static func updatedSecurityPreferences( securityPreferences: SecurityPreferences,viewController : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler){
    let params = securityPreferences.getParamsMap()
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath+SECURITY_PREFERENCES_UPDATE_SERVICE_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: responseHandler, body: params)
  }
  
  
  static func updatedEmailPreferences( emailPreferences :EmailPreferences, viewController : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler){
    let params = emailPreferences.getParamsMap()
    let url = communicationServerUrl+EMAIL_PREFERENCES_UPDATE_SERVICE_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: responseHandler, body: params)
  }
  
  
  
  static func updatedSMSPreferences( smsPreferences : SMSPreferences, viewController : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler){
    let params = smsPreferences.getParamsMap()
    let url = communicationServerUrl+SMS_PREFERENCES_UPDATE_SERVICE_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: responseHandler, body: params)
  }
  
    static func updatedWhatsAppPreferences(whatsAppPreferences: WhatsAppPreferences, viewController : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler){
        let params = whatsAppPreferences.getParamsMap()
        let url = communicationServerUrl+WHATSAPP_PREFERENCES_UPDATE_SERVICE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: responseHandler, body: params)
    }
    
    static func updatedCallPreferences(callPreferences: CallPreferences, viewController : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler){
        var params = [String :String]()
        params[User.FLD_CALL_PREF] = Mapper().toJSONString(callPreferences, prettyPrint: false)
        let url = communicationServerUrl+CALL_PREFERENCES_UPDATE_SERVICE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: responseHandler, body: params)
    }
  
  
  static func updateContactEmail(userId : Double, contactEmail :String, viewController : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler){
    var params = [String :String]()
    params[User.FLD_USER_ID] = StringUtils.getStringFromDouble(decimalNumber: userId)
    params[User.CONTACT_EMAIL] = contactEmail
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath+CONTACT_EMAIL_UPDATE_SERVICE_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: responseHandler, body: params)
  }
  static func updateUserVacation(userVacation : UserVacation, viewController : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler)
  {
    let params = userVacation.getParams()
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + USER_VACATION_UPDATE_SERVICE_PATH
    HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: responseHandler, body: params)
  }
    static func updateUserPrimaryRegion( userId : Double, primaryRegion : String?, primaryLat : Double, primaryLong : Double,country : String?,state : String?,city : String?,streetName : String?,areaName : String?,address : String?,viewContrller : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler)
  {
    var params = [String: String]()
    params[User.FLD_PHONE] = StringUtils.getStringFromDouble(decimalNumber: userId)
    params[User.PRIMARY_REGION] = primaryRegion
    params[User.PRIMARY_AREA_LAT] = String(primaryLat)
    params[User.PRIMARY_AREA_LNG] = String(primaryLong)
    params[User.COUNTRY] = country
    params[User.STATE] = state
    params[User.CITY] = city
    params[User.STREET_NAME] = streetName
    params[User.ADDRESS] = address
    params[User.AREA_NAME] = areaName
    
    let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UPDATING_REGION_NAME_SERVICE_PATH
    HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewContrller, handler: responseHandler, body: params)
  }
    
    static func setSuspendUser(userId : String,suspendedByUser : Bool,suspendedMessage : String, viewContrller : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler)
    {
        var params = [String: String]()
        params[User.FLD_PHONE] = userId
        params[User.SUSPENDED_BY_USER] = String(suspendedByUser)
        params[User.SUSPEND_STATUS_MESSAGE] = suspendedMessage
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + USER_ACCOUNT_SUSPEND_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewContrller, handler: responseHandler, body: params)
    }
    static func getUserFeedbacks(feedbackBy : Double ,rideId : Double,viewContrller : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler)
    {
        var params = [String: String]()
        params[UserFeedback.FEEDBACK_BY] = StringUtils.getStringFromDouble(decimalNumber: feedbackBy)
        params[UserFeedback.RIDE_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + EXISTED_FEEDBACK_GETTING_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewContrller, params: params, handler: responseHandler)
    }
    static func sendPassengerTripReportMailForRide(riderRideId : Double ,passengerRideId : Double,viewContrller : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler)
    {
         var params = [String: String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber : riderRideId)
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber : UserDataCache.getCurrentUserId())
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
         let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + PASSENGER_TRIP_BILL_SERVICE_RESOURCE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewContrller , params: params, handler: responseHandler)
    }
    
    static func sendRiderTripReportMailForRide(rideId : Double , actualEndTime : NSDate?,startTime : NSDate, fromLocation : String , toLocation : String , riderId : Double,viewContrller : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler)
    {
        var params = [String: String]()
        params[Ride.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        if let actualEndTime = actualEndTime {
            params[Ride.FLD_ACTUALENDTIME] = AppUtil.getDateStringFromNSDate(date: DateUtils.getDateTimeInUTC(date: actualEndTime))
        }
        params[Ride.FLD_STARTTIME] = AppUtil.getDateStringFromNSDate(date: DateUtils.getDateTimeInUTC(date: startTime))
        params[Ride.FLD_STARTADDRESS] = fromLocation
        params[Ride.FLD_ENDADDRESS] = toLocation
        params[Ride.FLD_USERID] = StringUtils.getStringFromDouble(decimalNumber : UserDataCache.getCurrentUserId())
        let url = AppConfiguration.financialServerUrlIp + AppConfiguration.FS_serverPort + AppConfiguration.financialServerPath + RIDER_REPORT_SERVICE_RESOURCE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewContrller, params: params, handler: responseHandler)
    }
    public static func saveUserDirectFeedback(targetViewController: UIViewController, body : Dictionary<String, String> , completionHandler: @escaping responseJSONCompletionHandler ){
        AppDelegate.getAppDelegate().log.debug("saveUserDirectFeedback()")
        let postUserFeedbackWithBodyUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.DIRECT_USER_FEEDBACK_SERVICE_PATH
        HttpUtils.postRequestWithBody(url: postUserFeedbackWithBodyUrl, targetViewController: targetViewController, handler: completionHandler, body : body)
    }

    public static func isReVerificationMailSent(userId : String, email : String, targetViewController: UIViewController?,  completionHandler: @escaping responseJSONCompletionHandler ){
        var params = [String: String]()
        params[User.FLD_USER_ID] = userId
        params[UserProfile.FLD_EMAIL] = email
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GETTING_REVERIFICATION_MAIL_SENT_STATUS_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: targetViewController, params: params, handler: completionHandler)

    }
    public static func updateDeviceUniqueId( userid :  Double?, uniqueID : String,appsFlyerId: String?,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler ){
        AppDelegate.getAppDelegate().log.debug("updateAppVersion() \(userid)")
        var params : [String : String] = [String : String]()
        params[User.FLD_USER_ID] = StringUtils.getStringFromDouble(decimalNumber: userid)
        params[User.FLD_DEVICE_UNIQUE_ID] = uniqueID
        params[User.APPSFLYER_ID] = appsFlyerId
        
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.UPDATING_DEVICE_UNIQUE_ID_SERVICE_PATH
        HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: handler, body:params)
    }
    
    static func searchUserForSearchIdentifier(searchIdentifier : String,viewController : UIViewController,handler: @escaping responseJSONCompletionHandler){
        var params = [String:String]()
        params[Group.GROUP_SEARCH_IDENTIFIER] = searchIdentifier
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + USERS_SEARCH_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    static func saveOfferStatus(userId : String?, offerId : Double?,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler ){
        var params = [String:String]()
        params[User.FLD_USER_ID] = userId
        params[Offer.OFFER_STATUS_OFFERID] = StringUtils.getStringFromDouble(decimalNumber: offerId)
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + USER_OFFER_STATUS_PATH
        HttpUtils.postJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    static func subscribeToCashTransaction(userId : String,status : String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        params[User.STATUS] = status
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + SUBSCRIBE_TO_CASH_TRANSACTIONS_PATH
       HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }

    static func getCurrentUser(phoneNo : String,countryCode : String,appName : String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_PHONE] = phoneNo
        params[User.FLD_COUNTRY_CODE] = countryCode
        params[User.FLD_APP_NAME] = appName
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_CURRENT_USER_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    static func getUserOnTimeComplianceRating(userId: String, viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_PHONE] = userId
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_ONTIMECOMPLIANCE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
    }
    static func removeRidePartnersContact(userId: String, contactId: String, isFavPartner: Bool, viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Contact.FLD_USER_ID] = userId
        params[Contact.FLD_CONTACT_ID] = contactId
        
        params[Contact.FLD_FAV_PARTNER] = String(isFavPartner)
        let  url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.REMOVE_RIDE_PARTICIPANTS
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func sendSubscriptionMailFromSupport(userId: String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        
        let  url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + SUBSCRIPTION_MAIL_FROM_SUPPORT_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func sendRegistrationMailAfterSignup(userId: String,preferedRole: String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[Ride.FLD_ID] = userId
        params[RidePreferences.PREFERRED_ROLE] = preferedRole
        
        let  url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + SEND_REGISTRATION_MAIL_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func getRegisterCoupons(viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){

       let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + REGISTER_SYSTEM_COUPONS_GETTING_SERVICE_PATH
       HttpUtils.getJSONRequestWithBodyUnSecure(url: url, targetViewController: viewController, params: [String : String](), completionHandler: handler)
    }
    
    static func applyUserCoupon(userId : String,appliedCoupon : String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_PHONE] = userId
        params[User.FLD_PROMO_CODE] = appliedCoupon
        
        let  url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + APPLY_USER_COUPON_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func updateGoogleAdvertiserId(userId : String,googleAdvertisingId : String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.FLD_PHONE] = userId
        params[User.googleAdvertisingId] = googleAdvertisingId
        
        let  url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UPDATE_GOOGLE_ADVERTISING_ID_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    static func saveUserRefererInfo(userRefererInfo : UserRefererInfo,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        
        let  url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + SAVE_USER_REF_INFO_SERVICE_PATH
        HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: userRefererInfo.getParams())
    }
    
    public static func getDisplayableRideEtiquette(userId: String?,targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler ){
        AppDelegate.getAppDelegate().log.debug("getDisplayableRideEtiquette()")
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.GET_DISPLAYABLE_RIDE_ETIQUETTE_SERVICE_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: targetViewController, params: params, handler: completionHandler)
    }
    
    public static func updateDisplayedRideEtiquette(userId: String?, etiquetteId: String?,targetViewController: UIViewController?, completionHandler: @escaping responseJSONCompletionHandler ){
        AppDelegate.getAppDelegate().log.debug("updateDisplayedRideEtiquette()")
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        params[RideEtiquette.FLD_ETIQUETTE_ID] = etiquetteId
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UserRestClient.Update_DISPLAYED_RIDE_ETIQUETTE_SERVICE_PATH
        HttpUtils.postRequestWithBody(url: url, targetViewController: targetViewController, handler: completionHandler, body: params)
    }
    static func getVirtualNumber(callerId : String, callerSourceApp : String, receiverId : String?, receiverSourceApp : String?, viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        
        params[User.CALLER_ID] = callerId
        params[User.RECIEVER_ID] = receiverId
        params["callerSourceApp"] = callerSourceApp
        params["receiverSourceApp"] = receiverSourceApp
        let url = AppConfiguration.userContactServerUrlIP + AppConfiguration.UCS_serverPort + AppConfiguration.userContactServerPath + VIRTUAL_NUMBER_PATH
        
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
   }
    
    static func fetchDrivingLicenseDetails(userId : String,dlNumber : String,dateOfBirth: String?,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        
         var params = [String : String]()
        
        params[User.FLD_USER_ID] = userId
        params[Vehicle.FLD_DL_NUM] = dlNumber
        params[User.FLD_DOB] = dateOfBirth
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + FETCH_DL_DETAILS_PATH
        
        HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
      
        
    }
    
    static func completeDrivingLicenseImageVerification(userId : String,photoString : String,viewController : UIViewController?,dlNumber : String,handler :@escaping responseJSONCompletionHandler){
        
        var params = [String : String]()
        
        params[User.FLD_USER_ID] = userId
        params[PHOTO_STRING] = photoString
        params[Vehicle.FLD_DL_NUM] = dlNumber
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + COMPLETE_DL_VERIFICATION_PATH
        
        HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func saveNomineeDetails(nomineeDetails : NomineeDetails,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
 
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + NOMINEE_DETAILS_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: nomineeDetails.getParams())
    }
    
    static func claimRideInsurance(userId : String?,passengerRideId : Double?,riderId : Double?,rideId : Double?,claimType : String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[NomineeDetails.PHONE] = userId
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        params[Ride.FLD_RIDERID] = StringUtils.getStringFromDouble(decimalNumber: riderId)
        params[Ride.FLD_RIDEID] = StringUtils.getStringFromDouble(decimalNumber: rideId)
        
        params[NomineeDetails.CLAIM_TYPE] = claimType
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + CLAIM_INSURANCE_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func cancelRideInsurance(passengerRideId : Double,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        
        var params = [String : String]()
        
        params[Ride.FLD_PASSENGERRIDEID] = StringUtils.getStringFromDouble(decimalNumber: passengerRideId)
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UPDATE_POLICY_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func addAlternateContactNo(userId : String,alternateContactNo : String?,viewController : UIViewController,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        
        params[User.FLD_USER_ID] = userId
        params[User.ALTERNATE_CONTACT_NO] = alternateContactNo
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + ADD_ALTERNATE_CONTACT_NUM_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    static func getReferralCoupons(viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_REFFERAL_COUPONS
        HttpUtils.getJSONRequestWithBodyUnSecure(url: url, targetViewController: viewController, params: [String : String](), completionHandler: handler)
    }
    static func getSocialUserStatus(userSocialNetworkId : String,userSocialNetworkType : String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        
        var params = [String : String]()
        params[SocialUserStatus.socialNetworkId] = userSocialNetworkId
        params[SocialUserStatus.socialNetworkType] = userSocialNetworkType
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + SOCIAL_LOGIN_PATH
        
        HttpUtils.performJSONRequestWithBodyAndStoreAuthToken(url: url, params: params, requestType: .get, encodingType: URLEncoding.methodDependent, targetViewController: viewController, handler: handler)
    }
    
    static func createProbableUser(contactNo : String,countryCode : String,appName : String,status : String,verificationProvider : String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        var params = [String : String]()
        params[User.CONTACT_NO] = contactNo
        params[User.FLD_COUNTRY_CODE] = countryCode
        params[User.FLD_APP_NAME] = appName
        params[User.STATUS] = status
        params[User.VERFICATION_PROVIDER] = verificationProvider
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + CREATE_PROBABLE_USER_PATH
        
        HttpUtils.postRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func resendOTPToNewUser(contactNo : String,appName : String,countryCode : String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        
        var params = [String : String]()
        params[User.CONTACT_NO] = contactNo
        params[User.FLD_COUNTRY_CODE] = countryCode
        params[User.FLD_APP_NAME] = appName
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + RESEND_OTP_TO_NEW_USER_PATH
        
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
    }
    
    static func verifyOTPForNewUser(contactNo : String,otp : String,countryCode : String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        
        var params = [String : String]()
        params[User.CONTACT_NO] = contactNo
        params[User.FLD_COUNTRY_CODE] = countryCode
        params["otp"] = otp
        params[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + NEW_USER_OTP_VERIFICATION_PATH
        HttpUtils.putRequestWithBody(url: url, targetViewController: viewController, handler: handler, body: params)
        
    }
    
    static func loginWithOTP(contactNo : Double?,otp : String,appName : String,countryCode : String?,appVersionName : String,phoneModel : String,uiViewController: UIViewController?, password : String?,completionController: @escaping responseJSONCompletionHandler){
        
        let loginUserUrl = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + LOGIN_WITH_OTP_PATH
        
        var params = [String : String]()
        params[User.CONTACT_NO] = StringUtils.getStringFromDouble(decimalNumber: contactNo)
        if countryCode != nil && !countryCode!.isEmpty
        {
            params[User.FLD_COUNTRY_CODE] = countryCode
        }
        params[User.OTP] = otp
        params[User.IOS_APP_VERSION_NAME] = appVersionName
        params[User.FLD_APP_NAME] = appName
        params[User.TIME_ZONE_OFF_SET] = StringUtils.getStringFromDouble(decimalNumber: DateUtils.getTimeZoneOffSet())
        params[User.PHONE_MODEL] = phoneModel
        params[User.FLD_DEVICE_UNIQUE_ID] = DeviceUniqueIDProxy().getDeviceUniqueId()
        params[User.FLD_PWD] = password
        params[User.CLIENT_DEVICE_TYPE] = Strings.ios
        
        HttpUtils.performJSONRequestWithBodyAndStoreAuthToken(url: loginUserUrl, params: params, requestType: .put, encodingType: URLEncoding.httpBody, targetViewController: uiViewController, handler: completionController)
        
    }
    
    static func getDecryptedPassword(userId : Double?,countryCode : String?,appName : String?,viewController : UIViewController?,handler : @escaping responseJSONCompletionHandler){
        
        var params = [String : String]()
        params[User.FLD_USER_ID] = StringUtils.getStringFromDouble(decimalNumber: userId)
        if countryCode != nil && !countryCode!.isEmpty
        {
            params[User.FLD_COUNTRY_CODE] = countryCode
        }
        params[User.FLD_APP_NAME] = appName
        
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_DECRYPTED_PASSWORD_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: viewController, params: params, handler: handler)
        
    }
    
    static func createSocialUser(userPostDictionary : [String : String], targetViewController : UIViewController?, completionHandler: @escaping responseJSONCompletionHandler){
        
        AppDelegate.getAppDelegate().log.debug("createSocialUser()")
        let createUserUrl =  baseServerUrl + AppConfiguration.apiServerPath + CREATE_SOCIAL_USER_PATH
        HttpUtils.performJSONRequestWithBodyAndStoreAuthToken(url: createUserUrl, params: userPostDictionary, requestType: .post, encodingType: URLEncoding.httpBody, targetViewController: targetViewController, handler: completionHandler)
        
    }
    
    static func updateUserRecentLocation(userId : Double?, locationInfo : String?,viewContrller : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler)
    {
      var params = [String: String]()
      params[User.FLD_PHONE] = StringUtils.getStringFromDouble(decimalNumber: userId)
      params["locationInfo"] = locationInfo
      
      let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + UPDATE_RECENT_LOCATION_PATH
      HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewContrller, handler: responseHandler, body: params)
    }
    
    static func saveOrUpdateUserPreferredPickupDrop(userId: String?, userPreferredPickupDropJsonString: String?,viewContrller : UIViewController?,responseHandler : @escaping responseJSONCompletionHandler)
    {
        var params = [String: String]()
        params[User.FLD_USER_ID] = userId
        params[UserPreferredPickupDrop.FLD_UER_PREFERRED_PICKUP_DROP] = userPreferredPickupDropJsonString
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + SAVE_OR_UPDATE_PREFERRED_PICKUP_DROP_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: viewContrller, handler: responseHandler, body: params)
    }
    static func updateUserUserNotificationSetting(targetViewController: UIViewController?, params : Dictionary<String, String> , completionHandler: @escaping responseJSONCompletionHandler )
    {
        AppDelegate.getAppDelegate().log.debug("updateUserUserNotificationSetting()")
        let url = communicationServerUrl + USER_NOTIFICATION_SETTINGS_SERVICE_PATH
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body: params)
    }
    static func saveUserInstallEventInfo(userInstallEvent: UserAttributionEvent,userAttributionType: String,completionHandler: @escaping responseJSONCompletionHandler) {
        var params = userInstallEvent.getParams()
        params["action"] = userAttributionType
        params["androidVersion"] = "0.0"
        params["iosVersion"] = AppConfiguration.APP_CURRENT_VERSION_NO
        let url = AppConfiguration.userEventServerUrlIp + AppConfiguration.UE_serverPort + USER_INSTALL_EVENT_PATH
        Alamofire.request(url, method: .post, parameters: params,encoding: JSONEncoding.default, headers: nil).responseJSON {
            response in
        }
    }
        
    
    static func sendEventToServer(eventType: String, params: [String: Any], uniqueField: String,completionHandler: @escaping responseJSONCompletionHandler) {
        let url = AppConfiguration.userEventServerUrlIp + AppConfiguration.UE_serverPort + USER_EVENT_PATH
        var paramsToPass = params
        paramsToPass["eventName"] = eventType
        paramsToPass["eventUniqueField"] = uniqueField
        paramsToPass["advertisingId"] = AppDelegate.getAppDelegate().getIDFA()
        paramsToPass["androidVersion"] = "0.0"
        paramsToPass["iosVersion"] = AppConfiguration.APP_CURRENT_VERSION_NO
        Alamofire.request(url, method: .post, parameters: paramsToPass,encoding: JSONEncoding.default, headers: nil).responseJSON {
        response in
        }
    }
    static func getCallHistory(userId: String,targetViewController: UIViewController?,completionHandler: @escaping responseJSONCompletionHandler) {
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        let url = AppConfiguration.userContactServerUrlIP + AppConfiguration.UCS_serverPort + AppConfiguration.userContactServerPath + CALL_HISTORY_PATH 
        HttpUtils.postRequestWithBody(url: url, targetViewController: targetViewController, handler: completionHandler, body: params)
    }
    static func getContactNoForDeviceId(deviceId: String,appName: String,completionHandler: @escaping responseJSONCompletionHandler) {
        var params = [String: String]()
        params[User.FLD_DEVICE_UNIQUE_ID] = deviceId
        params[User.FLD_APP_NAME] = appName
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + CONTACT_NUMBER_PATH
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    public static func saveCallLog(fromUserId: String?, toUserId: String?, refId: String?, viewController : UIViewController?,completionHandler : @escaping responseJSONCompletionHandler)
    {
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + SAVE_CALL_LOG_PATH
        var params = [String : String]()
        params["fromUserId"] = fromUserId
        params["toUserId"] = toUserId
        params["refId"] = refId
        HttpUtils.postRequestWithBody(url: url, targetViewController: viewController  , handler: completionHandler, body : params)
    }
    static func saveSafeKeeperStatus(userId: String?, status: String?,completionHandler : @escaping responseJSONCompletionHandler)
    {
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        params[User.COVID_ASSESSMENT_RESULT] = status
        let url = baseServerUrl + AppConfiguration.apiServerPath + SAVE_SAFE_KEEPER_SERVICE_PATH
        HttpUtils.postRequestWithBody(url: url, targetViewController: nil, handler: completionHandler, body : params)
    }
    static func getUserReferralStats(userId: String,completionHandler: @escaping responseJSONCompletionHandler) {
        var params = [String: String]()
        params[User.FLD_USER_ID] = userId
        let url = baseServerUrl + AppConfiguration.apiServerPath + REFERRAL_STATS
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    static func getReferralLeaderList(completionHandler: @escaping responseJSONCompletionHandler) {
        let params = [String: String]()
        let url = baseServerUrl + AppConfiguration.apiServerPath + REFERRAL_LEADER_LIST
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    
    static func getReferredUserInfo(userId: String,completionHandler: @escaping responseJSONCompletionHandler) {
        var params = [String: String]()
        params[User.FLD_USER_ID] = userId
        let url = baseServerUrl + AppConfiguration.apiServerPath + REFERRED_USER_LIST
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    static func getContactStatusForReferral(contactList: String,completionHandler: @escaping responseJSONCompletionHandler) {
        var params = [String: String]()
        params["contactList"] = contactList
        let url = baseServerUrl + AppConfiguration.apiServerPath + REFERRAL_CONTACT_REGISTRATION_STATUS
        HttpUtils.postRequestWithBody(url: url, targetViewController: nil  , handler: completionHandler, body : params)
    }
    static func getContactStatusForInvite(userId : Double, contactList: String,completionHandler: @escaping responseJSONCompletionHandler) {
        var params = [String: String]()
        params[User.FLD_USER_ID] = StringUtils.getStringFromDouble(decimalNumber: userId)
        params["contactNo"] = contactList
        let url = baseServerUrl + AppConfiguration.apiServerPath + GET_USER_CONTACT_REG_INFO_SERVICE_PATH
        HttpUtils.postRequestWithBody(url: url, targetViewController: nil  , handler: completionHandler, body : params)
    }
    
    public static func sendContactsToSerever(contactList: String,referralUrl: String?,completionHandler : @escaping responseJSONCompletionHandler){
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + INVITE_CONTACTS_TO_REFER
        var params = [String : String]()
        params["contactList"] = contactList
        params[User.FLD_USER_ID] = UserDataCache.getInstance()?.userId
        if let url = referralUrl,!url.isEmpty{
            params["referralLink"] = referralUrl
        }
        HttpUtils.postRequestWithBody(url: url, targetViewController: nil  , handler: completionHandler, body : params)
    }
    
    public static func getUserWithPickupOTP(userId: String?, uiViewController: UIViewController?, completionController: @escaping responseJSONCompletionHandler)
    {
      let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_USER_WITH_PICKUP_OTP_PATH
      var params = [String : String]()
      params[User.FLD_PHONE] = userId
      HttpUtils.getJSONRequestWithBody(url: url, targetViewController: uiViewController, params: params, handler: completionController)
    }
    static func updateBestMatchAlertRegistration(rideMatchAlertRegistration: RideMatchAlertRegistration, completionHandler: @escaping responseJSONCompletionHandler){
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + BEST_MATCH_ALERT_REGISTRATION
        let params = rideMatchAlertRegistration.getParamsMap()
        HttpUtils.postRequestWithBody(url: url, targetViewController: nil  , handler: completionHandler, body : params)
    }
    public static func getCompanyDomains(userId: String,identifier: String,completionController: @escaping responseJSONCompletionHandler){
      let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_COMPANY_DOMAINS
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        params["identifier"] = identifier
      HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    static func getUserProfile(userId: String?, completionHandler: @escaping responseJSONCompletionHandler){
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_USER_PROFILE_NEW
        var params = [String : String]()
        params[User.FLD_ID] = userId
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionHandler)
    }
    
    public static func checkCompanyDomainStatus(emailDomain: String,completionController: @escaping responseJSONCompletionHandler){
      let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + CHECK_COMPANY_EXISTANCE
        var params = [String : String]()
        params[CompanyVerificationStatus.emailDomain] = emailDomain
      HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params, handler: completionController)
    }
    
    static func getAdsListBasedOnScreen(userId: String,completionHandler: @escaping responseJSONCompletionHandler) {
        let createUserUrl = AppConfiguration.creditTrackServerUrl + AppConfiguration.CT_serverPort + AppConfiguration.CREDIT_TRACK_SERVER_PATH + GET_ADS_LIST
        var params = [String : String]()
        params[JobPromotionData.USER_ID] = userId
        HttpUtils.getJSONRequestWithBody(url: createUserUrl, targetViewController: nil, params: params, handler: completionHandler)
    }
    
    static func updateAdsImpressionCount(impressionAudit: ImpressionAudit, completionHandler: @escaping responseJSONCompletionHandler) {
         var params = [String : String]()
        params = impressionAudit.getParamsMap()
        let createUserUrl = AppConfiguration.creditTrackServerUrl + AppConfiguration.CT_serverPort + AppConfiguration.CREDIT_TRACK_SERVER_PATH + UPDATE_AD_IMPRESSION
        HttpUtils.postRequestWithBody(url: createUserUrl, targetViewController: nil  , handler: completionHandler, body : params)
    }
    static func offerImpressionSaving(offerIds: String,inputType: String,completionController: @escaping responseJSONCompletionHandler) {
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + OFFER_IMPRESSION_RECORD
        var params = [String : String]()
        params[User.FLD_USER_ID] = UserDataCache.getInstance()?.userId ?? ""
        params[User.FLD_OFFERID] = offerIds
        params[User.FLD_INPUT_TYPE] = inputType
        
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    static func updateBestMatchAlertStatus(rideMatchAlertId: String,userId: String,status: String,completionController: @escaping responseJSONCompletionHandler) {
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + BEST_MATCH_ALERT_UPDATE_STATUS
        var params = [String : String]()
        params[RideMatchAlertRegistration.rideMatchAlertId] = rideMatchAlertId
        params[RideMatchAlertRegistration.userId] = userId
        params[RideMatchAlertRegistration.status] = status
        HttpUtils.putJSONRequestWithBody(url: url, targetViewController: nil, handler: completionController, body: params)
    }
    static func getCouponsForReferralAndRole(userId: String,role: String,scheme: String,viewController : UIViewController?,handler :@escaping responseJSONCompletionHandler){
        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_SYSTEM_COUPONS
        var params = [String : String]()
        params[User.FLD_USER_ID] = userId
        params[SystemCouponCode.COUPON_APPLICABLE_ROLE] = role
        params[SystemCouponCode.COUPON_APPLICABLE_SCHEME] = scheme
        HttpUtils.getJSONRequestWithBodyUnSecure(url: url, targetViewController: viewController, params: params, completionHandler: handler)
    }
    static func deleteUserAccount(userId : Double, responseHandler : @escaping responseJSONCompletionHandler){
        var params = [String: String]()
        params["phone"] = StringUtils.getStringFromDouble(decimalNumber: userId)
      let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + DELETE_ACCOUNT
      HttpUtils.putRequestWithBody(url: url, targetViewController: nil, handler: responseHandler, body: params)
    }
    
}
