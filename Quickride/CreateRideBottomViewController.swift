//
//  CreateRideBottomViewController.swift
//  Quickride
//
//  Created by Ashutos on 2/2/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import ObjectMapper

class CreateRideBottomViewController: UIViewController {
    
    //MARK: OUTLETS
    @IBOutlet weak var rideCreationTableView: UITableView!
    var homeRideButtomViewModel = HomeRideButtomViewModel()
    //MARK: Variables
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellsToView()
        homeRideButtomViewModel = HomeRideButtomViewModel(rideModelDelegate: self)
        homeRideButtomViewModel.getJobPromotionAd()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        homeRideButtomViewModel.getTaxiOptions { [weak self](detailedEstimatedFare) in
            self?.rideCreationTableView.reloadData()
        }
        homeRideButtomViewModel.getUserReferralsDetails()
        homeRideButtomViewModel.checkUserHasHomeToOfficeAndOfficeToHomeRecurringRideOrNot()
        homeRideButtomViewModel.getMostFrequentRidesFromUserLocation()
        homeRideButtomViewModel.getOffers()
        rideCreationTableView.reloadData()
        rideCreationTableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        if let userDataCache = UserDataCache.getInstance(),!userDataCache.displayResumeDialogForSuspendedRecurringRides{
            checkIfAnySuspendedRecurringRidesAndAskUserToMakeActive()
        }
    }

    private func registerCellsToView() {
        rideCreationTableView.estimatedRowHeight = 44
        rideCreationTableView.rowHeight = UITableView.automaticDimension
        rideCreationTableView.register(UINib(nibName: "RideLocationSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "RideLocationSelectionTableViewCell")
        rideCreationTableView.register(UINib(nibName: "UpcomingRidesTableViewCell", bundle: nil), forCellReuseIdentifier: "UpcomingRidesTableViewCell")
        rideCreationTableView.register(UINib(nibName: "FrequentRideShowingTableViewCell", bundle: nil), forCellReuseIdentifier: "FrequentRideShowingTableViewCell")
        rideCreationTableView.register(UINib(nibName: "AddHomeOrOfcTableViewCell", bundle: nil), forCellReuseIdentifier: "AddHomeOrOfcTableViewCell")
        rideCreationTableView.register(UINib(nibName: "ProfileCardTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileCardTableViewCell")
        rideCreationTableView.register(UINib(nibName: "RideContributionTableViewCell", bundle: nil), forCellReuseIdentifier: "RideContributionTableViewCell")
         rideCreationTableView.register(UINib(nibName: "MyReferralTableViewCell", bundle: nil), forCellReuseIdentifier: "MyReferralTableViewCell")
        rideCreationTableView.register(UINib(nibName: "BlogTableViewCell", bundle : nil),forCellReuseIdentifier: "BlogTableViewCell")
        rideCreationTableView.register(UINib(nibName: "HomeNeedHelpTableViewCell", bundle : nil),forCellReuseIdentifier: "HomeNeedHelpTableViewCell")
        rideCreationTableView.register(UINib(nibName: "CreateRecurringRideTableViewCell", bundle : nil),forCellReuseIdentifier: "CreateRecurringRideTableViewCell")
        rideCreationTableView.register(UINib(nibName: "SocialMediaPromotionTableViewCell", bundle : nil),forCellReuseIdentifier: "SocialMediaPromotionTableViewCell")
        rideCreationTableView.register(UINib(nibName: "QuickRideJourneyTableViewCell", bundle : nil),forCellReuseIdentifier: "QuickRideJourneyTableViewCell")
        rideCreationTableView.register(UINib(nibName: "JobPromotionTableViewCell", bundle : nil),forCellReuseIdentifier: "JobPromotionTableViewCell")
        rideCreationTableView.register(UINib(nibName: "HomeScreenAndLiveRideOfferTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeScreenAndLiveRideOfferTableViewCell")
        rideCreationTableView.register(UINib(nibName: "ReferAndEarnTableViewCell", bundle: nil), forCellReuseIdentifier: "ReferAndEarnTableViewCell")
        rideCreationTableView.register(UINib(nibName: "AddPaymentMethodTableViewCell", bundle: nil), forCellReuseIdentifier: "AddPaymentMethodTableViewCell")
        rideCreationTableView.register(UINib(nibName: "MyRidesAutoMatchTableViewCell", bundle: nil), forCellReuseIdentifier: "MyRidesAutoMatchTableViewCell")
        rideCreationTableView.register(UINib(nibName: "HomepageTaxiCardTableViewCell", bundle: nil), forCellReuseIdentifier: "HomepageTaxiCardTableViewCell")
        rideCreationTableView.register(UINib(nibName: "MatchingOptionOutstationTaxiTableViewCell", bundle: nil), forCellReuseIdentifier: "MatchingOptionOutstationTaxiTableViewCell")
    }

    private func moveToLocationSelection(locationType : String, location : Location?,alreadySelectedLocation: Location?) {
        let changeLocationVC = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.alreadySelectedLocation = alreadySelectedLocation
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType, currentSelectedLocation: location, hideSelectLocationFromMap: false, routeSelectionDelegate: self, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }
    
    func checkIfAnySuspendedRecurringRidesAndAskUserToMakeActive(){
        let count = SharedPreferenceHelper.getSuspendedRecurringRideDailogShowedStatusCount()
        if count > 3{
            return
        }
        if (!MyRegularRidesCache.getInstance().getSuspendedRegularRiderRides().isEmpty || !MyRegularRidesCache.getInstance().getSuspendedRegularPassengerRides().isEmpty) && ConfigurationCache.getObjectClientConfiguration().displayRegularRideResumeDialogForSuspendedRides{
            let resumeRecurringRidesViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ResumeRecurringRidesViewController") as! ResumeRecurringRidesViewController
            SharedPreferenceHelper.storeSuspendedRecurringRideDailogShowedStatusCount(status: count + 1)
            UserDataCache.getInstance()?.displayResumeDialogForSuspendedRecurringRides = true
            ViewControllerUtils.addSubView(viewControllerToDisplay: resumeRecurringRidesViewController)
        }
    }

    
    func moveToCurrentLocation(location : Location) {
        AppDelegate.getAppDelegate().log.debug("moveToCurrentLocation()")
        self.homeRideButtomViewModel.updateCurrentLocation(currentLocation : location)
        self.rideCreationTableView.reloadData()
    }
    private func moveToPostRideScreen() {
        if !homeRideButtomViewModel.ride.isStartAndEndValid(){
            return
        }
        if RideValidationUtils.isStartAndEndAddressAreSame(ride: homeRideButtomViewModel.ride){
            UIApplication.shared.keyWindow?.makeToast(Strings.startAndEndAddressNeedToBeDiff, point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300), title: nil, image: nil, completion: nil)
            return
        }
        moveToCreateRideScreen()
        if let currentLoc = homeRideButtomViewModel.currentLocation{
            homeRideButtomViewModel.ride.startAddress = currentLoc.completeAddress!
            homeRideButtomViewModel.ride.startLatitude = currentLoc.latitude
            homeRideButtomViewModel.ride.startLongitude = currentLoc.longitude
        }
        homeRideButtomViewModel.ride.endAddress = ""
        homeRideButtomViewModel.ride.endLatitude = 0
        homeRideButtomViewModel.ride.endLongitude = 0
        homeRideButtomViewModel.ride.routeId = 0
        self.rideCreationTableView.reloadData()
    }
    
    private func moveToCreateRideScreen() {
        let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.routeViewController) as! RouteViewController
        routeViewController.initializeDataBeforePresenting(ride: homeRideButtomViewModel.ride.copy() as! Ride)
        self.navigationController?.pushViewController(routeViewController, animated: false)
    }

    private func createRide(ride: Ride){
        var newRide : Ride?
        if ride.rideType == Ride.RIDER_RIDE{
            newRide = (ride as! RiderRide).copy() as? RiderRide
        }else{
            newRide = (ride as! PassengerRide).copy() as? PassengerRide
        }
        if newRide!.startTime < NSDate().timeIntervalSince1970*1000{
            newRide!.startTime = NSDate().timeIntervalSince1970*1000
        }
        newRide?.rideId = 0
        let rideDuration = DateUtils.getDifferenceBetweenTwoDatesInMins(time1: newRide!.startTime, time2: newRide?.expectedEndTime)
        let rideRoute :RideRoute = RideRoute(routeId: newRide!.routeId!,overviewPolyline : (newRide?.routePathPolyline)!,distance :(newRide?.distance)!,duration : Double(rideDuration), waypoints : newRide?.waypoints)
        let redundantRide = MyActiveRidesCache.singleCacheInstance?.checkForRedundancyOfRide(ride: newRide!)
        if redundantRide != nil{
            RideValidationUtils.displayRedundentRideAlert(ride: redundantRide!, viewController: self)
            return
        }
        if newRide?.rideType == Ride.RIDER_RIDE{
            QuickRideProgressSpinner.startSpinner()
            (newRide as! RiderRide).availableSeats = (newRide as! RiderRide).capacity
            CreateRiderRideHandler(ride: newRide as! RiderRide, rideRoute: rideRoute, isFromInviteByContact: false, targetViewController: self).createRiderRide(handler: { (riderRide, error) in
                QuickRideProgressSpinner.stopSpinner()
                if riderRide != nil{
                    self.moveToRideView(ride: riderRide!)
                }
            })
        }else{
            QuickRideProgressSpinner.startSpinner()
            CreatePassengerRideHandler(ride: newRide as! PassengerRide, rideRoute: rideRoute, isFromInviteByContact: false, targetViewController: self, parentRideId: nil,relayLegSeq: nil).createPassengerRide(handler: { (passengerRide, error) in
                QuickRideProgressSpinner.stopSpinner()
                if passengerRide != nil{
                    self.moveToRideView(ride: passengerRide!)
                }
            })
        }

    }
    
    func editRideData() {
        rideCreationTableView.reloadData()
    }
    
    func moveToRideView(ride :Ride){
        AppDelegate.getAppDelegate().log.debug("moveToRideView()")
        QuickRideProgressSpinner.stopSpinner()
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: ride, isFromRideCreation: true, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        let sendInviteBaseViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SendInviteBaseViewController") as! SendInviteBaseViewController
        sendInviteBaseViewController.initializeDataBeforePresenting(scheduleRide: ride, isFromCanceRide: false, isFromRideCreation: true)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: mainContentVC, animated: false)
        self.navigationController?.pushViewController(sendInviteBaseViewController, animated: false)
    }
    
    @objc func viewMoreTapped(_ sender: UIButton) {
        let myRidesDetailViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "MyRidesDetailViewController") as! MyRidesDetailViewController
        self.navigationController?.pushViewController(myRidesDetailViewController, animated: false)
    }
}
//MARK: HomeRideButtomViewModelDelegate
extension CreateRideBottomViewController: HomeRideButtomViewModelDelegate {

    func receiveActiveRide() {
        rideCreationTableView.reloadData()
    }

    func receiveErrorForMyRides(responseError: ResponseError?, responseObject: NSDictionary?, error: NSError?) {
        if let responseError = responseError {
            MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: self, handler: nil)
        } else {
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        }
    }
    
    func ecoMeterData() {
        rideCreationTableView.reloadData()
    }
    
    func referralStats() {
        rideCreationTableView.reloadData()
    }
    
    func receivedJobPromotionAdsData() {
        rideCreationTableView.reloadData()
    }
}

//MARK: TableViewDataSource
extension CreateRideBottomViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        homeRideButtomViewModel.indexForOffer = 0
        return homeRideButtomViewModel.getHomePageCardsAndOffersCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch homeRideButtomViewModel.homePageCardAndOffers[indexPath.section] {
        case HomePageCard.LocationSelection:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RideLocationSelectionTableViewCell", for: indexPath) as! RideLocationSelectionTableViewCell
            let pickup = Location(latitude: homeRideButtomViewModel.ride.startLatitude, longitude: homeRideButtomViewModel.ride.startLongitude, shortAddress: homeRideButtomViewModel.ride.startAddress)
            let drop = Location(latitude: homeRideButtomViewModel.ride.endLatitude!, longitude: homeRideButtomViewModel.ride.endLongitude!, shortAddress: homeRideButtomViewModel.ride.endAddress)
            cell.initializeData(pickup: pickup, drop: drop, userSelectionDelegate: self, selectedRideType: homeRideButtomViewModel.rideType)
            return cell

        case HomePageCard.UpcomingRides:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingRidesTableViewCell", for: indexPath) as! UpcomingRidesTableViewCell
            cell.initialiseNextRides(upcomingRides: homeRideButtomViewModel.getUpcomingRidesOfUser())
            return cell
        case HomePageCard.FrequentRides:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FrequentRideShowingTableViewCell", for: indexPath) as! FrequentRideShowingTableViewCell
            cell.initialiseData(numberOfCells: homeRideButtomViewModel.getNumberOfCellForFrequentRides(),ride: homeRideButtomViewModel.frequentRides)
            cell.delegate = self
            return cell
        case HomePageCard.Taxi:
            if homeRideButtomViewModel.isOutstationRide(),let detailEstimatedFare = homeRideButtomViewModel.detailEstimatedFare,let ride = MyActiveRidesCache.getRidesCacheInstance()?.getActivePassengerRide(){
                let cell = tableView.dequeueReusableCell(withIdentifier: "MatchingOptionOutstationTaxiTableViewCell", for: indexPath) as! MatchingOptionOutstationTaxiTableViewCell
                cell.topView.isHidden = false
                cell.initialiseOutstationCard(ride: ride,detailedEstimatedFare: detailEstimatedFare, isFromSendInvite: false)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomepageTaxiCardTableViewCell", for: indexPath) as! HomepageTaxiCardTableViewCell
                if let detailEstimatedFare = homeRideButtomViewModel.detailEstimatedFare{
                    cell.initialiseTaxiView(detailEstimatedFare: detailEstimatedFare)
                    return cell
                }else{
                    return UITableViewCell()
                }
            }
        case HomePageCard.JobPromotion:
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobPromotionTableViewCell", for: indexPath) as! JobPromotionTableViewCell
            cell.setupUI(jobPromotionData: homeRideButtomViewModel.jobPromotionData,screenName: ImpressionAudit.Homepage)
            return cell
        case HomePageCard.HomeAndOfficeLocation:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddHomeOrOfcTableViewCell", for: indexPath) as! AddHomeOrOfcTableViewCell
            cell.updateUI()
            cell.delegate = self
            return cell
        case HomePageCard.Profile:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCardTableViewCell", for: indexPath) as! ProfileCardTableViewCell
            cell.initialiseViews(viewController: self)
            return cell
        case HomePageCard.AddPayment:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPaymentMethodTableViewCell", for: indexPath) as! AddPaymentMethodTableViewCell
            return cell
        case HomePageCard.AutoMatch:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyRidesAutoMatchTableViewCell", for: indexPath) as! MyRidesAutoMatchTableViewCell
            cell.setupAutoConfirmToggleUI(ridePreferences: homeRideButtomViewModel.getRidePreference())
            cell.delegate = self
            return cell
        case HomePageCard.RideContribution:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RideContributionTableViewCell", for: indexPath) as! RideContributionTableViewCell
            cell.updateUI(rideSharingCommunityContribution: homeRideButtomViewModel.rideSharingCommunityContribution!, viewController: self)
            return cell
        case HomePageCard.MyReferral:
            if (homeRideButtomViewModel.referralStats?.activatedReferralCount ?? 0) <= 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReferAndEarnTableViewCell", for: indexPath) as! ReferAndEarnTableViewCell
                cell.intializeViews(referralStats: homeRideButtomViewModel.referralStats!)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyReferralTableViewCell", for: indexPath) as! MyReferralTableViewCell
                cell.intializeViews(referralStats: homeRideButtomViewModel.referralStats!, viewController: self)
                return cell
            }
        case HomePageCard.Blog:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlogTableViewCell",for : indexPath) as! BlogTableViewCell
            cell.initializeViews(blog: HelpUtils.getRecentBlogToDisplay(), viewController: self)
            return cell
        case HomePageCard.CreateRecurringRide:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateRecurringRideTableViewCell",for : indexPath) as! CreateRecurringRideTableViewCell
            cell.showCreatingRecurringRideView(isRecurringRideRequiredFrom: homeRideButtomViewModel.isRecurringRideRequiredFrom)
            return cell
        case HomePageCard.HomeNeedHelp:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeNeedHelpTableViewCell",for : indexPath) as! HomeNeedHelpTableViewCell
            cell.initializeViews(viewController: self)
            return cell
        case HomePageCard.SocialMedia:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SocialMediaPromotionTableViewCell",for : indexPath) as! SocialMediaPromotionTableViewCell
            cell.initializeSocialMediaView(viewController: self)
            return cell
        case HomePageCard.QuickRideJourney:
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuickRideJourneyTableViewCell",for : indexPath) as! QuickRideJourneyTableViewCell
            return cell
        case HomePageCard.Offer:
            if homeRideButtomViewModel.indexForOffer < homeRideButtomViewModel.offerListDict.count{
                let offerCell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenAndLiveRideOfferTableViewCell", for: indexPath) as! HomeScreenAndLiveRideOfferTableViewCell
                offerCell.prepareData(offerList: Array(homeRideButtomViewModel.offerListDict.values)[homeRideButtomViewModel.indexForOffer], isFromLiveRide: false)
                homeRideButtomViewModel.indexForOffer = homeRideButtomViewModel.indexForOffer + 1
                return offerCell
            }else{
                homeRideButtomViewModel.indexForOffer = 0
                let offerCell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenAndLiveRideOfferTableViewCell", for: indexPath) as! HomeScreenAndLiveRideOfferTableViewCell
                offerCell.prepareData(offerList: Array(homeRideButtomViewModel.offerListDict.values)[homeRideButtomViewModel.indexForOffer], isFromLiveRide: false)
                homeRideButtomViewModel.indexForOffer = homeRideButtomViewModel.indexForOffer + 1
                return offerCell
            }
        }
    }
}

//MARK: TableViewDelegate
extension CreateRideBottomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (homeRideButtomViewModel.homePageCardAndOffers.count - 1) || homeRideButtomViewModel.homePageCardAndOffers[section] == HomePageCard.SocialMedia{
            return 1
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = UIView()
        footerCell.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        return footerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

}

//MARK:AddHomeOfcCellDelegate
extension CreateRideBottomViewController: AddHomeOrOfcTableViewCellDelegate {
    func addFavouriteLocation(favouriteLocation : UserFavouriteLocation?, locationtype: String) {
        let addFavoriteLocationViewController  = UIStoryboard(name : StoryBoardIdentifiers.add_favourite_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddFavoriteLocationViewController") as! AddFavoriteLocationViewController
        addFavoriteLocationViewController.favoriteLocation.name = locationtype
        self.navigationController?.pushViewController(addFavoriteLocationViewController, animated: false)
    }
    
    func updateFavouriteLocation(favouriteLocation : UserFavouriteLocation, locationType : String,locationName : String?){
    
            AppDelegate.getAppDelegate().log.debug("displayHomeAndOfficePopUpMenu()")
            let alertController : HomeAndOfficeLocationAlertController = HomeAndOfficeLocationAlertController(viewController: self) { (result) -> Void in
                if result == Strings.update{
                    self.moveToLocationSelection(locationType: locationType, location: Location(favouriteLocation: favouriteLocation), alreadySelectedLocation: nil)
                }else if result == Strings.delete{
                    QuickRideProgressSpinner.startSpinner()
                    UserRestClient.deleteFavouriteLocations(id: favouriteLocation.locationId!, viewController: self, completionHandler: { (responseObject, error) -> Void in
                        QuickRideProgressSpinner.stopSpinner()
                        if responseObject == nil || responseObject!["result"] as! String == "FAILURE" {
                            ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: self, handler: nil)
                        }else if responseObject!["result"] as! String == "SUCCESS"{
    
                            UserDataCache.getInstance()?.deleteUserFavouriteLocation(location: favouriteLocation)
                            if locationType == ChangeLocationViewController.HOME {
                               SharedPreferenceHelper.storeHomeLocation(homeLocation: nil)
                            }else{
                               SharedPreferenceHelper.storeOfficeLocation(officeLocation: nil)
                            }
    
                            self.rideCreationTableView.reloadData()
                          }
                    })
                }
            }
            alertController.updateAlertAction()
            alertController.deleteAlertAction()
            alertController.addRemoveAlertAction()
            alertController.showAlertController()
        }
}

//MARK: RideLocationSelectionTableViewCellDelegate
extension CreateRideBottomViewController: RideLocationSelectionTableViewCellDelegate {
    func rideTypeChanged(primary: String) {
        homeRideButtomViewModel.rideType = primary
        homeRideButtomViewModel.ride.rideType = primary
    }

    func fromLocationTapped() {
        if homeRideButtomViewModel.ride.startAddress.isEmpty {
            moveToLocationSelection(locationType: ChangeLocationViewController.ORIGIN, location:nil, alreadySelectedLocation: Location(latitude: homeRideButtomViewModel.ride.startLatitude,longitude: homeRideButtomViewModel.ride.startLongitude,shortAddress: homeRideButtomViewModel.ride.startAddress))
        }else{
            moveToLocationSelection(locationType: ChangeLocationViewController.ORIGIN, location: Location(latitude: homeRideButtomViewModel.ride.startLatitude,longitude: homeRideButtomViewModel.ride.startLongitude,shortAddress: homeRideButtomViewModel.ride.startAddress), alreadySelectedLocation: Location(latitude: homeRideButtomViewModel.ride.startLatitude,longitude: homeRideButtomViewModel.ride.startLongitude,shortAddress: homeRideButtomViewModel.ride.startAddress))
        }
       
        
    }

    func toLocationTapped() {
        if homeRideButtomViewModel.ride.endAddress.isEmpty {
            moveToLocationSelection(locationType: ChangeLocationViewController.DESTINATION, location:nil, alreadySelectedLocation: Location(latitude: homeRideButtomViewModel.ride.startLatitude,longitude: homeRideButtomViewModel.ride.startLongitude,shortAddress: homeRideButtomViewModel.ride.startAddress))
        }else{
            moveToLocationSelection(locationType: ChangeLocationViewController.DESTINATION, location: Location(latitude: homeRideButtomViewModel.ride.endLatitude!,longitude: homeRideButtomViewModel.ride.endLongitude!,shortAddress: homeRideButtomViewModel.ride.endAddress), alreadySelectedLocation: Location(latitude: homeRideButtomViewModel.ride.startLatitude,longitude: homeRideButtomViewModel.ride.startLongitude,shortAddress: homeRideButtomViewModel.ride.startAddress))
        }
    }
    func selectedFavLocation(location: Location) {
        handleselectedLocation(location: location, requestLocationType: ChangeLocationViewController.DESTINATION)
    }
}
//MARK: FrequentRideShowingTableViewCellDelegate
extension CreateRideBottomViewController: FrequentRideShowingTableViewCellDelegate {
    func findOrOfferRidePressed(ride: Ride) {
        createRide(ride: ride)
    }

    func editRidePressed(ride: Ride) {
        moveToPostRideScreen()
    }
}
//MARK: ReceiveLocationDelegate
extension CreateRideBottomViewController: ReceiveLocationDelegate {
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        
        handleselectedLocation(location: location, requestLocationType: requestLocationType)
        
    }

    func locationSelectionCancelled(requestLocationType: String) {}

    private func handleselectedLocation(location: Location, requestLocationType: String){
        if let createRideHomeViewController = self.parent?.parent as? CreateRideHomeViewController{
            createRideHomeViewController.locationFetched = true
        }
        if requestLocationType == ChangeLocationViewController.ORIGIN{
            homeRideButtomViewModel.ride.startLatitude = location.latitude
            homeRideButtomViewModel.ride.startLongitude = location.longitude
            homeRideButtomViewModel.ride.startAddress = location.completeAddress!
            rideCreationTableView.reloadData()
            moveToPostRideScreen()
            if let createRideHomeViewController = self.parent?.parent as? CreateRideHomeViewController{
                createRideHomeViewController.rideStartLocationChanged(location: location)
            }
        }else if requestLocationType == ChangeLocationViewController.DESTINATION{
            homeRideButtomViewModel.ride.endLatitude = location.latitude
            homeRideButtomViewModel.ride.endLongitude = location.longitude
            homeRideButtomViewModel.ride.endAddress = location.completeAddress!
            rideCreationTableView.reloadData()
            moveToPostRideScreen()
        }else if ChangeLocationViewController.HOME == requestLocationType{
            guard let homeFavLocation = UserDataCache.sharedInstance?.getHomeLocation() else {
                return
            }
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.do_you_want_to_set+location.completeAddress!+Strings.as_home_location, message2: nil, positiveActnTitle: Strings.yes_caps,negativeActionTitle : Strings.no_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.yes_caps == result{
                    self.updateSelectedLocation(location: location, oldLocation: homeFavLocation, name: UserFavouriteLocation.HOME_FAVOURITE)
                    
                }
            })
        }else if ChangeLocationViewController.OFFICE == requestLocationType{
            guard let officeFavLocation = UserDataCache.sharedInstance?.getOfficeLocation() else {
                return
            }
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.do_you_want_to_set+location.completeAddress!+Strings.as_office_location, message2: nil, positiveActnTitle: Strings.yes_caps,negativeActionTitle : Strings.no_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.yes_caps == result{
                    self.updateSelectedLocation(location: location, oldLocation: officeFavLocation, name: UserFavouriteLocation.OFFICE_FAVOURITE)
                }
            })
        }
    }

    func updateSelectedLocation(location: Location,oldLocation : UserFavouriteLocation, name :String){
        AppDelegate.getAppDelegate().log.debug("updateSelectedLocation()")
        let selectedLocation = getUpdatedFavLocation(location: location, name: oldLocation.name!, id: oldLocation.locationId!, phone: oldLocation.phoneNumber!)
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.updateFavouriteLocation(favouriteLocation: selectedLocation, viewController: self, handler: { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let location = Mapper<UserFavouriteLocation>().map(JSONObject: responseObject!.value(forKey: "resultData"))! as UserFavouriteLocation
                
                UserDataCache.getInstance()?.deleteUserFavouriteLocation(location: oldLocation)
                
                UserDataCache.getInstance()?.saveFavoriteLocations (favoriteLocations: location)
                self.rideCreationTableView.reloadData()
            }
            else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
        
    }
    private func  getUpdatedFavLocation( location : Location, name : String, id : Double, phone : Double) -> UserFavouriteLocation{
        AppDelegate.getAppDelegate().log.debug("getUpdatedFavLocation()")
        let selectedLocation = UserFavouriteLocation();
        selectedLocation.longitude = location.longitude
        selectedLocation.latitude = location.latitude
        selectedLocation.address = location.completeAddress
        selectedLocation.name = name
        selectedLocation.locationId = id
        selectedLocation.phoneNumber = phone
        selectedLocation.city = location.city
        selectedLocation.state = location.state
        selectedLocation.areaName = location.areaName
        selectedLocation.streetName = location.streetName
        selectedLocation.country = location.country
        return selectedLocation
    }
}
//MARK: ReceiveLocationDelegate
extension CreateRideBottomViewController: RouteSelectionDelegate{
    func receiveSelectedRoute(ride: Ride?, route: RideRoute) {
    }
    
    func recieveSelectedPreferredRoute(ride: Ride?, preferredRoute: UserPreferredRoute) {
        if preferredRoute.fromLocation != nil{
            homeRideButtomViewModel.ride.startLatitude = preferredRoute.fromLatitude!
            homeRideButtomViewModel.ride.startLongitude = preferredRoute.fromLongitude!
            homeRideButtomViewModel.ride.startAddress = preferredRoute.fromLocation!
        }
        if preferredRoute.toLocation != nil{
            homeRideButtomViewModel.ride.endLatitude = preferredRoute.toLatitude!
            homeRideButtomViewModel.ride.endLongitude = preferredRoute.toLongitude!
            homeRideButtomViewModel.ride.endAddress = preferredRoute.toLocation!
        }
        homeRideButtomViewModel.ride.routeId = preferredRoute.routeId
        moveToPostRideScreen()
    }
}
//MARK: MyRidesAutoMatchTableViewCellDelegate
extension CreateRideBottomViewController: MyRidesAutoMatchTableViewCellDelegate {
    func autoMatchSettingTapped() {
        let rideAutoConfirmationSettingViewController = UIStoryboard(name: StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideAutoConfirmationSettingViewController") as! RideAutoConfirmationSettingViewController
        rideAutoConfirmationSettingViewController.initializeViews(ridePreferences: homeRideButtomViewModel.getRidePreference())
            self.navigationController?.pushViewController(rideAutoConfirmationSettingViewController, animated: false)
    }

    func getStatusOfAutoMatch(status: Bool) {
        let preference = homeRideButtomViewModel.getRidePreference()
        preference.autoConfirmEnabled = status
        QuickRideProgressSpinner.startSpinner()
        SaveRidePreferencesTask(ridePreferences: preference, viewController: self, receiver: self).saveRidePreferences()
    }
}
//MARK: SaveRidePreferencesReceiver
extension CreateRideBottomViewController: SaveRidePreferencesReceiver {
    func ridePreferencesSavingFailed() {
        QuickRideProgressSpinner.stopSpinner()
    }

    func ridePreferencesSaved() {
        QuickRideProgressSpinner.stopSpinner()
    }
}
