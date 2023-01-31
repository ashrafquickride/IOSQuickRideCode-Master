//
//  SharedPreferenceHelper.swift
//  Quickride
//
//  Created by KNM Rao on 14/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class SharedPreferenceHelper{

    private static let PREFERENCES_NAME : String = "myprefrences"
    private static let USER : String = "user"
    private static let USER_PWD : String = "userPwd"
    private static let CONTACT_NO : String = "contactNo"
    private static let COUNTRY_CODE : String = "countryCode"
    private static let RIDE_TYPE : String  = "rideType"
    private static let VEHICLE : String = "vehicle"
    private static let USER_PROFILE : String = "profile"
    private static let REFERRAL_CODE : String = "referralCode"
    private static let USER_NAME : String = "name"
    private static let PHONE : String = "phone"
    private static let UNREAD_CHAT : String = "chat"
    private static let USERID : String = "userId"
    private static let USERNAME : String = "userName"
    private static let USERGENDER : String = "gender"
    private static let NOTIFICATION_COUNT:String = "notificationCount"
    private static let OFFERS:String = "offers"
    private static let USERPREFERENCES:String = "userPreferences"
    private static let OFFER_STATUS:String = "offerStatus"
    private static let LAST_UPDATED_TIME:String = "lastUpdatedTime"
    private static let bonusPoints_Key = "bonusPoints"
    private static let recent_notification = "recent_notification"
    private static let CONTACT_INVITE_GUIDE_STATUS = "CONTACT_INVITE_GUIDE_STATUS"
    private static let ROUTE_SELECTION_GUIDE_STATUS = "CONTACT_INVITE_GUIDE_STATUS"
    private static let tip_keys = ["OFFER_RIDE", "FIND_RIDE", "RIDER_RIDE_CREATED", "PASSENGER_RIDE_CREATED", "INVITE_SEND_RIDER", "INVITE_SEND_PASSENGER", "INVITE_SEND_PASSENGER_STARTED_RIDER_CONTEXT", "RIDER_JOINED_PASSENGER", "PASSENGER_JOINED_RIDER", "RIDER_RIDE_STARTED", "PASSENGER_RIDE_STARTED", "RIDER_RIDE_DELAYED", "RIDER_GROUP_CHAT", "RIDE_PREFERENCES", "NOTIFICATION_ACTION_CONTEXT", "UPDATE_FARE_CONTEXT"]
    private static let ALLOW_RATE_US_DIALOG_TO_SPECIFIC_USER = "allowRateUsDialog"
    private static let SHARE_RIDES_WITH_UNVERIFIED_USERS_STATUS = "SHARE_RIDES_WITH_UNVERIFIED_USERS_STATUS"
    private static let USER_REFERER_INFO = "USER_REFERER_INFO"
    private static let NEW_USER_INFO_UPDATE_STATUS = [SharedPreferenceHelper.NEW_USER_PROFILE_PIC_UPLOAD, SharedPreferenceHelper.NEW_USER_VEHICLE_DETAILS, SharedPreferenceHelper.NEW_USER_ORGANIZATION_DETAILS, SharedPreferenceHelper.NEW_USER_ROUTE_INFO, SharedPreferenceHelper.NEW_USER_ACTIVATED_STATUS]
    public static let NEW_USER_PROFILE_PIC_UPLOAD = "NEW_USER_PROFILE_PIC_UPLOAD"
    public static let NEW_USER_FEATURE_SELECTION_DETAILS = "NEW_USER_FEATURE_SELECTION_DETAILS"
    public static let NEW_USER_ROLE_DETAILS = "NEW_USER_ROLE_DETAILS"
    public static let NEW_USER_VEHICLE_DETAILS = "NEW_USER_VEHICLE_DETAILS"
    public static let NEW_USER_ORGANIZATION_DETAILS = "NEW_USER_ORGANIZATION_DETAILS"
    public static let NEW_USER_CARPOOL_ONBORDING_DETAILS = "NEW_USER_CARPOOL_ONBORDING_DETAILS"
    public static let NEW_USER_TAXI_ONBORDING_DETAILS = "NEW_USER_TAXI_ONBORDING_DETAILS"
    public static let NEW_USER_BAZAARY_ONBORDING_DETAILS = "NEW_USER_BAZAARY_ONBORDING_DETAILS"
    public static let NEW_USER_ROUTE_INFO = "NEW_USER_ROUTE_INFO"
    public static let NEW_USER_ACTIVATED_STATUS = "NEW_USER_ACTIVATED_STATUS"
    private static let RIDE_LOCATION_UDPATE_SEQUENCE = "RIDE_LOCATION_UDPATE_SEQUENCE"
    public static let DISPLAY_CHANGE_LOACATION_VIEW = "DISPLAY_CHANGE_LOACATION_VIEW"
    private static let DONT_SHOW_REDEMPTION_AGAIN = "DONT_SHOW_REDEMPTION_AGAIN"
    public static let DISPLAY_SWITCH_RIDE_INFO = "DISPLAY_SWITCH_RIDE_INFO"
    public static let UNVERIFIED_USER_DISPLAY_TIME = "UNVERIFIED_USER_DISPLAY_TIME"
    public static let SPLASH_VIDEO_DISPLAY_TIME = "SPLASH_VIDEO_DISPLAY_TIME"
    public static let AUTHORIZATION = "Authorization"
    static let FEEDBACK_GIVEN_USER_IDS = "FEEDBACK_GIVEN_USER_IDS"
    static let PREFERRED_ROLE = "PREFERRED_ROLE"
    static let IGNORED_USERS = "IGNORED_USERS"
    static let SUBSCRIPTION_MAIL = "SUBSCRIPTION_MAIL"
    static let APP_START_UP = "APP_START_UP"
    static let USER_DATA = "USER_DATA"
    static let RIDE_DATA = "EVENT_DATA"
    static let APP_STARTUP_DATA = "APP_STARTUP_DATA"
    private static let DONT_SHOW_RECHARGE_AGAIN = "DONT_SHOW_RECHARGE_AGAIN"
    static let REFER_EARN_OFFER_DISPLAY_TIME = "REFER_EARN_OFFER_DISPLAY_TIME"
    static let HOME_LOCATION = "HOME_LOCATION"
    static let OFFICE_LOCATION = "OFFICE_LOCATION"
    static let USER_OBJECT = "USER_OBJECT"
    static let USER_PROFILE_OBJECT = "USER_PROFILE_OBJECT"
    static let USER_VEHICLE_OBJECT = "USER_VEHICLE_OBJECT"
    static let USER_PRIMARY_LOCATION = "USER_PRIMARY_LOCATION"
    static let HOME_TO_OFFICE_ROUTE = "HOME_TO_OFFICE_ROUTE"
    static let OFFICE_TO_HOME_ROUTE = "OFFICE_TO_HOME_ROUTE"
    static let VIEW_IDENTIFIER = "VIEW_IDENTIFIER"
    static let userDefaults = UserDefaults.standard
    private static var APPVERSION = "APPVERSION"
    static let REWARDS_INFO_VIEW = "REWARDS_INFO_VIEW"
    static let SAVING_STATUS_ORG_DETAILS = "SAVING_STATUS_ORG_DETAILS"
    static let SAVING_STATUS_HOME_LOCATION = "SAVING_STATUS_HOME_LOCATION"
    static let SAVING_STATUS_OFFICE_LOCATION = "SAVING_STATUS_OFFICE_LOCATION"
    static let SAVING_STATUS_PIC_DETAILS = "SAVING_STATUS_PIC_DETAILS"
    static let USER_IMAGE = "USER_IMAGE"
    static let RIDE_ASSURED_INCENTIVE = "RIDE_ASSURED_INCENTIVE"
    static let RIDE_ASSURED_INCENTIVE_DISPLAY_COUNT = "RIDE_ASSURED_INCENTIVE_DISPLAY_COUNT"
    static let RIDE_ASSURED_INCENTIVE_DISPLAY_TIME = "RIDE_ASSURED_INCENTIVE_DISPLAY_TIME"
    static let RIDE_DETAIL_INFO = "RIDE_DETAIL_INFO"
    static let LAZYPAY_ELIGIBILITY = "LAZYPAY_ELIGIBILITY"
    static let CHECK_LAZYPAY_ELIGIBILITY_TIME = "CHECK_LAZYPAY_ELIGIBILITY_TIME"
    static let SHORT_SIGN_UP_FLOW_STATUS = "SHORT_SIGN_UP_FLOW_STATUS"
    static let GROUPS_INFO_VIEW_DISPLAY_STATUS = "GROUPS_INFO_VIEW_DISPLAY_STATUS"
    static let FAV_INFO_VIEW_DISPLAY_STATUS = "FAV_INFO_VIEW_DISPLAY_STATUS"
    static let PAST_TRANSACTION_TOOL_TIP = "PAST_TRANSACTION_TOOL_TIP"
    static let RIDE_ETIQUETTE = "RIDE_ETIQUETTE"

    static let RECURRING_RIDE_STATUS_FROM_BASE_RIDE = "RECURRING_RIDE_STATUS_FROM_BASE_RIDE"
    static let SHARE_AND_EARN_POINTS_AFTER_VERIFICATION = "SHARE_AND_EARN_POINTS_AFTER_VERIFICATION"
    static let SHARE_AND_EARN_POINTS_AFTER_FIRSTRIDE = "SHARE_AND_EARN_POINTS_AFTER_FIRSTRIDE"
    static let REGULAR_RIDE_SHOW_HIDE_STATUS = "REGULAR_RIDE_SHOW_HIDE_STATUS"
    static let RIDE_TAKER_PLEDGE = "RIDE_TAKER_PLEDGE"
    static let RIDE_GIVER_PLEDGE = "RIDE_GIVER_PLEDGE"
    static let OTP : String = "otp"
    static let VERIFICATION_VIEW : String = "VERIFICATION_VIEW"
    static let AUTOCONFIRM_POPUP_DISPLAY_COUNT_IN_MATCHING_OPTIONS = "AUTOCONFIRM_POPUP_DISPLAY_COUNT_IN_MATCHING_OPTIONS"
    static let RECENT_LOCATION_UPDATED_TIME = "RECENT_LOCATION_UPDATED_TIME"
    static let NEW_COMPANY = "NEW_COMPANY"
    static let RIDE_ID = "RIDE_ID"
    static let RIDER_RIDE_ID = "RIDER_RIDE_ID"
    static let WHY_CONFIRM_PICKUP = "WHY_CONFIRM_PICKUP"
    static let TRIP_REPORT_OPTIONS = "TRIP_REPORT_OPTIONS"
    static let TRIP_REPORT_OFFER_SHOWN = "TRIP_REPORT_OFFER_SHOWN"

    static let ROUTE_METRICS_PREFIX = "routeMetrics:"
    static let CLEVERTAP_APP_VERSION_STATUS = "CLEVERTAP_APP_VERSION_STATUS"
    static let MODERATOR_INFO_SHOWN_RIDE_ID = "MODERATOR_INFO_SHOWN_RIDE_ID"
    static let MODERATOR_INFO_SHOWN_COUNT = "MODERATOR_INFO_SHOWN_COUNT"
    static let UNREAD_MESSAGE_OF_USER = "UNREAD_MESSAGE_OF_USER"
    static let STRORE_AUTO_INVITE_USER_ID = "STRORE_AUTO_INVITE_USER_ID"
    static let LIKEING_APP_POPUP_SHOWN_DATE = "LIKEING_APP_POPUP_SHOWN_DATE"
    static let SET_RATING_POPUP_SHOWN_DATE = "SET_RATING_POPUP_SHOWN_DATE"
    static let SKIP_RATING_DATE = "SKIP_RATING_DATE"
    static let MQTT_DATA_FOR_APP = "MQTT_DATA_FOR_APP"
    static let SORT_AND_FILTER_STATUS = "SORT_AND_FILTER_STATUS"
    static let ORGNISATION_EMAIL_ID = "ORGNISATION_EMAIL_ID"
    static let SAFE_KEEPER_RECONFIRM_VIEW_DISPLY_TIME = "SAFE_KEEPER_RECONFIRM_VIEW_DISPLY_TIME"
    static let MATCHED_RIDER_LOCATION = "MATCHED_RIDER_LOCATION"
    static let REFERRAL_USER_LEVEL = "REFERRAL_USER_LEVEL"
    static let SAVE_SIMPL_OFFER_SHOWED_RIDE_IDS = "SAVE_SIMPL_OFFER_SHOWED_RIDE_IDS"
    static let HP_PAY_API_CALL_STATUS = "HP_PAY_API_CALL_STATUS"
    static let NOTIFY_ME_ACTIVETD_RIDE = "NOTIFY_ME_ACTIVETD_RIDE"
    static let STORE_INVITED_GROUP_IDS = "STORE_INVITED_GROUP_IDS"
    static let STORE_INVITED_PHONEBOOK_CONTACTS = "STORE_INVITED_PHONEBOOK_CONTACTS"
    static let STORE_RELAY_RIDE_STATUS = "STORE_RELAY_RIDE_STATUS"
    static let DEEPLINK_URL = "DEEP_LINK_URL"
    static let ENDORSEMENT_INFO_VIEW = "ENDORSEMENT_INFO_VIEW"
    static let USER_REGISTERED_FOR_IOCL = "USER_REGISTERED_FOR_IOCL"
    static let ROUTE_DEVIATION_STATUS = "ROUTE_DEVIATION_STATUS"
    static let PERTICULER_QUICK_JOB_URL = "PERTICULER_QUICK_JOB_URL"
    static let USER_REGISTERED_FOR_BANK = "USER_REGISTERED_FOR_BANK"
    static let SUSPENDED_RECURRING_RIDE_DAILOG_SHOWED_STATUS = "SUSPENDED_RECURRING_RIDE_DAILOG_SHOWED_STATUS"
    static let JOIN_MY_RIDER_ID = "JOIN_MY_RIDER_ID"
    static let JOIN_MY_RIDE_ID = "JOIN_MY_RIDE_ID"
    static let JOIN_MY_RIDE_SOURCE_TYPE = "JOIN_MY_RIDE_SOURCE_TYPE"
    static let RECENT_TAB_BAR_INDEX = "RECENT_TAB_BAR_INDEX"
    static let BEHALF_BOOKING_CONTACT_DETAILS = "BEHALF_BOOKING_CONTACT_DETAILS"

    //MARK: QuickShare
    static let PRODUCT_URL = "PRODUCT_URL"
    static let PRODUCT_URL_TYPE = "PRODUCT_URL_TYPE"

    //Taxi
    static let EMERGENCY_INITIATED_TIME = "EMERGENCY_INITIATED_TIME"
    static let TAXI_FEATURE_SHOWN_INDEX = "TAXI_FEATURE_SHOWN_INDEX"
    static let TAXI_RIDE_UPDATE_SUGGESTION = "TAXI_RIDE_UPDATE_SUGGESTION"
    static let TAXI_OFFER_AVAILABILITY = "TAXI_OFFER_AVAILABILITY"
    static let IS_RREQUIRED_TO_SHOW_NEW_DRIVER_ALLOTED_POPUP = "IS_RREQUIRED_TO_SHOW_NEW_DRIVER_ALLOTED_POPUP"
    static let TAXI_ALLOCATION_STATUS_OF = "TAXI_ALLOCATION_STATUS_OF"

    public static func clearSharedPreferences(){
        AppDelegate.getAppDelegate().log.debug("clearSharedPreferences()")
        let appDomain : String = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: appDomain)
        deleteJWTToken()

    }
    static func restoreIgnoredRidesBackup(_ ignoredRideIdsBackup: [String : [Double]]) {
        for data in ignoredRideIdsBackup{
            userDefaults.set(data.1, forKey: data.0)
        }
    }

    public static func clearSharedPreferenceObjForAKey(key: String){
        userDefaults.removeObject(forKey: key)
    }
    public static func getContactInviteGuidesStatus() -> Bool?
    {
        return userDefaults.value(forKey: CONTACT_INVITE_GUIDE_STATUS) as? Bool

    }

    public static func setContactInviteGuidesStatus(status : Bool){
        userDefaults.set(status, forKey: CONTACT_INVITE_GUIDE_STATUS)
    }

    public static func saveRecentNotification(notification : UserNotification){
        AppDelegate.getAppDelegate().log.debug("saveRecentNotification() \(notification)")
        var existingNotifications = getRecentNotifications()
        if existingNotifications == nil{
            existingNotifications = [UserNotification]()
        }
        existingNotifications?.append(notification)
        let notificationData = Mapper().toJSONString(existingNotifications! , prettyPrint: true)!
        userDefaults.setValue(notificationData, forKey: recent_notification)
    }
    public static func saveRecentNotifications(notifications : [UserNotification]){
        AppDelegate.getAppDelegate().log.debug("saveRecentNotifications() \(notifications)")

        let notificationData = Mapper().toJSONString(notifications , prettyPrint: true)!
        userDefaults.setValue(notificationData, forKey: recent_notification)
    }
    public static func deleteRecentNotification(){
        AppDelegate.getAppDelegate().log.debug("deleteRecentNotification")
        userDefaults.removeObject(forKey: recent_notification)
    }
    public static func getRecentNotifications() -> [UserNotification]?{
        AppDelegate.getAppDelegate().log.debug("getRecentNotification()")
        let notifications = userDefaults.string(forKey: recent_notification)
        if notifications != nil{
            return Mapper<UserNotification>().mapArray(JSONString: notifications!)
        }else{
            return nil
        }
    }
    public static func getLoggedInUserName() -> String{
        AppDelegate.getAppDelegate().log.debug("getLoggedInUserName()")
        var userName = userDefaults.string(forKey: USERNAME)
        if userName == nil{
            userName = ""
            return userName!
        }
        return userName!
    }

    public static func storeLoggedInUserName(userName : String){

        userDefaults.setValue(userName, forKey: USERNAME)
    }


    public static func storeCurrentUserGender(gender : String?)
    {
        if gender == nil{
            let user = UserCoreDataHelper.getUserObject()
            if user != nil
            {
                userDefaults.setValue(user!.gender, forKey: USERGENDER)
            }
        }
        else
        {
            userDefaults.setValue(gender, forKey: USERGENDER)
        }
    }
    public static func getCurrentUserGender() -> String?{
        AppDelegate.getAppDelegate().log.debug("")
        if let gender = userDefaults.string(forKey: USERGENDER){
            return gender
        }
        return nil
    }

    public static func storeUserPreferredRole(preferredRole : String){
        userDefaults.set(preferredRole, forKey: SharedPreferenceHelper.PREFERRED_ROLE)
    }

    public static func getUserPreferredRole()->String?{
        return userDefaults.value(forKey: SharedPreferenceHelper.PREFERRED_ROLE) as? String
    }

    public static func setNotificationCount(notificationCount:Int){
        AppDelegate.getAppDelegate().log.debug("setNotificationCount() \(notificationCount)")
        userDefaults.set(notificationCount, forKey: NOTIFICATION_COUNT)
    }

    public static func getNotificationCount() -> Int?{
        AppDelegate.getAppDelegate().log.debug("getNotificationCount()")
        if let notificationCount = userDefaults.value(forKey: NOTIFICATION_COUNT){
            return Int(notificationCount as! NSNumber)
        }
        return nil
    }
    public static func getOfferDisplayStatus(offerId : String) -> Bool{
        AppDelegate.getAppDelegate().log.debug("\(offerId)")
        if (userDefaults.value(forKey: OFFER_STATUS + offerId) != nil){
            return userDefaults.value(forKey: OFFER_STATUS + offerId) as! Bool
        }
        return false
    }
    public static func setOfferDisplayStatus(flag: Bool, offerId: String){
        AppDelegate.getAppDelegate().log.debug("")
        userDefaults.set(flag, forKey: OFFER_STATUS + offerId)
    }
    public static func setAllowRateUsDialogStatus(flag: Bool){
        AppDelegate.getAppDelegate().log.debug("\(flag)")
        userDefaults.set(flag, forKey: ALLOW_RATE_US_DIALOG_TO_SPECIFIC_USER)
    }
    public static func getAllowRateUsDialogStatus() -> Bool{
        if (userDefaults.value(forKey: ALLOW_RATE_US_DIALOG_TO_SPECIFIC_USER) != nil){
            return userDefaults.value(forKey: ALLOW_RATE_US_DIALOG_TO_SPECIFIC_USER) as! Bool
        }
        return false
    }
    static let keyChainTokenService  = "accessToken"
    static let keyChainAccount = "QuickRide"
    private static var jwtToken: String?
    public static func getJWTAuthenticationToken() -> String?{
        if let _ = jwtToken {
            AppDelegate.getAppDelegate().log.debug("JWT Token found in cache")
        }
        let query = [
            kSecAttrService as String : SharedPreferenceHelper.keyChainTokenService,
            kSecAttrAccount as String : SharedPreferenceHelper.keyChainAccount,
            kSecClass as String : kSecClassGenericPassword,
            kSecReturnData as String: true,
            kSecReturnAttributes as String: true
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        AppDelegate.getAppDelegate().log.debug("getJWTAuthenticationToken \(status)")
        AppDelegate.getAppDelegate().log.debug(result)
//        guard let data = result as? Data else {

//            if let token = userDefaults.value(forKey: AUTHORIZATION) as? String{
//                storeJWTAuthenticationToken(value: token)
//                userDefaults.removeObject(forKey: AUTHORIZATION)
//                return token
//            }else{
//                return nil
//            }
//        }
//         return String(data: data, encoding: .utf8)

        return userDefaults.value(forKey: AUTHORIZATION) as? String
    }

    public static func storeJWTAuthenticationToken(value : String){
        userDefaults.setValue(value, forKey: AUTHORIZATION)

        let data = Data(value.utf8)
        let query = [
            kSecValueData as String : data,
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String : SharedPreferenceHelper.keyChainTokenService,
            kSecAttrAccount as String : SharedPreferenceHelper.keyChainAccount,
        ] as CFDictionary

        let status = SecItemAdd(query, nil)
        if status == errSecDuplicateItem {
            // Item already exist, so update it.
            let query = [
                kSecAttrService  as String : SharedPreferenceHelper.keyChainTokenService,
                kSecAttrAccount as String : SharedPreferenceHelper.keyChainAccount,
                kSecClass as String : kSecClassGenericPassword,
            ] as CFDictionary

            let attributesToUpdate = [kSecValueData  as String: data] as CFDictionary
            let updateStatus = SecItemUpdate(query, attributesToUpdate)
            if  updateStatus == errSecItemNotFound {
                AppDelegate.getAppDelegate().log.error("Matching Item Not Found")
            }else if updateStatus != errSecSuccess {
                AppDelegate.getAppDelegate().log.error("Update JWTToken failed \(updateStatus)")
            }else{
                SharedPreferenceHelper.jwtToken = value
            }

        }
    }
    static func deleteJWTToken(){
        let query = [
            kSecAttrService as String : SharedPreferenceHelper.keyChainTokenService,
            kSecAttrAccount as String : SharedPreferenceHelper.keyChainAccount,
                kSecClass as String : kSecClassGenericPassword] as CFDictionary
        let status = SecItemDelete(query)
        if status != errSecSuccess || status == errSecItemNotFound {
            AppDelegate.getAppDelegate().log.error("Delete JWTToken failed")
        }
    }
    static func storeOffers(offers :[Offer]){
        AppDelegate.getAppDelegate().log.debug("storeOffers()")
        let offersJson = Mapper().toJSONString(offers , prettyPrint: true)!
        userDefaults.setValue(offersJson, forKey: OFFERS)
    }
    static func getOffers()->[Offer]{
        AppDelegate.getAppDelegate().log.debug("getOffers()")
        let offersJSON = userDefaults.string(forKey: OFFERS)
        if offersJSON != nil
        {
            let offers = Mapper<Offer>().mapArray(JSONString: offersJSON as! String)
            if offers != nil{
                return offers!
            }else{
                return [Offer]()
            }
        }
        else
        {
            return [Offer]()

        }
    }
    static func storeFeedbackGivenUserIDs(ids : [Double]){
        AppDelegate.getAppDelegate().log.debug("")
        userDefaults.set(ids, forKey: FEEDBACK_GIVEN_USER_IDS)
    }
    static func getFeedbackGivenUserIds()->[Double]{
        AppDelegate.getAppDelegate().log.debug("")
        let userIDs = userDefaults.array(forKey: FEEDBACK_GIVEN_USER_IDS)
        if userIDs == nil
        {
            return [Double]()
        }
        return userIDs as! [Double]
    }
    static func storeUserIDInFeedbackGivenList(id : Double)
    {
        var userIDs = userDefaults.array(forKey: FEEDBACK_GIVEN_USER_IDS)
        if userIDs == nil
        {
            userIDs = [Double]()
        }
        userIDs!.append(id)
        userDefaults.set(userIDs, forKey: FEEDBACK_GIVEN_USER_IDS)
    }

    static func storeUserPreferences(userPreferences :UserPreferences?){
        AppDelegate.getAppDelegate().log.debug("storeUserPreferences()")
        if userPreferences == nil{
            userDefaults.setValue(nil, forKey: USERPREFERENCES)
        }else{
            let userPreferencesJSON = Mapper().toJSONString(userPreferences! , prettyPrint: true)!
            userDefaults.setValue(userPreferencesJSON, forKey: USERPREFERENCES)
        }

    }
    static func getUserPreferences()->UserPreferences?{
        AppDelegate.getAppDelegate().log.debug("getUserPreferences()")
        let preferencesJSON = userDefaults.string(forKey: USERPREFERENCES)
        if preferencesJSON != nil
        {
            let userPreferences = Mapper<UserPreferences>().map(JSONString: preferencesJSON!)
            return userPreferences
        }
        else
        {
            return nil
        }
    }
    public static func getRecentUserRideType() -> String?{
        AppDelegate.getAppDelegate().log.debug("getRecentUserRideType()")
        return userDefaults.string(forKey: RIDE_TYPE)

    }

    public static func storeRecentUserRideType(rideType : String){
        AppDelegate.getAppDelegate().log.debug("storeRecentUserRideType() \(rideType)")
        userDefaults.set(rideType, forKey: RIDE_TYPE)
    }

    public static func getLoggedInUserId() -> String? {
        AppDelegate.getAppDelegate().log.debug("getLoggedInUserId()")
        return userDefaults.string(forKey: USERID)

    }

    public static func storeLoggedInUserId(userId : String){
        AppDelegate.getAppDelegate().log.debug("storeLoggedInUserId(): \(userId)")
        userDefaults.set(userId, forKey: USERID)
    }

    public static func getLoggedInUserPassword() -> String?{
        AppDelegate.getAppDelegate().log.debug("getLoggedInUserPassword()")
        return userDefaults.string(forKey: USER_PWD)
    }
    public static func storeLoggedInUserPwd(password : String){
        AppDelegate.getAppDelegate().log.debug("storeLoggedInUserPwd()")
        userDefaults.set(password, forKey: USER_PWD)
    }

    public static func getLoggedInOTP() -> String?{
        AppDelegate.getAppDelegate().log.debug("getLoggedInUserPassword()")
        return userDefaults.string(forKey: OTP)
    }
    public static func storeLoggedInOtp(otp : String){
        AppDelegate.getAppDelegate().log.debug("storeLoggedInUserPwd()")
        userDefaults.set(otp, forKey: OTP)
    }

    public static func storeLoggedInUserCountryCode(countryCode : String?){
        AppDelegate.getAppDelegate().log.debug("storeLoggedInUserCountryCode() \(String(describing: countryCode))")
        userDefaults.setValue(countryCode, forKey: COUNTRY_CODE)
    }
    public static func getLoggedInUserCountryCode() -> String?{
        AppDelegate.getAppDelegate().log.debug("getLoggedInUserCountryCode()")

        return userDefaults.string(forKey: COUNTRY_CODE)
    }
    public static func getLoggedInUserContactNo() -> String?{
        AppDelegate.getAppDelegate().log.debug("getLoggedInUserContactNo()")
        return userDefaults.string(forKey: CONTACT_NO)
    }

    public static func storeLoggedInUserContactNo(contactNo : String){

        userDefaults.setValue(contactNo, forKey: CONTACT_NO)
    }
    public static func incrementUnreadMessageCountOfARide(rideId : String){
        AppDelegate.getAppDelegate().log.debug("incrementUnreadMessageCountOfARide() \(rideId)")
        var count = getUnreadMessageCountOfARide(rideId: rideId)
        count = count + 1
        userDefaults.set(count, forKey: UNREAD_CHAT + rideId)
    }

    public static func getUnreadMessageCountOfARide(rideId : String) -> Int{
        AppDelegate.getAppDelegate().log.debug("getUnreadFlagOfARide() \(rideId)")
        let count = userDefaults.value(forKey: UNREAD_CHAT + rideId)
        if count == nil{
            return 0
        }else{
            let value = count as? Bool
            if value != nil && value! {
                return 1
            }
            return count as? Int ?? 0
        }
    }

    public static func resetUnreadMessagesOfRide(rideId : String){
        AppDelegate.getAppDelegate().log.debug("removeUnreadMessageFlagOfARide() \(rideId)")
        userDefaults.set(0, forKey: UNREAD_CHAT + rideId)
    }
    public static func getRouteSelectionGuideStatus() -> Bool{
        AppDelegate.getAppDelegate().log.debug("storeRouteSelectionGuideStatus")
        let flag = userDefaults.value(forKey: ROUTE_SELECTION_GUIDE_STATUS) as? Bool
        if flag == nil{
            return false
        }else{
            return flag!
        }
    }

    public static func storeRouteSelectionGuideStatus(flag: Bool){
        AppDelegate.getAppDelegate().log.debug("updateUnreadFlagOfARide")
        userDefaults.set(flag, forKey: ROUTE_SELECTION_GUIDE_STATUS)
    }
    static func getTipStatus(key : String) -> Int?
    {
        if (userDefaults.value(forKey: key) != nil){
            return userDefaults.value(forKey: key) as? Int
        }
        return -1
    }

    static func storeTipStatus(key : String,value : Int)
    {
        userDefaults.setValue(value, forKey: key)
    }

    static func getNewUserInfoUpdateStatus(key : String) -> Bool?
    {
        if (userDefaults.value(forKey: key) != nil){
            return userDefaults.value(forKey: key) as? Bool
        }
        return nil
    }

    static func storeNewUserInfoUpdateStatus(key : String,value : Bool)
    {
        userDefaults.setValue(value, forKey: key)
    }

    public static func getUnVerifiedUserAlertDisplayedTime()->NSDate?{
        AppDelegate.getAppDelegate().log.debug("")
        return userDefaults.value(forKey: UNVERIFIED_USER_DISPLAY_TIME) as? NSDate
    }
    public static func setUnVerifiedUserAlertDisplayTime(time : NSDate){
        AppDelegate.getAppDelegate().log.debug("\(time)")
        userDefaults.setValue(time, forKey: UNVERIFIED_USER_DISPLAY_TIME)
    }
    public static func getSplashVideoDisplayedTime()->NSDate?{
        AppDelegate.getAppDelegate().log.debug("")
        return userDefaults.value(forKey: SPLASH_VIDEO_DISPLAY_TIME) as? NSDate
    }
    public static func setSplashVideoDisplayedTime(time : NSDate){
        AppDelegate.getAppDelegate().log.debug("\(time)")
        userDefaults.setValue(time, forKey: SPLASH_VIDEO_DISPLAY_TIME)
    }

    public static func setReferAndEarnViewDisplayedTime(time : NSDate){
        AppDelegate.getAppDelegate().log.debug("\(time)")
        userDefaults.set(time, forKey: REFER_EARN_OFFER_DISPLAY_TIME)
    }

    public static func getReferAndEarnViewDisplayedTime() -> NSDate?{
        AppDelegate.getAppDelegate().log.debug("")
        return userDefaults.value(forKey: REFER_EARN_OFFER_DISPLAY_TIME) as? NSDate
    }

    static func storeTotalBonusPoints(bonusPoints : Int){
        AppDelegate.getAppDelegate().log.debug("storeTotalBonusPoints() \(bonusPoints)")
        userDefaults.set(bonusPoints, forKey: bonusPoints_Key)
    }
    static func getTotalBonusPoints() -> Int?{
        AppDelegate.getAppDelegate().log.debug("getTotalBonusPoints()")
        return userDefaults.value(forKey: bonusPoints_Key) as? Int
    }
    public static func getJoinWithUnverifiedUsersStatus() -> Bool?
    {
        if (userDefaults.value(forKey: SHARE_RIDES_WITH_UNVERIFIED_USERS_STATUS) != nil){
            return userDefaults.value(forKey: SHARE_RIDES_WITH_UNVERIFIED_USERS_STATUS) as? Bool
        }
        return false
    }

    public static func setJoinWithUnverifiedUsersStatus(status : Bool)
    {
        userDefaults.set(status, forKey: SHARE_RIDES_WITH_UNVERIFIED_USERS_STATUS)
    }
    public static func getSequenceNoForRide(rideId : Double) -> Int
    {
        let key = RIDE_LOCATION_UDPATE_SEQUENCE+StringUtils.getStringFromDouble(decimalNumber : rideId)
        var rideSequenceInfo = userDefaults.value(forKey: key) as? Int
        if rideSequenceInfo == nil{
            rideSequenceInfo = 0
        }
        rideSequenceInfo! += 1
        userDefaults.set(rideSequenceInfo!, forKey: key)
        return rideSequenceInfo!
    }
    static func restoreRideLocationSequenceNos(rideLocationSequenceNos : [String : Int]){
        for key in rideLocationSequenceNos.keys {
            userDefaults.set(rideLocationSequenceNos[key]!, forKey: key)
        }
    }
    static func getRideLocationSequenceNoBackup() -> [String:Int]{
        var rideLocationSequenceNos = [String:Int]()
        let allKeys = userDefaults.dictionaryRepresentation().keys
        for key in allKeys{

            if key.hasPrefix(RIDE_LOCATION_UDPATE_SEQUENCE){
                let value = userDefaults.value(forKey: key) as? Int
                if value != nil{
                    rideLocationSequenceNos[key] = value!
                }
            }

        }
        return rideLocationSequenceNos
    }
    static func removeRideLocationSequenceNo(rideId : Double){
        let key = RIDE_LOCATION_UDPATE_SEQUENCE+StringUtils.getStringFromDouble(decimalNumber : rideId)
        userDefaults.removeObject(forKey: key)
    }


    static func getMatchedUserCountForRoute (rideType : String,fromlat : Double, fromlong : Double, tolat :Double ,tolong : Double) -> Int{
        let key = rideType+MyRoutesCache.getCacheKey(fromlatitude: fromlat,fromlongitude: fromlong,tolatitude: tolat,tolongitude: tolong,places :3)
        var count = userDefaults.value(forKey: key) as? Int
        if count == nil{
            count = 0
        }
        return count!
    }
    public static func storeMatchedUserCountForRoute (rideType : String,fromlat : Double, fromlong : Double, tolat :Double ,tolong : Double, noOfMatches : Int)
    {
        let key = rideType+MyRoutesCache.getCacheKey(fromlatitude: fromlat,fromlongitude: fromlong,tolatitude: tolat,tolongitude: tolong,places :3)
        userDefaults.set(noOfMatches, forKey: key)
    }
    static func restoreMatchedUserCount(matchedUsersCount : [String : Int]){
        for key in matchedUsersCount.keys {
            userDefaults.set(matchedUsersCount[key]!, forKey: key)
        }
    }
    static func getMatchedUserCountBackup() -> [String:Int]{
        var matchedUsersCount = [String:Int]()
        let allKeys = userDefaults.dictionaryRepresentation().keys
        for key in allKeys{

            if key.hasPrefix(Ride.RIDER_RIDE) || key.hasPrefix(Ride.PASSENGER_RIDE){
                let value = userDefaults.value(forKey: key) as? Int
                if value != nil{
                    matchedUsersCount[key] = value!
                }
            }

        }
        return matchedUsersCount
    }
    static func restoreUnreadMessagesCount(messagesCount : [String : Int]){
        for key in messagesCount.keys {
            userDefaults.set(messagesCount[key]!, forKey: key)
        }
    }
    static func getUnreadMessagesCountBackup() -> [String:Int]{
        var messagesCount = [String:Int]()
        let allKeys = userDefaults.dictionaryRepresentation().keys
        for key in allKeys{

            if key.hasPrefix(GROUP_UNREAD_MESSAGE_PREFIX){
                let value = userDefaults.value(forKey: key) as? Int
                if value != nil{
                    messagesCount[key] = value!
                }
            }

        }
        return messagesCount
    }
    static func getDisplayChangeLocationGuideLineView() -> Bool
    {
        if (userDefaults.value(forKey: DISPLAY_CHANGE_LOACATION_VIEW) != nil){
            return userDefaults.value(forKey: DISPLAY_CHANGE_LOACATION_VIEW) as! Bool
        }
        return true
    }

    static func setDisplayChangeLocationGuideLineView(status : Bool)
    {
        userDefaults.set(status, forKey: DISPLAY_CHANGE_LOACATION_VIEW)
    }

    static func getDisplaySwitchRideInfoGuideLineView() -> Bool
    {
        var value = userDefaults.value(forKey: DISPLAY_SWITCH_RIDE_INFO)  as? Bool
        if (value == nil){
            value = false
        }
        return value!
    }

    static func setDisplaySwitchRideInfoGuideLineView(status : Bool){
        userDefaults.set(status, forKey: DISPLAY_SWITCH_RIDE_INFO)
    }

    static func setSubscriptionMailSent(status : Bool){
        userDefaults.set(status, forKey: SUBSCRIPTION_MAIL)
    }
    static func getSubscriptionMailSentStatus() -> Bool{
        var value = userDefaults.value(forKey: SUBSCRIPTION_MAIL) as? Bool
        if value == nil{
            value = false
        }
        return value!
    }
    static func getAppVersion() -> String?{

        return userDefaults.value(forKey: APPVERSION) as? String
    }
    static func setAppVersion(version : String){
        userDefaults.set(version, forKey: APPVERSION)
    }
    static func getDontShowReferMessage() -> Bool?
    {
        if (userDefaults.value(forKey: DONT_SHOW_REDEMPTION_AGAIN) != nil){
            return userDefaults.value(forKey: DONT_SHOW_REDEMPTION_AGAIN) as? Bool
        }
        return false
    }

    static func setDontShowReferMessage(status : Bool)
    {
        userDefaults.set(status, forKey: DONT_SHOW_REDEMPTION_AGAIN)
    }

    static func setDontShowReferMessageForRecharge(status : Bool)
    {
        userDefaults.set(status, forKey: DONT_SHOW_RECHARGE_AGAIN)
    }
    static func getDontShowReferMessageForRecharge() -> Bool
    {
        if userDefaults.value(forKey: DONT_SHOW_RECHARGE_AGAIN) == nil{
            return false
        }
        return userDefaults.value(forKey: DONT_SHOW_RECHARGE_AGAIN) as! Bool
    }
    static let GROUP_UNREAD_MESSAGE_PREFIX = "GROUP_UNREAD_MESSAGE_COUNT"

    static func incrementUnreadMessageForUserGroup(groupId : Double){
        var count = getUnreadMessageCountOfGroup(groupId: groupId)
        count = count + 1
        userDefaults.set(count, forKey: SharedPreferenceHelper.GROUP_UNREAD_MESSAGE_PREFIX+StringUtils.getStringFromDouble(decimalNumber: groupId))
    }

    static func getUnreadMessageCountOfGroup(groupId : Double) -> Int{
        let count = userDefaults.value(forKey: SharedPreferenceHelper.GROUP_UNREAD_MESSAGE_PREFIX+StringUtils.getStringFromDouble(decimalNumber: groupId))
        if count == nil {
            return 0
        }else{
            return count as! Int
        }
    }

    static func resetUnreadMessageForUserGroup(groupId : Double){
        userDefaults.set(0, forKey: SharedPreferenceHelper.GROUP_UNREAD_MESSAGE_PREFIX+StringUtils.getStringFromDouble(decimalNumber: groupId))
    }
    public static func getIgnoredRideIdsBackup() -> [String : [Double]]{
        let keys = userDefaults.dictionaryRepresentation().keys
        var backup = [String : [Double]]()
        for key in keys{
            if key.hasPrefix(IGNORED_USERS){
                let value = userDefaults.value(forKey: key)
                if value != nil{
                    backup[key] = value as! [Double]
                }
            }
        }
        return backup
    }
    public static func getIgnoredRideIds(rideId: String) -> [Double]{
        let value = userDefaults.value(forKey: SharedPreferenceHelper.IGNORED_USERS+","+rideId) as? [Double]
        if value == nil
        {
            return [Double]()
        }
        return value!
    }
    public static func storeIgnoredRideId(ignoredRideId: Double, rideId: String)
    {
        var ignoredRideIds = userDefaults.value(forKey: SharedPreferenceHelper.IGNORED_USERS+","+rideId) as? [Double]
        if ignoredRideIds == nil{
            ignoredRideIds = [ignoredRideId]
        }else{
            for rideId in ignoredRideIds!{
                if rideId != ignoredRideId{
                    ignoredRideIds!.append(ignoredRideId)
                }
            }
        }
        userDefaults.set(ignoredRideIds, forKey: SharedPreferenceHelper.IGNORED_USERS+","+rideId)
    }
    static func clearIgnoredRideIds(rideId: Double){
        userDefaults.removeObject(forKey: SharedPreferenceHelper.IGNORED_USERS+","+StringUtils.getStringFromDouble(decimalNumber: rideId))
    }
    static func saveUserRefererInfo(userRefInfo : UserRefererInfo?)
    {
        if userRefInfo != nil{
            let jsonText = Mapper().toJSONString(userRefInfo! , prettyPrint: true)!
            userDefaults.set(jsonText, forKey: SharedPreferenceHelper.USER_REFERER_INFO)
        }else{
            userDefaults.set(nil, forKey: SharedPreferenceHelper.USER_REFERER_INFO)
        }

    }
    static func getUserRefererInfo() -> UserRefererInfo?
    {
        let userRefInfo = userDefaults.value(forKey: SharedPreferenceHelper.USER_REFERER_INFO) as? String
        if userRefInfo != nil{
            return Mapper<UserRefererInfo>().map(JSONString: userRefInfo!)
        }
        return nil
    }

    static func storeAppStartUpData(appStartUpData : AppStartupData?){
        if appStartUpData != nil{
            let jsonText = Mapper().toJSONString(appStartUpData! , prettyPrint: true)!
            userDefaults.set(jsonText, forKey: SharedPreferenceHelper.APP_STARTUP_DATA)
        }else{
            userDefaults.set(nil, forKey: SharedPreferenceHelper.APP_STARTUP_DATA)
        }
    }

    static func getAppStartUpData() -> AppStartupData?{
        let appStartUpData = userDefaults.value(forKey: SharedPreferenceHelper.APP_STARTUP_DATA) as? String
        if appStartUpData != nil{
            return Mapper<AppStartupData>().map(JSONString: appStartUpData!)
        }
        return nil
    }

    static func storeHomeLocation(homeLocation: UserFavouriteLocation?){
        if homeLocation != nil{
            let jsonText = Mapper().toJSONString(homeLocation!, prettyPrint: true)!
            userDefaults.set(jsonText, forKey: SharedPreferenceHelper.HOME_LOCATION)
        }else{
            userDefaults.set(nil, forKey: SharedPreferenceHelper.HOME_LOCATION)
        }
    }

    static func storeOfficeLocation(officeLocation: UserFavouriteLocation?){
        if officeLocation != nil{
            let jsonText = Mapper().toJSONString(officeLocation!, prettyPrint: true)!
            userDefaults.set(jsonText, forKey: SharedPreferenceHelper.OFFICE_LOCATION)
        }else{
            userDefaults.set(nil, forKey: SharedPreferenceHelper.OFFICE_LOCATION)
        }
    }

    static func getHomeLocation() -> UserFavouriteLocation?{
        let homeLocation = userDefaults.value(forKey: SharedPreferenceHelper.HOME_LOCATION) as? String
        if homeLocation != nil{
            return Mapper<UserFavouriteLocation>().map(JSONString: homeLocation!)
        }
        return nil
    }

    static func getOfficeLocation() -> UserFavouriteLocation?{
        let officeLocation = userDefaults.value(forKey: SharedPreferenceHelper.OFFICE_LOCATION) as? String
        if officeLocation != nil{
            return Mapper<UserFavouriteLocation>().map(JSONString: officeLocation!)
        }
        return nil
    }

    static func storeUserObject(userObj: User) {
        let jsonText = Mapper().toJSONString(userObj, prettyPrint: true)!
        userDefaults.set(jsonText, forKey: SharedPreferenceHelper.USER_OBJECT)
    }

    static func getUserObject() -> User?{
        let user = userDefaults.value(forKey: SharedPreferenceHelper.USER_OBJECT) as? String
        if user != nil{
            return Mapper<User>().map(JSONString: user!)
        }
        return nil
    }

    static func storeUserProfileObject(userProfileObj: UserProfile) {
        let jsonText = Mapper().toJSONString(userProfileObj, prettyPrint: true)!
        userDefaults.set(jsonText, forKey: SharedPreferenceHelper.USER_PROFILE_OBJECT)
    }

    static func getUserProfileObject() -> UserProfile?{
        let userProfile = userDefaults.value(forKey: SharedPreferenceHelper.USER_PROFILE_OBJECT) as? String
        if userProfile != nil{
            return Mapper<UserProfile>().map(JSONString: userProfile!)
        }
        return nil
    }

    static func storeVehicleObject(vehicle: Vehicle?) {
        if vehicle == nil{
            userDefaults.set(nil, forKey: SharedPreferenceHelper.USER_VEHICLE_OBJECT)
            return
        }
        let jsonText = Mapper().toJSONString(vehicle!, prettyPrint: true)!
        userDefaults.set(jsonText, forKey: SharedPreferenceHelper.USER_VEHICLE_OBJECT)
    }

    static func getVehicleObject() -> Vehicle?{
        let vehicle = userDefaults.value(forKey: SharedPreferenceHelper.USER_VEHICLE_OBJECT) as? String
        if vehicle != nil{
            return Mapper<Vehicle>().map(JSONString: vehicle!)
        }
        return nil
    }

    static func storeHomeToOfficeRoute(homeToOfficeRoute: RideRoute?){
        if homeToOfficeRoute != nil{
            let jsonText = Mapper().toJSONString(homeToOfficeRoute!, prettyPrint: true)!
            userDefaults.set(jsonText, forKey: SharedPreferenceHelper.HOME_TO_OFFICE_ROUTE)
        }
    }

    static func getHomeToOfficeRoute() -> RideRoute?{
        let HomeToOfficeRoute = userDefaults.value(forKey: SharedPreferenceHelper.HOME_TO_OFFICE_ROUTE) as? String
        if HomeToOfficeRoute != nil{
            return Mapper<RideRoute>().map(JSONString: HomeToOfficeRoute!)
        }
        return nil
    }

    static func storeOfficeToHomeRoute(officeToHomeRoute: RideRoute?){
        if officeToHomeRoute != nil{
            let jsonText = Mapper().toJSONString(officeToHomeRoute!, prettyPrint: true)!
            userDefaults.set(jsonText, forKey: SharedPreferenceHelper.OFFICE_TO_HOME_ROUTE)
        }
    }

    static func getOfficeToHomeRoute() -> RideRoute?{
        let officeToHomeRoute = userDefaults.value(forKey: SharedPreferenceHelper.OFFICE_TO_HOME_ROUTE) as? String
        if officeToHomeRoute != nil{
            return Mapper<RideRoute>().map(JSONString: officeToHomeRoute!)
        }
        return nil
    }

    public static func getCurrentUserReferralCode() -> String?{
        AppDelegate.getAppDelegate().log.debug("getCurrentUserReferralCode()")

        return userDefaults.string(forKey: REFERRAL_CODE)
    }

    public static func storeCurrentUserReferralCode(referralCode : String?){

        userDefaults.setValue(referralCode, forKey: REFERRAL_CODE)
    }

    public static func storeViewPrefixForDeepLink(parameter : String?){
        userDefaults.set(parameter, forKey: VIEW_IDENTIFIER)
    }

    public static func getViewPrefixForDeepLink() -> String?{
        return userDefaults.value(forKey: VIEW_IDENTIFIER) as? String
    }
    public static func storeDeepLink(parameter : String?){
        userDefaults.set(parameter, forKey: DEEPLINK_URL)
    }

    public static func getDeepLink() -> String?{
        return userDefaults.value(forKey: DEEPLINK_URL) as? String
    }

    public static func setDisplayStatusForRewardsInfoView(status : Bool){
        userDefaults.set(status, forKey: REWARDS_INFO_VIEW)
    }
    public static func getDisplayStatusForRewardsnfoView() -> Bool{
        if let displayStatus = userDefaults.value(forKey: REWARDS_INFO_VIEW) as? Bool{
            return displayStatus
        }
        return false
    }

    public static func setSavingStatusForKey(key : String,status : Bool){
        userDefaults.set(status, forKey: key)
    }

    public static func getSavingDetailsForKey(key : String) -> Bool{
        if let savingStatus = userDefaults.value(forKey: key) as? Bool{
            return savingStatus
        }
        return false
    }

    static func getImage() -> UIImage? {
        if let imageData = UserDefaults.standard.value(forKey: USER_IMAGE) as? Data {
            return UIImage(data: imageData)
        }
        return nil
    }

    static func setImage(image: UIImage?) {
        UserDefaults.standard.set(image!.jpegData(compressionQuality: 1), forKey: USER_IMAGE)
    }

    static func storeRideAssuredIncentive(rideAssuredIncentive : RideAssuredIncentive?){
        if rideAssuredIncentive != nil{
            let jsonText = Mapper().toJSONString(rideAssuredIncentive!, prettyPrint: true)!
            userDefaults.set(jsonText, forKey: SharedPreferenceHelper.RIDE_ASSURED_INCENTIVE)
        }else{
            userDefaults.set(nil, forKey: SharedPreferenceHelper.RIDE_ASSURED_INCENTIVE)
        }
    }

    static func getRideAssuredIncentive() -> RideAssuredIncentive?{
        let rideAssuredIncentive = userDefaults.value(forKey: SharedPreferenceHelper.RIDE_ASSURED_INCENTIVE) as? String
        if rideAssuredIncentive != nil{
            return Mapper<RideAssuredIncentive>().map(JSONString: rideAssuredIncentive!)
        }
        return nil
    }

    static func setRideAssuredIncentiveDisplayCount(count : Int){
        userDefaults.setValue(count, forKey: RIDE_ASSURED_INCENTIVE_DISPLAY_COUNT)
    }

    static func getRideAssuredIncentiveDisplayCount() -> Int{
        if let count = userDefaults.value(forKey: RIDE_ASSURED_INCENTIVE_DISPLAY_COUNT) as? Int{
            return count
        }
        return 0
    }

    static func setAutoConfirmCount(count: Int) {
        userDefaults.setValue(count, forKey: AUTOCONFIRM_POPUP_DISPLAY_COUNT_IN_MATCHING_OPTIONS)
    }

    static func getAutoConfirmCount() -> Int {
        if let count = userDefaults.value(forKey: AUTOCONFIRM_POPUP_DISPLAY_COUNT_IN_MATCHING_OPTIONS) as? Int{
            return count
        }
        return 0
    }

    public static func getRideAssuredIncentiveDialogueDisplaytime()->NSDate?{
        AppDelegate.getAppDelegate().log.debug("")
        return userDefaults.value(forKey: RIDE_ASSURED_INCENTIVE_DISPLAY_TIME) as? NSDate
    }
    public static func setRideAssuredIncentiveDialogueDisplaytime(time : NSDate){
        userDefaults.setValue(time, forKey: RIDE_ASSURED_INCENTIVE_DISPLAY_TIME)
    }

    static func storeRideDetailInfo(rideDetailInfo : RideDetailInfo?){
        if rideDetailInfo != nil{
            let jsonText = Mapper().toJSONString(rideDetailInfo! , prettyPrint: true)!
            userDefaults.set(jsonText, forKey: SharedPreferenceHelper.RIDE_DETAIL_INFO + "," + StringUtils.getStringFromDouble(decimalNumber: rideDetailInfo!.riderRideId))
        }
    }

    static func getRideDetailInfo(riderRideId: String) -> RideDetailInfo?{
        let rideDetailInfo = userDefaults.value(forKey: SharedPreferenceHelper.RIDE_DETAIL_INFO + "," + riderRideId) as? String
        if rideDetailInfo != nil {
            return Mapper<RideDetailInfo>().map(JSONString: rideDetailInfo!)
        }
        return nil
    }

    static func getRideDetailInfoBackUp() -> [String : RideDetailInfo]{
        let keys = userDefaults.dictionaryRepresentation().keys
        var backup = [String : RideDetailInfo]()
        for key in keys{
            if key.hasPrefix(RIDE_DETAIL_INFO){
                let rideDetailInfo = userDefaults.value(forKey: key) as? String
                if rideDetailInfo != nil {
                    backup[key] = Mapper<RideDetailInfo>().map(JSONString: rideDetailInfo!)
                }
            }
        }
        return backup
    }

    static func restoreRideDetailInfo(rideDetailInfoBackup: [String : RideDetailInfo]){
        for data in rideDetailInfoBackup{
            if data.1.currentUserRide?.status == Ride.RIDE_STATUS_COMPLETED || data.1.currentUserRide?.status == Ride.RIDE_STATUS_CANCELLED{
                return
            }
            let jsonText = Mapper().toJSONString(data.1 , prettyPrint: true)!
            userDefaults.set(jsonText, forKey: data.0)
        }
    }

    static func clearRideDetailInfo(riderRideId: String){
        userDefaults.removeObject(forKey: SharedPreferenceHelper.RIDE_DETAIL_INFO + "," + riderRideId)
    }

    static func setLazyPayEligibilityAndTime(status : Bool,time : NSDate)
    {
        userDefaults.set(status, forKey: LAZYPAY_ELIGIBILITY)
        userDefaults.setValue(time, forKey: CHECK_LAZYPAY_ELIGIBILITY_TIME)
    }
    static func storeShortSignReqStatus(value : Bool){
        userDefaults.set(value, forKey: SHORT_SIGN_UP_FLOW_STATUS)
    }

    static func getShortSignReqStatus() -> Bool{
        let value = userDefaults.value(forKey: SHORT_SIGN_UP_FLOW_STATUS) as? Bool
        if value != nil{
            return value!
        }
        return false
    }

    static func storeGroupInfoViewDisplayStatus(value : Bool){
        userDefaults.set(value, forKey: GROUPS_INFO_VIEW_DISPLAY_STATUS)
    }
    static func getGroupInfoViewDisplayStatus() -> Bool{
        if let value = userDefaults.value(forKey: GROUPS_INFO_VIEW_DISPLAY_STATUS) as? Bool {
            return value
        }
        return false
    }
    static func storeFavInfoViewDisplayStatus(value : Bool){
        userDefaults.set(value, forKey: FAV_INFO_VIEW_DISPLAY_STATUS)
    }
    static func getFavInfoViewDisplayStatus() -> Bool{
        if let value = userDefaults.value(forKey: FAV_INFO_VIEW_DISPLAY_STATUS) as? Bool{
            return value
        }
        return false
    }
    static func storeRideEtiquette(rideEtiquette : RideEtiquette?){
        if rideEtiquette != nil{
            let jsonText = Mapper().toJSONString(rideEtiquette!, prettyPrint: true)!
            userDefaults.set(jsonText, forKey: SharedPreferenceHelper.RIDE_ETIQUETTE)
        }else{
            userDefaults.set(nil, forKey: SharedPreferenceHelper.RIDE_ETIQUETTE)
        }
    }
    static func setPastTransactionToolTip(status : Bool)
    {
        userDefaults.set(status, forKey: PAST_TRANSACTION_TOOL_TIP)
    }
    static func getPastTransactionToolTip() -> Bool
    {
        let result = userDefaults.value(forKey: PAST_TRANSACTION_TOOL_TIP)
        if result != nil{
            return result as! Bool
        }
        return false
    }

    static func getRideEtiquette() -> RideEtiquette?{
        let rideEtiquette = userDefaults.value(forKey: SharedPreferenceHelper.RIDE_ETIQUETTE) as? String
        if rideEtiquette != nil{
            return Mapper<RideEtiquette>().map(JSONString: rideEtiquette!)
        }
        return nil
    }
    static func storeShareAndEarnPoints(pointsAfterVerificationOfReferredUser : Int?,pointsFirstRideOfRefferedUser: Int?){
        userDefaults.set(pointsAfterVerificationOfReferredUser, forKey: SHARE_AND_EARN_POINTS_AFTER_VERIFICATION)
        userDefaults.set(pointsFirstRideOfRefferedUser, forKey: SHARE_AND_EARN_POINTS_AFTER_FIRSTRIDE)
    }
    static func getShareAndEarnPointsAfterVerification() -> Int?{
        return userDefaults.value(forKey: SHARE_AND_EARN_POINTS_AFTER_VERIFICATION) as? Int
    }
    static func getShareAndEarnPointsAfterFirstRide() -> Int?{
        return userDefaults.value(forKey: SHARE_AND_EARN_POINTS_AFTER_FIRSTRIDE) as? Int
    }
    static func setDisplayStatusForRideTakerPledge(status : Bool){
        userDefaults.set(status, forKey: RIDE_TAKER_PLEDGE)
    }
    static func setDisplayStatusForRideGiverPledge(status : Bool){
        userDefaults.set(status, forKey: RIDE_GIVER_PLEDGE)
    }
    static func getDisplayStatusForRideTakerPledge() -> Bool?{
        if let value = userDefaults.value(forKey: RIDE_TAKER_PLEDGE) as? Bool{
            return value
        }
        return nil
    }
    static func getDisplayStatusForRideGiverPledge() -> Bool?{
        if let value = userDefaults.value(forKey: RIDE_GIVER_PLEDGE) as? Bool{
            return value
        }
        return nil
    }

    static func incrementCountForVerificationViewDisplay(){
        var count = getCountForVerificationViewDisplay()
        count = count + 1
        userDefaults.set(count, forKey: SharedPreferenceHelper.VERIFICATION_VIEW)
    }

    static func getCountForVerificationViewDisplay() -> Int{
        let count = userDefaults.value(forKey: SharedPreferenceHelper.VERIFICATION_VIEW)
        if count == nil {
            return 0
        }else{
            return count as! Int
        }
    }

    static func setCountForVerificationViewDisplay(count : Int){
        userDefaults.set(count, forKey: SharedPreferenceHelper.VERIFICATION_VIEW)
    }

    static func removeLoggedInPassword(){
        userDefaults.removeObject(forKey: USER_PWD)
    }
    public static func getRecentLocationUpdatedTime()->NSDate?{
        AppDelegate.getAppDelegate().log.debug("")
        return userDefaults.value(forKey: RECENT_LOCATION_UPDATED_TIME) as? NSDate
    }
    public static func setRecentLocationUpdatedTime(time : NSDate?){
        AppDelegate.getAppDelegate().log.debug("\(String(describing: time))")
        userDefaults.setValue(time, forKey: RECENT_LOCATION_UPDATED_TIME)
    }

    static func setRecurringStatusFromBaseRide(status : Bool) {
        userDefaults.set(status, forKey: RECURRING_RIDE_STATUS_FROM_BASE_RIDE)
    }
    static func getRecurringRideStatusFromBaseRide() -> Bool {
        let result = userDefaults.value(forKey: RECURRING_RIDE_STATUS_FROM_BASE_RIDE)
        if result != nil{
            return result as! Bool
        }
        return false
    }
    static func getNewCompanyAddedStatus() -> Bool?{
        return userDefaults.value(forKey: NEW_COMPANY) as? Bool
    }
    static func setNewCompanyAdded(status : Bool) {
        userDefaults.set(status, forKey: NEW_COMPANY)
    }
    //store rideId to check whether to display welcome greeting view or not
    static func storeRideId(rideId: Double?) {
        userDefaults.set(rideId, forKey: RIDE_ID)
    }
    //get rideId to check whether to display welcome greeting view or not
    static func getRideId() -> Double? {
        return userDefaults.value(forKey: RIDE_ID) as? Double
    }

    //store riderRideId to check whether to display thankyou greeting view or not
    static func storeRiderRideId(riderRideId: Double?) {
        userDefaults.set(riderRideId, forKey: RIDER_RIDE_ID)
    }
    //get riderRideId to check whether to display thankyou greeting view or not
    static func getRiderRideId() -> Double? {
        return userDefaults.value(forKey: RIDER_RIDE_ID) as? Double
    }

    static func saveRegularRideActiveState(status: String) {
        userDefaults.set(status, forKey: REGULAR_RIDE_SHOW_HIDE_STATUS)
    }

    static func getRegularRideDisplayStatus() -> String? {
        let result = userDefaults.value(forKey: REGULAR_RIDE_SHOW_HIDE_STATUS) as? String
        return result
    }

    static func getRouteMetrics( key : String) -> RouteMetrics? {

        if let data =  userDefaults.string(forKey: SharedPreferenceHelper.ROUTE_METRICS_PREFIX+key){
            return Mapper<RouteMetrics>().map(JSONString: data)
        }
        return nil
    }
    static func saveRouteMetrics( key : String, routeMetrics : RouteMetrics){
        userDefaults.set(routeMetrics.toJSONString(), forKey: SharedPreferenceHelper.ROUTE_METRICS_PREFIX+key)
    }

    static func setDisplayStatusForWhyConfirmPickup(status : Bool){
        userDefaults.set(status, forKey: WHY_CONFIRM_PICKUP)
    }
    static func getDisplayStatusForWhyConfirmPickup() -> Bool?{
        if let value = userDefaults.value(forKey: WHY_CONFIRM_PICKUP) as? Bool{
            return value
        }
        return nil
    }

    static func clearRouteMetricsForRideId( riderRideId : Double){

        let keys = userDefaults.dictionaryRepresentation().keys
        for key in keys{
            if key.hasPrefix(SharedPreferenceHelper.ROUTE_METRICS_PREFIX+String(riderRideId)){
                userDefaults.removeObject(forKey: key)
            }
        }
    }

    static func saveAppVersionStatusForCleverTap(status: String) {
        userDefaults.set(status, forKey: CLEVERTAP_APP_VERSION_STATUS)
    }

    static func getAppVersionStatusForCleverTap() -> String? {
        let result = userDefaults.value(forKey: CLEVERTAP_APP_VERSION_STATUS) as? String
        return result
    }
    static func incrementUnreadMessageOfUser(sourceId : Double){
        var count = getUnreadMessageCountOfUser(sourceId: sourceId)
        count = count + 1
        userDefaults.set(count, forKey: UNREAD_MESSAGE_OF_USER+StringUtils.getStringFromDouble(decimalNumber: sourceId))
    }

    static func getUnreadMessageCountOfUser(sourceId : Double) -> Int{
        let count = userDefaults.value(forKey: UNREAD_MESSAGE_OF_USER+StringUtils.getStringFromDouble(decimalNumber: sourceId))
        if count == nil {
            return 0
        }else{
            return count as! Int
        }
    }

    static func resetUnreadMessageOfUser(sourceId : Double){
        userDefaults.set(0, forKey: UNREAD_MESSAGE_OF_USER+StringUtils.getStringFromDouble(decimalNumber: sourceId))
    }

    static func setTripReportOptionShownIndex(index: Int) {
          userDefaults.set(index, forKey: SharedPreferenceHelper.TRIP_REPORT_OPTIONS)
      }
      static func getTripReportOptionShownIndex() -> Int {
          if let index = userDefaults.value(forKey: SharedPreferenceHelper.TRIP_REPORT_OPTIONS) as? Int {
             return index
          }else{
              return 0
          }
      }

      static func setTripReportOfferShownIndex(index: Int) {
          userDefaults.set(index, forKey: SharedPreferenceHelper.TRIP_REPORT_OFFER_SHOWN)
      }
      static func getTripReportOfferShownIndex() -> Int {
          if let index = userDefaults.value(forKey: SharedPreferenceHelper.TRIP_REPORT_OFFER_SHOWN) as? Int {
             return index
          }else{
              return 0
          }
      }
    static func storeShownAutoInviteUserId(rideId : Double,list: [Double]?){
        AppDelegate.getAppDelegate().log.debug("")
        userDefaults.set(list, forKey: STRORE_AUTO_INVITE_USER_ID+String(rideId))
    }
    static func getShownAutoInviteUserId(rideId: Double)->[Double]{
        AppDelegate.getAppDelegate().log.debug("")
        let userIDs = userDefaults.array(forKey: STRORE_AUTO_INVITE_USER_ID+String(rideId))
        if userIDs == nil
        {
            return [Double]()
        }
        return userIDs as! [Double]
    }

    //store rideId to check whether to display moderatorInfo
    static func storeModeratorInfoShownRideIds(rideId: Double) {
        userDefaults.set(rideId, forKey: MODERATOR_INFO_SHOWN_RIDE_ID + String(rideId))
    }

    //get rideId to check whether to display moderatorInfo
    static func getModeratorInfoShownRideIds(rideId: Double) -> Double? {
        return userDefaults.value(forKey: MODERATOR_INFO_SHOWN_RIDE_ID + String(rideId)) as? Double
    }

    //store rideId to check whether to display moderatorInfo
    static func getModeratorInfoDisplayedCount() -> Int {
        if let count = userDefaults.value(forKey: SharedPreferenceHelper.MODERATOR_INFO_SHOWN_COUNT) as? Int {
            return count
        } else {
            return 0
        }
    }

    //store rideId to check whether to display moderatorInfo
    static func setModeratorInfoDisplayedCount(count : Int?){
        userDefaults.set(count, forKey: SharedPreferenceHelper.MODERATOR_INFO_SHOWN_COUNT)
    }

   static func getLikingTheAppPopupShownDate() -> NSDate? {
        return userDefaults.value(forKey: LIKEING_APP_POPUP_SHOWN_DATE) as? NSDate
    }
    static func setLikingTheAppPopupShownDate(time : NSDate) {
        userDefaults.setValue(time, forKey: LIKEING_APP_POPUP_SHOWN_DATE)
    }

    static func getRatingPopUpShownDate() -> NSDate? {
        return userDefaults.value(forKey: SET_RATING_POPUP_SHOWN_DATE) as? NSDate
    }

    static func setRatingPopUpShownDate(time: NSDate){
       userDefaults.setValue(time, forKey: SET_RATING_POPUP_SHOWN_DATE)
    }

    static func getSkipRatingDate() -> NSDate? {
        return userDefaults.value(forKey: SKIP_RATING_DATE) as? NSDate
    }

    static func setSkipRatingDate(time: NSDate){
       userDefaults.setValue(time, forKey: SKIP_RATING_DATE)
    }

    static func setReferralCurrentLevel(count : Int?){
        userDefaults.set(count, forKey: SharedPreferenceHelper.REFERRAL_USER_LEVEL)
    }

    static func getReferralCurrentLevel() -> Int {
        if let count = userDefaults.value(forKey: SharedPreferenceHelper.REFERRAL_USER_LEVEL) as? Int {
            return count
        } else {
            return 0
        }
    }

    static func setSimplOfferShowedRideIds(userId: String,showedRideIds : [Double]){
        userDefaults.set(showedRideIds, forKey: SharedPreferenceHelper.SAVE_SIMPL_OFFER_SHOWED_RIDE_IDS+String(userId))
    }

    static func getSimplOfferShowedRideIds(userId: String) -> [Double] {
        if let rideIds = userDefaults.value(forKey: SharedPreferenceHelper.SAVE_SIMPL_OFFER_SHOWED_RIDE_IDS+String(userId)) as? [Double] {
            return rideIds
        } else {
            return [Double]()
        }
    }

    static func storeMatchedUserLocation(userId: Double?, rideParticipantLocation: RideParticipantLocation?){
        if rideParticipantLocation != nil{
            let jsonText = Mapper().toJSONString(rideParticipantLocation!, prettyPrint: true)!
            userDefaults.set(jsonText, forKey: MATCHED_RIDER_LOCATION+String(rideParticipantLocation!.userId ?? 0))
        } else {
            userDefaults.set(nil, forKey: MATCHED_RIDER_LOCATION+String(userId ?? 0))
        }
    }

    static func getMatchedUserRideLocation(participantId: Double) -> RideParticipantLocation?{
        let rideParticipantLocation = userDefaults.value(forKey: MATCHED_RIDER_LOCATION+String(participantId)) as? String
        if rideParticipantLocation != nil{
            return Mapper<RideParticipantLocation>().map(JSONString: rideParticipantLocation!)
        }
        return nil
    }

    static func saveSortAndFilterStatus(rideId: Double,status: [String : String]?,rideType: String) {
        userDefaults.set(status, forKey: SORT_AND_FILTER_STATUS+String(rideId)+rideType)
    }

    static func getSortAndFilterStatus(rideId: Double, rideType: String) -> [String : String]{
        if let status = userDefaults.value(forKey: SORT_AND_FILTER_STATUS+String(rideId)+rideType) as? [String : String] {
            return status
        }else{
            return [String : String]()
        }
    }
    static func storeBestMatchAlertActivetdRides(routeId : Double,rideMatchAlertRegistration: RideMatchAlertRegistration?){
        AppDelegate.getAppDelegate().log.debug("")
        if let rideMatchAlert = rideMatchAlertRegistration{
            let jsonText = Mapper().toJSONString(rideMatchAlert, prettyPrint: true)
            userDefaults.set(jsonText, forKey: NOTIFY_ME_ACTIVETD_RIDE+String(routeId))
        }else{
            userDefaults.set(nil, forKey: NOTIFY_ME_ACTIVETD_RIDE+String(routeId))
        }
    }

    static func getBestMatchAlertActivetdRides(routeId: Double)-> RideMatchAlertRegistration?{
        AppDelegate.getAppDelegate().log.debug("")
        if let jsonText = userDefaults.value(forKey: NOTIFY_ME_ACTIVETD_RIDE+String(routeId)) as? String{
            return Mapper<RideMatchAlertRegistration>().map(JSONString: jsonText)
        }else{
            return nil
        }
    }

    static func storeInvitedGroupIds(rideId: Double,groupIds : [Double]?){
        userDefaults.set(groupIds, forKey: SharedPreferenceHelper.STORE_INVITED_GROUP_IDS+String(rideId))
    }

    static func getInvitedGroupsIds(rideId: Double) -> [Double] {
        if let groupIds = userDefaults.value(forKey: SharedPreferenceHelper.STORE_INVITED_GROUP_IDS+String(rideId)) as? [Double] {
            return groupIds
        } else {
            return [Double]()
        }
    }

    static func storeInvitedPhoneBookContacts(rideId: Double,contacts : [String]?){
        userDefaults.set(contacts, forKey: SharedPreferenceHelper.STORE_INVITED_PHONEBOOK_CONTACTS+String(rideId))
    }

    static func getInvitedPhoneBookContacts(rideId: Double) -> [String] {
        if let contacts = userDefaults.value(forKey: SharedPreferenceHelper.STORE_INVITED_PHONEBOOK_CONTACTS+String(rideId)) as? [String] {
            return contacts
        } else {
            return [String]()
        }
    }

    public static func setDisplayStatusForEndorsementInfoView(status : Bool){
        userDefaults.set(status, forKey: ENDORSEMENT_INFO_VIEW)
    }
    public static func getDisplayStatusForEndorsementInfoView() -> Bool{
        if let displayStatus = userDefaults.value(forKey: ENDORSEMENT_INFO_VIEW) as? Bool{
            return displayStatus
        }
        return false
    }

    static func storeRelayRideStatusForCurrentRide(rideId : Double,isSelectedRelayRide: Bool){
        AppDelegate.getAppDelegate().log.debug("")
        userDefaults.set(isSelectedRelayRide, forKey: STORE_RELAY_RIDE_STATUS+String(rideId))
    }

    static func getRelayRideStatusForCurrentRide(rideId: Double)-> Bool?{
        AppDelegate.getAppDelegate().log.debug("")
        if (userDefaults.value(forKey: STORE_RELAY_RIDE_STATUS+String(rideId)) != nil){
            return userDefaults.value(forKey: STORE_RELAY_RIDE_STATUS+String(rideId)) as? Bool
        }else{
            return false
        }
    }

    static func saveRouteDeviationStatus(id: Double, status: String){
        userDefaults.set(status, forKey: ROUTE_DEVIATION_STATUS+String(id))
    }

    static func getRouteDeviationStatus(id: Double)-> String? {
        if let status = userDefaults.value(forKey: ROUTE_DEVIATION_STATUS+String(id)) as? String {
            return status
        }else{
            return nil
        }
    }
    static func storeSuspendedRecurringRideDailogShowedStatusCount(status : Int){
        userDefaults.set(status, forKey: SUSPENDED_RECURRING_RIDE_DAILOG_SHOWED_STATUS)
    }

    static func getSuspendedRecurringRideDailogShowedStatusCount() -> Int {
        if let value = userDefaults.value(forKey: SUSPENDED_RECURRING_RIDE_DAILOG_SHOWED_STATUS)  as? Int{
            return value
        }else{
            return 0
        }
    }
    public static func getJoinMyRideRideId() -> String?{
        AppDelegate.getAppDelegate().log.debug("getCurrentUserReferralCode()")
        return userDefaults.value(forKey: JOIN_MY_RIDE_ID) as? String
    }
    public static func getJoinMyRideRiderId() -> String?{
        AppDelegate.getAppDelegate().log.debug("getCurrentUserReferralCode()")
        return userDefaults.value(forKey: JOIN_MY_RIDER_ID) as? String
    }

    public static func storeJoinMyRideIdAndRiderId(rideId : String?,riderId: String?,isFromTaxipool: Bool){
        userDefaults.setValue(rideId, forKey: JOIN_MY_RIDE_ID)
        userDefaults.setValue(riderId, forKey: JOIN_MY_RIDER_ID)
        userDefaults.setValue(isFromTaxipool, forKey: JOIN_MY_RIDE_SOURCE_TYPE)
    }

    public static func getJoinMyRideSourceType() -> Bool{
        AppDelegate.getAppDelegate().log.debug("getCurrentUserReferralCode()")
        if let result = userDefaults.value(forKey: JOIN_MY_RIDE_SOURCE_TYPE) as? Bool{
            return result
        }else{
            return false
        }
    }

    public static func getRecentTabBarIndex() -> Int{
        if let index = userDefaults.value(forKey: RECENT_TAB_BAR_INDEX) as? Int{
            return index
        }else{
            return 0
        }
    }
    public static func storeRecentTabBarIndex(tabBarIndex: Int){
        userDefaults.setValue(tabBarIndex, forKey: RECENT_TAB_BAR_INDEX)
    }
}


//MARK: MqttData
extension SharedPreferenceHelper {
    static func storeMqttDataForApp(mqttData : MqttDataForApp?){
        if mqttData != nil{
            let jsonText = Mapper().toJSONString(mqttData! , prettyPrint: true)!
            userDefaults.set(jsonText, forKey: SharedPreferenceHelper.MQTT_DATA_FOR_APP)
        }else{
            userDefaults.set(nil, forKey: SharedPreferenceHelper.MQTT_DATA_FOR_APP)
        }
    }

    static func getMqttDataForApp() -> MqttDataForApp?{
        let mqttData = userDefaults.value(forKey: SharedPreferenceHelper.MQTT_DATA_FOR_APP) as? String
        if mqttData != nil{
            return Mapper<MqttDataForApp>().map(JSONString: mqttData!)
        }
        return nil
    }
        static func saveOrganizationEmailId(emailId: String?) {
        userDefaults.set(emailId, forKey: ORGNISATION_EMAIL_ID)
    }

    static func getOrganizationEmailId() -> String? {
        let result = userDefaults.value(forKey: ORGNISATION_EMAIL_ID) as? String
        return result
    }
}

//MARK: SafeKeeper Status
extension SharedPreferenceHelper {

    public static func getSafeKepeerReconfirmViewDispalyTime()->NSDate?{
        return userDefaults.value(forKey: SAFE_KEEPER_RECONFIRM_VIEW_DISPLY_TIME) as? NSDate
    }
    public static func setSafeKepeerReconfirmViewDisplayTime(time : NSDate){
        userDefaults.setValue(time, forKey: SAFE_KEEPER_RECONFIRM_VIEW_DISPLY_TIME)
    }

    static func storeHpPayApiCallStatus(status : Bool){
        userDefaults.set(status, forKey: HP_PAY_API_CALL_STATUS)
    }

    static func getHpPayApiCallStatus() -> Bool {
        var value = userDefaults.value(forKey: HP_PAY_API_CALL_STATUS)  as? Bool
        if value == nil {
            value = false
        }
        return value!
    }

    static func setUserRegisteredForIOCL(status : Bool){
        userDefaults.set(status, forKey: USER_REGISTERED_FOR_IOCL)
    }

    static func getUserRegisteredForIOCL() -> Bool {
        var value = userDefaults.value(forKey: USER_REGISTERED_FOR_IOCL)  as? Bool
        if value == nil {
            value = false
        }
        return value!
    }
    static func setBankRegistration(status : Bool){
        userDefaults.set(status, forKey: USER_REGISTERED_FOR_BANK)
    }

    static func getBankRegistration() -> Bool {
        if let value = userDefaults.value(forKey: USER_REGISTERED_FOR_BANK)  as? Bool{
            return value
        }else{
           return false
        }
    }

    public static func storeQuickJobUrl(parameter : String?){
        userDefaults.set(parameter, forKey: PERTICULER_QUICK_JOB_URL)
    }

    public static func getQuickJobUrl() -> String?{
        return userDefaults.value(forKey: PERTICULER_QUICK_JOB_URL) as? String
    }
}
//MARK: QuickShare
extension SharedPreferenceHelper {
    static func storeProductUrl(url : String?,type: String?){
        userDefaults.set(url, forKey: PRODUCT_URL)
        userDefaults.set(url, forKey: PRODUCT_URL_TYPE)
    }

    static func getProductUrl() -> String?{
        return userDefaults.value(forKey: PRODUCT_URL) as? String
    }

    static func getProductUrlType() -> String?{
        return userDefaults.value(forKey: PRODUCT_URL_TYPE) as? String
    }
}
//MARK: Taxi
extension SharedPreferenceHelper {
    static func storeShownTaxiFeatureIndex(shownIndex: Int){
        userDefaults.set(shownIndex, forKey: TAXI_FEATURE_SHOWN_INDEX)
    }

    static func getShownTaxiFeatureIndex() -> Int{
        if let index = userDefaults.value(forKey: TAXI_FEATURE_SHOWN_INDEX) as? Int{
            return index
        }else{
            return 0
        }
    }

    static func storeEmeregencyInitiatedTime(initiatedTime: Double){
        userDefaults.set(initiatedTime, forKey: EMERGENCY_INITIATED_TIME)
    }

    static func getEmeregencyInitiatedTime() -> Double?{
        return userDefaults.value(forKey: EMERGENCY_INITIATED_TIME) as? Double
    }
    static func storeTaxiRideGroupSuggestionUpdate(taxiGroupId: Double,taxiUpdateSuggestion: TaxiRideGroupSuggestionUpdate?){
        if let object = taxiUpdateSuggestion{
            let jsonText = Mapper().toJSONString(object , prettyPrint: true)
            userDefaults.set(jsonText, forKey: TAXI_RIDE_UPDATE_SUGGESTION+String(taxiGroupId))
        }else{
            userDefaults.set(nil, forKey: TAXI_RIDE_UPDATE_SUGGESTION+String(taxiGroupId))
        }
    }

    static func getTaxiRideGroupSuggestionUpdate(taxiGroupId: Double) -> TaxiRideGroupSuggestionUpdate?{
        if let taxiRideUpdateSuggestion = userDefaults.value(forKey: TAXI_RIDE_UPDATE_SUGGESTION+String(taxiGroupId)) as? String{
            return Mapper<TaxiRideGroupSuggestionUpdate>().map(JSONString: taxiRideUpdateSuggestion)
        }
        return nil
    }
    static func setTaxiOfferCoupon(coupon: SystemCouponCode?){
        if let object = coupon{
            let jsonText = Mapper().toJSONString(object , prettyPrint: true)
            userDefaults.set(jsonText, forKey: TAXI_OFFER_AVAILABILITY)
        }else{
            userDefaults.set(nil, forKey: TAXI_OFFER_AVAILABILITY)
        }
    }

    static func getTaxiOfferCoupon() -> SystemCouponCode? {
        if let coupon = userDefaults.value(forKey: TAXI_OFFER_AVAILABILITY) as? String{
            return Mapper<SystemCouponCode>().map(JSONString: coupon)
        }
        return nil
    }

    static func storeNewDriverAllotedNotification(isRequiredToShowNewDriverAllotedPopup: Bool){
        userDefaults.set(isRequiredToShowNewDriverAllotedPopup, forKey: IS_RREQUIRED_TO_SHOW_NEW_DRIVER_ALLOTED_POPUP)
    }

    static func getNewDriverAllotedNotification() -> Bool{
        if let storedValue = userDefaults.value(forKey: IS_RREQUIRED_TO_SHOW_NEW_DRIVER_ALLOTED_POPUP) as? Bool {
            return storedValue
        } else {
            return false
        }
    }
    static func saveLastLocation(latLng : LatLng){
        userDefaults.set(latLng.toJSONString(), forKey: "lastLocation")
    }

    static func getLastLocation() -> LatLng?{
        if let latLngJson = userDefaults.value(forKey: "lastLocation") as? String, let latLng = Mapper<LatLng>().map(JSONString: latLngJson ){
            return latLng
        }
        return nil
    }

    static func storeTaxiDriverAllocationStatus(taxiRidePassengerId: Double, isAllocationStarted: Bool?) {
        let key = TAXI_ALLOCATION_STATUS_OF + StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        if let isAllocationStarted = isAllocationStarted {
            userDefaults.set(isAllocationStarted, forKey: key)
        }else {
            userDefaults.removeObject(forKey: key)
        }
    }

    static func getTaxiDriverAllocationStatus(taxiRidePassengerId: Double) -> Bool {
        let key = TAXI_ALLOCATION_STATUS_OF + StringUtils.getStringFromDouble(decimalNumber: taxiRidePassengerId)
        if let storedValue = userDefaults.value(forKey: key) as? Bool {
            return storedValue
        } else {
            return false
        }
    }

    static func storeBehalfBookingContactDetails(behalfBookingContactDetailsList: [TaxiBehalfBookingContactDetails]){
        let contactList = Mapper().toJSONString(behalfBookingContactDetailsList , prettyPrint: true)!
        userDefaults.set(contactList, forKey: BEHALF_BOOKING_CONTACT_DETAILS)
    }

    static func getBehalfBookingContactDetails() -> [TaxiBehalfBookingContactDetails] {
        if let contactList = userDefaults.string(forKey: BEHALF_BOOKING_CONTACT_DETAILS) {
            if let contacts = Mapper<TaxiBehalfBookingContactDetails>().mapArray(JSONString: contactList ) {
                return contacts
            }else{
                return [TaxiBehalfBookingContactDetails]()
            }
        }else {
            return [TaxiBehalfBookingContactDetails]()
        }
    }
}
