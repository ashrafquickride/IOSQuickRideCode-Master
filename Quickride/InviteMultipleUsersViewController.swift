//
//  InviteMultipleUsersViewController.swift
//  Quickride
//
//  Created by rakesh on 5/19/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class InviteMultipleUsersViewController : ModelViewController,UITableViewDelegate,UITableViewDataSource,RideInvitationActionCompletionListener{
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var matchedUsersTableView: UITableView!
    
    @IBOutlet weak var acceptBtn: UIButton!
    
    @IBOutlet weak var selectAllBtn: UIButton!
    
    var rideInvites = [RideInvitation]()
    var selectedUsers : [Int : Bool] = [Int : Bool]()
    var currentUserRide : Ride?
    var riderRideId : Double?
    var selectedRideInvitation : RideInvitation?
    var liveRideViewController : BaseLiveRideMapViewController?
    var dismissHandler : DialogDismissCompletionHandler?
    var isModerator = false
    
    func initializeDataBeforePresenting(riderRideId : Double?, rideInvites : [RideInvitation],currentUserRide : Ride?,selectedRideInvitation : RideInvitation,liveRideViewController : BaseLiveRideMapViewController, isModerator: Bool, dismissHandler : DialogDismissCompletionHandler?){
        self.rideInvites = rideInvites
        self.currentUserRide = currentUserRide
        self.riderRideId = riderRideId
        self.selectedRideInvitation = selectedRideInvitation
        self.liveRideViewController = liveRideViewController
        self.isModerator = isModerator
        self.dismissHandler = dismissHandler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: acceptBtn, cornerRadius: 5.0)
        matchedUsersTableView.delegate = self
        matchedUsersTableView.dataSource = self
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InviteMultipleUsersViewController.backGroundViewClicked(_:))))
        matchedUsersTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rideInvites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MultiUserTableViewCell") as! MultiUserTableViewCell
        if rideInvites.endIndex <= indexPath.row{
            return cell
        }
        let rideInvite = rideInvites[indexPath.row]
        if selectedUsers[indexPath.row] == nil{
            if rideInvite == selectedRideInvitation{
                selectedUsers[indexPath.row] = true
            }else{
                selectedUsers[indexPath.row] = false
            }
        }
        cell.matchedUserNameLbl.text = rideInvite.invitingUserName?.capitalizingFirstLetter()
        if rideInvite.newFare > 0{
            cell.matchingPercentageLbl.text = String(describing: rideInvite.newFare)
        }else{
            cell.matchingPercentageLbl.text = String(describing: rideInvite.points!)
        }
        
        cell.pickUpTimeLbl.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: rideInvite.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        let userBasicInfo = RideInviteCache.getInstance().getUserBasicInfo(userId: rideInvite.passengerId!)
        if userBasicInfo == nil{
            RideInviteCache.getInstance().getUserBasicInfo(userId: rideInvite.riderId!, handler: { (userBasicInfo,responseError,error) in
                if userBasicInfo != nil{
                    self.matchedUsersTableView.reloadData()
                }
            })
        }else{
            self.setInvitedUserImage(invitedUser: userBasicInfo!, rideInvitation: rideInvite, cell: cell)
        }
        cell.matchedUserSelectBtn.tag = indexPath.row
        setSelectButtonBasedOnSelection(isSelected: selectedUsers[indexPath.row],button: cell.matchedUserSelectBtn)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rideInvite = rideInvites[indexPath.row]
        selectedRideInvitation = rideInvite
        RouteMatcherServiceClient.getMatchingPassenger(passengerRideId: rideInvite.passenegerRideId!, riderRideId: rideInvite.rideId!, targetViewController: self) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let matchedUser = Mapper<MatchedPassenger>().map(JSONObject: responseObject!["resultData"])
                if matchedUser != nil{
                    rideInvite.matchPercentageOnPassengerRoute = matchedUser!.matchPercentageOnMatchingUserRoute
                    rideInvite.matchPercentageOnRiderRoute = matchedUser!.matchPercentage!
                    if rideInvite.newFare != -1{
                        matchedUser!.newFare = rideInvite.newFare
                    }
                    if matchedUser!.pickupLocationAddress == nil{
                        matchedUser!.pickupLocationAddress = rideInvite.pickupAddress
                        matchedUser!.pickupLocationLatitude = rideInvite.pickupLatitude
                        matchedUser!.pickupLocationLongitude = rideInvite.pickupLongitude
                    }
                    if matchedUser!.dropLocationAddress == nil{
                        matchedUser!.dropLocationAddress = rideInvite.dropAddress
                        matchedUser!.dropLocationLatitude = rideInvite.dropLatitude
                        matchedUser!.dropLocationLongitude = rideInvite.dropLongitude
                    }
                    self.rideInvites[indexPath.row] = rideInvite
                    self.moveToRideDetailView(matchedUser: matchedUser!)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func setInvitedUserImage(invitedUser : UserBasicInfo,rideInvitation : RideInvitation,cell : MultiUserTableViewCell){
        ImageCache.getInstance().setImageToView(imageView: cell.matchedUserImageView, imageUrl: invitedUser.imageURI, gender: invitedUser.gender!,imageSize: ImageCache.DIMENTION_TINY)
    }
    func moveToRideDetailView(matchedUser : MatchedUser){
        
        self.view.removeFromSuperview()
        self.removeFromParent()
        var riderRideObj = currentUserRide
        if isModerator, let rideId = selectedRideInvitation?.rideId{
            riderRideObj = MyActiveRidesCache.singleCacheInstance?.getRiderRideFromRideDetailInfo(rideId: rideId)
            if riderRideObj == nil {
                riderRideObj = currentUserRide
            }
        }
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController

        mainContentVC.initializeData(ride: currentUserRide!, matchedUserList: [matchedUser], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, isFromJoinMyRide: false, selectedUserDelegate: nil)
        let drawerContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedViewController") as! RideDetailedViewController
        drawerContentVC.initializeData(ride: currentUserRide!, matchedUserList: [matchedUser], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, isFromJoinMyRide: false, selectedUserDelegate: nil, matchedUserDataChangeDelagate: mainContentVC.self)
        ViewControllerUtils.addPulleyViewController(mainContentViewController: mainContentVC, drawerContentViewController: drawerContentVC, currentViewController: self)
    }
    @objc func backGroundViewClicked(_ gesture : UITapGestureRecognizer){
        removeViewFromSuperView()
    }
    
    func setSelectButtonBasedOnSelection(isSelected : Bool?,button : UIButton){
        if isSelected != nil && isSelected == true{
            
            button.setImage(UIImage(named: "group_tick_icon"), for: .normal)
            
        }else{
            button.setImage(UIImage(named: "tick_icon"), for: .normal)
            
        }
        
    }
    @IBAction func selectInviteBtnClicked(_ sender: UIButton) {
        
        if selectedUsers[sender.tag] == nil{
            selectedUsers[sender.tag] = true
        }else if selectedUsers[sender.tag] == false{
            selectedUsers[sender.tag] = true
        }else{
            selectedUsers[sender.tag] = false
        }
        var count = 0
        for value in selectedUsers.values{
            if value{
                count += 1
            }
        }
        var riderRideObj = currentUserRide
        if isModerator, let rideId = selectedRideInvitation?.rideId{
            riderRideObj = MyActiveRidesCache.singleCacheInstance?.getRiderRideFromRideDetailInfo(rideId: rideId)
            if riderRideObj == nil {
                riderRideObj = currentUserRide
            }
        }
        if let riderRide = riderRideObj as? RiderRide {
            if count == riderRide.availableSeats + 1 {
                UIApplication.shared.keyWindow?.makeToast(message: Strings.passengers_more_than_available, duration: 5.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-300))
            }
            if let cell = matchedUsersTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? MultiUserTableViewCell{
                setSelectButtonBasedOnSelection(isSelected: selectedUsers[sender.tag],button: cell.matchedUserSelectBtn)
            }else{
                matchedUsersTableView.reloadData()
            }
        }
    }
    
    @IBAction func acceptBtnClicked(_ sender: Any) {
        
        removeViewFromSuperView()
        
        var rideInvitesToBeAccepted = [RideInvitation]()
        for index in 0...rideInvites.count-1{
            if selectedUsers[index] == true{
                rideInvitesToBeAccepted.append(rideInvites[index])
            }
        }
        if rideInvitesToBeAccepted.isEmpty{
            UIApplication.shared.keyWindow?.makeToast(message: Strings.empty_invite_accept_message, duration: 3.0)
            return
        }
        let jsonString = rideInvitesToBeAccepted.toJSONString()
        if jsonString == nil
        {
            return
        }
        
        QuickRideProgressSpinner.startSpinner()
        RiderRideRestClient.addMultiplePassengersToRide(riderRideId: self.riderRideId!, rideInviteString: jsonString!, moderatorId: isModerator ? QRSessionManager.getInstance()?.getUserId() : nil , ViewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                
                let rideInvitesResponse = Mapper<MultipleAcceptResponse>().mapArray(JSONObject: responseObject!["resultData"])
                if rideInvitesResponse != nil && !rideInvitesResponse!.isEmpty{
                    var failedUserInvites = [RideInvitation]()
                    for response in rideInvitesResponse!{
                        if response.error != nil {
                            let failedInvitation = self.getFailedInvitationFromInviteId(invitationId: response.inviteId!)
                            if failedInvitation != nil{
                                failedUserInvites.append(failedInvitation!)
                            }
                        }else{
                            self.deleteAcceptedInvitations(invitationId: response.inviteId!, rideInvitations: rideInvitesToBeAccepted)
                        }
                    }
                    if !failedUserInvites.isEmpty{
                        self.displayFailureToastForFailedInvites(failedUserInvites: failedUserInvites)
                    }
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
            }
        }
    }
    
    func displayFailureToastForFailedInvites(failedUserInvites : [RideInvitation]){
        var failedUserNameString = ""
        for invite in failedUserInvites{
            failedUserNameString = failedUserNameString + invite.invitingUserName! + ","
        }
        
        UIApplication.shared.keyWindow?.makeToast(message: String(format: Strings.accepting_invites_failed,failedUserNameString.substring(to: failedUserNameString.index(before: failedUserNameString.endIndex))))
    }
    
    func getFailedInvitationFromInviteId(invitationId : Double) -> RideInvitation?{
        for rideInvitation in rideInvites{
            if rideInvitation.rideInvitationId == invitationId{
                return rideInvitation
            }
        }
        return nil
    }
    
    func deleteAcceptedInvitations(invitationId : Double,rideInvitations : [RideInvitation]){
        for rideInvite in rideInvitations{
            if rideInvite.rideInvitationId == invitationId{
                self.removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED, rideInvitation: rideInvite)
            }
        }
    }
    
    @IBAction func declineButtonClicked(_ sender: Any) {
        
        rejectRideInvite(isFromRideDetailView: false)
    }
    
    func rejectRideInvite(isFromRideDetailView : Bool){
        let rejectReasonAlertController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "RejectCustomAlertController")as! RejectCustomAlertController
        rejectReasonAlertController.initializeDataBeforePresentingView(title: Strings.do_u_have_reason, positiveBtnTitle: Strings.confirm_caps, negativeBtnTitle: Strings.skip_caps, viewController: ViewControllerUtils.getCenterViewController(), rideType: Ride.RIDER_RIDE) { (text, result) in
            
            if result == Strings.confirm_caps{
                self.removeViewFromSuperView()
                self.completeRejectAction(rejectReason: text,isFromRideDetailInfo:isFromRideDetailView )
                
            }
        }
    }
    
    func selectedUser(selectedUser: MatchedUser) {
        
        selectedRideInvitation?.matchPercentageOnPassengerRoute = selectedUser.matchPercentageOnMatchingUserRoute
        if (selectedRideInvitation!.fareChange)
        {
            if (selectedUser.newFare > selectedRideInvitation!.newFare){
                invitePassenger(selectedUser: selectedUser)
            }
            else{
                initiatiteRideJoin(selectedUser: selectedUser)
            }
        }
        else if (selectedUser.newFare != -1) && (selectedUser.newFare > selectedUser.points!)
        {
            invitePassenger(selectedUser: selectedUser)
        }
        else{
            initiatiteRideJoin(selectedUser: selectedUser)
            
        }
        
    }
    func initiatiteRideJoin(selectedUser : MatchedUser){
        selectedRideInvitation!.pickupTime = selectedUser.pickupTime
        selectedRideInvitation!.dropTime = selectedUser.dropTime
        selectedRideInvitation!.pickupLatitude = selectedUser.pickupLocationLatitude
        selectedRideInvitation!.pickupLongitude = selectedUser.pickupLocationLongitude
        selectedRideInvitation!.pickupAddress = selectedUser.pickupLocationAddress
        selectedRideInvitation!.dropLatitude = selectedUser.dropLocationLatitude
        selectedRideInvitation!.dropLongitude = selectedUser.dropLocationLongitude
        selectedRideInvitation!.dropAddress = selectedUser.dropLocationAddress
        selectedRideInvitation!.newFare = selectedUser.newFare
        selectedRideInvitation!.points = selectedUser.points
        joinRide(displayPointsConfirmation : false,pickUpTimeRecalculationRequired : selectedUser.pickupTimeRecalculationRequired)
    }
    func rejectUser(selectedUser: MatchedUser) {
        self.removeViewFromSuperView()
        rejectRideInvite(isFromRideDetailView: true)
    }
    
    func notSelected() {
        displayView()
    }
    
    func displayView(){
        ViewControllerUtils.addSubView(viewControllerToDisplay: self)
    }
    
    func joinRide(displayPointsConfirmation : Bool,pickUpTimeRecalculationRequired : Bool){
        let joinPassengerToRideHandler = JoinPassengerToRideHandler(viewController: self, riderRideId: riderRideId!, riderId: selectedRideInvitation!.riderId!, passengerRideId: selectedRideInvitation!.passenegerRideId!, passengerId: selectedRideInvitation!.passengerId!, rideType: selectedRideInvitation!.rideType, pickupAddress: selectedRideInvitation!.pickupAddress, pickupLatitude: selectedRideInvitation!.pickupLatitude!, pickupLongitude: selectedRideInvitation!.pickupLongitude!, pickupTime: selectedRideInvitation!.pickupTime!, dropAddress: selectedRideInvitation!.dropAddress, dropLatitude: selectedRideInvitation!.dropLatitude!, dropLongitude: selectedRideInvitation!.dropLongitude!, dropTime: selectedRideInvitation!.dropTime!, matchingDistance: selectedRideInvitation!.matchedDistance!, points: selectedRideInvitation!.points!,newFare: (selectedRideInvitation?.newFare)!, noOfSeats: selectedRideInvitation!.noOfSeats!, rideInvitationId: selectedRideInvitation!.rideInvitationId!,invitingUserName: selectedRideInvitation!.invitingUserName! ,invitingUserId :selectedRideInvitation!.invitingUserId!,displayPointsConfirmationAlert: displayPointsConfirmation, riderHasHelmet: false, pickupTimeRecalculationRequired: pickUpTimeRecalculationRequired,passengerRouteMatchPercentage: selectedRideInvitation!.matchPercentageOnPassengerRoute,riderRouteMatchPercentage: selectedRideInvitation!.matchPercentageOnRiderRoute, moderatorId: isModerator ? QRSessionManager.getInstance()?.getUserId() : nil,listener :self)
        
        joinPassengerToRideHandler.joinPassengerToRide()
    }
    
    func completeRejectAction(rejectReason : String?,isFromRideDetailInfo : Bool){
        
        if !isFromRideDetailInfo{
            var rideInvitesToBeDeclined = [RideInvitation]()
            for index in 0...rideInvites.count-1{
                if selectedUsers[index] == true{
                    rideInvitesToBeDeclined.append(rideInvites[index])
                }
            }
            if rideInvitesToBeDeclined.isEmpty{
                UIApplication.shared.keyWindow?.makeToast(message: Strings.empty_invite_decline_message, duration: 3.0)
                return
            }
            for rideInvitation in rideInvitesToBeDeclined{
                let riderRejectPassengerInvitationTask = RiderRejectPassengerInvitationTask(rideInvitation: rideInvitation, moderatorId: isModerator ? QRSessionManager.getInstance()?.getUserId() : nil, viewController: self, rideRejectReason: rejectReason, rideInvitationActionCompletionListener: self)
                riderRejectPassengerInvitationTask.rejectPassengerInvitation()
            }
        }else{
            let riderRejectPassengerInvitationTask = RiderRejectPassengerInvitationTask(rideInvitation: selectedRideInvitation!, moderatorId: isModerator ? QRSessionManager.getInstance()?.getUserId() : nil, viewController: self, rideRejectReason: rejectReason, rideInvitationActionCompletionListener: self)
            riderRejectPassengerInvitationTask.rejectPassengerInvitation()
        }
        
    }
    
    func rideInviteRejectCompleted(rideInvitation: RideInvitation) {
        removeViewFromSuperView()
        removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_REJECTED, rideInvitation: rideInvitation)
    }
    
    func rideInviteAcceptCompleted(rideInvitationId: Double) {
        removeViewFromSuperView()
        removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED, rideInvitation: selectedRideInvitation!)
    }
    
    func rideInviteActionFailed(responseError: ResponseError?, error: NSError?, isNotificationRemovable: Bool) {
        removeViewFromSuperView()
        if responseError != nil{
            if responseError!.errorCode == RideValidationUtils.PASSENGER_ALREADY_JOINED_THIS_RIDE{
                self.removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED, rideInvitation: selectedRideInvitation!)
            } else if responseError!.errorCode == RideValidationUtils.PASSENGER_ENGAGED_IN_OTHER_RIDE || responseError!.errorCode == RideValidationUtils.INSUFFICIENT_SEATS_ERROR {
                self.removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_REJECTED, rideInvitation: selectedRideInvitation!)
            } else if responseError!.errorCode == RideValidationUtils.RIDE_ALREADY_COMPLETED || responseError!.errorCode == RideValidationUtils.RIDER_ALREADY_CROSSED_PICK_UP_POINT_ERROR || responseError!.errorCode == RideValidationUtils.RIDE_CLOSED_ERROR {
                self.removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED, rideInvitation: selectedRideInvitation!)
            } else {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: ViewControllerUtils.getCenterViewController())
            }
        }else{
            ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: ViewControllerUtils.getCenterViewController())
        }
    }
    
    func rideInviteActionCancelled() { }
    
    func removeInvitationAndRefreshData(status : String,rideInvitation : RideInvitation){
        let rideInvitationStatus = RideInviteStatus(rideInvitation: rideInvitation)
        rideInvitation.invitationStatus = RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED
        NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: rideInvitationStatus.invitationId)
        RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
        
        if self.liveRideViewController != nil{
            self.liveRideViewController!.validateAndGetRideInvites()
        }
    }
    
    func invitePassenger(selectedUser : MatchedUser){
        let ride = MyActiveRidesCache.singleCacheInstance?.getRiderRide(rideId: selectedRideInvitation!.rideId!)
        if ride == nil{
            return
        }
        var selectedPassengers = [MatchedPassenger]()
        selectedPassengers.append(selectedUser as! MatchedPassenger)
        InviteSelectedPassengersAsyncTask(riderRide: ride!, selectedUsers: selectedPassengers, viewController: self, displaySpinner: true, selectedIndex: nil, invitePassengersCompletionHandler: { (error,nserror) in
        }).invitePassengersFromMatches()
    }
    
    @IBAction func selectAllBtnClicked(_ sender: Any) {
        if selectAllBtn.currentTitle == Strings.select_all {
            selectAllBtn.setTitle(Strings.deselect_all, for: .normal)
            for (index,_) in rideInvites.enumerated(){
                selectedUsers[index] = true
            }
            matchedUsersTableView.reloadData()
        }else{
            selectAllBtn.setTitle(Strings.select_all, for: .normal)
            selectedUsers.removeAll()
            selectedRideInvitation = nil
            matchedUsersTableView.reloadData()
        }
        
    }
    func removeViewFromSuperView()
    {
        if self.dismissHandler != nil
        {
            self.dismissHandler!()
        }
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    
}
