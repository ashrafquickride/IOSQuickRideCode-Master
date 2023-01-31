//
//  RiderReachPickupPointToRiderNotificationHandler.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 10/04/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import Foundation
import ObjectMapper
class RiderReachPickupPointToRiderNotificationHandler : RideNotificationHandler{
    private var userNotification = UserNotification()
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            let rideData = Mapper<RiderReachPickupPointToRiderNotificationDynamicData>().map(JSONString: clientNotification.msgObjectJson!)

            var rideId : Double? = nil
            if rideData != nil && rideData!.riderRideId != nil{
                rideId = Double(rideData!.riderRideId!)
            }
            let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
            if(myActiveRidesCache == nil || rideId == nil)
            {
                return handler(false)
            }
            let ride = myActiveRidesCache!.getRiderRide(rideId: rideId!)
            if(ride != nil)
            {
                return handler(true)
            }
            else
            {
                return handler(false)
            }
        }
        
    }
    
    override func handleTextToSpeechMessage(userNotification : UserNotification)
    {
        let ride = Mapper<RiderReachPickupPointToRiderNotificationDynamicData>().map(JSONString: userNotification.msgObjectJson!)
        if ride == nil {
            return
        }
        let riderRideId = Double(ride!.riderRideId!)
        
        let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
        if myActiveRidesCache == nil || riderRideId == nil{
            return
        }
        let riderRide = myActiveRidesCache!.getRiderRide(rideId: riderRideId!)
        if riderRide != nil{
                checkRiderRideStatusAndSpeakInvitation(text: String(format: Strings.pickup_voice_msg, arguments: [ride!.passengerName!]), time: .now() + 4)
        }
    }
    
    private func showOTPToPickupView(rideParticipant: RideParticipant, joinedRiderRideId: Double) {
        let otpToPickupViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OTPToPickupViewController") as! OTPToPickupViewController
        otpToPickupViewController.initializeData(rideParticipant: rideParticipant, riderRideId: joinedRiderRideId, isFromMultiPickup: false, passengerPickupDelegate: self)
        ViewControllerUtils.addSubView(viewControllerToDisplay: otpToPickupViewController)
    }
    
    private func updatePassengerRideStatus(passengerRideId: Double, joinedRiderRideId: Double, passengerId: Double, passengerName: String, viewController : UIViewController?) {
        QuickRideProgressSpinner.startSpinner()
        PassengerRideServiceClient.updatePassengerRideStatus(passengerRideId: passengerRideId, joinedRiderRideId: joinedRiderRideId, passengerId: passengerId, status: Ride.RIDE_STATUS_STARTED, fromRider: true, otp: nil, viewController: viewController, completionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil {
                if responseObject!["result"] as! String == "SUCCESS" {
                    UIApplication.shared.keyWindow?.makeToast( Strings.checked_in_passenger)
                    super.handlePositiveAction(userNotification: self.userNotification, viewController: viewController)
                    super.navigateToLiveRideView(riderRideId: joinedRiderRideId)
                }else{
                    let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                    if responseError?.errorCode == RideValidationUtils.RIDER_PICKED_UP_ERROR{
                        MessageDisplay.displayInfoViewAlert(title: "", titleColor: nil, message: String(format: Strings.rider_picked_up_error, arguments: [passengerName,passengerName]), infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps) {
                        }
                    }
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        })
    }
    
    override func handlePositiveAction(userNotification:UserNotification, viewController : UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")
        self.userNotification = userNotification
        let riderReachPickupPointToRiderNotificationDynamicData = Mapper<RiderReachPickupPointToRiderNotificationDynamicData>().map(JSONString: userNotification.msgObjectJson!)
        if let notificationData = riderReachPickupPointToRiderNotificationDynamicData, let passengerUserIdInString = notificationData.passengerUserId, let passengerUserId = Double(passengerUserIdInString), let passengerRideIdInString = notificationData.passengerRideId, let passengerRideId = Double(passengerRideIdInString), let passengerName = notificationData.passengerName, let riderRideIdInString = notificationData.riderRideId, let rideId = Double(riderRideIdInString), let riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideId) {
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: "Do you want to pick up "+passengerName+"?", message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle: Strings.no_caps, linkButtonText: nil, viewController: nil) { (result) in
                if result == Strings.yes_caps{
                    if let rideParticipant = MyActiveRidesCache.getRidesCacheInstance()?.getRideParicipantForUserId(riderRideId: riderRide.rideId, userId: passengerUserId), RideViewUtils.isOTPRequiredToPickupPassenger(rideParticipant: rideParticipant, ride: riderRide, riderProfile: UserDataCache.getInstance()?.getLoggedInUserProfile()) {
                        self.showOTPToPickupView(rideParticipant: rideParticipant, joinedRiderRideId: riderRide.rideId)
                    } else {
                        self.updatePassengerRideStatus(passengerRideId: passengerRideId, joinedRiderRideId: riderRide.rideId, passengerId: passengerUserId, passengerName: passengerName, viewController: viewController)
                    }
                }
            }
        }
    }
   
    override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
        super.handleTap(userNotification: userNotification, viewController: viewController)
        let riderReachPickupPointToRiderNotificationDynamicData = Mapper<RiderReachPickupPointToRiderNotificationDynamicData>().map(JSONString: userNotification.msgObjectJson!)
        if riderReachPickupPointToRiderNotificationDynamicData == nil {
            return
        }
        let riderRideId = Double(riderReachPickupPointToRiderNotificationDynamicData!.riderRideId!)
        if riderRideId != nil && riderRideId != 0{
            super.navigateToLiveRideView(riderRideId: riderRideId!)
        }
    }
    
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        let riderReachPickupPointToRiderNotificationDynamicData = Mapper<RiderReachPickupPointToRiderNotificationDynamicData>().map(JSONString: userNotification.msgObjectJson!)
        if riderReachPickupPointToRiderNotificationDynamicData == nil ||
             riderReachPickupPointToRiderNotificationDynamicData!.passengerUserId == nil || riderReachPickupPointToRiderNotificationDynamicData!.passengerRideId == nil || riderReachPickupPointToRiderNotificationDynamicData!.passengerName == nil{
            return nil
        }
        let rideId =  Double(riderReachPickupPointToRiderNotificationDynamicData!.riderRideId!)
        let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
        if rideId == nil || myActiveRidesCache == nil{
            return nil
        }
        let riderRide = myActiveRidesCache!.getRiderRide(rideId: rideId!)
        if riderRide == nil {
            return nil
        }
        if riderRide!.status != Ride.RIDE_STATUS_STARTED{
            return nil
        }
        return Strings.pick_up
    }
    override func getNotificationAudioFilePath()-> String?{
        AppDelegate.getAppDelegate().log.debug("")
        return Bundle.main.path(forResource: "carunlock", ofType: "mp3")
    }
    class RiderReachPickupPointToRiderNotificationDynamicData : NSObject, Mappable {
        var riderRideId : String?
        var passengerUserId : String?
        var passengerRideId : String?
        var passengerName : String?
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            riderRideId <- map[Ride.FLD_RIDER_RIDE_ID]
            passengerUserId <- map[Ride.FLD_PASSENGERID]
            passengerRideId <- map[Ride.FLD_ID]
            passengerName <- map[Ride.FLD_PASSENGER_NAME]
        }
        public override var description: String {
            return "riderRideId: \(String(describing: self.riderRideId))," + "passengerUserId: \(String(describing: self.passengerUserId))," + " passengerRideId: \( String(describing: self.passengerRideId))," + " passengerName: \(String(describing: self.passengerName)),"
        }
    }
}
extension RiderReachPickupPointToRiderNotificationHandler: PassengerPickupWithOtpDelegate {
    func passengerPickedUpWithOtp(riderRideId : Double, userId: Double) {
        UIApplication.shared.keyWindow?.makeToast( Strings.checked_in_passenger)
        super.handlePositiveAction(userNotification: self.userNotification, viewController: nil)
        super.navigateToLiveRideView(riderRideId: riderRideId)
    }
    
    func passengerNotPickedUp(userId: Double) { }
}

