//
//  RecurringRideViewController.swift
//  Quickride
//
//  Created by Vinutha on 28/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RecurringRideViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var recurringRideTableView: UITableView!
    @IBOutlet weak var rideTypeLabel: UILabel!
    @IBOutlet weak var backButton: CustomUIButton!
    @IBOutlet weak var rideCreatedSuccessView: UIView!
    @IBOutlet weak var cancelImage: UIImageView!
    
    //MARK: Variables
    private var recurringRideViewModel = RecurringRideViewModel()
    
    func initializeDataBeforePresentingView(ride : Ride,isFromRecurringRideCreation: Bool) {
        AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresentingView()")
        recurringRideViewModel = RecurringRideViewModel(ride: ride,isFromRecurringRideCreation: isFromRecurringRideCreation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        recurringRideViewModel.fillTimeForDayInWeek()
        recurringRideViewModel.prapareRideRoute()
        if recurringRideViewModel.isFromRecurringRideCreation{
            rideCreatedSuccessView.isHidden = false
            cancelImage.image = cancelImage.image?.withRenderingMode(.alwaysTemplate)
            cancelImage.tintColor = UIColor(netHex: 0x318F4A)
        }else{
            rideCreatedSuccessView.isHidden = true
        }
        if recurringRideViewModel.ride?.status != Ride.RIDE_STATUS_SUSPENDED{
            recurringRideViewModel.getConnectedMatches(viewController: self, myRegularRidesCacheListener: self)
            recurringRideViewModel.getRecommendedMatches(viewController: self, matchingRegularRideOptionsDelegate: self)
        }
        MyRegularRidesCache.getInstance().addRideUpdateListener(rideId:recurringRideViewModel.ride?.rideId ?? 0,listener : self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        confirmNsNotification()
    }
    
    private func prepareView(){
        recurringRideTableView.estimatedRowHeight = 160
        recurringRideTableView.rowHeight = UITableView.automaticDimension
        recurringRideTableView.register(UINib(nibName: "RecurringRideRouteTableViewCell", bundle: nil), forCellReuseIdentifier: "RecurringRideRouteTableViewCell")
        recurringRideTableView.register(UINib(nibName: "RecurringRideMatchingOptionTableViewCell", bundle: nil), forCellReuseIdentifier: "RecurringRideMatchingOptionTableViewCell")
        
        backButton.changeBackgroundColorBasedOnSelection()
        if recurringRideViewModel.ride?.rideType == Ride.REGULAR_RIDER_RIDE{
            rideTypeLabel.text = Strings.offer_ride_you_are_rider
        } else {
            rideTypeLabel.text = Strings.find_ride_you_are_passenger
        }
        recurringRideTableView.reloadData()
    }
    private func confirmNsNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(editDaysAndTime(_:)), name: .editDaysAndTime ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rideStatusChanged(_:)), name: .rideStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteRideTapped(_:)), name: .deleteRideTapped, object: recurringRideViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(recurringRideStatusUpdated), name: .recurringRideStatusUpdated, object: recurringRideViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(recurringRideStatusUpdateFailed(_:)), name: .recurringRideStatusUpdateFailed, object: recurringRideViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(unjoiningSucess(_:)), name: .unjoiningSucess, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Actions
    @objc func editDaysAndTime(_ notification:Notification) {
        let recurringRideSettingsViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RecurringRideSettingsViewController") as! RecurringRideSettingsViewController
        recurringRideSettingsViewController.initailizeRecurringRideSettingView(ride: recurringRideViewModel.ride!, dayType: recurringRideViewModel.dayType, weekdays: recurringRideViewModel.weekdays, editWeekDaysTimeCompletionHandler: { (weekdays,dayType,startTime) in
            self.recurringRideViewModel.weekdays = weekdays
            self.recurringRideViewModel.dayType = dayType
            if let rideStartTime = startTime{
                self.recurringRideViewModel.ride?.startTime = rideStartTime
            }
            self.recurringRideViewModel.updateRide(viewContoller: self, updateRegularRideDelegate: self)
            self.recurringRideTableView.reloadData()
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: recurringRideSettingsViewController)
    }
    @objc func rideStatusChanged(_ notification:Notification) {
        QuickRideProgressSpinner.startSpinner()
        let status = notification.userInfo?["status"] as? String
        recurringRideViewModel.updateRegularRideStatus(status: status ?? "")
    }
    @objc func recurringRideStatusUpdated(_ notification:Notification) {
        QuickRideProgressSpinner.stopSpinner()
    }
    @objc func recurringRideStatusUpdateFailed(_ notification:Notification) {
        QuickRideProgressSpinner.stopSpinner()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["nsError"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @objc func unjoiningSucess(_ notification:Notification) {
        recurringRideViewModel.connectedMatches.removeAll()
        recurringRideViewModel.getConnectedMatches(viewController: self, myRegularRidesCacheListener: self)
        recurringRideTableView.reloadData()
    }
    
    @objc func deleteRideTapped(_ notification:Notification){
        deleteRide()
    }
    private func deleteRide(){
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.ride_delete_message, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if result == Strings.yes_caps{
                let cancelRegularRideTask : CancelRegularRideTask = CancelRegularRideTask(ride: self.recurringRideViewModel.ride!, rideType: self.recurringRideViewModel.ride?.rideType, viewController: self)
                cancelRegularRideTask.cancelRegularRide()
            }
        })
    }
    private func goBackToCallingViewController(){
        AppDelegate.getAppDelegate().log.debug("goBackToCallingViewController()")
        MyRegularRidesCache.getInstance().removeRideUpdateListenre(rideId: (recurringRideViewModel.ride?.rideId)!)
        NotificationCenter.default.post(name: .refreshRides, object: nil)
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("backButtonAction()")
        goBackToCallingViewController()
    }
    @IBAction func cancelSucessViewTapped(_ sender: Any) {
        rideCreatedSuccessView.isHidden = true
    }
}

//MARK: UITableViewDataSource
extension RecurringRideViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            if recurringRideViewModel.connectedMatches.count > 0{
                return 1
            }else{
                return 0
            }
        }else if section == 2{
            if recurringRideViewModel.connectedMatches.count > 0{
                return recurringRideViewModel.connectedMatches.count
            }else{
                return 0
            }
        }else if section == 3{
            if recurringRideViewModel.recommendedMatches.count > 0{
                return 1
            }else{
                return 0
            }
        }else if section == 4{
            if recurringRideViewModel.recommendedMatches.count > 0{
                return recurringRideViewModel.recommendedMatches.count
            }else{
                return 0
            }
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecurringRideRouteTableViewCell", for: indexPath) as! RecurringRideRouteTableViewCell
            cell.initalizeRoute(ride: recurringRideViewModel.ride, rideRoute: recurringRideViewModel.rideRoute, viewController: self, routeSelectionDelegate: self)
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecurringRideConnectedMatchCell", for: indexPath)
            cell.isUserInteractionEnabled = false
            return cell
        }else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecurringRideMatchingOptionTableViewCell", for: indexPath) as! RecurringRideMatchingOptionTableViewCell
            if recurringRideViewModel.connectedMatches.endIndex <= indexPath.row{
                return cell
            }
            cell.initializeMatchedUser(matchedRegularUser: recurringRideViewModel.connectedMatches[indexPath.row]
                , ride: recurringRideViewModel.ride, viewController: self, isConnectedRide: true)
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecurringRideMatchingOptionText", for: indexPath)
            cell.isUserInteractionEnabled = false
            return cell
        }else if indexPath.section == 4{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecurringRideMatchingOptionTableViewCell", for: indexPath) as! RecurringRideMatchingOptionTableViewCell
            if recurringRideViewModel.recommendedMatches.endIndex <= indexPath.row{
                return cell
            }
            cell.initializeMatchedUser(matchedRegularUser: recurringRideViewModel.recommendedMatches[indexPath.row]
                , ride: recurringRideViewModel.ride, viewController: self, isConnectedRide: false)
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecurringRideDeleteTableViewCell", for: indexPath)
            return cell
        }
    }
}
//MARK: UITableViewDataSource
extension RecurringRideViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2{
            moveToConnectedProfile(index: indexPath.row)
        }else if indexPath.section == 4{
             moveToRideDetailView(index: indexPath.row)
        }else if indexPath.section == 5{
            deleteRide()
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    
    func moveToRideDetailView(index: Int){
        let matchedUser = recurringRideViewModel.recommendedMatches[index]
        recurringRideViewModel.selectedRecommendMatchesIndex = index
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
        mainContentVC.initializeData(ride: recurringRideViewModel.ride!, matchedUserList: [matchedUser], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false,  selectedUserDelegate: self)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
    
    func moveToConnectedProfile(index: Int){
        let connectedUser = recurringRideViewModel.connectedMatches[index]
        let profile:ProfileDisplayViewController = (UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as? ProfileDisplayViewController)!
        var vehicle : Vehicle?
        var userRole = UserRole.Passenger
        if connectedUser.userRole == MatchedUser.REGULAR_RIDER{
            
            let matchedRider = connectedUser as! MatchedRegularRider
            vehicle = Vehicle(ownerId : matchedRider.userid!, vehicleModel :  matchedRider.model!, vehicleType: matchedRider.vehicleType,
                              registrationNumber : matchedRider.vehicleNumber, capacity : matchedRider.capacity, fare : matchedRider.fare, makeAndCategory : matchedRider.vehicleMakeAndCategory,additionalFacilities : matchedRider.additionalFacilities,riderHasHelmet : matchedRider.riderHasHelmet)
            vehicle?.imageURI = matchedRider.vehicleImageURI
            userRole = UserRole.Rider
        }
        profile.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: connectedUser.userid!),isRiderProfile: userRole,rideVehicle: vehicle, userSelectionDelegate: nil,displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: connectedUser.userOnTimeComplianceRating, noOfSeats: nil, isSafeKeeper: connectedUser.hasSafeKeeperBadge)
        self.navigationController?.pushViewController(profile, animated: false)
    }
}
//MARK: MatchingRegularRideOptionsDelegate
extension RecurringRideViewController: MatchingRegularRideOptionsDelegate{
    func onFailed() {}
    
    func receiveMatchingRegularRiders(matchedRegularRiders: [MatchedRegularRider]) {
        recurringRideViewModel.recommendedMatches = recurringRideViewModel.putFavouritePartnersOnTop(recommendedMatches: matchedRegularRiders)
        recurringRideTableView.reloadData()
    }
    
    func receiveMatchingRegularPassengers(matchedRegularPassengers: [MatchedRegularPassenger]) {
        recurringRideViewModel.recommendedMatches = recurringRideViewModel.putFavouritePartnersOnTop(recommendedMatches: matchedRegularPassengers)
        recurringRideTableView.reloadData()
    }
}
//MARK: RegularRideUpdateListener
extension RecurringRideViewController: RegularRideUpdateListener{
    func participantStatusUpdated(rideStatus: RideStatus) {
        if recurringRideViewModel.ride?.userId == rideStatus.userId{
            handleSelfRideUpdate(rideStatus: rideStatus)
        }else{
            handleConnectedRideUpdate(rideStatus: rideStatus)
        }
    }
    
    func handleSelfRideUpdate( rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("handleSelfRideUpdate()")
        if Ride.REGULAR_RIDER_RIDE == rideStatus.rideType{
            if Ride.RIDE_STATUS_SCHEDULED == rideStatus.status{
                recurringRideViewModel.recommendedMatches.removeAll()
                recurringRideViewModel.getRecommendedMatches(viewController: self, matchingRegularRideOptionsDelegate: self)
            }else if MyRegularRidesCache.getInstance().isRideClosed(status: rideStatus.status!){
                goBackToCallingViewController()
            }
        }else if Ride.REGULAR_PASSENGER_RIDE == rideStatus.rideType{
            if Ride.RIDE_STATUS_SCHEDULED == rideStatus.status{
                recurringRideViewModel.recommendedMatches.removeAll()
                recurringRideViewModel.connectedMatches.removeAll()
                recurringRideViewModel.getRecommendedMatches(viewController: self, matchingRegularRideOptionsDelegate: self)
                recurringRideViewModel.getConnectedMatches(viewController: self, myRegularRidesCacheListener: self)
            }else if Ride.RIDE_STATUS_REQUESTED == rideStatus.status{
                recurringRideViewModel.recommendedMatches.removeAll()
                recurringRideViewModel.connectedMatches.removeAll()
                recurringRideViewModel.getRecommendedMatches(viewController: self, matchingRegularRideOptionsDelegate: self)
                recurringRideViewModel.getConnectedMatches(viewController: self, myRegularRidesCacheListener: self)
            }else if MyRegularRidesCache.getInstance().isRideClosed(status: rideStatus.status!){
                goBackToCallingViewController()
            }
        }
    }
    
    func handleConnectedRideUpdate(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("handleConnectedRideUpdate()")
        if Ride.REGULAR_RIDER_RIDE == rideStatus.rideType{
            if MyRegularRidesCache.getInstance().isRideClosed(status: rideStatus.status!){
                recurringRideViewModel.recommendedMatches.removeAll()
                recurringRideViewModel.getRecommendedMatches(viewController: self, matchingRegularRideOptionsDelegate: self)
            }
        }else if Ride.REGULAR_PASSENGER_RIDE == rideStatus.rideType{
            if Ride.RIDE_STATUS_SCHEDULED == rideStatus.status{
                recurringRideViewModel.recommendedMatches.removeAll()
                recurringRideViewModel.connectedMatches.removeAll()
                recurringRideViewModel.getRecommendedMatches(viewController: self, matchingRegularRideOptionsDelegate: self)
                recurringRideViewModel.getConnectedMatches(viewController: self, myRegularRidesCacheListener: self)
            }else if Ride.RIDE_STATUS_REQUESTED == rideStatus.status{
                recurringRideViewModel.recommendedMatches.removeAll()
                recurringRideViewModel.connectedMatches.removeAll()
                recurringRideViewModel.getRecommendedMatches(viewController: self, matchingRegularRideOptionsDelegate: self)
                recurringRideViewModel.getConnectedMatches(viewController: self, myRegularRidesCacheListener: self)
            }else if MyRegularRidesCache.getInstance().isRideClosed(status: rideStatus.status!){
                recurringRideViewModel.recommendedMatches.removeAll()
                recurringRideViewModel.connectedMatches.removeAll()
                recurringRideViewModel.getRecommendedMatches(viewController: self, matchingRegularRideOptionsDelegate: self)
                recurringRideViewModel.getConnectedMatches(viewController: self, myRegularRidesCacheListener: self)
            }
        }
    }
}
//MARK: MyRegularRidesCacheListener
extension RecurringRideViewController: MyRegularRidesCacheListener{
    func receiveRegularPassengersInfo(passengersInfo: [MatchedRegularPassenger]?) {
        recurringRideViewModel.connectedMatches = passengersInfo ?? [MatchedRegularUser]()
        recurringRideTableView.reloadData()
    }
    
    func receiveRegularRiderInfo(riderInfo: MatchedRegularRider?) {
        recurringRideViewModel.connectedMatches = [(riderInfo ?? MatchedRegularRider())]
        recurringRideTableView.reloadData()
    }
}
//MARK: UpdateRegularRideDelegate
extension RecurringRideViewController: UpdateRegularRideDelegate{
    func updateRegularRiderRide(ride: RegularRiderRide) {
        AppDelegate.getAppDelegate().log.debug("Rider ride updated")
        recurringRideViewModel.ride = ride
        recurringRideViewModel.recommendedMatches.removeAll()
        recurringRideViewModel.connectedMatches.removeAll()
        recurringRideViewModel.getRecommendedMatches(viewController: self, matchingRegularRideOptionsDelegate: self)
        recurringRideViewModel.getConnectedMatches(viewController: self, myRegularRidesCacheListener: self)
    }
    
    func updateRegularPassengerRide(ride: RegularPassengerRide) {
        AppDelegate.getAppDelegate().log.debug("passenger ride updated")
        recurringRideViewModel.ride = ride
        recurringRideViewModel.recommendedMatches.removeAll()
        recurringRideViewModel.connectedMatches.removeAll()
        recurringRideViewModel.getRecommendedMatches(viewController: self, matchingRegularRideOptionsDelegate: self)
        recurringRideViewModel.getConnectedMatches(viewController: self, myRegularRidesCacheListener: self)
    }
}
//MARK: SelectedUserDelegate
extension RecurringRideViewController: SelectedUserDelegate{
    func selectedUser(selectedUser: MatchedUser) {
        AppDelegate.getAppDelegate().log.debug("selectedUser()")
        if recurringRideViewModel.selectedRecommendMatchesIndex != -1 &&
            !recurringRideViewModel.recommendedMatches.isEmpty{
            let matchedRegularUser = recurringRideViewModel.recommendedMatches[recurringRideViewModel.selectedRecommendMatchesIndex]
            if matchedRegularUser.userRole == MatchedUser.REGULAR_RIDER{
                let inviteRegularRider = InviteRegularRider(passengerRideId: recurringRideViewModel.ride?.rideId ?? 0, passengerId: recurringRideViewModel.ride?.userId ?? 0, matchedRegularUser: matchedRegularUser, viewcontroller: self)
                inviteRegularRider.sendInviteToRegularRider()
            }else{
                let inviteRegularPassenger = InviteRegularPassenger(matchedRegularUser: matchedRegularUser, riderRideId: recurringRideViewModel.ride?.rideId ?? 0, riderId: recurringRideViewModel.ride?.userId ?? 0, viewController: self)
                inviteRegularPassenger.sendRegularRideInvitationToPassenger()
            }
            recurringRideViewModel.selectedRecommendMatchesIndex = -1
        }
    }
}
//MARK: RouteSelectionDelegate
extension RecurringRideViewController: RouteSelectionDelegate{
    func receiveSelectedRoute(ride: Ride?, route: RideRoute) {
        recurringRideViewModel.rideRoute = route
        if ride != nil{
            recurringRideViewModel.updateRide(viewContoller: self, updateRegularRideDelegate: self)
        }
    }
    
    func recieveSelectedPreferredRoute(ride: Ride?, preferredRoute: UserPreferredRoute) {
        if let rideRoute = MyRoutesCachePersistenceHelper.getRouteFromRouteId(routeId: preferredRoute.routeId) {
            recurringRideViewModel.rideRoute = rideRoute
        }
        guard let editedRide = ride else { return }
        if preferredRoute.fromLocation != nil {
            editedRide.startLatitude = preferredRoute.fromLatitude!
            editedRide.startLongitude = preferredRoute.fromLongitude!
            editedRide.startAddress = preferredRoute.fromLocation!
        }
        if preferredRoute.toLocation != nil {
            editedRide.endLatitude = preferredRoute.toLatitude!
            editedRide.endLongitude = preferredRoute.toLongitude!
            editedRide.endAddress = preferredRoute.toLocation!
        }
        recurringRideViewModel.ride = editedRide
        recurringRideViewModel.updateRide(viewContoller: self, updateRegularRideDelegate: self)
    }
}

