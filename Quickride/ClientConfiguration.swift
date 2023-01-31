//
//  ClientConfiguration.swift
//  Quickride
//
//  Created by KNM Rao on 10/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ClientConfigurtion :  Mappable {
    
    var carDefaultCapacity : Int = 3
    var carDefaultFare : Double = 3
    var bikeDefaultCapacity : Int? = 1
    var bikeDefaultFare : Double? = 3
    var newUserDefaultBonusPoints : Int = 50
    var referredUserBonusPoints : Int = 25
    var referralSourceBonusPoints : Int = 50
    var minimumEncashableAmount : Int = 100
    var minimumEncashableAmountForPayTm : Int = 100
    var minEncashableAmountForNonVerifiedUser : Int = 500
    var transferMaximumNumberOfPoints = 600
    var maxTransferTransactionsPerDay = 5
    var minRechargableAmount = 5
    var maxRechargableAmount = 3000
    var maxWalletAmountForVerifiedUser = 4000
    var maxWalletAmountForNonVerifiedUser = 800
    var maxRidePaymentPerPassenger = 1500
    var enableAmazonPayAsRecharge = false
    var enableAmazonPayAsEncash = false
    var amazonPayRedemptionBonusPercent = 0
    
    var clientConfiguartionVersion = 0
    var googleApiKey  = "AIzaSyAHEnttji21sClq8r4h9Mh0dIQSR-1QcNY"
    var vehicleMaxFare  = 7.0
    var maxTimeEmergency : Double  = 900000
    var timeDelayEmergency : Double = 60000
    var noOfAdvanceDaysForRegularRide = 2
    var rideMatchDefaultPercentageRider : Int = 10
    var rideMatchDefaultPercentagePassenger : Int = 50
    var freeRideValidityPeriod = 7
    var rideMatchMinPercentageRider : Int = 5
    var rideMatchMinPercentagePassenger : Int = 20
    var paytmServiceFee : Int = 2
    var minPointsForARide = 1
    
    var rideMatchMaxPercentageRider : Int = 100
    var rideMatchMaxPercentagePassenger : Int = 100
    var rideMatchMaxPercentForFindingMatches = 70
    
    var dontDisturbFromTime : String = "2200"
    var dontDisturbToTime : String = "0600"
    var customerSupportAllowFromTime : String = "9"
    var customerSupportAllowToTime : String = "18"
    
    var callQuickRideForSupport = "08039515455"
    var emailForSupport = AppConfiguration.support_email
    var minBalanceToDisplayLowBalanceNotification = 100.0
    var hatchBackCarDefaultCapacity = 3
    var sedanCarDefaultCapacity = 4
    var suvCarDefaultCapacity = 6
    var premiumCarDefaultCapacity = 3
    
    let VEHICLE_DEFAULT_CAPACITY : Int = 4
    let VEHICLE_DEFAULT_FARE : Double = 3.5
    let VEHICLE_MAX_FARE : Double = 7
    let BIKE_DEFAULT_CAPACITY : Int = 1
    let BIKE_DEFAULT_FARE : Double = 3
    let NEW_USER_DEFAULT_BONUS_POINTS : Int = 50
    let REFERRED_USER_BONUS_POINTS : Int = 50
    let REFERRAL_SOURCE_BONUS_POINTS : Int = 50
    let MIN_PERCENT_FOR_REQUESTING_FARE_CHANGE=50
    let MIN_FARE_FOR_REQUESTING_FARE_CHANGE=2
    let MINIMUM_ENCASHABLE_AMOUNT : Int = 300
    let GOOGLE_API_KEY = "AIzaSyAHEnttji21sClq8r4h9Mh0dIQSR-1QcNY"
    let MAX_TIME_EMERGENCY = 900000
    let TIME_DELAY_EMERGENCY = 60000
    let MIN_BALANCE_IN_ACCOUNT = 100.0
    let MAX_MIN_FARE_FOR_RIDE = 20
    let MIN_MIN_FARE_FOR_RIDE = 0
    
    var dishaServiceFeesPercentageForTransfer = 7
    var groupMatchingThreshold : Double = 5.0
    var maxRedemptionsForMonth : Int = 5
    var minRedemablePointsForFirstTimeForFuelCard = 500
    var rideCreationRadiusForGRide = 4
    var originForGRide  = LatLng(lat: 8.557443,long: 76.881481)
    var originsForGRide  = [Location]()
    var gRideNewCompanies  = [String]()
    var taxiLocations = [LocationLatLong]()
    var instantTaxiEnabledLocations = [InstantTaxiEnabledLocation]()
    var minMatchingPercentForBestMatchToRetrieveRelayRides = 0
    
    var minPercentToRequestForFareChange  = 0
    var minFareToRequestForFareChange : Float = 0
    var bonusPointsForRiderOnFirstRideCompletion = 25
    var rideMatchTimeDefaultInMins = 45
    var offersUrl : String?
    var verificationSupportMail : String = "verificationsupport@quickride.in"
    var minFareToConsiderFareChangeAlways = 200.0
    var thresholdDaysForRidePartnersExpiry = 7
    var gstNo : String?
    var companyName : String?
    var longDistanceForUser = 100
    var maxMinFareForRide = 30
    var defaultMinFareForRide = 20
    var rechargeServiceFee : Float = 0
    var tmwSupportEmail = "cs@tmwpay.com"
    var tmwSupportPhone = "+917507375073"
    var googleServerKeyBackUp = "AIzaSyAHEnttji21sClq8r4h9Mh0dIQSR-1QcNY"
    var firstRideBonusPoints = 20.0
    var enableFirstRideBonusPointsOffer = true
    var verificationCancelledInitiatedDate: Double = 0
    var enableToGetInactiveMatches = false
    var thresoldMatchesToGetInactiveMatches = 4
    var disableImageVerification = false 
    var enableVehicleInsurance = true
    var illegalChatMessages = [String]()
    var autoConfirmDefaultValue = RidePreferences.AUTO_CONFIRM_VERIFIED
    var autoConfirmDefaultRideMatchTimeThreshold = 15
    var autoConfirmDefaultRideMatchPercentageAsRider = 50
    var autoConfirmDefaultRideMatchPercentageAsPassenger = 90
    var autoConfirmTypeDefaultValue = RidePreferences.AUTO_CONFIRM_FOR_RIDES_TYPE_BOTH
    var disableSendSMSForCompanyCode = false
    var discountBelowTenKm : Double = 0
    var discountBelowTwentyKm : Double = 10
    var discountBelowThirtyKm : Double = 20
    var discountBelowFiftyKm : Double = 30
    var discountBelowHundredKm : Double = 35
    var discountBelowThreeHundredKm : Double = 70
    var discountBelowFiveHundredKm : Double = 75
    var discountAboveFiveHundredKm : Double = 80
    var higherThresoldBalance = 8000
    var userRideEtiquetteMediaList : [UserRideEtiquetteMedia]?
    var percentCommissionForReferredUser = 2
    var maximumOrganizationReferralPoints = 3000
    var maximumCommunityReferralPoints = 500
    var totalNoOfRiderRideSharedToShowOnTimeCompliance = 5
    var maxPercentageMovingRewardsToEarnedPoints = 20
    var trustedLevelConfiguredCompanies : [String]?
    var availablePetrolCards : [String]?
    var helmetMandatoryForRegion = true
    var etiquetteList = [RideEtiquette]()
    var blogList = [Blog]()
    var availableRechargeOptions : [String]?
    var availableRedemptionOptions : [String]?
    var availableWalletOptions = [String]()
    var availablePayLaterOptions = [String]()
    var availableUpiOptions = [String]()
    var availableRedemptionWalletOptions = [String]()
    var linkedWalletOffers = [LinkWalletOptionsOffer]()
    var referAndEarnTermsAndConditionsFileURL = "https://storage.googleapis.com/imgqr/ReferAndRewardsTermsAndConditionsTest.json"
    var vehicleInsuranceList = [VehicleInsurance]()
    var isRideInsuranceOptionVisible = true
    var publicEmailIds = ["office","service","account","business","technical","finance","bank","revenue","marketing","advisor","admin","info","project","operation","movement","solution","mail","merchant","reply","purchase","support","sales","design","contact","director","manager","team","inquiry","hr","care","crm","mis","sale"]
    var greetingDetailsFileURl = "https://qr-images.s3.ap-south-1.amazonaws.com/GreetingDetails.json"
    var minNoOfRidesReqNotToShowJoiningUnverifiedDialog = 20
    var adhaarEnabledForRegion: Bool?
    var mqttDataForApp: MqttDataForApp?
    var mandatoryDateOfBirthStatesForDlVerification = [String]()
    var showCovid19SelfAssessment = false
    var subscriptionMandatory = false
    var subscriptionAmount = 100
    var defaultEmergencyContactList : [String]?
    var thresholdTimeForLocationUpdateEventServerMillis = 90000
    var thresholdPointsToRestrictOTP = 150
    var thresholdNoOfRidesForUnVerifiedNewRiderToRestrictOTP = 10
    var minDistanceForInterCityRide = 75.0
    var taxiSupportMobileNumber = ""
    var taxiSupportEmail = ""
    var taxiPickUpTimeRangeInMins = 30
    var taxiPoolGSTPercentage = 5.0
    var taxiPoolInstantBookingThresholdTimeInMins = 30
    var ivrEnabledDefault = true
    var quickJobsUrl = "https://pwa.quickjobs.works/#/index"
    var autoVerificationMail = ""
    var hyperVergeReadKyc = "https://ind-docs.hyperverge.co/v2.0/readKYC"
    var hyperVergeFaceIDMatch = "https://ind-faceid.hyperverge.co/v1/photo/verifyPair"
    var hyperVergeReadDL = "https://ind-dl-staging.hyperverge.co/v2.0/readDL"
    var hyperVergeAppId = "8f0df4"
    var hyperVergeAppKey = "fe9f5212fce3189d961b"
    var accountTransactionsDisplayStartDate: String?
    var serviceFeeForBankTransfer = 2
    var displayRegularRideResumeDialogForSuspendedRides = false
    var taxiRideEtiquetteList = [TaxiRideEtiquette]()
    var rideEtiquettesVideos = [RideEtiquetteVideoItem]()
    var quickRideSupportNumberForTaxi = ""
    var quickRideSupportNumberForCarpool = ""
    var maximumWalkDistanceForFullMatch: Int?
    
    //MARK: OUTSTATION
    var enableOutStationTaxi : Bool? = true
    var outStationInstantBookingThresholdTimeInMins = 180
    var outStationTaxiAdvancePaymentPercentage: Int = 20
    var enableOutStationTaxiFullPayment = false
    //MARK: Driver
    var driverAdvanceBookingAmount = 99
    var driverInstantBookingThresholdTimeInMins = 90
    var showCarpoolersForTaxiRide = false
    var minMatchingPercentForTaxiRidesToRetrieveCarpoolRiders = 95
    
    //MARK: CallCredits Configuration
    var maximumChargePerCall: Int = 2
    var maximumCreditsRequiredPerCall: Int = 2
    var rideEtqtCertificationUrl: String?
    
    static let CLIENT_CONFIG_VERSION = "client_configuration_version"
    static let APP_VERSION = "app_version_name"
    static let IOS_APP_VERSION_NAME = "iosAppVersionName"
    static let EVENT_BROKER_TYPE_RMQ = "RMQ"
    static let EVENT_BROKER_TYPE_IOT = "IOT"
    
    
    init(){
        self.carDefaultCapacity = VEHICLE_DEFAULT_CAPACITY;
        self.carDefaultFare = VEHICLE_DEFAULT_FARE
        self.bikeDefaultCapacity = BIKE_DEFAULT_CAPACITY
        self.bikeDefaultFare = BIKE_DEFAULT_FARE
        self.newUserDefaultBonusPoints = NEW_USER_DEFAULT_BONUS_POINTS
        self.referredUserBonusPoints = REFERRED_USER_BONUS_POINTS
        self.referralSourceBonusPoints = REFERRAL_SOURCE_BONUS_POINTS
        self.minimumEncashableAmount = MINIMUM_ENCASHABLE_AMOUNT
        self.maxTimeEmergency = Double(MAX_TIME_EMERGENCY)
        self.timeDelayEmergency = Double(TIME_DELAY_EMERGENCY)
        self.vehicleMaxFare = VEHICLE_MAX_FARE
        self.minPercentToRequestForFareChange  = MIN_PERCENT_FOR_REQUESTING_FARE_CHANGE
        self.minFareToRequestForFareChange  = Float(MIN_FARE_FOR_REQUESTING_FARE_CHANGE)
        self.minBalanceToDisplayLowBalanceNotification = MIN_BALANCE_IN_ACCOUNT
    }
    
    required  init?(map: Map) {

    }
    
    func mapping(map: Map) {
        self.carDefaultCapacity <- map["carDefaultCapacity"]
        self.carDefaultFare <- map["carDefaultFare"]
        self.bikeDefaultCapacity <- map["bikeDefaultCapacity"]
        self.bikeDefaultFare <- map["bikeDefaultFare"]
        self.newUserDefaultBonusPoints <- map["newUserDefaultBonusPoints"]
        self.referredUserBonusPoints <- map["referredUserBonusPoints"]
        self.referralSourceBonusPoints <- map["referralSourceBonusPoints"]
        self.minimumEncashableAmount <- map["minimumEncashableAmount"]
        self.minimumEncashableAmountForPayTm <- map["minimumEncashableAmountForPayTm"]
        self.clientConfiguartionVersion <- map["clientConfiguartionVersion"]
        self.googleApiKey <- map["googleApiKey"]
        self.vehicleMaxFare <- map["vehiclMaxFare"]
        self.dishaServiceFeesPercentageForTransfer <- map["dishaServiceFeesPercentageForTransfer"]
        self.maxTimeEmergency <- map["maxTimeEmergency"]
        self.timeDelayEmergency <- map["timeDelayEmergency"]
        self.callQuickRideForSupport <- map["callQuickRideForSupport"]
        self.emailForSupport <- map["emailForSupport"]
        self.rideMatchDefaultPercentageRider <- map["rideMatchDefaultPercentageRider"]
        self.rideMatchDefaultPercentagePassenger <- map["rideMatchDefaultPercentagePassenger"]
        self.rideMatchMinPercentageRider <- map["rideMatchMinPercentageRider"]
        self.rideMatchMinPercentagePassenger <- map["rideMatchMinPercentagePassenger"]
        self.rideMatchMaxPercentageRider <- map["rideMatchMaxPercentageRider"]
        self.rideMatchMaxPercentagePassenger <- map["rideMatchMaxPercenatgePassenger"]
        self.noOfAdvanceDaysForRegularRide <- map["noOfAdvanceDaysForRegularRide"]
        self.dontDisturbFromTime <- map["dontDisturbFromTime"]
        self.dontDisturbToTime <- map["dontDisturbToTime"]
        self.transferMaximumNumberOfPoints <- map["transferMaximumNumberOfPoints"]
        self.freeRideValidityPeriod <- map["freeRideValidityPeriod"]
        self.groupMatchingThreshold <- map["groupMatchingThreshold"]
        self.rideMatchMaxPercentForFindingMatches <- map["rideMatchMaxPercentForFindingMatches"]
        self.paytmServiceFee <- map["paytmServiceFee"]
        self.maxTransferTransactionsPerDay <- map["maxTransferTransactionsPerDay"]
        self.maxRedemptionsForMonth <- map["maxRedemptionsForMonth"]
        self.minRedemablePointsForFirstTimeForFuelCard <- map["minRedemablePointsForFirstTimeForFuelCard"]
        self.rideCreationRadiusForGRide <- map["rideCreationRadiusForGRide"]
        self.originForGRide <- map["originForGRide"]
        self.originsForGRide <- map["originsForGRide"]
        self.minPercentToRequestForFareChange <- map["minPercentToRequestForFareChange"]
        self.minFareToRequestForFareChange <- map["minFareToRequestForFareChange"]
        self.bonusPointsForRiderOnFirstRideCompletion <- map["bonusPointsForRiderOnFirstRideCompletion"]
        self.gRideNewCompanies <- map["grideNewCompanies"]
        self.rideMatchTimeDefaultInMins <- map["rideMatchTimeDefaultInMins"]
        self.offersUrl <- map["offersUrl"]
        self.verificationSupportMail <- map["verificationSupportMail"]
        self.minFareToConsiderFareChangeAlways <- map["minFareToConsiderFareChangeAlways"]
        self.customerSupportAllowFromTime <- map["customerSupportAllowFromTimeForIos"]
        self.customerSupportAllowToTime <- map["customerSupportAllowToTimeForIos"]
        self.gstNo <- map["gstNo"]
        self.companyName <- map["companyName"]
        self.minBalanceToDisplayLowBalanceNotification <- map["minBalanceToDisplayLowBalanceNotification"]
        self.thresholdDaysForRidePartnersExpiry <- map["thresholdDaysForRidePartnersExpiry"]
        self.longDistanceForUser <- map["longDistanceForUser"]
        self.minPointsForARide <- map["minPointsForARide"]
        self.maxMinFareForRide <- map["maxMinFareForRide"]
        self.defaultMinFareForRide <- map["defaultMinFareForRide"]
        self.rechargeServiceFee <- map["rechargeServiceFee"]
        self.tmwSupportEmail <- map["tmwSupportEmail"]
        self.tmwSupportPhone <- map["tmwSupportPhone"]
        self.googleServerKeyBackUp <- map["googleServerKeyBackUp"]
        self.minEncashableAmountForNonVerifiedUser <- map["minEncashableAmountForNonVerifiedUser"]
        self.firstRideBonusPoints <- map["firstRideBonusPoints"]
        self.enableFirstRideBonusPointsOffer <- map["enableFirstRideBonusPointsOffer"]
        self.verificationCancelledInitiatedDate <- map["verificationCancellationDateForNoImageProfiles"]
        self.enableToGetInactiveMatches <- map["enableToGetInactiveMatches"]
        self.thresoldMatchesToGetInactiveMatches <- map["thresoldMatchesToGetInactiveMatches"]
        self.minRechargableAmount <- map["minRechargableAmount"]
        self.maxRechargableAmount <- map["maxRechargableAmount"]
        self.maxWalletAmountForVerifiedUser <- map["maxRechargableAmountForVerifiedUser"]
        self.maxWalletAmountForNonVerifiedUser <- map["maxRechargableAmountForNonVerifiedUser"]
        self.disableImageVerification <- map["disableImageVerification"]
        self.illegalChatMessages <- map["illegalChatMessages"]
        self.autoConfirmDefaultValue <- map["autoConfirmRides"]
        self.autoConfirmDefaultRideMatchTimeThreshold <- map["autoConfirmRidesTimeThreshold"]
        self.autoConfirmDefaultRideMatchPercentageAsRider <- map["autoConfirmRideMatchPercentageAsRider"]
        self.autoConfirmDefaultRideMatchPercentageAsPassenger <- map["autoConfirmRideMatchPercentageAsPassenger"]
        self.autoConfirmTypeDefaultValue <- map["autoConfirmRidesType"]
        self.hatchBackCarDefaultCapacity <- map["hatchBackCarDefaultCapacity"]
        self.disableSendSMSForCompanyCode <- map["disableSendSMSForCompanyCode"]
        self.discountBelowTenKm <- map["discountBelowTenKm"]
        self.discountBelowTwentyKm <- map["discountBelowTwentyKm"]
        self.discountBelowThirtyKm <- map["discountBelowThirtyKm"]
        self.discountBelowFiftyKm <- map["discountBelowFiftyKm"]
        self.discountBelowHundredKm <- map["discountBelowHundredKm"]
        self.discountBelowThreeHundredKm <- map["discountBelowThreeHundredKm"]
        self.discountBelowFiveHundredKm <- map["discountBelowFiveHundredKm"]
        self.discountAboveFiveHundredKm <- map["discountAboveFiveHundredKm"]
        self.higherThresoldBalance <- map["higherThresoldBalance"]
        self.maxRidePaymentPerPassenger <- map["maxRidePaymentPerPassenger"]
        self.sedanCarDefaultCapacity <- map["sedanCarDefaultCapacity"]
        self.suvCarDefaultCapacity <- map["suvCarDefaultCapacity"]
        self.premiumCarDefaultCapacity <- map["premiumCarDefaultCapacity"]
        self.userRideEtiquetteMediaList <- map["userRideEtiquetteMediaList"]
        self.enableAmazonPayAsRecharge <- map["enableAmazonPayAsRecharge"]
        self.enableAmazonPayAsEncash <- map["enableAmazonPayAsEncash"]
        self.amazonPayRedemptionBonusPercent <- map["amazonPayRedemptionBonusPercent"]
        self.percentCommissionForReferredUser <- map["percentCommissionForReferredUser"]
        self.maximumOrganizationReferralPoints <- map["maximumOrganizationReferralPoints"]
        self.maximumCommunityReferralPoints <- map["maximumCommunityReferralPoints"]
        self.totalNoOfRiderRideSharedToShowOnTimeCompliance <- map["totalNoOfRiderRideSharedToShowOnTimeCompliance"]
        self.maxPercentageMovingRewardsToEarnedPoints <- map["maxPercentageMovingRewardsToEarnedPoints"]
        self.isRideInsuranceOptionVisible <- map["isRideInsuranceOptionVisible"]
        availablePetrolCards <- map["availablePetrolCards"]
        trustedLevelConfiguredCompanies <- map["trustedLevelConfiguredCompanies"]
        helmetMandatoryForRegion <- map["helmetMandatoryForRegion"]
        etiquetteList <- map["etiquetteList"]
        blogList <- map["blogList"]
        availableRechargeOptions <- map["availableRechargeOptions"]
        availableRedemptionOptions <- map["availableRedemptionOptions"]
        availableWalletOptions <- map["availableWalletOptions"]
        availableRedemptionWalletOptions <- map["availableRedemptionWalletOptions"]
        linkedWalletOffers <- map["linkedWalletOffers"]
        availablePayLaterOptions <- map["availablePayLaterOptions"]
        availableUpiOptions <- map["availableUpiOptions"]
        referAndEarnTermsAndConditionsFileURL <- map["referAndEarnTermsAndConditionsFileURL"]
        vehicleInsuranceList <- map["vehicleInsuranceCompanies"]
        publicEmailIds <- map["publicEmailIds"]
        minNoOfRidesReqNotToShowJoiningUnverifiedDialog <- map["minNoOfRidesReqNotToShowJoiningUnverifiedDialog"]
        greetingDetailsFileURl <- map["greetingDetailsURL"]
        adhaarEnabledForRegion <- map["adhaarEnabledForRegion"]
        mqttDataForApp <- map["mqttDataForApp"]
        mandatoryDateOfBirthStatesForDlVerification <- map["mandatoryDateOfBirthStatesForDlVerification"]
        showCovid19SelfAssessment <- map["showCovid19SelfAssessment"]
        subscriptionMandatory <- map["subscriptionMandatory"]
        subscriptionAmount <- map["subscriptionAmount"]
        defaultEmergencyContactList <- map["defEmergencyContactList"]
        thresholdTimeForLocationUpdateEventServerMillis <- map["thresholdTimeForLocationUpdateEventServerMillis"]
        thresholdPointsToRestrictOTP <- map["thresholdPointsToRestrictOTP"]
        thresholdNoOfRidesForUnVerifiedNewRiderToRestrictOTP <- map["thresholdNoOfRidesForUnVerifiedNewRiderToRestrictOTP"]
        minDistanceForInterCityRide <- map["minDistanceForInterCityRide"]
        self.taxiSupportMobileNumber <- map["taxiSupportMobileNumber"]
        self.taxiSupportEmail <- map["taxiSupportEmail"]
        self.taxiPickUpTimeRangeInMins <- map["taxiPickUpTimeRangeInMins"]
        self.taxiPoolGSTPercentage <- map["taxiPoolGSTPercentage"]
        ivrEnabledDefault <- map["ivrEnabledDefault"]
        self.quickJobsUrl <- map["quickJobsUrl"]
        self.minMatchingPercentForBestMatchToRetrieveRelayRides <- map["minMatchingPercentForBestMatchToRetrieveRelayRides"]
        self.autoVerificationMail <- map["autoVerificationMail"]
        self.hyperVergeReadKyc <- map["hyperVergeReadKyc"]
        self.hyperVergeFaceIDMatch <- map["hyperVergeFaceIDMatch"]
        self.hyperVergeReadDL <- map["hyperVergeReadDL"]
        self.hyperVergeAppId <- map["hyperVergeAppId"]
        self.hyperVergeAppKey <- map["hyperVergeAppKey"]
        self.taxiLocations <- map["taxiLocations"]
        self.taxiPoolInstantBookingThresholdTimeInMins <- map["taxiPoolInstantBookingThresholdTimeInMins"]
        self.enableOutStationTaxi <- map["enableOutStationTaxi"]
        self.outStationInstantBookingThresholdTimeInMins <- map["outStationInstantBookingThresholdTimeInMins"]
        self.outStationTaxiAdvancePaymentPercentage <- map["outStationTaxiAdvancePaymentPercentage"]
        self.driverAdvanceBookingAmount <- map["driverAdvanceBookingAmount"]
        self.driverInstantBookingThresholdTimeInMins <- map["driverInstantBookingThresholdTimeInMins"]
        accountTransactionsDisplayStartDate <- map["accountTransactionsDisplayStartDate"]
        serviceFeeForBankTransfer <- map["serviceFeeForBankTransfer"]
        displayRegularRideResumeDialogForSuspendedRides <- map["displayRegularRideResumeDialogForSuspendedRides"]
        instantTaxiEnabledLocations <- map["instantTaxiEnabledLocations"]
        enableOutStationTaxiFullPayment <- map["enableOutStationTaxiFullPayment"]
        taxiRideEtiquetteList <- map["taxiRideEtiquetteList"]
        rideEtiquettesVideos <- map["rideEtiquettesVideos"]
        self.quickRideSupportNumberForTaxi <- map["quickRideSupportNumberForTaxi"]
        self.quickRideSupportNumberForCarpool <- map["quickRideSupportNumberForCarpool"]
        showCarpoolersForTaxiRide <- map["showCarpoolersForTaxiRide"]
        minMatchingPercentForTaxiRidesToRetrieveCarpoolRiders <- map["minMatchingPercentForTaxiRidesToRetrieveCarpoolRiders"]
        maximumChargePerCall <- map["maximunChargePerCall"]
        maximumCreditsRequiredPerCall <- map["maximumCreditsRequiredPerCall"]
        rideEtqtCertificationUrl <- map["rideEtqtCertificationUrl"]
        maximumWalkDistanceForFullMatch <- map["maximumWalkDistanceForFullMatch"]
    }
    
    func getRideEtiquetteBasedOnRoleAndRating(role: String, rating: String)-> [RideEtiquette]{
        var rideEtiquettesBasedOnRoleAndRating = [RideEtiquette]()
        for rideEtiquette in self.etiquetteList{
            let ratings = rideEtiquette.ratings?.components(separatedBy: ",")
            for i in 0 ..< ratings!.count{
                if ratings![i] == rating && (role == rideEtiquette.role || rideEtiquette.role == RideEtiquette.ROLE_BOTH){
                    rideEtiquettesBasedOnRoleAndRating.append(rideEtiquette)
                }
            }
        }
        return rideEtiquettesBasedOnRoleAndRating
    }
    
    func updateAndReturnLatestBlog(blogsFromServer: [Blog]) -> [Blog]{
        var oldBlogLastUpdateTimeDict = [Int : Double]()
        for oldBlog in self.blogList{
            oldBlogLastUpdateTimeDict[oldBlog.id] = oldBlog.lastDisplayedTime
        }
        for newBlog in blogsFromServer{
            newBlog.lastDisplayedTime = oldBlogLastUpdateTimeDict[newBlog.id]
        }
        return blogsFromServer
    }
    
    func updateLastDisplayedTimeOfBlogInSharedPreference(time: Double, blogId: Int){
        let appStartUpData = SharedPreferenceHelper.getAppStartUpData()
        let blogList = appStartUpData?.clientConfiguration?.blogList
        if appStartUpData != nil && blogList != nil{
            for blog in blogList!{
                if blog.id == blogId{
                    blog.lastDisplayedTime = time
                    self.blogList = blogList!
                    SharedPreferenceHelper.storeAppStartUpData(appStartUpData: appStartUpData)
                }
            }
        }
    }
}
