//
//  HomeRideButtomViewModel.swift
//  Quickride
//
//  Created by Ashutos on 03/02/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation

enum HomePageCard {
    case LocationSelection
    case UpcomingRides
    case FrequentRides
    case JobPromotion
    case HomeAndOfficeLocation
    case Profile
    case RideContribution
    case MyReferral
    case Blog
    case CreateRecurringRide
    case HomeNeedHelp
    case SocialMedia
    case QuickRideJourney
    case Offer
    case AddPayment
    case AutoMatch
    case Taxi
}
protocol HomeRideButtomViewModelDelegate {
    func receiveActiveRide()
    func receiveErrorForMyRides(responseError: ResponseError?, responseObject: NSDictionary?,error : NSError?)
    func ecoMeterData()
    func referralStats()
    func receivedJobPromotionAdsData()
}

class HomeRideButtomViewModel {
    
    var rideModelDelegate: HomeRideButtomViewModelDelegate?
    var rideSharingCommunityContribution : RideSharingCommunityContribution?
    var frequentRides = [Ride]()
    var ride = Ride()
    var currentLocation: Location?
    var rideType = Ride.PASSENGER_RIDE
    var isRecurringRideRequiredFrom: String?
    var referralStats: ReferralStats?
    var userStatistics = [UserStatistic]()
    var jobPromotionData = [JobPromotionData]()
    var offerListDict = [String: [Offer]]()

    var indexForOffer = 0
    var homePageCardAndOffers = [HomePageCard]()
    var detailEstimatedFare : DetailedEstimateFare?
    var isRequiredToGetLocationInfoForLatLng = false
    
    init() {
        
    }
    
    init(rideModelDelegate : HomeRideButtomViewModelDelegate){
        ride.rideType = UserDataCache.getInstance()?.getUserRecentRideType()
        self.rideModelDelegate = rideModelDelegate
        frequentRides = getMostFrequentRidesFromUserLocation()
        getRideSharingCommunityContribution()
        rideType = UserDataCache.getInstance()?.getUserRecentRideType() ?? Ride.PASSENGER_RIDE
    }

    
    func getHomeOrOfficeNumberOfCells() -> Int {
        guard let userDataCache = UserDataCache.sharedInstance,let userProfile = userDataCache.getLoggedInUserProfile() else {
            return 0
        }
        if (userProfile.numberOfRidesAsRider + userProfile.numberOfRidesAsPassenger) > 5 {
            return 0
        }
        if userDataCache.getHomeLocation() != nil && userDataCache.getOfficeLocation() != nil {
            return 0
        }
        return 1
    }
    
    func getNumberOfCellsForUpComingRides () -> Int{
        if MyActiveRidesCache.singleCacheInstance?.getNextRecentRideOfUser() != nil{
            return 1
        }else{
            return 0
        }
    }
    
    func getActiveRidesCount() -> Int {
        var activeRidesCount = 0
        if let riderRides = MyActiveRidesCache.getRidesCacheInstance()?.getActiveRiderRides() {
            activeRidesCount = riderRides.count
        }
        if let passengerRides = MyActiveRidesCache.getRidesCacheInstance()?.getActivePassengerRides() {
            activeRidesCount += passengerRides.count
        }
        return activeRidesCount
    }
    
    func getNumberOfCellForFrequentRides() -> Int {
        if frequentRides.count > 3 {
            return 3
        }else{
            return frequentRides.count
        }
    }
    
    func getNumberOfCellForUserStatistics() -> Int {
        if userStatistics.count > 0 {
            return userStatistics.count
        }
        return 0
    }
    
    func updateCurrentLocation(currentLocation : Location){
        self.currentLocation = currentLocation
        UserDataCache.getInstance()?.userCurrentLocation = currentLocation
        AppDelegate.getAppDelegate().log.debug("Current Location" + String(currentLocation.latitude) + "," + String(currentLocation.longitude))
        self.ride.startAddress = currentLocation.completeAddress!
        self.ride.startLatitude = currentLocation.latitude
        self.ride.startLongitude = currentLocation.longitude
        self.frequentRides = getMostFrequentRidesFromUserLocation()
    }
    
    func getMostFrequentRidesFromUserLocation() -> [Ride]{
        var frequentRides = [Ride]()
        guard let userDataCache = UserDataCache.sharedInstance else{
            return frequentRides
        }
        var homeCLLocation, officeCLLocation : CLLocation?  
        let homeLocation = userDataCache.getHomeLocation()
        if homeLocation != nil {
            homeCLLocation = CLLocation(latitude: homeLocation!.latitude!, longitude: homeLocation!.longitude!)
        }
        let officeLocation = userDataCache.getOfficeLocation()
        if officeLocation != nil {
            officeCLLocation = CLLocation(latitude: officeLocation!.latitude!, longitude: officeLocation!.longitude!)
        }
        var  allClosedRides = [Ride]()
        for ride in MyClosedRidesCache.getClosedRidesCacheInstance().closedRiderRides! {
            allClosedRides.append(ride.1)
        }
        for ride in MyClosedRidesCache.getClosedRidesCacheInstance().closedPassengerRides! {
            allClosedRides.append(ride.1)
        }
        if allClosedRides.isEmpty {
            return frequentRides
        }
        allClosedRides.sort(by: { $0.startTime > $1.startTime})
        let uniqueFrequentRidesForHomeOfficeLocatios = getUniqueFrequentHomeOfficeRides(homeCLLocation: homeCLLocation, officeCLLocation: officeCLLocation, allClosedRides: allClosedRides)
        var uniqueFrequentRidesOtherHomeOfficeLocatios = getUniqueFrequentRidesOtherThanHomeOffice(frequentRides: uniqueFrequentRidesForHomeOfficeLocatios, allClosedRides: allClosedRides)
        uniqueFrequentRidesOtherHomeOfficeLocatios.sort(by: { $0.startTime > $1.startTime})
        if currentLocation != nil && !uniqueFrequentRidesForHomeOfficeLocatios.isEmpty {
            let currentCLLocation = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            if homeCLLocation != nil && currentCLLocation.distance(from: homeCLLocation!) <= 1000.0 {
                frequentRides.append(contentsOf: uniqueFrequentRidesForHomeOfficeLocatios)
                if !uniqueFrequentRidesOtherHomeOfficeLocatios.isEmpty {
                    frequentRides.append(contentsOf: uniqueFrequentRidesOtherHomeOfficeLocatios)
                }
            } else if officeCLLocation != nil && currentCLLocation.distance(from: officeCLLocation!) <= 1000.0 {
                frequentRides.append(contentsOf: uniqueFrequentRidesForHomeOfficeLocatios)
                if !uniqueFrequentRidesOtherHomeOfficeLocatios.isEmpty {
                    frequentRides.append(contentsOf: uniqueFrequentRidesOtherHomeOfficeLocatios)
                }
            } else {
                if !uniqueFrequentRidesOtherHomeOfficeLocatios.isEmpty {
                    frequentRides.append(contentsOf: uniqueFrequentRidesOtherHomeOfficeLocatios)
                }
                if !uniqueFrequentRidesForHomeOfficeLocatios.isEmpty {
                    frequentRides.append(contentsOf: uniqueFrequentRidesForHomeOfficeLocatios)
                }
                frequentRides.sort(by: { $0.startTime > $1.startTime})
            }
        } else {
            if !uniqueFrequentRidesOtherHomeOfficeLocatios.isEmpty {
                frequentRides.append(contentsOf: uniqueFrequentRidesOtherHomeOfficeLocatios)
            }
            if !uniqueFrequentRidesForHomeOfficeLocatios.isEmpty {
                frequentRides.append(contentsOf: uniqueFrequentRidesForHomeOfficeLocatios)
            }
            frequentRides.sort(by: { $0.startTime > $1.startTime})
        }
        
        return frequentRides;
    }
    private func getUniqueFrequentHomeOfficeRides( homeCLLocation : CLLocation?,  officeCLLocation : CLLocation?, allClosedRides : [Ride]) -> [Ride]{
        var frequentRides = [Ride]()
        var recentHomeLocationRide , recentOfficeLocationRide, recentHomeOfficeLocationRide , recentOfficeHomeLocationRide : Ride?
        
        for ride in allClosedRides {
            if ride.rideId == 73748761{
                print("Found")
            }
            let rideStartCLLocation = CLLocation(latitude: ride.startLatitude, longitude: ride.startLongitude)
            let rideEndCLLocation = CLLocation(latitude: ride.endLatitude!, longitude: ride.endLongitude!)
            if homeCLLocation != nil && (recentHomeLocationRide == nil || recentHomeLocationRide!.startTime < ride.startTime) && homeCLLocation!.distance(from: rideStartCLLocation) <= 1000.0 {
                recentHomeLocationRide = ride
            }
            if officeCLLocation != nil && (recentOfficeLocationRide == nil || recentOfficeLocationRide!.startTime < ride.startTime) &&
                officeCLLocation!.distance(from: rideStartCLLocation) <= 1000.0 {
                recentOfficeLocationRide = ride;
            }
            if homeCLLocation != nil && officeCLLocation != nil {
                if (recentHomeOfficeLocationRide == nil || recentHomeOfficeLocationRide!.startTime < ride.startTime) && homeCLLocation!.distance(from: rideStartCLLocation) <= 1000.0 &&
                    officeCLLocation!.distance(from: rideEndCLLocation) <= 1000.0 {
                    recentHomeOfficeLocationRide = ride
                }
                if recentOfficeHomeLocationRide == nil && officeCLLocation!.distance(from: rideStartCLLocation) <= 1000.0 &&
                    homeCLLocation!.distance(from: rideEndCLLocation) <= 1000.0 {
                    recentOfficeHomeLocationRide = ride
                }
            }
            
        }
        if recentHomeOfficeLocationRide != nil {
            if recentHomeLocationRide != nil && DateUtils.getDifferenceBetweenTwoDatesInDays(time1: recentHomeOfficeLocationRide?.startTime, time2: recentHomeLocationRide?.startTime) > 5 {
                frequentRides.append(recentHomeLocationRide!)
            } else {
                frequentRides.append(recentHomeOfficeLocationRide!)
            }
        } else if recentHomeLocationRide != nil {
            frequentRides.append(recentHomeLocationRide!)
        }
        if recentOfficeHomeLocationRide != nil {
            if recentOfficeLocationRide != nil && DateUtils.getDifferenceBetweenTwoDatesInDays(time1: recentOfficeHomeLocationRide?.startTime,time2: recentOfficeLocationRide?.startTime) > 5 {
                frequentRides.append(recentOfficeLocationRide!)
            } else {
                frequentRides.append(recentOfficeHomeLocationRide!)
            }
        } else if recentOfficeLocationRide != nil {
            frequentRides.append(recentOfficeLocationRide!)
        }
        return frequentRides
    }
    private func getUniqueFrequentRidesOtherThanHomeOffice(frequentRides : [Ride], allClosedRides : [Ride]) -> [Ride]{
        var frequentRidesOtherThanHomeOffice = [Ride]()
        var frequentRidesAll = [Ride]()
        if !frequentRides.isEmpty {
            frequentRidesAll.append(contentsOf: frequentRides)
        }
        for ride in allClosedRides {
            if (!isAlreadyAFrequentRide(ride: ride, frequentRides: frequentRidesAll)) {
                frequentRidesOtherThanHomeOffice.append(ride)
                frequentRidesAll.append(ride)
            }
            if (frequentRidesAll.count >= 3) {
                break;
            }
        }
        return frequentRidesOtherThanHomeOffice;
    }
    private func isAlreadyAFrequentRide( ride : Ride, frequentRides : [Ride]) -> Bool {
        if frequentRides.isEmpty {
            return false
        }
        let rideStartCLLocation = CLLocation(latitude: ride.startLatitude, longitude: ride.startLongitude)
        let rideEndCLLocation = CLLocation(latitude: ride.endLatitude!, longitude: ride.endLongitude!)
        for frequentRide in frequentRides {
            let freqRideStartCLLocation = CLLocation(latitude: frequentRide.startLatitude, longitude: frequentRide.startLongitude)
            let freqRideEndCLLocation = CLLocation(latitude: frequentRide.endLatitude!, longitude: frequentRide.endLongitude!)
            
            if freqRideStartCLLocation.distance(from: rideStartCLLocation) <= 1000.0 && freqRideEndCLLocation.distance(from: rideEndCLLocation) <= 1000.0 {
                return true
            }
        }
        return false
    }
    func checkUserHasHomeToOfficeAndOfficeToHomeRecurringRideOrNot(){
        if UserDataCache.getInstance()?.getTotalCompletedRides() == 0{
            return
        }
        if let homeLocation = UserDataCache.getInstance()?.getHomeLocation,let officeLocation = UserDataCache.getInstance()?.getOfficeLocation(){
            let riderRecurringRides = MyRegularRidesCache.getInstance().regularRiderRides.values
            let passengerRecurringRids = MyRegularRidesCache.getInstance().regularPassengerRides.values
            var isRecurringRideExistFromHomeToOffice = false
            var isRecurringRideExistFromOfficeToHome = false
            for recurringRide in riderRecurringRides{
                if recurringRide.startAddress == homeLocation()?.address && recurringRide.endAddress == officeLocation.address{
                    isRecurringRideExistFromHomeToOffice = true
                }else if recurringRide.startAddress == officeLocation.address && recurringRide.endAddress == homeLocation()?.address{
                    isRecurringRideExistFromOfficeToHome = true
                }
            }
            
            for recurringRide in passengerRecurringRids{
                if recurringRide.startAddress == homeLocation()?.address && recurringRide.endAddress == officeLocation.address{
                    isRecurringRideExistFromHomeToOffice = true
                }else if recurringRide.startAddress == officeLocation.address && recurringRide.endAddress == homeLocation()?.address{
                    isRecurringRideExistFromOfficeToHome = true
                }
            }
            if !isRecurringRideExistFromHomeToOffice{
                isRecurringRideRequiredFrom = RegularRideCreationViewController.HOME_TO_OFFICE
            }else if !isRecurringRideExistFromOfficeToHome{
                isRecurringRideRequiredFrom = RegularRideCreationViewController.OFFICE_TO_HOME
            }
        }else{
            isRecurringRideRequiredFrom = RegularRideCreationViewController.HOME_TO_OFFICE
        }
    }
    
    func getTaxiOptions(handler : @escaping (_ detailedEstimatedFare : DetailedEstimateFare) -> Void) {
        if let passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getActivePassengerRide() as? PassengerRide {
            AvailableTaxiCache.getInstance().getAvailableTaxis(passengerRide: passengerRide, handler: { ( response ) in
                if let result = response.result {
                    self.detailEstimatedFare = result
                    handler(result)
                }
            })
        }
    }
    
    func isOutstationRide() -> Bool{
        let passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getActivePassengerRide()
        if passengerRide?.distance ?? 0 > ConfigurationCache.getObjectClientConfiguration().minDistanceForInterCityRide{
            return true
        }else{
            return false
        }
    }
    
    func getUserReferralsDetails(){
        UserRestClient.getUserReferralStats(userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if let referralStats = Mapper<ReferralStats>().map(JSONObject: responseObject?["resultData"]) {
                self.referralStats = referralStats
                self.rideModelDelegate?.referralStats()
            }
        }
    }
    func getHomePageCardsAndOffersCount() -> Int{
        homePageCardAndOffers.removeAll()
        var homePageCards = [HomePageCard]()
        homePageCardAndOffers.append(HomePageCard.LocationSelection)
        if  !getUpcomingRidesOfUser().isEmpty{
            homePageCardAndOffers.append(HomePageCard.UpcomingRides)
        }
        if getNumberOfCellsForUpComingRides() == 0 && !frequentRides.isEmpty{
            homePageCardAndOffers.append(HomePageCard.FrequentRides)
        }
        if let detailEstimatedFare = detailEstimatedFare, detailEstimatedFare.serviceableArea{
            homePageCardAndOffers.append(HomePageCard.Taxi)
        }
        if jobPromotionData.count > 0{
            homePageCardAndOffers.append(HomePageCard.JobPromotion)
        }
        if getHomeOrOfficeNumberOfCells()  == 1{
            homePageCards.append(HomePageCard.HomeAndOfficeLocation)
        }
        homePageCards.append(HomePageCard.Profile)
        let role = UserDataCache.getInstance()?.getUserRecentRideType()
        if UserDataCache.getInstance()?.getDefaultLinkedWallet() == nil && role != Ride.RIDER_RIDE{
            homePageCards.append(HomePageCard.AddPayment)
        }
        homePageCards.append(HomePageCard.AutoMatch)
        if rideSharingCommunityContribution != nil {
            homePageCards.append(HomePageCard.RideContribution)
        }
        if referralStats != nil{
            homePageCards.append(HomePageCard.MyReferral)
        }
        if HelpUtils.getRecentBlogToDisplay() != nil {
            homePageCards.append(HomePageCard.Blog)
        }
        if isRecurringRideRequiredFrom != nil{
            homePageCards.append(HomePageCard.CreateRecurringRide)
        }
        homePageCards.append(HomePageCard.HomeNeedHelp)
        homePageCards.append(HomePageCard.SocialMedia)
        homePageCards.append(HomePageCard.QuickRideJourney)
        
        var addedOffers = 0
        for (index,homePageCard) in homePageCards.enumerated(){
            homePageCardAndOffers.append(homePageCard)
            if index < offerListDict.keys.count{
                homePageCardAndOffers.append(HomePageCard.Offer)
                addedOffers += 1
            }
        }
        let remainingOffers = offerListDict.count - addedOffers
        for _ in 0..<remainingOffers{
            homePageCardAndOffers.append(HomePageCard.Offer)
        }
        return homePageCardAndOffers.count
    }
    
    func getUpcomingRidesOfUser() -> [Ride]{
        var upcomingRides = [Ride]()
        if let riderRides = MyActiveRidesCache.getRidesCacheInstance()?.getActiveRiderRides().values{
            for riderRide in riderRides{
                upcomingRides.append(riderRide)
            }
        }
        if let passengerRides = MyActiveRidesCache.getRidesCacheInstance()?.getActivePassengerRides().values{
            for ride in passengerRides{
                upcomingRides.append(ride)
            }
        }
        return upcomingRides
    }
    
    func getRidePreference() -> RidePreferences {
        return UserDataCache.getInstance()?.getLoggedInUserRidePreferences().copy() as? RidePreferences ?? RidePreferences()
    }
}



extension HomeRideButtomViewModel {
    func getRideSharingCommunityContribution() {
        let userID = QRSessionManager.getInstance()?.getUserId()
        RideServicesClient.getUserRideSharingCommunityContribution(userId: Double(userID!)!, handler: { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                self.rideSharingCommunityContribution = Mapper<RideSharingCommunityContribution>().map(JSONObject: responseObject!["resultData"])
                self.rideModelDelegate?.ecoMeterData()
            }
        })
    }
}

//MARK: RideObjectUdpateListener - when ride will edit then RideUpdateViewController will listen to this protocol
extension HomeRideButtomViewModel: RideObjectUdpateListener {
    func rideUpdated(ride: Ride) {
        self.rideModelDelegate?.receiveActiveRide()
    }
}

//MARK: RideActionDelegate
extension HomeRideButtomViewModel: RideActionDelegate {
    func rideArchived(ride: Ride) {
        
        self.rideModelDelegate?.receiveActiveRide()
    }
    
    func handleFreezeRide(freezeRide: Bool) {
        
        self.rideModelDelegate?.receiveActiveRide()
    }
    func handleEditRoute() {}
}

//MARK: Job Promotion Visibility
extension HomeRideButtomViewModel {
    func getJobPromotionAd() {
        JobPromotionUtils.getJobPromotionDataBasedOnScreen(screenName: ImpressionAudit.Homepage) {(jobPromotionData) in
            self.jobPromotionData = jobPromotionData
            self.rideModelDelegate?.receivedJobPromotionAdsData()
        }
    }
}
//MARK: offers
extension HomeRideButtomViewModel {
    func getOffers() {
        var filterList = [Offer]()
        if let offers = ConfigurationCache.getInstance()?.offersList {
            for offer in offers {
                if offer.displayType == Strings.displaytype_both && (offer.targetDevice == Strings.targetdevice_all || offer.targetDevice == Strings.targetdevice_ios) && offer.offerScreenImageUri != nil && offer.offerScreenImageUri!.isEmpty == false {
                    filterList.append(offer)
                }
            }
            if !filterList.isEmpty {
                updateOfferAsPerPreferedRole(filterOfferList: filterList)
            }
        }
    }
    
    private func updateOfferAsPerPreferedRole(filterOfferList : [Offer]) {
        var finalOfferList = [Offer]()
        guard let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile() else { return }
        for offer in filterOfferList {
            if (UserProfile.PREFERRED_ROLE_PASSENGER == userProfile.roleAtSignup && offer.targetRole == Strings.targetrole_passenger) || (UserProfile.PREFERRED_ROLE_RIDER == userProfile.roleAtSignup && offer.targetRole == Strings.targetrole_rider) || offer.targetRole == Strings.targetrole_both{
                finalOfferList.append(offer)
            }
        }
        if !finalOfferList.isEmpty {
            getOfferCategoryAndList(offerList: finalOfferList)
        }
    }
    
    private func getOfferCategoryAndList(offerList: [Offer]) {
        offerListDict.removeAll()
        for offer in offerList {
            if let category = offer.category {
                if self.offerListDict.keys.contains(category) {
                    var offerList = [Offer]()
                    let offers = Array<Offer>(offerListDict[category] ?? [Offer]())
                    offerList.append(contentsOf: offers)
                    offerList.append(offer)
                    offerListDict[category] =  offerList.sorted(by: { $0.validUpto > $1.validUpto})
                }else{
                    offerListDict[category] = [offer]
                }
            }
        }
    }
}
