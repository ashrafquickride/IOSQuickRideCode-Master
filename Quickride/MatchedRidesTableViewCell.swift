//
//  MatchedRidesTableViewCell.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 14/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol UserSelectionDelegate{
    func userSelectedAtIndex(row :Int,matchedUser : MatchedUser)
    func userUnSelectedAtIndex(row : Int,matchedUser : MatchedUser)
}

protocol ProfileVerificationViewDelegate {
    func hideProfileVerificationView()
}

class MatchedRidesTableViewCell: RidesTableViewCell{
    
    @IBOutlet weak var carImage: UIImageView!
 
    @IBOutlet weak var lastRideCreatedTimeLabel: UILabel!
    
    @IBOutlet weak var lastRideCreatedTimeLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var longDistanceDateLabel: UILabel!
    
    @IBOutlet weak var callButton: UIButton!
    
    @IBOutlet weak var callOptionBGView: UIView!
    
    @IBOutlet weak var callInfoShowingView: UIView!
    
    @IBOutlet weak var callInfoShowingLabel: UILabel!
    
    // Not in Quick Ride
    
    @IBOutlet weak var favoritePartnerImage: UIImageView!
    
    @IBOutlet weak var firstTimeGiftView: UIView!
    
    @IBOutlet weak var noOfPassengersView: UIView!
    
    @IBOutlet weak var noOfPassengersLabel: UILabel!
    
    @IBOutlet weak var rideNotesView: UIView!
    
    @IBOutlet weak var rideNotesLabel: UILabel!
    
    @IBOutlet weak var rideNotesHeightConstraint: NSLayoutConstraint!

    
    // Matched Rider Metrics outlets
    
    @IBOutlet weak var matchedRiderMetricsView: UIView!

    @IBOutlet weak var matchingPercentageForRider: UILabel!
    
    @IBOutlet var fareLabelForRider: UILabel!
    
    @IBOutlet weak var onTimeLabelForRider: UILabel!
    
    @IBOutlet weak var pointsLabelWidthForRider: NSLayoutConstraint!
    
    @IBOutlet weak var pointsSubTitleWidthForRider: NSLayoutConstraint!
    
    
    // Matched Passenger outlets
    
    @IBOutlet weak var matchedPassengerMetricsView: UIView!
    
    @IBOutlet weak var matchingPercentageForPassenger: UILabel!
    
    @IBOutlet var fareLabelForPassenger: UILabel!
    
    @IBOutlet weak var noOfSeatsLabelForPassenger: UILabel!
    
    @IBOutlet weak var pointsLabelWidthForPassenger: NSLayoutConstraint!
    
    @IBOutlet weak var pointsSubTitleWidthForPassenger: NSLayoutConstraint!
    
    @IBOutlet weak var rideStatusRightMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var longDistanceDateLblHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var noOfPassengersViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var noOfPassengersViewTopSpaceConstraint: NSLayoutConstraint!
   @IBOutlet weak var rideStatusLblHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rideStatusTopSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstRideGiftViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageTopSpace: NSLayoutConstraint!
    
    
    @IBOutlet weak var passImage: UIImageView!
    
    
    @IBOutlet weak var verificationBtn: UIButton!
    
    
    @IBOutlet weak var verificationInfoView: UIView!
    
    @IBOutlet weak var verificationIcon: UIImageView!
    
    @IBOutlet weak var verificationInfoTitle: UILabel!
    
    
    @IBOutlet weak var verificationInfoMessage: UILabel!
    
    @IBOutlet weak var arrowIcon: UIImageView!
    
    @IBOutlet weak var gotItBtn: UIButton!
    
    @IBOutlet weak var assuredRiderBtn: UIButton!
    
    var delegate : ProfileVerificationViewDelegate?
    
    
    func getMatchingPercentageLabel() -> UILabel{
        if matchedUser!.userRole == MatchedUser.RIDER{
            return matchingPercentageForRider
        }else{
            return matchingPercentageForPassenger
        }
    }
   
    func getPointsSubTitleLabel() -> UILabel{
        if matchedUser!.userRole == MatchedUser.RIDER{
            return fareLabelForRider
        }else{
            return fareLabelForPassenger
        }
    }


    func initializeViews(rideId : Double?, rideType : String?,matchedUser:MatchedUser,isSelected : Bool?,  userSelectionDelegate:UserSelectionDelegate,viewController : UIViewController, row: Int,ride : Ride?,rideInviteActionCompletionListener : RideInvitationActionCompletionListener?){
        AppDelegate.getAppDelegate().log.debug("initializeViews()")
        
        self.userSelectionDelegate = userSelectionDelegate
        if isSelected != nil{
          self.selectedUser = isSelected!
        }else{
          self.selectedUser = false
        }
        super.initializeViews(rideId: rideId, rideType: rideType, matchedUser: matchedUser, viewController: viewController, row: row, ride: ride, rideInviteActionCompletionListener: rideInviteActionCompletionListener)
        ViewCustomizationUtils.addBorderToView(view: verificationInfoView, borderWidth: 1.0, color: UIColor(netHex: 0xB7B7B7))
        ViewCustomizationUtils.addCornerRadiusToView(view: verificationInfoView, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: gotItBtn, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: gotItBtn, borderWidth: 1.0, color: UIColor(netHex: 0x0091EA))
        ViewCustomizationUtils.addCornerRadiusToView(view: callOptionBGView, cornerRadius: self.callOptionBGView.frame.height/2)
        ViewCustomizationUtils.addCornerRadiusToView(view: callInfoShowingView, cornerRadius: 5.0)
        handlePointsView()
        handlePassImageView()
        handleFareChangeView()
        self.backGroundView.isUserInteractionEnabled = true
        self.backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MatchedRidesTableViewCell.userDetailsTapped(_:))))
        setNoOfSeatsOrOnTimeComplianceLabel()
        setRideTime()
        setMatchinPercentage()
        setDollarSymbolToNewUser(matchedUser: matchedUser)
        adjustRideStatusLabelConstraints()
        setVehicleDetails()
        checkAndDisplayRideLastCreatedTime()
        checkAndDisplayAssuredRiderBtn()
        setRideNotes()
        setFavoritePartnerImageToView(matchedUser : matchedUser)
        initializeNoOfSeatsOccupied()
        adjustMarginsBasedOnHiddenViews()
        handleViewChangesForVerificationInfoDialogue()
    }
    
    func handleFareChangeView(){
        if FareChangeUtils.isFareChangeApplicable(matchedUser: matchedUser!)
        {
            self.getPointsLabel().textColor = Colors.editRouteBtnColor
            if matchedUser!.userRole == MatchedUser.RIDER{
                iboPointsAvailableForRider.alpha = 1.0
                fareLabelForRider.alpha = 1.0
            }else{
                iboPointsAvailableForPassenger.alpha = 1.0
                fareLabelForPassenger.alpha = 1.0
            }
            self.getPointsSubTitleLabel().textColor = Colors.editRouteBtnColor
            self.getPointsLabel().isUserInteractionEnabled = true
            self.getPointsLabel().addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MatchedRidesTableViewCell.fareChangeTapped(_:))))
            self.getPointsSubTitleLabel().isUserInteractionEnabled = true
            self.getPointsSubTitleLabel().addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MatchedRidesTableViewCell.fareChangeTapped(_:))))
            
        }else if matchedUser!.userRole == MatchedUser.PASSENGER && matchedUser!.ridePassId != 0{
            self.getPointsLabel().isUserInteractionEnabled = true
            self.getPointsSubTitleLabel().isUserInteractionEnabled = true
            self.getPointsLabel().textColor = UIColor.black
            self.getPointsSubTitleLabel().textColor = UIColor.black
            self.getPointsLabel().addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MatchedRidesTableViewCell.infoViewTapped(_:))))
            self.getPointsSubTitleLabel().addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MatchedRidesTableViewCell.infoViewTapped(_:))))
            
          
        }else{
            self.getPointsLabel().isUserInteractionEnabled = false
            self.getPointsSubTitleLabel().isUserInteractionEnabled = false
            self.getPointsLabel().textColor = UIColor.black
            self.getPointsSubTitleLabel().textColor = UIColor.black
            self.getPointsLabel().removeGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MatchedRidesTableViewCell.fareChangeTapped(_:))))
            self.getPointsSubTitleLabel().removeGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MatchedRidesTableViewCell.fareChangeTapped(_:))))
        }
    }
    
    @objc func infoViewTapped(_ gesture : UITapGestureRecognizer){

        MessageDisplay.displayInfoViewAlert(title: Strings.commute_pass_title, titleColor: nil, message: String(format: Strings.commute_pass_msg, arguments: [matchedUser!.name!]), infoImage: UIImage(named: "noun_carpool"), imageColor: UIColor(netHex: 0x00B557), isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps, handler: {
        })
    }
    
    func handlePointsView(){
        if matchedUser!.userRole == MatchedUser.PASSENGER{
            matchedPassengerMetricsView.isHidden = false
            matchedRiderMetricsView.isHidden = true
            pointsLabelWidthForPassenger.constant = (self.backGroundView.frame.width-60
                )*0.4
            pointsSubTitleWidthForPassenger.constant = (self.backGroundView.frame.width-60)*0.4
        }else{
            matchedPassengerMetricsView.isHidden = true
            matchedRiderMetricsView.isHidden = false
            
            pointsLabelWidthForRider.constant = (self.backGroundView.frame.width-60
                )/5
            pointsSubTitleWidthForRider.constant = (self.backGroundView.frame.width-60)/5
        }
    }
    
    func handlePassImageView(){
        if matchedUser!.userRole == MatchedUser.PASSENGER && matchedUser!.ridePassId != 0{
            passImage.isHidden = false
        }else{
            passImage.isHidden = true
        }
    }
    
    func adjustMarginsBasedOnHiddenViews(){
        if (matchedUser!.verificationStatus && matchedUser!.totalNoOfRideShared == 0) ||
            ( matchedUser!.userRole == MatchedUser.RIDER && ((matchedUser as! MatchedRider).rideStatus == Ride.RIDE_STATUS_STARTED ||  (matchedUser as! MatchedRider).capacity != (matchedUser as! MatchedRider).availableSeats)) || (matchedUser!.userRole == MatchedUser.RIDER && (matchedUser as! MatchedRider).rideAssuIncId != nil && (matchedUser as! MatchedRider).rideAssuIncId != 0){
            
            profileImageTopSpace.constant = 32
            
        }else{
            profileImageTopSpace.constant = 18
        }
    }
    
    @objc func userDetailsTapped(_ gesture: UITapGestureRecognizer){
        
        if viewController!.isKind(of: SendInviteBaseViewController.classForCoder())
        {
            backGroundView.rippleStarting(at: backGroundView.center, with: UIColor(netHex: 0xefefef), duration: 0.2, radius: backGroundView.frame.width/2 + 30, fadeAfter: 0.5) {
                let sendInviteViewController = (self.viewController as! SendInviteBaseViewController)
                sendInviteViewController.goToProfile(index: self.row!, isFromReadyToGo: false)
                
            }
        }
    }
    
    func setFavoritePartnerImageToView(matchedUser : MatchedUser?){
        let isFavoritePartner = UserDataCache.getInstance()?.isFavouritePartner(userId: matchedUser!.userid!)
        
        if isFavoritePartner == nil || !isFavoritePartner!{
            self.favoritePartnerImage.isHidden = true
        }else{
            self.favoritePartnerImage.isHidden = false
        }
    }
    func setDollarSymbolToNewUser(matchedUser : MatchedUser){
        
        clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        if UserDataCache.getInstance()?.getLoggedInUserProfile()?.verificationStatus != 0 && clientConfiguration!.enableFirstRideBonusPointsOffer  && (matchedUser.androidAppVersionName! >= MatchedUser.SUPPORTED_ANDROID_APP_VERSION || matchedUser.iosAppVersionName! >= MatchedUser.SUPPORTED_IOS_APP_VERSION){
            
            if matchedUser.verificationStatus && matchedUser.totalNoOfRideShared == 0{
                self.firstTimeGiftView.isHidden = false
                self.firstRideGiftViewHeightConstraint.constant = 24
                self.firstTimeGiftView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(MatchedRidesTableViewCell.showGiftDetails(_:))))
            }else{
                self.firstTimeGiftView.isHidden = true
                self.firstRideGiftViewHeightConstraint.constant = 0
            }
        }else{
            self.firstTimeGiftView.isHidden = true
            self.firstRideGiftViewHeightConstraint.constant = 0
        }
    }
    
    
    @objc func fareChangeTapped(_ gesture : UITapGestureRecognizer){
        
        var noOfSeats = 1
        var rideFarePerKm = 0.0
        if ride!.isKind(of:PassengerRide.classForCoder()){
            noOfSeats = (ride as! PassengerRide).noOfSeats
            rideFarePerKm = (matchedUser as! MatchedRider).fare ?? 0.0
        }else if matchedUser!.isKind(of: MatchedPassenger.classForCoder()){
            noOfSeats = (matchedUser as! MatchedPassenger).requiredSeats
            rideFarePerKm = (ride as! RiderRide).farePerKm
        }
        let fareChangeViewController = UIStoryboard(name: "LiveRide", bundle: nil).instantiateViewController(withIdentifier: "FareChangeViewController") as! FareChangeViewController
        fareChangeViewController.initializeDataBeforePresenting(rideType: rideType!,actualFare: matchedUser!.points!,distance: matchedUser!.distance!,selectedSeats: noOfSeats, farePerKm: rideFarePerKm) { (actualFare, requestedFare) in
            self.matchedUser?.newFare = requestedFare
            self.matchedUser?.fareChange = true
            self.updateNewFare(selectedUser: self.matchedUser!)
            
        }
        ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: fareChangeViewController, animated: false, completion: nil)
    }
    
 
    override func handleEnablingOfMultiInvite(){
        if ride?.status == Ride.RIDE_STATUS_SCHEDULED || ride?.status == Ride.RIDE_STATUS_DELAYED{
            sendInviteButton.setTitle(Strings.switch_rider, for: .normal)
            self.callButton.isHidden = true
            checkAndEnableMultiInvite(enable: false)
        }else{
            checkAndEnableMultiInvite(enable: true)
        }
    }
    
    override func handleCallBtnVisibility() {
        
        if let viewController = viewController, viewController.isKind(of: SendInviteBaseViewController.classForCoder()) {
            let sendInviteViewController = viewController as! SendInviteBaseViewController
            if (UserProfile.SUPPORT_CALL_ALWAYS == matchedUser!.callSupport || UserProfile.SUPPORT_CALL_AFTER_JOINED == matchedUser!.callSupport) && matchedUser!.enableChatAndCall {
                if matchedUser?.matchingSortingStatus == MatchedUser.ENABLE_CALL_OPTION_TO_INACTIVE_USER && sendInviteViewController.sendInviteViewModel.callOptionEnableSelectedRow == self.row && !sendInviteViewController.sendInviteViewModel.callOptionEnabledId.contains(matchedUser!.userid!){
                    self.callOptionBGView.isHidden = false
                    self.callButton.isHidden = false
                    let name = matchedUser?.name ?? ""
                    callInfoShowingLabel.text = String(format: Strings.call_info, arguments: [name, name])
                    self.callInfoShowingView.isHidden = false
                    sendInviteViewController.sendInviteViewModel.callOptionEnableSelectedRow = -1
                    sendInviteViewController.sendInviteViewModel.callOptionEnabledId.append(matchedUser!.userid!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                        self?.hideCallMessageDialogueAfterSomeTime()
                    }
                } else if MatchedUser.RIDER ==  matchedUser!.userRole && Ride.RIDE_STATUS_STARTED == (matchedUser as! MatchedRider).rideStatus {
                    self.callButton.isHidden = false
                    hideCallMessageDialogueAfterSomeTime()
                }else if sendInviteViewController.sendInviteViewModel.callOptionEnabledId.contains(matchedUser!.userid!) {
                    self.callButton.isHidden = false
                    hideCallMessageDialogueAfterSomeTime()
                }else{
                    self.callButton.isHidden = true
                    hideCallMessageDialogueAfterSomeTime()
                }
            } else {
                self.callButton.isHidden = true
                hideCallMessageDialogueAfterSomeTime()
            }
        } else {
            self.callButton.isHidden = true
            hideCallMessageDialogueAfterSomeTime()
        }
    }
   
    func updateNewFare(selectedUser : MatchedUser){
        if matchedUser!.rideid == selectedUser.rideid && matchedUser!.userRole == selectedUser.userRole{
            matchedUser!.newFare = selectedUser.newFare
            inviteClicked(selectedUser,position: -1)
            (self.viewController as! SendInviteBaseViewController).iboTableView.reloadData()
            (self.viewController as! SendInviteBaseViewController).iboTableView.setContentOffset(CGPoint(x: 0, y: (self.viewController as! SendInviteBaseViewController).sendInviteViewModel.contentOffset), animated: true)
            return
        }
    }
    
    func checkAndDisplayRideLastCreatedTime(){
        
        if(matchedUser?.rideid == 0)
        {
            backGroundView.backgroundColor = UIColor(netHex : 0xe5e5e5)
            lineView.backgroundColor = UIColor.white
            if matchedUser!.lastRideCreatedTime == nil{
                lastRideCreatedTimeLabel.isHidden = true
                lastRideCreatedTimeLabelHeight.constant = 0
            }
            else{
                lastRideCreatedTimeLabel.isHidden = false
                lastRideCreatedTimeLabelHeight.constant = 15
                lastRideCreatedTimeLabel.text = getTextForLastRideCreated(lastRideCreatedTime: matchedUser!.lastRideCreatedTime!)
            }
            
        }
        else
        {
            backGroundView.backgroundColor = UIColor.white
            lineView.backgroundColor = UIColor(netHex : 0xe5e5e5)
            lastRideCreatedTimeLabel.isHidden = true
            lastRideCreatedTimeLabelHeight.constant = 0
            lastRideCreatedTimeLabel.text = nil
        }
    }
    func checkAndDisplayAssuredRiderBtn(){
        if matchedUser != nil && matchedUser!.userRole == MatchedUser.RIDER && (matchedUser as! MatchedRider).rideAssuIncId != nil && (matchedUser as! MatchedRider).rideAssuIncId != 0{
           self.assuredRiderBtn.isHidden = false
        }else{
           self.assuredRiderBtn.isHidden = true
        }
    }
    
    func getTextForLastRideCreated(lastRideCreatedTime : Double) -> String
    {
        let lastRideCreatedDate = NSDate(timeIntervalSince1970: lastRideCreatedTime/1000)
        var dateDifference = DateUtils.getDifferenceBetweenTwoDatesInDays(date1: NSDate(), date2: lastRideCreatedDate)
        if dateDifference < 1{
            dateDifference = 1
        }
        var text = Strings.last_ride_created
        if dateDifference == 1{
            text = text+String(dateDifference)+Strings.day_ago
        }else{
            text = text+String(dateDifference)+Strings.days_ago
        }
        return text
    }
    
    
    func setMatchinPercentage(){
        
        let matchedPercentage = "\(matchedUser!.matchPercentage!)"
        
        if(matchedUser!.userRole == MatchedUser.PASSENGER && matchedUser!.matchPercentageOnMatchingUserRoute != 0){
            self.getMatchingPercentageLabel().text = matchedPercentage + "(" + String(describing: matchedUser!.matchPercentageOnMatchingUserRoute) + ")" + Strings.percentage_symbol
            
        }else{
            self.getMatchingPercentageLabel().text = matchedPercentage + Strings.percentage_symbol
        }
    }
    func setNoOfSeatsOrOnTimeComplianceLabel(){
        AppDelegate.getAppDelegate().log.debug("setNoOfSeatsOrOnTimeComplianceLabel()")
        if matchedUser!.userRole == MatchedUser.PASSENGER{
            self.noOfSeatsLabelForPassenger.text = String((matchedUser as! MatchedPassenger).requiredSeats)
        }else{
            if matchedUser!.userOnTimeComplianceRating != nil && matchedUser!.userOnTimeComplianceRating!.isEmpty == false {
                self.onTimeLabelForRider.text = matchedUser!.userOnTimeComplianceRating! + Strings.percentage_symbol
            }else{
                self.onTimeLabelForRider.text = Strings.NA
            }
        }
    }
   
    override func checkAndEnableMultiInvite(enable : Bool) {
        if enable{
            var longGesture = UILongPressGestureRecognizer()
            longGesture = UILongPressGestureRecognizer(target: self, action: #selector(MatchedRidesTableViewCell.longPress(_:)))
            longGesture.minimumPressDuration = 0.2
            self.iboProfileImage.addGestureRecognizer(longGesture)
        }
        
    }
    
    
    func setRideTime(){
        AppDelegate.getAppDelegate().log.debug("")
        var longDistance : Int?
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil
        {
            clientConfiguration = ClientConfigurtion()
        }
        longDistance = clientConfiguration!.longDistanceForUser
        
        if matchedUser!.isKind(of: MatchedPassenger.classForCoder())
        {
          handleSettingRideTimeForPassenger(longDistance: longDistance!)
        }else{
          handleSettingRideTimeForRider(longDistance: longDistance!)
        }
    }
    
    func handleSettingRideTimeForPassenger(longDistance : Int){
        var time = 0.0
        if let pickupTime = matchedUser?.psgReachToPk {
            time = pickupTime
        }else if let pickupTime = matchedUser?.passengerReachTimeTopickup {
            time = pickupTime
        }else if let startDate = matchedUser?.startDate {
            time = startDate
        }
        self.getAmOrPMLabel().text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_a)
        setRideTimeBasedOnLongDistanceLbl(longDistance: longDistance, time: time)
    }
    
    func setRideTimeBasedOnLongDistanceLbl(longDistance : Int,time : Double?){
        let requiredTime = DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.DATE_FORMAT_dd_MMM_yy)
        let weekDay = DateUtils.getDayOfWeek(today: requiredTime)
        if matchedUser!.distance! >= Double(longDistance)
        {
            longDistanceDateLabel.isHidden = false
            longDistanceDateLblHeightConstraint.constant = 15
            longDistanceDateLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser!.passengerReachTimeTopickup, timeFormat: DateUtils.DATE_FORMAT_dd_MMM)
            if weekDay != nil
            {
                self.getStartTimeLabel().text = DateUtils.getDayOfWeek(today: requiredTime)! + " " + DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hh_mm)!
            }
            else{
                self.getStartTimeLabel().text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hh_mm)!
            }
        }
        else
        {
            self.getStartTimeLabel().text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hh_mm)!
            longDistanceDateLabel.isHidden = true
            longDistanceDateLblHeightConstraint.constant = 0
        }
    }
    
    func handleSettingRideTimeForRider(longDistance : Int){
         self.getAmOrPMLabel().text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser!.pickupTime!, timeFormat: DateUtils.TIME_FORMAT_a)
         setRideTimeBasedOnLongDistanceLbl(longDistance: longDistance, time: matchedUser!.pickupTime)
    }
  
    func adjustRideStatusLabelConstraints(){
        if MatchedUser.RIDER ==  matchedUser!.userRole && Ride.RIDE_STATUS_STARTED == (matchedUser as! MatchedRider).rideStatus{
            rideStatusLblHeightConstraint.constant = 12
            rideStatusTopSpaceConstraint.constant = 18
            if firstTimeGiftView.isHidden{
                rideStatusRightMarginConstraint.constant = 20
            }else{
                rideStatusRightMarginConstraint.constant = 150
            }
        }else{
            rideStatusLblHeightConstraint.constant = 0
            rideStatusTopSpaceConstraint.constant = 0
        }
    }
    func setVehicleDetails(){
        AppDelegate.getAppDelegate().log.debug("setVehicleDetails()")
        if matchedUser!.userRole == MatchedUser.RIDER && (matchedUser as! MatchedRider).vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
            self.carImage.isHidden = false
        }else{
            self.carImage.isHidden = true
        }
    }
    func setRideNotes(){
        if matchedUser!.rideNotes == nil || matchedUser!.rideNotes!.isEmpty{
            rideNotesView.isHidden = true
            rideNotesHeightConstraint.constant = 0
        }else{
            rideNotesView.isHidden = false
            rideNotesLabel.text = matchedUser!.rideNotes!
            rideNotesHeightConstraint.constant = 28
        }
    }
    @objc func tapped(_ sender:UITapGestureRecognizer) {
        AppDelegate.getAppDelegate().log.debug("")
        selectedUser = !selectedUser
        var sendInviteViewController : SendInviteBaseViewController?
        if viewController != nil && viewController!.isKind(of: SendInviteBaseViewController.classForCoder())
        {
            sendInviteViewController = (self.viewController as! SendInviteBaseViewController)
        }
        if sendInviteViewController != nil && sendInviteViewController!.sendInviteViewModel.selectedMatches.values.contains(true){
            if (!selectedUser) {
                UIImageView.transition(with: iboProfileImage, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
                setContactImage()
                userSelectionDelegate?.userUnSelectedAtIndex(row: row!, matchedUser: self.matchedUser!)
            }
            else{
                userImageLongPress()
            }
        }
        else{
            moveToProfile()
            selectedUser = !selectedUser
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
  @IBAction func callButtonTapped(_ sender: Any) {
    guard let ride = ride, let rideType = ride.rideType else { return }
    AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: matchedUser!.userid), refId: rideType+StringUtils.getStringFromDouble(decimalNumber: ride.rideId), name: matchedUser!.name ?? "", targetViewController: ViewControllerUtils.getCenterViewController())
    }
    @objc func longPress(_ sender:UILongPressGestureRecognizer) {
        if sender.state == .began{
            selectedUser = !selectedUser
            userImageLongPress()
        }
    }
    func userImageLongPress(){
        if Ride.PASSENGER_RIDE == rideType && (ride?.status == Ride.RIDE_STATUS_SCHEDULED || ride?.status == Ride.RIDE_STATUS_DELAYED){
            return
        }
        if (selectedUser){
            UIImageView.transition(with: iboProfileImage, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setContactImage()
            userSelectionDelegate?.userSelectedAtIndex(row: row!, matchedUser: self.matchedUser!)
        } else {
            UIImageView.transition(with: iboProfileImage, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setContactImage()
            userSelectionDelegate?.userUnSelectedAtIndex(row: row!, matchedUser: self.matchedUser!)
        }
    }

    @objc func showGiftDetails(_ gesture: UITapGestureRecognizer){
        let bonusMsg : String?
        if matchedUser!.userRole == MatchedUser.RIDER {
            bonusMsg = String(format: Strings.dollar_sym_msg_for_rider, arguments: [matchedUser!.name!,matchedUser!.name!,StringUtils.getStringFromDouble(decimalNumber: clientConfiguration!.firstRideBonusPoints)])
        }else{
            bonusMsg = String(format: Strings.dollar_sym_msg, arguments: [matchedUser!.name!,matchedUser!.name!,StringUtils.getStringFromDouble(decimalNumber: clientConfiguration!.firstRideBonusPoints)])
        }
        MessageDisplay.displayErrorAlertWithAction(title: Strings.dollar_sym_info, isDismissViewRequired: true, message1: bonusMsg!, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: viewController) { (result) in
            
        }
        
    }
    
  
    
    func initializeNoOfSeatsOccupied(){
        
        noOfPassengersView.isHidden = true
        noOfPassengersViewHeightConstraint.constant = 0
        noOfPassengersViewTopSpaceConstraint.constant = 0
        
        if matchedUser!.userRole == MatchedUser.RIDER {
            if let rider = matchedUser as? MatchedRider{
                let passengersCount = rider.capacity! - rider.availableSeats!
                if passengersCount != 0{
                    noOfPassengersView.isHidden = false
                    noOfPassengersViewTopSpaceConstraint.constant = 21
                    noOfPassengersViewHeightConstraint.constant = 12
                    noOfPassengersLabel.text = String(passengersCount)
                }
            }
        }
    }
    
    @IBAction func verificationLblClicked(_ sender: UIButton) {
        
        if viewController != nil && viewController!.isKind(of: SendInviteBaseViewController.classForCoder())
        {
            let sendInviteViewController = (self.viewController as! SendInviteBaseViewController)
            sendInviteViewController.sendInviteViewModel.verificationInfoWindowSelectedView = self.row!
            sendInviteViewController.iboTableView.reloadData()
        }
        
     }
    
 
    
    
    @IBAction func gotItBtnClicked(_ sender: UIButton) {
      
        if viewController != nil && viewController!.isKind(of: SendInviteBaseViewController.classForCoder())
        {
            let sendInviteViewController = (self.viewController as! SendInviteBaseViewController)
            sendInviteViewController.sendInviteViewModel.verificationInfoWindowSelectedView = -1
            sendInviteViewController.iboTableView.reloadData()
        }
    }
    func handleViewChangesForVerificationInfoDialogue(){
        
        if let sendInviteViewController = self.viewController as? SendInviteBaseViewController{
            if sendInviteViewController.sendInviteViewModel.verificationInfoWindowSelectedView == self.row{
                self.verificationInfoView.isHidden = false
                self.arrowIcon.isHidden = false
                self.verificationIcon.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: matchedUser!.profileVerificationData)
                let verificationStatusText = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: matchedUser!.profileVerificationData, companyName: nil)
                setVerificationContent(verificationStatus: verificationStatusText)
            }else{
                self.verificationInfoView.isHidden = true
                self.arrowIcon.isHidden = true
            }
        }
        
    }
    
    
    func setVerificationContent(verificationStatus : String){
        if verificationStatus == Strings.org_verified{
            self.verificationInfoTitle.text = Strings.org_verified
            self.verificationInfoMessage.text = String(format: Strings.org_verified_content, arguments: [matchedUser!.name!])
        }else if verificationStatus == Strings.personal_id_verified{
            self.verificationInfoTitle.text = Strings.govt_id_verified
            self.verificationInfoMessage.text = String(format: Strings.personal_verified_content, arguments: [matchedUser!.name!])
        }else if verificationStatus == Strings.profile_verified{
            self.verificationInfoTitle.text = Strings.fully_verified
            self.verificationInfoMessage.text = String(format: Strings.profile_verified_content, arguments: [matchedUser!.name!])
        }else{
            self.verificationInfoTitle.text = Strings.not_verified.capitalized
            self.verificationInfoMessage.text = String(format: Strings.not_verified_content, arguments: [matchedUser!.name!])
        }
        let attributedString = NSMutableAttributedString(string: self.verificationInfoMessage.text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0.75
        paragraphStyle.lineHeightMultiple = 1.25
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        self.verificationInfoMessage.attributedText = attributedString
    }
    
    override func handleCallView(selectedRiders: [MatchedRider]) {
        if matchedUser == nil{
            return
        }
        if selectedRiders.count == 1 && Ride.RIDE_STATUS_STARTED == selectedRiders[0].rideStatus && MatchedUser.RIDER ==  selectedRiders[0].userRole && (UserProfile.SUPPORT_CALL_ALWAYS == matchedUser!.callSupport || UserProfile.SUPPORT_CALL_AFTER_JOINED == matchedUser!.callSupport) && matchedUser!.enableChatAndCall{
            self.callButton.isHidden = false
            self.callButton.pulsate()
        }
    }
    
    @IBAction func assuredRiderBtnClicked(_ sender: Any) {
        MessageDisplay.displayInfoViewAlert(title: Strings.assured_rider, titleColor: nil, message: String(format: Strings.assured_rider_msg, arguments: [matchedUser!.name!]), infoImage: UIImage(named: "ic_receipt"), imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps) {
        }
    }

   override func setTagToVerificationBtn(){
       self.verificationBtn.tag = row!
    }
    override func hideCallBtn(){
       self.callButton.isHidden = true
       hideCallMessageDialogueAfterSomeTime()
    }
    
    func hideCallMessageDialogueAfterSomeTime() {
        self.callOptionBGView.isHidden = true
        self.callInfoShowingView.isHidden = true
    }

    @IBAction func inviteBtnClciked(_ sender: UIButton) {
        if self.viewController != nil && self.viewController!.isKind(of: SendInviteBaseViewController.classForCoder())
        {
            (self.viewController as! SendInviteBaseViewController).view.endEditing(true)
        }
      
//        if let userProfile = UserDataCache.getInstance()?.userProfile,let profileVerificationData = userProfile.profileVerificationData,!profileVerificationData.profileVerified{
//            if let displayStatus = UserDataCache.getInstance()?.getEntityDisplayStatus(key: UserDataCache.VERIFICATION_VIEW),!displayStatus,SharedPreferenceHelper.getCountForVerificationViewDisplay() < 3{
//                let profileVerificationVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileVerificationViewController") as! ProfileVerificationViewController
//                profileVerificationVC.initializeViews(rideType: ride?.rideType) { [weak self] in
//                    if profileVerificationData.profileVerified{
//                        self?.delegate?.hideProfileVerificationView()
//                    }
//                }
//                ViewControllerUtils.addSubView(viewControllerToDisplay: profileVerificationVC)
//                profileVerificationVC.view.layoutIfNeeded()
//            }else{
//               inviteClicked(matchedUser!, position: sender.tag)
//            }
//        }else{
            inviteClicked(matchedUser!, position: sender.tag)
//        }
       
    }
}
