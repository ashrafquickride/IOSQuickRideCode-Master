//
//  RecommendedMatchesViewController.swift
//  Quickride
//
//  Created by USER on 02/04/19.
//  Copyright © 2019 iDisha. All rights reserved.
//

import Foundation

class RecommendedMatchesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SelectedUserDelegate, UserSelectedDelegate, MatchingRegularRideOptionsDelegate, MyRegularRidesCacheListener, RegularRideUpdateListener{
    
    
    @IBOutlet weak var recommendationTableView: UITableView!
    
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    var connectedUsers : [MatchedRegularUser] = [MatchedRegularUser]()
    var recommededMatchedusers : [MatchedRegularUser] = [MatchedRegularUser]()
    var showDays : [Int : Bool] = [Int: Bool]()
    var fromRideView = false
    var defaultDate : Double?
    var isExpanded = false
    var finishIfNoMatchedFound : Bool = false
    var selectedRecommendMatchesIndex = -1
    var ride : Ride?

    func initializeDataBeforeViewPresentingView(connectedUsers : [MatchedRegularUser], matchedUsers : [MatchedRegularUser], ride: Ride){
        self.connectedUsers = connectedUsers
        self.recommededMatchedusers = matchedUsers
        self.ride = ride
        if connectedUsers.isEmpty == false{
           self.title = Strings.connected_matches
        }else{
            self.title = Strings.recommended_matches
        }
    }
    
    override func viewDidLoad() {
        MyRegularRidesCache.getInstance().addRideUpdateListener(rideId: ride!.rideId, listener: self)
        recommendationTableView.dataSource = self
        recommendationTableView.delegate = self
       recommendationTableView.reloadData()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        AppDelegate.getAppDelegate().log.debug("numberOfSectionsInTableView()")
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AppDelegate.getAppDelegate().log.debug("tableView() numberOfRowsInSection() Number of rows in section \(section)")
        if section == 0{
            return connectedUsers.count
        }else{
            return recommededMatchedusers.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecomendCell", for: indexPath) as! RecomendTableViewCell
        let matchedUser : MatchedRegularUser
        ViewCustomizationUtils.addBorderToView(view: cell.sendInviteBtn, borderWidth: 1.0, color: UIColor(netHex:0x40CB5B))
        ViewCustomizationUtils.addCornerRadiusToView(view: cell.sendInviteBtn, cornerRadius: 8.0)
        if  indexPath.section == 0{
            if self.connectedUsers.endIndex <= indexPath.row{
                recommendationTableView.reloadData()
                return cell
            }
            matchedUser  = self.connectedUsers[indexPath.row]
            cell.moreButton.isHidden = true
            cell.buttonArrow.isHidden = true
            cell.daysDisplayView.isHidden = false
            cell.daysDisplayViewHeight.constant = 45
            cell.displayDaysView(matchedRegularUser: matchedUser)
            cell.inviteAndRemoveClicked(value: Strings.remove)
        }else{
            if self.recommededMatchedusers.endIndex <= indexPath.row{
                recommendationTableView.reloadData()
                return cell
            }
            matchedUser  = self.recommededMatchedusers[indexPath.row]
            cell.moreButton.isHidden = false
            cell.buttonArrow.isHidden = false
            cell.moreButton.tag = indexPath.row
            cell.buttonArrow.tag = indexPath.row
            if self.showDays[indexPath.row] == nil{
                showDays[indexPath.row] = false
                cell.daysDisplayView.isHidden = true
                cell.daysDisplayViewHeight.constant = 0
            }
            if self.showDays[indexPath.row] == true{
                cell.daysDisplayView.isHidden = false
                cell.daysDisplayViewHeight.constant = 45
                cell.displayDaysView(matchedRegularUser: matchedUser)
            }
            else{
                cell.daysDisplayView.isHidden = true
                cell.daysDisplayViewHeight.constant = 0
            }
            
            cell.inviteAndRemoveClicked(value: Strings.invite)
            
        }
        cell.sendInviteBtn.tag = indexPath.row
        
        cell.initializeViews(matchedUser:  matchedUser, viewController : self, section: indexPath.section)
        let isFavoritePartner = UserDataCache.getInstance()!.isFavouritePartner(userId: matchedUser.userid!)
        if !isFavoritePartner{
            cell.favoritePartnerImage.isHidden = true
        }else{
            cell.favoritePartnerImage.isHidden = false
        }
        cell.userNameLbl.text = matchedUser.name
        cell.ratingLabel.text = "(\(String(matchedUser.noOfReviews)))"
        cell.fromLbl.text = matchedUser.fromLocationAddress
        cell.toLbl.text = matchedUser.toLocationAddress
        cell.userImageView.image = nil
        if let image = ImageCache.getInstance()?.getUserImage(imageUrl: matchedUser.imageURI,gender: matchedUser.gender){
            cell.userImageView.image = image
        }else{
            ImageCache.getInstance()?.getUserImage(imageUrl: matchedUser.imageURI, gender: matchedUser.gender, imageRetrievalHandler: { (image) in
                self.recommendationTableView.reloadData()
            })
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppDelegate.getAppDelegate().log.debug("tableView() didSelectRowAtIndexPath()")
        if indexPath.section == 0{
            self.moveToConnectedProfile(indexPath: indexPath)
        }else if indexPath.section == 1{
            self.moveToRideDetailView(indexPath: indexPath)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
            if (indexPath.section == 0 && indexPath.row == 0) {
                return 165
            }
                
            else if (indexPath.section == 1 && indexPath.row == 0)
            {
                if self.showDays[indexPath.row] == true{
                    return 220
                }
                else
                {
                    return 180
                }
            }
            else if indexPath.section == 1{
                if self.showDays[indexPath.row] == true{
                    return 205
                }
                else
                {
                    return 165
                }
            }
            else{
                return 145
            }
    }
    func moveToConnectedProfile(indexPath: IndexPath){
        let connectedUser = connectedUsers[indexPath.row]
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
        profile.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: connectedUser.userid!),isRiderProfile: userRole,rideVehicle: vehicle, userSelectionDelegate: self,displayAction: false,supportCall: UserProfile.isCallSupportAfterJoined(callSupport: connectedUser.callSupport, enableChatAndCall: connectedUser.enableChatAndCall), isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: connectedUser.userOnTimeComplianceRating, noOfSeats: nil)
        self.navigationController?.pushViewController(profile, animated: false)
    }
    func moveToRideDetailView(indexPath: IndexPath){
        let rideDetailViewController = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.rideDetailViewController) as! BaseRideDetailViewController
        let matchedUser = recommededMatchedusers[indexPath.row]
        selectedRecommendMatchesIndex = indexPath.row
        rideDetailViewController.initializeDataBeforePresenting(matchedUsersList: [matchedUser], selectedIndex: 0,ride: ride!, selectedUserDelegate: self,showJoinButton: true,showAcceptButton: false,startAndEndChangeRequired: false, isFromRegularRide: true)
        self.navigationController?.pushViewController(rideDetailViewController, animated: false)
    }

    @IBAction func SendInviteAndRemoveButtonAction(_ sender: UIButton) {
        AppDelegate.getAppDelegate().log.debug("SendInviteAndRemoveButtonAction()")
        if sender.titleLabel?.text == Strings.remove{
            
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.ride_cancel_title, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if result == Strings.yes_caps{
                    var regularPassngerRideId : Double? = 0
                    if self.ride?.rideType == Ride.REGULAR_PASSENGER_RIDE{
                        regularPassngerRideId = self.ride?.rideId
                    }else{
                        regularPassngerRideId = self.connectedUsers[sender.tag].rideid
                    }
                    QuickRideProgressSpinner.startSpinner()
                    RideServicesClient.unJoinParticipantFromRegularRide(regularPassengerRideId: regularPassngerRideId!, rideType: (self.ride?.rideType)!, viewController: self, completionHandler: { (responseObject, error) -> Void in
                        QuickRideProgressSpinner.stopSpinner()
                        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.RECURRING_RIDE_JOINED, params: ["from" : self.ride?.startAddress,"to" : self.ride?.endAddress,"rideId" : self.ride?.rideId])
                    })
                }
            })
        }else{
            if recommededMatchedusers.isEmpty == false && sender.tag <= recommededMatchedusers.count{
                inviteSelectedUser(matchedRegularUser: recommededMatchedusers[sender.tag])
            }
        }
    }
    func inviteSelectedUser(matchedRegularUser : MatchedRegularUser){
        AppDelegate.getAppDelegate().log.debug("inviteSelectedUser()")
        if matchedRegularUser.userRole == MatchedUser.REGULAR_RIDER{
            let inviteRegularRider = InviteRegularRider(passengerRideId: ride!.rideId, passengerId: (ride?.userId)!, matchedRegularUser: matchedRegularUser, viewcontroller: self)
            inviteRegularRider.sendInviteToRegularRider()
        }else{
            let inviteRegularPassenger = InviteRegularPassenger(matchedRegularUser: matchedRegularUser, riderRideId: (ride?.rideId)!, riderId: (ride?.userId)!, viewController: self)
            inviteRegularPassenger.sendRegularRideInvitationToPassenger()
        }
    }
    
    func participantStatusUpdated(rideStatus: RideStatus) {
        AppDelegate.getAppDelegate().log.debug("participantStatusUpdated()")
        ride = getRide(rideId: ride!.rideId,rideType : ride!.status)
        if ride?.userId == rideStatus.userId{
            handleSelfRideUpdate(rideStatus: rideStatus)
        }else{
            handleConnectedRideUpdate(rideStatus: rideStatus)
        }
    }
    
    func getRide(rideId : Double,rideType : String) -> Ride{
        if rideType == Ride.REGULAR_RIDER_RIDE{
            ride = MyRegularRidesCache.getInstance().getRegularRiderRide(riderRideId: rideId)
        }else if rideType == Ride.REGULAR_PASSENGER_RIDE{
            ride = MyRegularRidesCache.getInstance().getRegularPassengerRide(passengerRideId: rideId)
        }
        return ride!
    }
    
    func handleSelfRideUpdate( rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("handleSelfRideUpdate()")
        if Ride.REGULAR_PASSENGER_RIDE == rideStatus.rideType{
            if Ride.RIDE_STATUS_SCHEDULED == rideStatus.status{
                getConnectedMatches()
                removeRecommendedMatches()
            }else if Ride.RIDE_STATUS_REQUESTED == rideStatus.status{
                getRecommendedMatches()
                removeConnectedMatches()
            }
        }
    }
    
    func handleConnectedRideUpdate(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("handleConnectedRideUpdate()")
        if Ride.REGULAR_RIDER_RIDE == rideStatus.rideType{
            if MyRegularRidesCache.getInstance().isRideClosed(status: rideStatus.status!){
                getRecommendedMatches()
                removeConnectedMatches()
            }
        }else if Ride.REGULAR_PASSENGER_RIDE == rideStatus.rideType{
            if Ride.RIDE_STATUS_SCHEDULED == rideStatus.status{
                getConnectedMatches()
                removeRecommendedMatches()
                getRecommendedMatches()
            }else if Ride.RIDE_STATUS_REQUESTED == rideStatus.status{
                getRecommendedMatches()
                getConnectedMatches()
            }else if MyRegularRidesCache.getInstance().isRideClosed(status: rideStatus.status!){
                getRecommendedMatches()
                getConnectedMatches()
            }
        }
    }
    
    func getRecommendedMatches(){
        AppDelegate.getAppDelegate().log.debug("getRecommendedMatches()")
        if ride?.status == Ride.RIDE_STATUS_SUSPENDED{
            return
        }
        if Ride.REGULAR_PASSENGER_RIDE == ride?.rideType && Ride.RIDE_STATUS_REQUESTED == ride?.status  {
            
            let findMatchingRegularRiders : FindMatchingRegularRiders = FindMatchingRegularRiders(rideId: ride!.rideId, viewController: self, delegate: self)
            findMatchingRegularRiders.getMatchingRegularRiders()
            
        }else if Ride.REGULAR_RIDER_RIDE == ride?.rideType{
            let findMatchingRegularPassengers : FindMatchingRegularPassengers = FindMatchingRegularPassengers(rideId: (ride?.rideId)!, viewController: self, delegate: self)
            findMatchingRegularPassengers.getMatchingRegularPassengers()
        }else{
            recommededMatchedusers.removeAll()
        }
    }
    func getConnectedMatches(){
        AppDelegate.getAppDelegate().log.debug("getConnectedMatches()")
        if ride?.status == Ride.RIDE_STATUS_SUSPENDED{
            return
        }
        if Ride.REGULAR_RIDER_RIDE == ride?.rideType && (ride as! RegularRiderRide).noOfPassengers > 0 {
            MyRegularRidesCache.getInstance().getConnectedPassengersOfRegularRiderRide(rideId: (ride?.rideId)!, viewController: self, listener: self)
        }else if Ride.REGULAR_PASSENGER_RIDE == ride?.rideType && ride?.status != Ride.RIDE_STATUS_REQUESTED {
            MyRegularRidesCache.getInstance().getConnectedRiderOfRegularPassengerRide(regularPassengerRideId: (ride?.rideId)!, regularRiderRideId: (ride as! RegularPassengerRide).regularRiderRideId, viewController: self, listener: self)
        }else{
            connectedUsers.removeAll()
            
        }
    }
    
    func receiveMatchingRegularPassengers(matchedRegularPassengers: [MatchedRegularPassenger]) {
        AppDelegate.getAppDelegate().log.debug("receiveMatchingRegularPassengers()")
        
        recommededMatchedusers.removeAll()
        if matchedRegularPassengers.isEmpty == true{
            recommendationTableView.reloadData()
        }else{
            
            for matchedPassenger in matchedRegularPassengers{
                recommededMatchedusers.append(matchedPassenger)
            }
            recommededMatchedusers = putFavouritePartnersOnTop(actualMatchedUsers: recommededMatchedusers) as! [MatchedRegularUser]
            recommendationTableView.reloadData()
        }
    }
    
    func receiveMatchingRegularRiders(matchedRegularRiders: [MatchedRegularRider]) {
        AppDelegate.getAppDelegate().log.debug("receiveMatchingRegularRiders()")
        recommededMatchedusers.removeAll()
        if matchedRegularRiders.isEmpty{
            recommendationTableView.reloadData()
        }else{
            
            for matchedRider in matchedRegularRiders{
                recommededMatchedusers.append(matchedRider)
            }
            recommededMatchedusers = putFavouritePartnersOnTop(actualMatchedUsers: recommededMatchedusers) as! [MatchedRegularUser]
            recommendationTableView.reloadData()
        }
    }
    
    func receiveRegularPassengersInfo(passengersInfo: [MatchedRegularPassenger]?) {
        AppDelegate.getAppDelegate().log.debug("receiveRegularPassengersInfo()")
        self.connectedUsers = passengersInfo!
        connectedUsers = putFavouritePartnersOnTop(actualMatchedUsers: connectedUsers) as! [MatchedRegularUser]
        recommendationTableView.reloadData()
    }
    func receiveRegularRiderInfo(riderInfo: MatchedRegularRider?) {
        AppDelegate.getAppDelegate().log.debug("receiveRegularRiderInfo()")
        connectedUsers.removeAll()
        self.connectedUsers.append(riderInfo!)
        connectedUsers = putFavouritePartnersOnTop(actualMatchedUsers: connectedUsers) as! [MatchedRegularUser]
        recommendationTableView.reloadData()
    }
    
    func putFavouritePartnersOnTop(actualMatchedUsers : [MatchedUser]) -> [MatchedUser]
    {
        var connectedMatchedUsers = [MatchedUser]()
        var newMatchedUsers = [MatchedUser]()
        
        for matchedUser in actualMatchedUsers
        {
            if UserDataCache.getInstance()!.isFavouritePartner(userId: matchedUser.userid!)
            {
                connectedMatchedUsers.append(matchedUser)
            }else{
                newMatchedUsers.append(matchedUser)
            }
        }
        connectedMatchedUsers.append(contentsOf: newMatchedUsers)
        return connectedMatchedUsers
    }
    
    func onFailed() {
        
    }
    
    func removeConnectedMatches(){
        AppDelegate.getAppDelegate().log.debug("removeConnectedMatches()")
        recommendationTableView.delegate = nil
        recommendationTableView.dataSource = nil
        connectedUsers.removeAll()
        recommendationTableView.delegate = self
        recommendationTableView.dataSource = self
        recommendationTableView.reloadData()
    }
    func removeRecommendedMatches(){
        AppDelegate.getAppDelegate().log.debug("removeRecommendedMatches()")
        recommendationTableView.delegate = nil
        recommendationTableView.dataSource = nil
        recommededMatchedusers.removeAll()
        recommendationTableView.delegate = self
        recommendationTableView.dataSource = self
        recommendationTableView.reloadData()
    }
    func selectedUser(selectedUser: MatchedUser) {
        AppDelegate.getAppDelegate().log.debug("selectedUser()")
        
        if selectedRecommendMatchesIndex != -1{
            recommededMatchedusers[selectedRecommendMatchesIndex] = selectedUser as! MatchedRegularUser
            inviteSelectedUser(matchedRegularUser: selectedUser as! MatchedRegularUser)
            selectedRecommendMatchesIndex = -1
        }
    }
    @IBAction func moreBtnTapped(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 1)
        if let cell = recommendationTableView.cellForRow(at: IndexPath(row: sender.tag, section: 1)) as? RecomendTableViewCell{
            if cell.daysDisplayView.isHidden{
                cell.buttonArrow.setImage(UIImage(named: "up_arrow_blue"), for: .normal)
                cell.moreButton.setTitle(Strings.less, for: UIControl.State.normal)
                showDays[indexPath.row] = true
            }else{
                cell.buttonArrow.setImage(UIImage(named: "down_arrow_blue"), for: .normal)
                cell.moreButton.setTitle(Strings.more, for: UIControl.State.normal)
                showDays[indexPath.row] = false
            }
            recommendationTableView.reloadData()
        }
    }
   
    
    @IBAction func backBtnTapped(_ sender: Any) {
        MyRegularRidesCache.getInstance().removeRideUpdateListenre(rideId: (ride?.rideId)!)
        self.navigationController?.popViewController(animated: false)
    }
    
}
