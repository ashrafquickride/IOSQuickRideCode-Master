//
//  ConfigurationCache.swift
//  Quickride
//
//  Created by KNM Rao on 17/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ConfigurationCache {
    private static var sharedInstance : ConfigurationCache?
    private var dispatchSF  : DispatchSemaphore!
    
    private var clientConfiguration : ClientConfigurtion?
    private var googleAPIConfiguration : GoogleAPIConfiguration?
    var offersList:[Offer] = []
    var mqttDataForApp : MqttDataForApp?
    var appUpgradeStatus : String?
    var publishLocUpdatesToRideMgmtBroker = true
    var isAlertDisplayedForUpgrade = false
    var customerSupportFileUrl : String?
    var isResumeSession = false
    var emailVerificationInitiatedDate: Double?
    var userCoupons = [UserCouponCode]()
    var placesAPIGenuineKeyStartTime : NSDate?
    var adhaarClientCodeForWeb: String?
    var adhaarApiKeyForWeb: String?
    var adhaarSaltForWeb: String?
    
    static var isCouponsRetrieved = false
    private let GET_APP_STARTUP_DATA_PATH = "QRClient/appstartup/ios"
    private let GET_USER_COUPONS_PATH = "QRPromotion/activatedCoupons"
    
    private init(){
        
    }
    
    static func removeCacheInstance(){
        self.sharedInstance?.clientConfiguration = nil
        self.sharedInstance?.offersList.removeAll()
        self.sharedInstance = nil
    }
    
    static func getInstance() -> ConfigurationCache? {
        return sharedInstance
    }
    static func newUserSession() throws {
        if (self.sharedInstance != nil) {
            self.removeCacheInstance()
        }
        
        self.sharedInstance = ConfigurationCache()
        try self.sharedInstance?.retrieveAllConfigsFromServer()
        self.sharedInstance?.getUserCoupons()
    }
    
    static func reInitialiseUserSession() throws {
        try newUserSession()
    }
    
    static func resumeUserSession() throws {
        if (self.sharedInstance != nil) {
            self.removeCacheInstance()
        }
        self.sharedInstance = ConfigurationCache()
        try self.sharedInstance?.initialiseAppStartUpDataAndRefreshInSharedPrefrences()
        self.sharedInstance?.getUserCoupons()
    }
    
    static func clearUserSession() {
        if (self.sharedInstance != nil) {
            self.removeCacheInstance()
        }
        SharedPreferenceHelper.storeAppStartUpData(appStartUpData: nil)
    }
    static func clearUserPersistentStore(){
        if (self.sharedInstance != nil) {
            self.removeCacheInstance()
        }
    }
    
    static func getObjectClientConfiguration() -> ClientConfigurtion{
        return ConfigurationCache.getInstance()?.getClientConfiguration() ?? ClientConfigurtion()
    }
    
    func getClientConfiguration() -> ClientConfigurtion? {
        
        return clientConfiguration
    }
    func getGoogleAPIConfiguration() -> GoogleAPIConfiguration? {
        
        return googleAPIConfiguration
    }
    func getDefaultClientConfiguration() -> ClientConfigurtion? {
        
        return ClientConfigurtion()
    }
    
    func getMinimumRedeemablePoints() -> Int? {
        return getClientConfiguration()?.minimumEncashableAmount
    }
    
    func getMaximumTransferablePoints() -> Int? {
        return getClientConfiguration()?.transferMaximumNumberOfPoints
    }
    func retrieveAllConfigsFromServer() throws {
        let currentAppVersionNo = getCurrentAppVersionNumber()
        let userId = QRSessionManager.getInstance()!.getUserId()
        
        dispatchSF = DispatchSemaphore(value: 0)
        try loadAppStartupDataFromServer(currentAppVersionNo : currentAppVersionNo, appName: AppConfiguration.APP_NAME, userId: userId, isResumeSession: false)
        dispatchSF.wait(timeout: .distantFuture)
    }
    
    func initialiseAppStartUpDataAndRefreshInSharedPrefrences() throws{
        let currentAppVersionNo = getCurrentAppVersionNumber()
        let userId = QRSessionManager.getInstance()!.getUserId()
        self.loadAppStartUpDataFromPersistence()
        try loadAppStartupDataFromServer(currentAppVersionNo : currentAppVersionNo, appName: AppConfiguration.APP_NAME, userId: userId, isResumeSession: true)
    }
    
    private func getCurrentAppVersionNumber() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        else {
            return AppConfiguration.APP_CURRENT_VERSION_NO
        }
    }
    
    func loadAppStartUpDataFromPersistence(){
        initializeConfigCacheDataFromSharedPreferences()
    }
    
    private func loadAppStartupDataFromServer(currentAppVersionNo : String, appName : String, userId : String,isResumeSession : Bool) throws {
        let currentClientConfigVersion = ConfigurationCache.getObjectClientConfiguration().clientConfiguartionVersion
        AppDelegate.getAppDelegate().log.debug("loadAppStartupData() \(currentClientConfigVersion) \(currentAppVersionNo)")
        

        let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_APP_STARTUP_DATA_PATH
        
        var params = [String : String]()
        params[ClientConfigurtion.CLIENT_CONFIG_VERSION] = String(currentClientConfigVersion)
        params[ClientConfigurtion.APP_VERSION] = currentAppVersionNo
        params[User.FLD_APP_NAME] = appName
        params[User.FLD_PHONE] = userId
        params[ClientConfigurtion.IOS_APP_VERSION_NAME] = currentAppVersionNo
        
        var appStartupDataLoadingFailureCause : SessionManagerOperationFailedException? = nil
        
        
        HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params) { (responseObject, error) in
            
            if responseObject != nil && responseObject!["result"]! as! String == "SUCCESS"{
                let appStartupData : AppStartupData = Mapper<AppStartupData>().map(JSONObject: responseObject!["resultData"])!
                appStartupDataLoadingFailureCause = nil
                self.saveAppStartupData(appStartupData: appStartupData)
                if (self.dispatchSF != nil) {
                    self.dispatchSF.signal()
                }
            }
            else if responseObject != nil && responseObject!["result"]! as! String == "FAILURE" {
                let errorResponse = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                AppDelegate.getAppDelegate().log.debug("Error while loading app startup data \(String(describing: errorResponse))")
                appStartupDataLoadingFailureCause = SessionManagerOperationFailedException.SessionChangeOperationFailed
                if (self.dispatchSF != nil) {
                    self.dispatchSF.signal()
                }
            }else{
                if error == QuickRideErrors.NetworkConnectionNotAvailableError{
                    appStartupDataLoadingFailureCause = SessionManagerOperationFailedException.NetworkConnectionNotAvailable
                }else if error == QuickRideErrors.RequestTimedOutError{
                    appStartupDataLoadingFailureCause = SessionManagerOperationFailedException.SessionChangeOperationTimedOut
                }else{
                    appStartupDataLoadingFailureCause = SessionManagerOperationFailedException.SessionChangeOperationFailed
                }
                if (self.dispatchSF != nil) {
                    self.dispatchSF.signal()
                }
            }
        }
        AppDelegate.getAppDelegate().log.debug("Waiting for app startup data to get loaded")
        
        
        AppDelegate.getAppDelegate().log.debug("After waiting")
        if (appStartupDataLoadingFailureCause != nil && !isResumeSession){
            throw appStartupDataLoadingFailureCause!
        }
    }
    
    private func saveAppStartupData (appStartupData : AppStartupData) {
        
        AppDelegate.getAppDelegate().log.debug("saveAppStartupData()")
        
        if ConfigurationCache.sharedInstance == nil{
            return
        }
        ConfigurationCache.sharedInstance!.appUpgradeStatus = appStartupData.isUpgradeRequired
        if appStartupData.clientConfiguration != nil {
            let updatedBlogList = ConfigurationCache.sharedInstance!.clientConfiguration?.updateAndReturnLatestBlog(blogsFromServer: appStartupData.clientConfiguration!.blogList)
            ConfigurationCache.sharedInstance!.clientConfiguration = appStartupData.clientConfiguration
            if updatedBlogList != nil{
                ConfigurationCache.sharedInstance!.clientConfiguration!.blogList = updatedBlogList!
            }
            parseAndStoreGreetingDetails(greetingDetailsFileUrl: appStartupData.clientConfiguration!.greetingDetailsFileURl)
        }
        ConfigurationCache.sharedInstance!.googleAPIConfiguration = appStartupData.googleAPIConfiguration
        if appStartupData.offersList != nil{
            ConfigurationCache.sharedInstance!.offersList = appStartupData.offersList!
            SharedPreferenceHelper.storeOffers(offers: offersList)
        }
       
        ConfigurationCache.sharedInstance!.publishLocUpdatesToRideMgmtBroker = appStartupData.publishLocUpdatesToRideMgmtBroker
        ConfigurationCache.sharedInstance!.customerSupportFileUrl = appStartupData.customerSupportFileURL
        ConfigurationCache.sharedInstance!.emailVerificationInitiatedDate = appStartupData.emailVerificationInitiatedDate
        ConfigurationCache.sharedInstance!.adhaarClientCodeForWeb = appStartupData.adhaarClientCodeForWeb
        ConfigurationCache.sharedInstance!.adhaarApiKeyForWeb = appStartupData.adhaarApiKeyForWeb
        ConfigurationCache.sharedInstance!.adhaarSaltForWeb = appStartupData.adhaarSaltForWeb
        CustomerSupportDetailsParser.getInstance()
        
        SharedPreferenceHelper.storeAppStartUpData(appStartUpData: appStartupData)
        saveMqttData()
    }
    
    func setPlacesAPIGenuineUsageStartTime(date : NSDate){
        self.placesAPIGenuineKeyStartTime = date
    }
    func getPlacesAPIGenuineUsageStartTime() -> NSDate?{
        return self.placesAPIGenuineKeyStartTime
    }
    static func getPremiumAPIKey() -> String{
        if let premiumKey = ConfigurationCache.sharedInstance?.googleAPIConfiguration?.googlePremiumKey{
            return premiumKey
        }else{
            return AppConfiguration.googleMapsKey
        }
    }
    
    func initializeConfigCacheDataFromSharedPreferences(){
        if ConfigurationCache.sharedInstance == nil{
           ConfigurationCache.sharedInstance = ConfigurationCache()
        }
        let appStartUpData = SharedPreferenceHelper.getAppStartUpData()
        if appStartUpData != nil{
            ConfigurationCache.sharedInstance?.clientConfiguration = appStartUpData!.clientConfiguration
            ConfigurationCache.sharedInstance?.googleAPIConfiguration = appStartUpData!.googleAPIConfiguration
            ConfigurationCache.sharedInstance?.appUpgradeStatus = appStartUpData!.isUpgradeRequired
            ConfigurationCache.sharedInstance?.offersList = SharedPreferenceHelper.getOffers()
            ConfigurationCache.sharedInstance?.publishLocUpdatesToRideMgmtBroker = appStartUpData!.publishLocUpdatesToRideMgmtBroker
            ConfigurationCache.getInstance()?.customerSupportFileUrl = appStartUpData!.customerSupportFileURL
            ConfigurationCache.sharedInstance?.emailVerificationInitiatedDate = appStartUpData!.emailVerificationInitiatedDate
            ConfigurationCache.getInstance()?.adhaarClientCodeForWeb = appStartUpData!.adhaarClientCodeForWeb
            ConfigurationCache.getInstance()?.adhaarApiKeyForWeb = appStartUpData!.adhaarApiKeyForWeb
            ConfigurationCache.getInstance()?.adhaarSaltForWeb = appStartUpData!.adhaarSaltForWeb
        }
        initializeMqttDataFromSharedPreferences()
    }
    
    private func initializeMqttDataFromSharedPreferences() {
        mqttDataForApp = SharedPreferenceHelper.getMqttDataForApp()
    }

    func saveAppStartupDataInSharedPreferences(appStartData : AppStartupData){
        
        if appStartData.offersList != nil{
         SharedPreferenceHelper.storeOffers(offers: appStartData.offersList!)
        }
        
    }
    
    
    func getFilteredOfferList(displayType: String) -> [Offer]?{
        var filterList = [Offer]()
        for offer in self.offersList{
            if offer.displayType == displayType
            {
                filterList.append(offer)
            }
        }
        return filterList
    }
    
    func getUserCoupons(){
      let url = AppConfiguration.serverUrl + AppConfiguration.serverPort + AppConfiguration.apiServerPath + GET_USER_COUPONS_PATH
      
      var params = [String : String]()
      params[User.FLD_PHONE] = QRSessionManager.getInstance()!.getUserId()
    
      HttpUtils.getJSONRequestWithBody(url: url, targetViewController: nil, params: params) { (responseObject, error) in
         if responseObject != nil && responseObject!["result"]! as! String == "SUCCESS" && responseObject!["resultData"] != nil{
         
            if let userCoupons = Mapper<UserCouponCode>().mapArray(JSONObject: responseObject!["resultData"]){
                
                ConfigurationCache.getInstance()?.userCoupons = userCoupons
                
                if !userCoupons.isEmpty{
                  ConfigurationCache.isCouponsRetrieved = true
                }
            }
        }
      }
    }
    
    private func parseAndStoreGreetingDetails(greetingDetailsFileUrl: String){
        HttpUtils.performRestCallToOtherServer(url: greetingDetailsFileUrl, params:  [String : String](), requestType: .get, targetViewController: nil, handler: { (responseObject, error) in
            if responseObject != nil {
                let greetingDetails = Mapper<GreetingDetails>().map(JSONObject: responseObject)
                if let listOfGreetingDetail = greetingDetails?.greetingDetails{
                    UserCoreDataHelper.clearTableForEntity(entityName: UserCoreDataHelper.greetingDetailsTable)
                    UserCoreDataHelper.saveGreetingDetails(greetingDetails: listOfGreetingDetail)
                }
            }
        })
    }
    
    private func saveMqttData() {
        mqttDataForApp = clientConfiguration?.mqttDataForApp
        SharedPreferenceHelper.storeMqttDataForApp(mqttData: mqttDataForApp)
    }
    
    func getRideMgmtEventBrokerType() -> String? {
        return mqttDataForApp?.rideMgmtEventBrokerType
    }
    
    func getMainEventBrokerConnectInfo() -> RmqBrokerConnectInfo? {
        return mqttDataForApp?.mainEventBrokerConnectInfo
    }
    
    func getLocationMgmtEventBrokerType() -> String? {
        return mqttDataForApp?.locationMgmtEventBrokerType
    }
    
    func getLocationEventBrokerConnectInfo() -> RmqBrokerConnectInfo? {
        return mqttDataForApp?.locationEventBrokerConnectInfo
    }
    
    func getAwsIotConnectCredentials() -> AWSIosConnectCredentials? {
        return mqttDataForApp?.awsIotConnectCredentials
    }
   
        static func getOfferList() -> [Offer]{
        if let offerList = ConfigurationCache.getInstance()?.offersList {
            return offerList
        }else{
            return SharedPreferenceHelper.getOffers()
        }
    }
}
