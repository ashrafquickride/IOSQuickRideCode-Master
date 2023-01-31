

//
//  Constants.swift
//  Quickride
//
//  Created by Aakash on 18/09/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import Foundation
import GoogleMaps

// A global struct for constansts
struct AppConfiguration {

    static let RAZORPAY_MERCHANT_NAME = "QuickRide"

    static let RAZORPAY_CURRENCY = "INR"
    static let DEFAULT_COUNTRY_CODE_IND = "+91"
    //Production Configurarion_PayTm
    static let checksumGenerationURL = "https://fs.getquickride.com:443/financialserver/checkSumGenerator.do"
    static let checksumValidationURL = "https://fs.getquickride.com:443/financialserver/checkSumVerify.do"
    static let merchantId = "quicki20223181211538"
    static let channelId = "WAP"
    static let industryTypeId = "Retail120"
    static let companyWebsite = "quickride"
    static let requestType = "DEFAULT"
    static let paytm_transaction_cancelled_response_code_1  = 14113
    static let paytm_transaction_cancelled_response_code_2  = 14112
    static let paytm_transaction_cancelled_response_code_3  = 141
    static let razorPay_public_key = "rzp_live_NjxztKBVEiesfV"

    //Test Configurarion_PayTm
    static let test_checksumGenerationURL = "https://testrm.getquickride.com:8443/financialserver/checkSumGenerator.do"
    static let test_checksumValidationURL = "https://testrm.getquickride.com:8443/financialserver/checkSumVerify.do"
    static let test_merchantId = "iDisha67492402293512"
    static let test_companyWebsite = "iDishawap"
    static let test_industryTypeId = "Retail"
    static let test_razorPay_public_key = "rzp_test_7TceM65HdiakvM"

    //FreeCharge

    static let FREECHARGE_CHANNEL_ID = "IOS"
    static let FREECHARGE_MERCHANT_ID = "8mILp0KGOdEG57"
    static let FREECHARGE_PRODUCT_INFO = "auth"
    static let FREECHARGE_SANDBOX_URL = "https://checkout-sandbox.freecharge.in/api/v1/co/pay/init"
    static let FREECHARGE_PRODUCTION_URL = "https://checkout.freecharge.in/api/v1/co/pay/init"

    //Test Configurarion FreeCharge

    static let FREECHARGE_TEST_SURL = "https://testrm.getquickride.com:8443/dishaapiserver/qr_freecharge_success.do?"
    static let FREECHARGE_TEST_FURL = "https://testrm.getquickride.com:8443/dishaapiserver/qr_freecharge_failure.do?"
    static let FREECHARGE_TEST_MERCHANT_KEY = "ebb4d8d0-c406-467e-baea-00ee2c1787b2"

    //Production Configurarion FreeCharge

    static let FREECHARGE_PRODUCTION_SURL = "https://quickride.in/freecharge-success.php"
    static let FREECHARGE_PRODUCTION_FURL = "https://quickride.in/freecharge-failure.php"
    static let FREECHARGE_PRODUCTION_MERCHANT_KEY = "2caad441-88b3-4bb5-8ca4-af939feecd0a"

    static let useProductionServerForPG = true

    //Mobikwik
    static let MOBIKWIK_CURRENCY = "INR"
    static let MOBIQWIK_MERCHANT_RETURN_URL_PRODUCTION = "https://getquickride.com:443/dishaapiserver/mobiqwikresponse.do?"
    static let MOBIQWIK_RETURN_URL_PRODUCTION = "https://getquickride.com/dishaapiserver/mobiqwikresponse.do?"
    static let MOBIQWIK_MERCHANT_URL_PRODUCTION = "https://getquickride.com:8443/dishaapiserver/mobiqwikpayment.do?"
    static let MOBIQWIK_MERCHANT_ID_PRODUCTION = "804d3768b9934e97ad68972de310dbf4"

    static let MOBIQWIK_MERCHANT_URL_STAGGING = "https://testrm.getquickride.com:8443/dishaapiserver/mobiqwikpayment.do?"
    static let MOBIQWIK_MERCHANT_ID_STAGGING = "b19e8f103bce406cbd3476431b6b7973"
    static let MOBIKWIK_MERCHANT_RETURN_URL_STAGGING = "http://zaakpaystaging.centralindia.cloudapp.azure.com:8080/merchant/test_merchant_output.jsp"


    //coverfox
    static let COVERFOX_INSURANCE_STAGGING_REQUEST_URL_FOR_CAR = "http://quickride.quickride.uat.coverfox.com/car-insurance/?category=quickride&network=adpartners&vehicle_reg_no="
    static let COVERFOX_INSURANCE_STAGGING_REQUEST_URL_FOR_BIKE = "http://quickride.quickride.uat.coverfox.com/two-wheeler-insurance/?category=quickride&network=adpartners&vehicle_reg_no="
    static let COVERFOX_INSURANCE_STAGGING_REQUEST_URL_FOR_TERM = "http://quickride.quickride.uat.coverfox.com/term-insurance/?category=quickride&network=adpartners"
    static let COVERFOX_INSURANCE_PRODUCTION_REQUEST_URL_FOR_CAR = "http://quickride.coverfox.com/car-insurance/?category=quickride&network=adpartners&vehicle_reg_no="
    static let COVERFOX_INSURANCE_PRODUCTION_REQUEST_URL_FOR_BIKE = "http://quickride.coverfox.com/two-wheeler-insurance/?category=quickride&network=adpartners&vehicle_reg_no="
    static let COVERFOX_INSURANCE_PRODUCTION_REQUEST_URL_FOR_TERM = "https://quickride.coverfox.com/term-insurance/?category=quickride&network=adpartners"

    static let COVERFOX_INSURANCE_STAGGING_SURL_FOR_CAR = "https://quickride.quickride.uat.coverfox.com/motor/fourwheeler/payment/success/"
    static let COVERFOX_INSURANCE_STAGGING_SURL_FOR_BIKE = "https://quickride.quickride.uat.coverfox.com/motor/twowheeler/payment/success/"

    static let COVERFOX_INSURANCE_SURL_FOR_CAR = "https://quickride.coverfox.com/motor/fourwheeler/payment/success/"
    static let COVERFOX_INSURANCE_SURL_FOR_BIKE = "https://quickride.coverfox.com/motor/twowheeler/payment/success/"

    static let SALESPOINT_STAGGING_URL = "https://qa.salespointonline.com/btob-products?"
    static let SALESPOINT_STAGGING_PARTNER_CODE = "ADCA101312"

    static let SALESPOINT_PRODUCTION_URL = "https://www.salespointonline.com/btob-products?"
    static let SALESPOINT_PRODUCTION_PARTNER_CODE = "ADCA114132"

    static let INIT_WEB_KYC_URL_STAGGING = "https://sandbox.veri5digital.com/video-id-kyc/_initWebVIKYC?"
    static let KYC_INFO_CALL_BACK_URL_STAGGING = "https://testrm.getquickride.com/dishaapiserver/fetchkycinfo.do"

    static let INIT_WEB_KYC_URL_PRODUCTION = "https://prod.veri5digital.com/video-id-kyc/_initWebVIKYC"
    static let KYC_INFO_CALL_BACK_URL_PRODUCTION = "https://getquickride.com/dishaapiserver/fetchkycinfo.do"
    //Simpl
    static let SIMPL_MERCHANT_ID = "c97cb43e861ce00ad7c1a7c9dbab1f2d"

    //AppsFlyer

    static let APPSFLYER_DEV_KEY = "sGV2ULRhtVSmrq7bD5VExm"

    //Apple App Id

    // paytm
    static let PAYTM_REGISTRATION_LINK = "https://paytm.com/login?redirect=%2F"

    static let APPLE_APP_ID = "1071794769"

    //DeepLinking

    static let quickride_firebase_link = "https://quickrides.page.link"

    //Netcore

    static let netcore_prod_app_id = "dbc9da9bb96833ba7e73cc577c3c4104"
    static let netcore_dev_app_id = "63fa8a3c46be7a5126fe77806cc5661d"

    // Mqtt constants

    static let keepaliveSeconds = 60
    static let eventNotificationKey = "com.quickride.event.messageCallback"

    //MARK: Get Ride etiquette certification url
    static let GET_RIDE_ETIQUETTE_CERTIFICATE_STAGGING_URL = "https://testpwa.getquickride.com/#/ride-eti"
    static let GET_RIDE_ETIQUETTE_CERTIFICATE_PRODUCTION_URL = "https://pwa.getquickride.com/#/ride-eti"

    // Server Constants

    static let HTTPS_PROTOCOL_STR = "https://"

#if DEBUG

    static let RM_SERVER_DOMAIN_NAME = "testrm.getquickride.com"
    static let serverUrl = HTTPS_PROTOCOL_STR + RM_SERVER_DOMAIN_NAME
    static let ROUTE_MATCH_SERVER_DOMAIN_NAME = "testrr.getquickride.com"
    static let routeServerUrl = HTTPS_PROTOCOL_STR + ROUTE_MATCH_SERVER_DOMAIN_NAME
    static let ROUTES_SERVER_DOMAIN_NAME = "testtaxi.getquickride.com"
    static let routeRepositoryServerUrl = HTTPS_PROTOCOL_STR + ROUTES_SERVER_DOMAIN_NAME
    static let AE_SERVER_DOMAIN_NAME = "testrr.getquickride.com"
    static let analyticsServerUrl = HTTPS_PROTOCOL_STR + AE_SERVER_DOMAIN_NAME
    static let RE_SERVER_DOMAIN_NAME = "testtaxi.getquickride.com"
    static let rideEngineServerUrlIP = HTTPS_PROTOCOL_STR + RE_SERVER_DOMAIN_NAME
    static let RL_SERVER_DOMAIN_NAME = "testrr.getquickride.com"
    static let rideLocationServerUrlIP = HTTPS_PROTOCOL_STR + RL_SERVER_DOMAIN_NAME
    static let RC_SERVER_DOMAIN_NAME = "testrc.getquickride.com"
    static let rideConnectivityServerUrlIP = HTTPS_PROTOCOL_STR + RC_SERVER_DOMAIN_NAME
    static let CM_SERVER_DOMAIN_NAME = "testrm.getquickride.com"
    static let communicationServerUrlIP = HTTPS_PROTOCOL_STR + CM_SERVER_DOMAIN_NAME
    static let UC_SERVER_DOMAIN_NAME = "testrm.getquickride.com"
    static let userContactServerUrlIP = HTTPS_PROTOCOL_STR + UC_SERVER_DOMAIN_NAME
    static let UE_SERVER_DOMAIN_NAME = "testevent.getquickride.com"
    static let userEventServerUrlIp = HTTPS_PROTOCOL_STR + UE_SERVER_DOMAIN_NAME
    static let FS_SERVER_DOMAIN_NAME = "testrc.getquickride.com"
    static let financialServerUrlIp = HTTPS_PROTOCOL_STR + FS_SERVER_DOMAIN_NAME
    static let QS_SERVER_DOMAIN_NAME = "testrr.getquickride.com"
    static let quickShareServerUrlIp = HTTPS_PROTOCOL_STR + QS_SERVER_DOMAIN_NAME
    static let CREDIT_TRACK_SERVER_DOMAIN_NAME = "testcts.getquickride.com"
    static let creditTrackServerUrl = HTTPS_PROTOCOL_STR + CREDIT_TRACK_SERVER_DOMAIN_NAME
    static let TAXI_DEMAND_SERVER_DOMAIN_NAME = "testre.getquickride.com"
    static let taxiDemandServerUrlIp = HTTPS_PROTOCOL_STR + TAXI_DEMAND_SERVER_DOMAIN_NAME
    static let TAXI_RIDE_ENGINE_SERVER_DOMAIN_NAME = "testtaxi.getquickride.com"
    static let taxiRideEngineServerUrlIp = HTTPS_PROTOCOL_STR + TAXI_RIDE_ENGINE_SERVER_DOMAIN_NAME
    static let PWA_SERVER_DOMAIN_NAME = "testpwa.getquickride.com"
    static let pwaServerUrl = HTTPS_PROTOCOL_STR + PWA_SERVER_DOMAIN_NAME
    static let TAXI_ROUTE_MATCH_SERVER_DOMAIN_NAME = "testre.getquickride.com"
    static let taxiRouteMatchServerUrlIp = HTTPS_PROTOCOL_STR + TAXI_ROUTE_MATCH_SERVER_DOMAIN_NAME
    static let serverPort = ":443"
    static let AE_serverPort = ":443"
    static let RE_serverPort = ":443"
    static let ROUTE_REPOSITORY_serverPort = ":443"
    static let ROUTE_MATCH_serverPort  = ":443"
    static let RC_serverPort = ":443"
    static let RL_serverPort = ":443"
    static let CM_serverPort = ":443"
    static let UCS_serverPort = ":443"
    static let FS_serverPort = ":443"
    static let UE_serverPort = ":443"
    static let QS_serverPort = ":443"
    static let CT_serverPort = ":443"
    static let TD_serverPort = ":8443"
    static let PWA_serverPort = ":443"
    static let TAXI_ROUTE_MATCH_SERVER_PORT = ":8443"
    static let mqttClientIp = "3.229.115.19"
    static let mqttClientPort : Int32 = 1883
    static let locMqttClientIp = "3.229.115.19"
    static let locMqttClientPort : Int32 = 1883
#else
    static let RM_SERVER_DOMAIN_NAME = "getquickride.com"
    static let serverUrl = HTTPS_PROTOCOL_STR + RM_SERVER_DOMAIN_NAME

    static let ROUTE_MATCH_SERVER_DOMAIN_NAME = "rr.getquickride.com"
    static let routeServerUrl = HTTPS_PROTOCOL_STR + ROUTE_MATCH_SERVER_DOMAIN_NAME

    static let ROUTES_SERVER_DOMAIN_NAME = "routes.getquickride.com"
    static let routeRepositoryServerUrl = HTTPS_PROTOCOL_STR + ROUTES_SERVER_DOMAIN_NAME

    static let AE_SERVER_DOMAIN_NAME = "analytics.getquickride.com"
    static let analyticsServerUrl = HTTPS_PROTOCOL_STR + AE_SERVER_DOMAIN_NAME

    static let RE_SERVER_DOMAIN_NAME = "re.getquickride.com"
    static let rideEngineServerUrlIP = HTTPS_PROTOCOL_STR + RE_SERVER_DOMAIN_NAME

    static let RL_SERVER_DOMAIN_NAME = "rl.getquickride.com"
    static let rideLocationServerUrlIP = HTTPS_PROTOCOL_STR + RL_SERVER_DOMAIN_NAME

    static let RC_SERVER_DOMAIN_NAME = "rc.getquickride.com"
    static let rideConnectivityServerUrlIP = HTTPS_PROTOCOL_STR + RC_SERVER_DOMAIN_NAME

    static let UC_SERVER_DOMAIN_NAME = "ucs.getquickride.com"
    static let userContactServerUrlIP = HTTPS_PROTOCOL_STR + UC_SERVER_DOMAIN_NAME

    static let CM_SERVER_DOMAIN_NAME = "cm.getquickride.com"
    static let communicationServerUrlIP = HTTPS_PROTOCOL_STR + CM_SERVER_DOMAIN_NAME

    static let UE_SERVER_DOMAIN_NAME = "eventslog.getquickride.com"
    static let userEventServerUrlIp = HTTPS_PROTOCOL_STR + UE_SERVER_DOMAIN_NAME

    static let FS_SERVER_DOMAIN_NAME = "fs.getquickride.com"
    static let financialServerUrlIp = HTTPS_PROTOCOL_STR + FS_SERVER_DOMAIN_NAME

    static let QS_SERVER_DOMAIN_NAME = "qms.getquickride.com"
    static let quickShareServerUrlIp = HTTPS_PROTOCOL_STR + QS_SERVER_DOMAIN_NAME

    static let CREDIT_TRACK_SERVER_DOMAIN_NAME = "cts.getquickride.com"
    static let creditTrackServerUrl = HTTPS_PROTOCOL_STR + CREDIT_TRACK_SERVER_DOMAIN_NAME

    static let TAXI_DEMAND_SERVER_DOMAIN_NAME = "qtds.getquickride.com"
    static let taxiDemandServerUrlIp = HTTPS_PROTOCOL_STR + TAXI_DEMAND_SERVER_DOMAIN_NAME
    
    static let TAXI_RIDE_ENGINE_SERVER_DOMAIN_NAME = "qtre.getquickride.com"
    static let taxiRideEngineServerUrlIp = HTTPS_PROTOCOL_STR + TAXI_RIDE_ENGINE_SERVER_DOMAIN_NAME

    static let PWA_SERVER_DOMAIN_NAME = "pwa.getquickride.com"
    static let pwaServerUrl = HTTPS_PROTOCOL_STR + PWA_SERVER_DOMAIN_NAME

    static let TAXI_ROUTE_MATCH_SERVER_DOMAIN_NAME = "qtrr.getquickride.com"

    static let taxiRouteMatchServerUrlIp = HTTPS_PROTOCOL_STR + TAXI_ROUTE_MATCH_SERVER_DOMAIN_NAME

    static let serverPort = ":443"
    static let AE_serverPort = ":443"
    static let RE_serverPort = ":443"
    static let ROUTE_REPOSITORY_serverPort = ":443"
    static let ROUTE_MATCH_serverPort  = ":443"
    static let RC_serverPort = ":443"
    static let RL_serverPort = ":443"
    static let UCS_serverPort = ":443"
    static let CM_serverPort = ":443"
    static let UE_serverPort = ":443"
    static let FS_serverPort = ":443"
    static let QS_serverPort = ":443"
    static let CT_serverPort = ":443"
    static let TD_serverPort = ":443"
    static let PWA_serverPort = ":443"
    static let TAXI_ROUTE_MATCH_SERVER_PORT = ":443"
    static let mqttClientIp = "events.getquickride.com"
    static let mqttClientPort : Int32 = 1883
    static let locMqttClientIp = "locevents.getquickride.com"
    static let locMqttClientPort : Int32 = 1883
#endif


    //APP_version

    static let APP_CURRENT_VERSION_NO = "8.72"
    static let APP_NAME = "Quick Ride"
    static let DEFAULT_COUNTRY_CODE = "IN"
    static let googleMapsKey = "AIzaSyDgTSOKLU_V0q6KZV6Fb7dMBWQ8M9jexc0"
    static let DEFAULT_PHONE_CODE = "+91"

    static let GOOGLE_ANALYTICS_ID = "UA-61361367-1";

    // In nanoseconds

    // In seconds
    static let waitTimeBeforeStartingPostSessionInitialization : Double = 3
    static let waitTimeBeforeClearingInitialMessagesInEventService : Double = 10*60
    static let maxTimeToWaitForEventServiceInitialization : Int64 = 60

    static let QuickRideLogCatBackUpSize = 1024*5 // 1MB

    static let GOOGLE_MAPS_LOCATION_LINK = "https://www.google.co.in/maps/place/"
    static let apiServerPath = "/dishaapiserver/rest/"
    static let routeServerPath = "/routematchserver/rest/"
    static let routeRepositoryServerPath = "/routerepositoryserver/rest/"
    static let userContactServerPath = "/usercontactserver/rest/"
    static let rideengineServerPath = "/rideengineserver/rest/"
    static let rideLocationServerPath = "/ridelocationserver/rest/"
    static let rideConnectivityServerPath = "/rideconnectivityserver/rest"
    static let communicationServerPath = "/communicationserver/rest/"
    static let userServiceUrl = apiServerPath + "QRUser?"
    static let userLoginUrl = apiServerPath + "QRUser/login?"
    static let USER_ACTIVE_SESSION_DETAILS_UPDATE_SERVICE_PATH = apiServerPath + "/QRUser/loginAndUpdate"
    static let userResetPasswordUrl = apiServerPath + "QRUser/password?"
    static let userReferalVerifyUrl = apiServerPath + "QRUser/checkReferralCode"
    static let userResendVerificationCode = apiServerPath + "QRUser/activationCode?"
    static let USER_INFO_GETTING_SERVICE_PATH = apiServerPath + "QRUser/userInfo"
    static let userCompleteProfile = apiServerPath + "QRUser/userCompleteProfile/new"
    static let vehicle = apiServerPath + "QRVehicle?"
    static let getUserFavoriteLocation = apiServerPath + "QRUserProfile/favouriteLocations?"
    static let getUserName = apiServerPath + "/QRUser/name"
    static let updateVehicle = apiServerPath + "QRVehicle/update"
    static let createVehicle = apiServerPath + "QRVehicle"
    static let createDeviceToken = apiServerPath + "QRUser/updateClientIosToken"
    static let USER_ID_GETTING_SERVICE_PATH = apiServerPath + "/QRUser/userId"
    static let USER_CONTACT_NO_SERVICE_PATH = apiServerPath + "/QRUser/contactno/new"
    static let USER_NAME_USING_CONTACT_NO_GETTING_SERVICE_PATH = apiServerPath + "/QRUser/contactno/name"
    static let vehicle_insurance_status_update_server_path = apiServerPath + "/QRVehicle/vehicleInsuranceOffer"
    static let financialServerPath = "/financialserver/rest"
    static let CREDIT_TRACK_SERVER_PATH = "/rest/credittrack"
    static let quickShareServerPath = "/productserver/rest"
    static let taxiDemandServerPath = "/taxidemandserver/rest"
    static let taxiRouteMatchServerPath = "/taxiroutematchserver/rest"
    static let taxiRideEngineServerPath = "/taxirideengineserver/rest"

    //Location update configuration
    static let ADVANCE_TIME_LOCATION_UPDATE_IN_MINUTES = 10
    static let MIN_DISTANCE_CHANGE_FOR_UPDATES_HIGH = 10//100
    static let MIN_DISTANCE_CHANGE_FOR_UPDATES_MEDIUM = 20//100
    static let MAX_SPEED_ALLOWED = 120 //KmPh
    static let OVER_SPEED_LIMIT = 80.0 //KmPh
    static let OVER_SPEED_LIMIT_MPS = 22.2222 //mps
    static let MIN_DISTANCE_CHANGE_FOR_SERVER_UPDATE_MEDIUM = 40//150
    static let MIN_DISTANCE_CHANGE_FOR_SERVER_UPDATE_HIGH = 30//150
    static let LOCATION_REFRESH_TIME_THRESHOLD_IN_SECS = 10.0

    //Create Ride Constants
    static var notificationCount:Int = 0
    static var notification:[UserNotification] = [UserNotification]()
    static var maximumNotifications = 50
    static var maximumEventStoreEntities = 50
    static var THRESHOLD_TIME_TO_STORE_EVENT_ENTITIES_IN_HOURS = 6

    // MARK:- Account
    static let userAccountDetails = financialServerPath + "/account"
    static let userAccountBalanceRecharge = financialServerPath + "/QRAccount/balance/recharge"
    static let userAccountEncash = financialServerPath + "/QRRedemption"
    static let userAccountTransfer = financialServerPath + "/QRInvoice/transfer"
    static let userAccountRechangeFailure = financialServerPath + "/QRAccount/balance/recharge/failure"
    static let userAccountTransactionDetails = financialServerPath + "/account/transactions"
    static let encashinformationgettingservicepath = financialServerPath + "/account/encash/information"
    static let userRefferalCode = apiServerPath + "QRUser/referralCode"
    static let encashablePoints = apiServerPath + "QRAccount/encash/allowedpoints"

    // MARK:-  Bill
    static let userPassengerBillGenerator = "QRInvoiceQuery/passenger"
    static let userRiderBillGenerator = "QRInvoiceQuery/rider/utc"
    static let RIDE_BILLING_DETAILS = "/QRRiderRide/rideBillingDetails"
    static let RIDER_RIDE_BILLING_DETAILS = "QRRiderRide/rideBillingDetails/all"

    // MARK:- System Feedback
    static let userSystemFeedback = apiServerPath + "feedback/system"
    static let saveUserFeedback = "QRFeedback"
    static let systemFeedback = "QRFeedback/system/utc"

    // MARK:- User Profile
    static let userProfile = "QRUserProfile/updateIncludingGender/new"
    static let userParticipantCompleteProfile = "QRUser/completeProfile"

    static let oldPassword = "old_pwd"
    static let newPassword = "new_pwd"
    static let phone = "phone"
    static let userId = "userId"
    static let password = "pwd"
    static let id = "id"
    static let referralCode = "referralCode"
    static let activationCode = "activationCode"
    static let imageId = "imageId"
    static let socialNetworkType = "socialNetworkType"
    static let socialNetworkId = "socialNetworkId"
    static let email = "email"
    static let clientUniqueDeviceId = "cleintuniquedeviceid"

    // MARK: Time Constants
    static let advancedTimeLocationUpdateInMinutes = 10 * 60
    static let advancedTimeActiveRide = 12

    //MARK: TaxiPOOL Cancel Policy Url
    static let taxipool_cancel_url = "https://quickride.in/taxipool_cp.php"
    static let local_taxi_cancel_url = "https://quickride.in/taxi_cp.php"
    static let outstation_taxi_cancel_url = "https://quickride.in/outstation_cp.php"


    //App Store URLS

    static let application_link_ios_url = "https://goo.gl/THj58b"
    static let application_link  = "https://itunes.apple.com/in/app/quick-ride/id1071794769?mt=8"
    static let application_link_android_url = "https://play.google.com/store/apps/details?id=com.disha.quickride&"
    static let facebook_page = "https://www.facebook.com/QuickRide.in"
    static let offers_url = "https://www.quickride.in/offers.php"
    static let subscription_url = "https://quickride.in/monthly-subscription.php"
    static let refer_once_offers_url = "https://quickride.in/offers/refer-once.php"
    static let support_email = "support@quickride.in"
    static let sales_email = "sales@quickride.in"
    static let admod_app_id = "ca-app-pub-6770064255988165~6407550351"
    static let interstial_ad_id = "ca-app-pub-6770064255988165/5030179061"
    static let quickride_url = "https://www.quickride.in"
    static let auto_confirm_link = "https://quickride.in/blog/new-feature-auto-confirm/"
    static let lazyPay_terms_url = "https://lazypay.in/tnc"
    static let simpl_terms_url = "https://www.getsimpl.com/terms-and-conditions/?source=app&utm_source=transaction"
    static let quick_ride_deck_for_org_refer = "https://quickride.in/offers/QuickRide-Deck.PDF"
    static let about_sodexo = "https://WWW.sodexobenefitsindia.com/users/multi-benefits-pass/"
    static let hpPay_terms_conditions = "https://www.hppay.in/program-details"
    static let cancellationPolicy_url = "https://quickride.in/ride_cp.php"


    static let MIN_ANDROID_APP_VERSION_REQUIRED_FOR_CONVERSATION_STATUS : Double = 3.0
    static let MIN_IOS_APP_VERSION_REQUIRED_FOR_CONVERSATION_STATUS : Double = 2.0

    static let MIN_ANDROID_APP_VERSION_REQUIRED_FOR_CONVERSATION_STATUS_USING_USER_STATIC_TOPIC : Double = 4.2
    static let MIN_IOS_APP_VERSION_REQUIRED_FOR_CONVERSATION_STATUS_USING_USER_STATIC_TOPIC : Double = 3.0
    static let TMW_REDIRECTION_URL = "https://themobilewallet.com/TMWPG/login"
    static let TMW_REDIRECTION_URL_STAGGING = "https://staging.themobilewallet.com/Restruct_TMWPG/login"
    static let TMW_RETAILER_ID="6310007780"

    //Google Login ClientID

    static let GOOGLE_CLIENT_ID = "535263540624-hnjhtces50evt7ae3pl6los5achgqe2p.apps.googleusercontent.com"

    //Adjust App Token

    static let ADJUST_APP_TOKEN = "acqv6qndmy9s"

    //TimeOutIntervalForAlamofire
    static let API_TIME_OUT_INTERVAL = 120.0

    //AWS identity pool Id
    static let AWS_IDENTITY_POOL_ID = "ap-south-1:7d8b37cd-9ce5-49f1-9242-26ea96bd2604"


}
