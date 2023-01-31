//
//  RidesTableViewCell.swift
//  Quickride
//
//  Created by Admin on 31/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RidesTableViewCell : UITableViewCell{
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var iboProfileImage: UIImageView!
    
    @IBOutlet weak var userDetailsView: UIView!
    
    @IBOutlet weak var rideStatus: UILabel!
    
    @IBOutlet weak var iboProfileName: UILabel!
    
    @IBOutlet weak var verificationBadge: UIImageView!
    
    @IBOutlet weak var companyName: UILabel!
    
    @IBOutlet weak var iboStartLocationAddress: UILabel!
    
    @IBOutlet weak var iboEndLocationAddress: UILabel!
    
    @IBOutlet weak var lineView: UIView!
    
    @IBOutlet weak var iboPointsAvailableForPassenger: UILabel!
    
    @IBOutlet weak var iboPointsAvailableForRider: UILabel!
    
    @IBOutlet weak var amOrPMLabelForPassenger: UILabel!
    
    @IBOutlet weak var amOrPMLabelForRider: UILabel!
    
    @IBOutlet weak var ratingLabelForRider: UILabel!
    
    @IBOutlet weak var ratingLabelForPassenger: UILabel!
    
    @IBOutlet weak var iboStartTimeForRider: UILabel!
    
    @IBOutlet weak var iboStartTimeForPassenger: UILabel!
    
    @IBOutlet weak var noOfReviewsForPassenger: UILabel!
    
    @IBOutlet weak var noOfReviewsForRider: UILabel!
    
    @IBOutlet weak var inviteRemindView: UIView!
    @IBOutlet weak var inviteProgressImageView: UIImageView!
    
    @IBOutlet weak var sendInviteButton: UIButton!
    
    var selectedUser : Bool = false
    var matchedUser:MatchedUser?
    var userSelectionDelegate:UserSelectionDelegate?
    var row:Int?
    var rideId : Double?
    var rideType : String?
    weak var viewController : UIViewController?
    var ride : Ride?
    var clientConfiguration : ClientConfigurtion?
    var rideInviteActionCompletionListener : RideInvitationActionCompletionListener?
    
    
    func initializeViews(rideId : Double?, rideType : String?,matchedUser:MatchedUser,viewController : UIViewController, row: Int,ride : Ride?,rideInviteActionCompletionListener : RideInvitationActionCompletionListener?){
        
        self.rideId = rideId
        self.rideType = rideType
        self.viewController = viewController
        self.row = row
        self.matchedUser = matchedUser
        self.ride = ride
        self.rideInviteActionCompletionListener = rideInviteActionCompletionListener
        self.iboProfileName.text = matchedUser.name
        self.iboStartLocationAddress.text = matchedUser.fromLocationAddress
        self.iboEndLocationAddress.text = matchedUser.toLocationAddress
        if matchedUser.newFare != -1{
            self.getPointsLabel().attributedText = FareChangeUtils.getFareDetails(newFare: matchedUser.newFare,actualFare:  matchedUser.points!, rideType : rideType ?? Ride.RIDER_RIDE, textColor: getPointsLabel().textColor)
            
        }else{
            self.getPointsLabel().text = StringUtils.getStringFromDouble(decimalNumber: matchedUser.points!)
        }
       
        self.iboProfileImage.isUserInteractionEnabled = true
        self.iboProfileImage.addGestureRecognizer(UITapGestureRecognizer(target: self , action: #selector(MatchedRidesTableViewCell.tapped(_:))))
        setRating()
        setVerificationLabel()
        checkForRideStatusStartedAndSetStatusLabel()
        setImageAndTextColorsBasedOnMatchedUser()
        setContactImage()
        checkAndSetInvitedLabel()
        ViewCustomizationUtils.addCornerRadiusToView(view: sendInviteButton, cornerRadius: 8.0)
        ViewCustomizationUtils.addBorderToView(view: sendInviteButton, borderWidth: 1.0, color: Colors.inviteActionBtnTextColor)
    }
    
    func setRating(){
        AppDelegate.getAppDelegate().log.debug("setRating()")
        if (matchedUser?.rating)! > 0.0{
            self.getRatingLabel().text = String(matchedUser!.rating!)
            self.getnoOfReviewsLabel().text = "("+String(matchedUser!.noOfReviews)+")"
        }else{
            self.getRatingLabel().text = Strings.NA
            self.getnoOfReviewsLabel().text = Strings.NA
        }
    }
    
    func getnoOfReviewsLabel() -> UILabel{
        if matchedUser!.userRole == MatchedUser.RIDER{
            return noOfReviewsForRider
        }else{
            return noOfReviewsForPassenger
        }
    }
    
    func getRatingLabel() -> UILabel{
        if matchedUser!.userRole == MatchedUser.RIDER{
            return ratingLabelForRider
        }else{
            return ratingLabelForPassenger
        }
    }
    
    func getPointsLabel() -> UILabel{
        if matchedUser!.userRole == MatchedUser.RIDER{
            return iboPointsAvailableForRider
        }else{
            return iboPointsAvailableForPassenger
        }
    }
    
    func setImageAndTextColorsBasedOnMatchedUser()
    {
        if matchedUser!.rideid == 0{
            iboProfileImage.alpha = 0.5
            iboProfileName.textColor = UIColor(netHex:0x9B9B9B)
            iboStartLocationAddress.textColor = UIColor(netHex:0x9B9B9B)
            iboEndLocationAddress.textColor = UIColor(netHex:0x9B9B9B)
        }else{
            
            iboProfileImage.alpha = 1.0
            iboProfileName.textColor = UIColor(netHex:0x000000).withAlphaComponent(0.8)
            iboStartLocationAddress.textColor = UIColor(netHex:0x363636)
            iboEndLocationAddress.textColor = UIColor(netHex:0x363636)
        }
    }
    
    func setContactImage(){

        if selectedUser{
            self.iboProfileImage.image = UIImage(named: "rider_select")
        }else{
            ImageCache.getInstance().setImageToView(imageView: self.iboProfileImage, imageUrl: matchedUser!.imageURI, gender: matchedUser!.gender!,imageSize: ImageCache.DIMENTION_SMALL)
        }
    }
    
    func checkForRideStatusStartedAndSetStatusLabel(){
        AppDelegate.getAppDelegate().log.debug("checkForRideStatusStartedAndSetStatusLabel()")
        if MatchedUser.RIDER ==  matchedUser!.userRole && Ride.RIDE_STATUS_STARTED == (matchedUser as! MatchedRider).rideStatus{
            rideStatus.isHidden = false
        }else{
            rideStatus.isHidden = true
        }
    }
    
    func moveToProfile(){
        if matchedUser == nil{
            return
        }
        let profile:ProfileDisplayViewController = (UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController)
        
        var vehicle : Vehicle?
        if matchedUser!.userRole == MatchedUser.RIDER{
            let matchedRider = matchedUser as! MatchedRider
            vehicle = Vehicle(ownerId : matchedRider.userid!, vehicleModel : matchedRider.model!,vehicleType: matchedRider.vehicleType, registrationNumber : matchedRider.vehicleNumber, capacity : matchedRider.capacity!, fare : matchedRider.fare!, makeAndCategory : matchedRider.vehicleMakeAndCategory,additionalFacilities : matchedRider.additionalFacilities,riderHasHelmet : matchedRider.riderHasHelmet)
            vehicle?.imageURI = matchedRider.vehicleImageURI
        }else if matchedUser!.userRole == MatchedUser.REGULAR_RIDER{
            let matchedRider = matchedUser as! MatchedRegularRider
            vehicle = Vehicle(ownerId : matchedRider.userid!, vehicleModel : matchedRider.model!, vehicleType: matchedRider.vehicleType,registrationNumber : matchedRider.vehicleNumber, capacity : matchedRider.capacity, fare : matchedRider.fare, makeAndCategory : matchedRider.vehicleMakeAndCategory,additionalFacilities : matchedRider.additionalFacilities,riderHasHelmet : matchedRider.riderHasHelmet)
            vehicle?.imageURI = matchedRider.vehicleImageURI
        }
        let userRole : UserRole?
        if matchedUser!.userRole == MatchedUser.RIDER || matchedUser!.userRole == MatchedUser.REGULAR_RIDER{
            userRole = UserRole.Rider
        }
        else{
            userRole = UserRole.Passenger
            
        }
        profile.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: matchedUser!.userid!),isRiderProfile: userRole! , rideVehicle: vehicle,userSelectionDelegate: nil,displayAction: false, isFromRideDetailView : false, rideNotes: matchedUser?.rideNotes, matchedRiderOnTimeCompliance: matchedUser!.userOnTimeComplianceRating, noOfSeats: (matchedUser as? MatchedPassenger)?.requiredSeats, isSafeKeeper: matchedUser!.hasSafeKeeperBadge)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: profile, animated: false)
    }

    func setVerificationLabel(){
        AppDelegate.getAppDelegate().log.debug("setVerificationLabel()")
        companyName.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: matchedUser?.profileVerificationData, companyName: matchedUser?.companyName?.capitalized)
        if companyName.text == Strings.not_verified {
            companyName.textColor = UIColor.black
        }else{
            companyName.textColor = UIColor(netHex: 0x24A647)
        }
        verificationBadge.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: matchedUser!.profileVerificationData)

    }
    
    func getStartTimeLabel() -> UILabel{
        if matchedUser!.userRole == MatchedUser.RIDER{
            return iboStartTimeForRider
        }else{
            return iboStartTimeForPassenger
        }
    }
    
    func getAmOrPMLabel() -> UILabel{
        if matchedUser!.userRole == MatchedUser.RIDER{
            return amOrPMLabelForRider
        }else{
            return amOrPMLabelForPassenger
        }
    }
    
    func inviteClicked(_ matchedUser: MatchedUser,position : Int) {
        let defaultPaymentMethod = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        if (defaultPaymentMethod?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE || defaultPaymentMethod?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI) && SendInviteViewModel.isAnimating {
            sendInviteButton.shake()
            UIApplication.shared.keyWindow?.makeToast( Strings.request_in_progress)
            return
        }
        if position >= 0 {
          
                self.inviteRemindView.isHidden = true
                self.sendInviteButton.isHidden = true
                self.inviteProgressImageView.isHidden = false
                self.inviteProgressImageView.startAnimating()
                SendInviteViewModel.isAnimating = true
           
        }
        setDataToRow(row: position)
        let invitation = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: rideId!, rideType: rideType!, matchedUserRideId: matchedUser.rideid!, matchedUserTaxiRideId: nil)
        var newFare: Double = 0
        if invitation?.rideType == Ride.PASSENGER_RIDE || invitation?.rideType == Ride.REGULAR_PASSENGER_RIDE {
            newFare = invitation?.newRiderFare ?? 0
        }else{
            newFare = invitation?.newFare ?? 0
        }
        if invitation != nil && matchedUser.newFare == newFare {
            matchedUser.pickupTime = invitation!.pickupTime
            matchedUser.dropTime = invitation!.dropTime
            matchedUser.pickupTimeRecalculationRequired = false
            joinMatchedUser(matchedUser: matchedUser, displayPointsConfirmation: true,invitation: invitation!)
        }else{
            inviteMatchedUser(matchedUser: matchedUser, invite: invitation)
        }
    }
    
    private func setDataToRow(row: Int) {
        if viewController != nil && viewController!.isKind(of: SendInviteBaseViewController.classForCoder())
        {
            let sendInviteViewController = (self.viewController as! SendInviteBaseViewController)
            sendInviteViewController.sendInviteViewModel.callOptionEnableSelectedRow = row
        }
    }
    
   func inviteMatchedUser(matchedUser : MatchedUser, invite : RideInvitation?) {
        if matchedUser.userRole == MatchedUser.RIDER {
            if (invite != nil && invite!.fareChange)
            {
                if (matchedUser.newFare < invite!.newFare){
                    invitingRider(matchedUser: matchedUser)
                }
                else
                {
                    joinMatchedUser(matchedUser: matchedUser,displayPointsConfirmation : false,invitation: invite!)
                }
            }
            else if (matchedUser.newFare != -1) && (matchedUser.newFare < matchedUser.points!)
            {
                invitingRider(matchedUser: matchedUser)
            }
            else if invite == nil
            {
                invitingRider(matchedUser: matchedUser)
            }
            else
            {
                joinMatchedUser(matchedUser: matchedUser,displayPointsConfirmation : false,invitation: invite!)
            }
        }
        else if matchedUser.userRole == MatchedUser.PASSENGER {
            if (invite != nil && invite!.fareChange)
            {
                if (matchedUser.newFare > invite!.newFare){
                    invitingPassenger(matchedUser: matchedUser)
                }
                else
                {
                    joinMatchedUser(matchedUser: matchedUser,displayPointsConfirmation : false,invitation: invite!)
                }
            }
                
            else if (matchedUser.newFare != -1) && (matchedUser.newFare > matchedUser.points!)
            {
                invitingPassenger(matchedUser: matchedUser)
            }
            else if invite == nil
            {
                invitingPassenger(matchedUser: matchedUser)
            }
            else
            {
                joinMatchedUser(matchedUser: matchedUser,displayPointsConfirmation : false,invitation: invite!)
            }
        }
    }
    
    func invitingRider(matchedUser : MatchedUser)
    {
        var selectedRiders = [MatchedRider]()
        selectedRiders.append(matchedUser as! MatchedRider)
        InviteRiderHandler(passengerRide: ride as! PassengerRide, selectedRiders: selectedRiders, displaySpinner: false, selectedIndex: "\((row ?? 0)+1)", viewController: viewController!).inviteSelectedRiders(inviteHandler: { (error,nserror) in
            if error == nil && nserror == nil{
                if self.viewController != nil{
                    if self.viewController!.isKind(of: SendInviteBaseViewController.classForCoder())
                    {
                        (self.viewController as! SendInviteBaseViewController).displayAckForRideRequest(matchedUser: matchedUser)
                    }
                }
                
            }
            self.stopAnimatingInviteProgressView()
            self.handleCallView(selectedRiders: selectedRiders)
        })
    }
    
    func handleCallView(selectedRiders : [MatchedRider]){
      
    }
    
    func invitingPassenger(matchedUser : MatchedUser)
    {
        var selectedPassengers = [MatchedPassenger]()
        selectedPassengers.append(matchedUser as! MatchedPassenger)
        InviteSelectedPassengersAsyncTask(riderRide: ride as! RiderRide, selectedUsers: selectedPassengers, viewController: viewController!, displaySpinner: false, selectedIndex: "\((row ?? 0)+1)", invitePassengersCompletionHandler: { (error,nserror) in
            if error == nil && nserror == nil{
                if self.viewController != nil{
                    if self.viewController!.isKind(of: SendInviteBaseViewController.classForCoder())
                    {
                        (self.viewController as! SendInviteBaseViewController).displayAckForRideRequest(matchedUser: matchedUser)
                    }
                }
            }
            self.stopAnimatingInviteProgressView()

        }).invitePassengersFromMatches()
    }
    func joinMatchedUser(matchedUser : MatchedUser,displayPointsConfirmation : Bool,invitation : RideInvitation){
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        if matchedUser.verificationStatus == false && SharedPreferenceHelper.getJoinWithUnverifiedUsersStatus() == false && SharedPreferenceHelper.getCurrentUserGender() == User.USER_GENDER_FEMALE && Int(matchedUser.noOfRidesShared) <= clientConfiguration!.minNoOfRidesReqNotToShowJoiningUnverifiedDialog{
            let alertControllerWithCheckBox = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AlertControllerWithCheckBox") as! AlertControllerWithCheckBox
            alertControllerWithCheckBox.initializeDataBeforePresenting(alertTitle: Strings.dont_show_again_title, checkBoxText: Strings.dont_show_again_checkBox_text, handler: { (result,dontShow) in
                SharedPreferenceHelper.setJoinWithUnverifiedUsersStatus(status: dontShow)
                if Strings.yes_caps == result{
                    self.continueJoin(invitation: invitation, displayPointsConfirmation: displayPointsConfirmation,matchedUser : matchedUser)
                } else {
                    self.stopAnimatingInviteProgressView()
                }
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: alertControllerWithCheckBox)
        }else{
            self.continueJoin(invitation: invitation, displayPointsConfirmation: displayPointsConfirmation,matchedUser : matchedUser)
        }
        
    }
    func continueJoin(invitation : RideInvitation,displayPointsConfirmation: Bool,matchedUser : MatchedUser){
   
      
        if matchedUser.userRole == MatchedUser.RIDER{
            let passengerRide = ride as! PassengerRide
            JoinPassengerToRideHandler(viewController: viewController, riderRideId: matchedUser.rideid!, riderId: matchedUser.userid!, passengerRideId: passengerRide.rideId, passengerId: passengerRide.userId,rideType: matchedUser.userRole, pickupAddress: matchedUser.pickupLocationAddress, pickupLatitude: matchedUser.pickupLocationLatitude!, pickupLongitude: matchedUser.pickupLocationLongitude!, pickupTime: matchedUser.pickupTime, dropAddress: matchedUser.dropLocationAddress, dropLatitude: matchedUser.dropLocationLatitude!, dropLongitude: matchedUser.dropLocationLongitude!, dropTime: matchedUser.dropTime, matchingDistance: matchedUser.distance!, points: matchedUser.points!,newFare: matchedUser.newFare, noOfSeats: passengerRide.noOfSeats, rideInvitationId: invitation.rideInvitationId,invitingUserName : invitation.invitingUserName!,invitingUserId : invitation.invitingUserId,displayPointsConfirmationAlert: displayPointsConfirmation, riderHasHelmet: (matchedUser as! MatchedRider).riderHasHelmet, pickupTimeRecalculationRequired: matchedUser.pickupTimeRecalculationRequired, passengerRouteMatchPercentage: matchedUser.matchPercentage!, riderRouteMatchPercentage: matchedUser.matchPercentageOnMatchingUserRoute, moderatorId: nil,listener: self).joinPassengerToRide(invitation: invitation)
        }else if matchedUser.userRole == MatchedUser.PASSENGER{
            let riderRide = ride as! RiderRide
            JoinPassengerToRideHandler(viewController: viewController!, riderRideId: riderRide.rideId, riderId: riderRide.userId, passengerRideId: matchedUser.rideid!, passengerId: matchedUser.userid!,rideType: matchedUser.userRole, pickupAddress: matchedUser.pickupLocationAddress, pickupLatitude: matchedUser.pickupLocationLatitude!, pickupLongitude: matchedUser.pickupLocationLongitude!, pickupTime: matchedUser.pickupTime, dropAddress: matchedUser.dropLocationAddress, dropLatitude: matchedUser.dropLocationLatitude!, dropLongitude: matchedUser.dropLocationLongitude!, dropTime: matchedUser.dropTime, matchingDistance: matchedUser.distance!, points: matchedUser.points!,newFare: matchedUser.newFare, noOfSeats: (matchedUser as! MatchedPassenger).requiredSeats, rideInvitationId: invitation.rideInvitationId,invitingUserName : invitation.invitingUserName!,invitingUserId : invitation.invitingUserId, displayPointsConfirmationAlert: displayPointsConfirmation, riderHasHelmet: false, pickupTimeRecalculationRequired: matchedUser.pickupTimeRecalculationRequired, passengerRouteMatchPercentage: matchedUser.matchPercentageOnMatchingUserRoute, riderRouteMatchPercentage: matchedUser.matchPercentage!, moderatorId: nil, listener: self).joinPassengerToRide(invitation: invitation)
        }
    }
    
    
  
    
    func checkAndSetInvitedLabel(){
        
        if sendInviteButton == nil {
            return
        }
        handleCustomizationToInviteView()
        setTitleToInviteBtn()
        
        if sendInviteButton == nil || rideId == nil || rideId!.isZero == true || rideType == nil || rideType!.isEmpty == true{
            return
        }
        let invite = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: rideId!, rideType: rideType!, matchedUserRideId: matchedUser!.rideid!, matchedUserTaxiRideId: nil)
    
        checkAndEnableMultiInvite(enable: true)
        if invite != nil && matchedUser!.newFare == invite!.newFare{
            sendInviteButton.setTitle( Strings.ACCEPT, for: UIControl.State.normal)
            sendInviteButton.isHidden = false
            inviteRemindView.isHidden = true
            inviteProgressImageView.isHidden =  true
        }
        else if Ride.RIDER_RIDE == rideType{
            handleVisibilityOfInviteElementsBasedOnInvite( riderRideId: rideId!, passengerRideId: matchedUser!.rideid!)
        }else{
            handleVisibilityOfInviteElementsBasedOnInvite(riderRideId: matchedUser!.rideid!, passengerRideId: rideId!)
            handleEnablingOfMultiInvite()
        }
    }
    
    func handleEnablingOfMultiInvite(){
        
    }
    
    func checkAndEnableMultiInvite(enable: Bool){
        
    }
    
    func setTitleToInviteBtn(){
        if Ride.RIDER_RIDE == rideType{
            sendInviteButton.setTitle(Strings.offer_ride, for: UIControl.State.normal)
        }else{
            sendInviteButton.setTitle(Strings.join, for: UIControl.State.normal)
        }
    }
    
    func handleCustomizationToInviteView(){
        
        ViewCustomizationUtils.addCornerRadiusToView(view: inviteProgressImageView, cornerRadius: 8.0)
        inviteProgressImageView.animationImages
            = [UIImage(named: "match_option_invite_progress_1"),UIImage(named: "match_option_invite_progress_2")] as? [UIImage]
        inviteProgressImageView.isHidden = true
        inviteProgressImageView.animationDuration = 0.3
        inviteRemindView.isHidden = false
        inviteRemindView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RidesTableViewCell.remindInvite(_:))))
        sendInviteButton.setTitleColor(Colors.inviteActionBtnTextColor, for: .normal)
        sendInviteButton.tag = row!
        inviteRemindView.tag = row!
        setTagToVerificationBtn()
    }
    
    @objc func remindInvite(_ gesture : UITapGestureRecognizer){
        if self.viewController != nil && self.viewController!.isKind(of: SendInviteBaseViewController.classForCoder())
        {
            (self.viewController as! SendInviteBaseViewController).view.endEditing(true)
        }
        inviteClicked(matchedUser!, position: row!)
        
    }
    
    func setTagToVerificationBtn(){
        
    }
    
    func handleVisibilityOfInviteElementsBasedOnInvite(riderRideId : Double,passengerRideId : Double){
        if let _ =  RideInviteCache.getInstance().getOutGoingInvitationPresentBetweenRide(riderRideId: riderRideId, passengerRideId: passengerRideId, rideType: rideType!,userId: matchedUser!.userid!){
            sendInviteButton.isHidden = true
            inviteRemindView.isHidden = false
            inviteProgressImageView.isHidden =  true
            handleCallBtnVisibility()
        }else{
            sendInviteButton.isHidden = false
            inviteRemindView.isHidden = true
            inviteProgressImageView.isHidden =  true
            hideCallBtn()
        }
    }
    
    func handleCallBtnVisibility() {}
    
    func hideCallBtn() {}
    
    private func stopAnimatingInviteProgressView() {
        self.inviteProgressImageView.stopAnimating()
        self.inviteProgressImageView.isHidden = true
        SendInviteViewModel.isAnimating = false 
        if self.viewController != nil{
            if self.viewController != nil && self.viewController!.isKind(of: SendInviteBaseViewController.classForCoder())
            {
                let sendInviteViewController = (self.viewController as! SendInviteBaseViewController)
                sendInviteViewController.iboTableView.reloadData()
                sendInviteViewController.iboTableView.setContentOffset(CGPoint(x: 0, y: sendInviteViewController.sendInviteViewModel.contentOffset), animated: true)
               
            }
        }
    }
}

extension RidesTableViewCell : RideInvitationActionCompletionListener{
    func rideInviteAcceptCompleted(rideInvitationId: Double) {
        stopAnimatingInviteProgressView()
        rideInviteActionCompletionListener?.rideInviteAcceptCompleted(rideInvitationId: rideInvitationId)
    }
    
    func rideInviteRejectCompleted(rideInvitation: RideInvitation) {
        stopAnimatingInviteProgressView()
        rideInviteActionCompletionListener?.rideInviteRejectCompleted(rideInvitation: rideInvitation)
    }
    
    func rideInviteActionFailed(rideInvitationId: Double,responseError: ResponseError?, error: NSError?, isNotificationRemovable: Bool) {
        stopAnimatingInviteProgressView()
        rideInviteActionCompletionListener?.rideInviteActionFailed(rideInvitationId: rideInvitationId, responseError: responseError, error: error, isNotificationRemovable: isNotificationRemovable)
    }
    
    func rideInviteActionCancelled () {
        stopAnimatingInviteProgressView()
    }
}
