//
//  RiderDetailToPassengerCardTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 18/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import Lottie
import ObjectMapper
import CoreLocation
import MessageUI
import FTPopOverMenu_Swift

class RiderDetailToPassengerCardTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var otpButton: UIButton!
    @IBOutlet weak var imageViewRider: UIImageView!
    @IBOutlet weak var labelRiderRideStatus: UILabel!
    @IBOutlet weak var labelRiderName: UILabel!
    @IBOutlet weak var labelVehicleName: UILabel!
    @IBOutlet weak var vehicleModelNameLabel: UILabel!
    @IBOutlet weak var rideNotesContainerView: UIView!
    @IBOutlet weak var rideNotesLabel: UILabel!
    
    //MARK: Properties
    private var viewModel = RiderDetailToPassengerCardViewModel()
    
    //MARK: Initializer
    func initiateData(ride: Ride) {
        viewModel = RiderDetailToPassengerCardViewModel(currentUserRide: ride)
        setUpUI()
    }
    
    //MARK: Methods
    private func setUpUI() {
        displayRiderInfoToPassenger()
    }
    
    private func displayRiderInfoToPassenger(){
        
        guard let riderParticipanInfo = viewModel.getRiderParticipantInfo(), let riderRide = viewModel.rideDetailInfo?.riderRide else {
            return
        }
        
        labelVehicleName.isUserInteractionEnabled = true
        labelVehicleName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(vehicleNameTapped(_:))))
        imageViewRider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(riderImageClicked(_:))))
        labelRiderName.text = riderParticipanInfo.name
        setArrivalTimeOfRiderToPickup(rideParticipant: riderParticipanInfo)
        if let vehicleNumber = riderRide.vehicleNumber, !vehicleNumber.isEmpty {
            labelVehicleName.isHidden = false
            self.labelVehicleName.text = vehicleNumber.uppercased()
        }else{
            labelVehicleName.isHidden = true
        }
        if let makeAndCategory = riderRide.makeAndCategory, !makeAndCategory.isEmpty {
            vehicleModelNameLabel.isHidden = false
            vehicleModelNameLabel.text = makeAndCategory
        }else {
            vehicleModelNameLabel.isHidden = true
        }
        displayRideNotesIfAvailabel()
        ImageCache.getInstance().setImageToView(imageView: self.imageViewRider, imageUrl: riderParticipanInfo.imageURI, gender: riderParticipanInfo.gender!,imageSize: ImageCache.DIMENTION_SMALL)
        if let rideParticipants = viewModel.rideDetailInfo?.rideParticipants, let passengerInfo = RideViewUtils.getRideParticipantObjForParticipantId(participantId: viewModel.currentUserRide.userId, rideParticipants: rideParticipants) {
            checkAndDisplayOTPToPickup(riderId: riderRide.userId,passenger: passengerInfo)
        }
    }
    private func displayRideNotesIfAvailabel(){
        guard let rideParticipants = viewModel.rideDetailInfo?.rideParticipants,let riderId = viewModel.rideDetailInfo?.riderRide?.userId else {
            rideNotesContainerView.isHidden = true
            return
        }
        for rideParticipant in rideParticipants {
            if riderId == rideParticipant.userId, let rideNote = rideParticipant.rideNote, !rideNote.isEmpty {
                rideNotesContainerView.isHidden = false
                rideNotesLabel.text = rideParticipant.rideNote
            }else {
                rideNotesContainerView.isHidden = true
            }
        }
    }
    
    
    private func setArrivalTimeOfRiderToPickup(rideParticipant: RideParticipant){
        self.labelRiderRideStatus.textColor = UIColor(netHex: 0x00B557)
        self.labelRiderRideStatus.text = rideParticipant.status.uppercased()
    }
    
    private func checkAndDisplayOTPToPickup(riderId: Double,passenger : RideParticipant) {
        UserDataCache.getInstance()?.getOtherUserCompleteProfile(userId: StringUtils.getStringFromDouble(decimalNumber: riderId), completeProfileRetrievalCompletionHandler: { (otherUserInfo, error, responseObject) -> Void in
            if RideViewUtils.isOTPRequiredToPickupPassenger(rideParticipant: passenger, ride: self.viewModel.currentUserRide, riderProfile: otherUserInfo?.userProfile) {
                if let user = UserDataCache.getInstance()?.getUser(),let otp = user.pickupOTP, !otp.isEmpty {
                    self.otpButton.isHidden = false
                    self.otpButton.setTitle("OTP \(otp)", for: .normal)
                    return
                }
                UserRestClient.getUserWithPickupOTP(userId: QRSessionManager.getInstance()?.getUserId(), uiViewController: nil) { (responseObject, error) in
                    if responseObject != nil && responseObject!["result"] as? String == "SUCCESS" {
                        if let user = Mapper<User>().map(JSONObject: responseObject!["resultData"]) {
                            UserDataCache.getInstance()?.storeUserDynamicChanges(user: user)
                            self.otpButton.isHidden = false
                            self.otpButton.setTitle("OTP \(user.pickupOTP!)", for: .normal)
                        }
                    }else{
                        self.otpButton.isHidden = true
                    }
                }
                
            } else {
                self.otpButton.isHidden = true
            }
        })
    }
    
    @objc func riderImageClicked(_ gesture: UITapGestureRecognizer) {
        guard let rider = viewModel.getRiderParticipantInfo() else {
            return
        }
        let actions = viewModel.getApplicableActionOnRiderSelection(rideParticipant: rider)
        
        let configuration = FTConfiguration.shared
        configuration.backgoundTintColor = UIColor.black
        configuration.menuSeparatorColor = UIColor.white
        configuration.menuSeparatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        FTPopOverMenu.showForSender(sender: imageViewRider,with: actions, done: { (selectedIndex) -> () in
            self.handleRideParticiapantAction(selectedType: actions[selectedIndex], rideParticipant: rider)
        }, cancel: {
            
        })
    }
    
    func handleRideParticiapantAction(selectedType: String,rideParticipant: RideParticipant){
        
        switch selectedType {
        case Strings.smsLabel:
            UserDataCache.getInstance()?.getContactNo(userId: StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId), handler: { (contactNo) in
                self.sendSMS(phoneNumber: contactNo, message: "")
            })
        case Strings.profile:
            self.displayRiderUserProfile(rideParticipant: rideParticipant)
        case Strings.unjoin, Strings.unjoin+" " + (rideParticipant.name ?? ""):
            unjoinRiderFromRide(rideParticipant: rideParticipant)
        case Strings.route:
            moveToSelectedUserRouteView(rideParticipant: rideParticipant)
        case Strings.ride_notes:
            MessageDisplay.displayInfoDialogue(title: Strings.ride_notes, message: rideParticipant.rideNote, viewController: nil)
        case String(format: Strings.rate_user, arguments: [rideParticipant.name ?? ""]):
            let systemFeedbackViewController = UIStoryboard(name: "SystemFeedback", bundle: nil).instantiateViewController(withIdentifier: "DirectUserFeedbackViewController") as! DirectUserFeedbackViewController
            systemFeedbackViewController.initializeDataAndPresent(name: rideParticipant.name ?? "",imageURI: rideParticipant.imageURI,gender: rideParticipant.gender ?? "U",userId: rideParticipant.userId, rideId: rideParticipant.riderRideId)
            ViewControllerUtils.addSubView(viewControllerToDisplay: systemFeedbackViewController)
        default:
            break
        }
    }
    private func displayRiderUserProfile(rideParticipant : RideParticipant){
        let vc  = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        
        guard let vehicle = viewModel.getRiderVehicle() else {
            return
        }
        vc.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId),isRiderProfile: UserRole.Rider,rideVehicle: vehicle, userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: rideParticipant.rideNote, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: vc, animated: false)
        
    }
    
    private func moveToSelectedUserRouteView(rideParticipant : RideParticipant){
        
        let rideRouteDisplayViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RidePathDisplayViewController") as! RidePathDisplayViewController
        rideRouteDisplayViewController.initializeDataBeforePresenting(currentUserRidePath: viewModel.currentUserRide.routePathPolyline, joinedUserRidePath: nil, currentUserRideType: viewModel.currentUserRide.rideType!, currentUserRideId: viewModel.currentUserRide.rideId, joinedUserRideId: rideParticipant.rideId, pickUp: CLLocationCoordinate2D(latitude: rideParticipant.startPoint!.latitude, longitude: rideParticipant.startPoint!.longitude),drop: CLLocationCoordinate2D(latitude: rideParticipant.endPoint!.latitude, longitude: rideParticipant.endPoint!.longitude), points: rideParticipant.points!)
        parentViewController?.present(rideRouteDisplayViewController, animated: false, completion: nil)
    }
    private func unjoinRiderFromRide(rideParticipant : RideParticipant){
        let rideCancellationAndUnJoinViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RideCancellationAndUnJoinViewController") as! RideCancellationAndUnJoinViewController
        
        rideCancellationAndUnJoinViewController.initializeDataForUnjoin(rideParticipants: viewModel.rideDetailInfo?.rideParticipants, rideType: viewModel.currentUserRide.rideType, ride: viewModel.currentUserRide, riderRideId: viewModel.getRiderRideId(), unjoiningUserRideId: viewModel.currentUserRide.rideId, unjoiningUserId: viewModel.currentUserRide.userId, unjoiningUserRideType: Ride.PASSENGER_RIDE) {
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationAndUnJoinViewController)
    }
    
    @objc func vehicleNameTapped(_ gesture: UITapGestureRecognizer) {
        guard let vehicle = viewModel.getRiderVehicle() else {
            return
        }
        let vehicleDisplayViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "VehicleDisplayViewController") as! VehicleDisplayViewController
        vehicleDisplayViewController.initializeDataBeforePresentingView(vehicle: vehicle)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: vehicleDisplayViewController, animated: false)
    }

    func sendSMS(phoneNumber:String?, message : String){

        let messageViewConrtoller = MFMessageComposeViewController()

        if MFMessageComposeViewController.canSendText() {
            messageViewConrtoller.body = message
            if phoneNumber != nil{
                messageViewConrtoller.recipients = [phoneNumber!]
            }
            messageViewConrtoller.messageComposeDelegate = parentViewController
            parentViewController?.present(messageViewConrtoller, animated: false, completion: nil)

        }
    }
    
    @IBAction func rideNotesTapped(_ sender: Any) {
        guard let riderRide = viewModel.rideDetailInfo?.riderRide else {
            return
        }
        guard let rideNotes = riderRide.rideNotes else {
            return
        }
        MessageDisplay.displayInfoDialogue(title: Strings.ride_notes, message: rideNotes, viewController: self.parentViewController)
    }
    
    @IBAction func switchRideButtonTapped(_ sender: Any) {
        let sendInviteBaseViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SendInviteBaseViewController") as! SendInviteBaseViewController
        sendInviteBaseViewController.initializeDataBeforePresenting(scheduleRide: viewModel.currentUserRide, isFromCanceRide: false, isFromRideCreation: false)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: sendInviteBaseViewController, animated: false)
    }
    
    
}
extension RiderDetailToPassengerCardTableViewCell : RideActionComplete {
    func rideActionCompleted(status: String) {
        
    }
    
    func rideActionFailed(status: String, error: ResponseError?) {
        ErrorProcessUtils.handleResponseError(responseError: error, error: nil, viewController: parentViewController)
    }
}
