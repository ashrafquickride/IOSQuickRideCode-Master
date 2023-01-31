//
//  RideDirectInviteNotificationHandler.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 27/12/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideDirectInviteNotificationHandler : NotificationHandler,SelectedUserDelegate,RideInvitationActionCompletionListener,VehicleDetailsUpdateListener
{
    var matchedUserRideId = 0.0
    var matchedUserUserId = 0.0
    var matchedUserRole : String?
    var ride : Ride?
    var userNotification : UserNotification?
    var viewController : UIViewController?
    var selectedUser : MatchedUser?
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
            if myActiveRidesCache == nil{
                return handler(false)
            }
            let riderRideList = myActiveRidesCache!.getActiveRiderRides().values
            for riderRide in riderRideList{
                if (Ride.RIDE_STATUS_SCHEDULED == riderRide.status || Ride.RIDE_STATUS_DELAYED == riderRide.status) && riderRide.noOfPassengers > 0 &&  (riderRide.startTime <= Double(clientNotification.time!)*1000 && riderRide.expectedEndTime! >= Double(clientNotification.time!)*1000)
                {
                    return handler(false)
                }
            }
            let passengerRideList = myActiveRidesCache!.getActivePassengerRides().values
            for passengerRide in passengerRideList{
                var pickUpTime = passengerRide.pickupTime
                if pickUpTime == 0.0{
                    pickUpTime = passengerRide.startTime
                }
                if (Ride.RIDE_STATUS_SCHEDULED == passengerRide.status || Ride.RIDE_STATUS_DELAYED == passengerRide.status) && (pickUpTime <=  Double(clientNotification.time!)*1000 && passengerRide.dropTime >= Double(clientNotification.time!)*1000)
                {
                    return handler(false)
                }
            }
            guard let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: clientNotification) else {
                return handler(false)
            }
            RideInviteCache.getInstance().getRideInviteFromServer(id: rideInvitation.rideInvitationId) { (invite,responseError, error) in
                if responseError != nil || error != nil {
                    return handler(true)
                }
                return handler(invite != nil)
            }
            
        }
        
    }
    
    override func handleNewUserNotification(clientNotification: UserNotification) {
        self.userNotification = clientNotification
        
        super.handleNewUserNotification(clientNotification: clientNotification)
    }
    override func handleTap(userNotification: UserNotification,viewController : UIViewController?) {
        
        handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }
    
    override func handleNeutralAction(userNotification: UserNotification, viewController: UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("handleNeutralAction()")
        super.handleNeutralAction(userNotification: userNotification,viewController : viewController)
    }
    
    override func getNegativeActionNameWhenApplicable(userNotification : UserNotification) -> String?{
        return Strings.REJECT
    }
    override func getPositiveActionNameWhenApplicable(userNotification : UserNotification) -> String?{
        return Strings.VIEW_TO_JOIN
    }
    
    override func getNeutralActionNameWhenApplicable(userNotification: UserNotification) -> String?
    {
        return nil
    }
    
    func joinPassengerToRide(rideInvitation : RideInvitation?,matchedUser : MatchedUser,ignoringPointsConformation : Bool)
    {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if matchedUser.verificationStatus == false && Int(matchedUser.noOfRidesShared) <= clientConfiguration.minNoOfRidesReqNotToShowJoiningUnverifiedDialog && SharedPreferenceHelper.getCurrentUserGender() == User.USER_GENDER_FEMALE && SharedPreferenceHelper.getJoinWithUnverifiedUsersStatus() == false{
            let alertControllerWithCheckBox = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard,bundle: nil).instantiateViewController(withIdentifier: "AlertControllerWithCheckBox") as! AlertControllerWithCheckBox
            alertControllerWithCheckBox.initializeDataBeforePresenting(alertTitle: Strings.dont_show_again_title, checkBoxText: Strings.dont_show_again_checkBox_text, handler: { (result, dontShow) in
                SharedPreferenceHelper.setJoinWithUnverifiedUsersStatus(status: dontShow)
                if Strings.yes_caps == result{
                    self.continueJoin(rideInvitation: rideInvitation, displayPointsConfirmation: true,matchedUser : matchedUser)
                }
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: alertControllerWithCheckBox)
        }else{
            self.continueJoin(rideInvitation: rideInvitation, displayPointsConfirmation: ignoringPointsConformation,matchedUser : matchedUser)
        }
        
        
    }
    func continueJoin(rideInvitation : RideInvitation?,displayPointsConfirmation: Bool,matchedUser : MatchedUser){
        var riderHasHelmet = false
        if Ride.RIDER_RIDE == rideInvitation!.rideType
        {
            riderHasHelmet = (matchedUser as! MatchedRider).riderHasHelmet
        }
        
        let joinPassengerToRideHandler = JoinPassengerToRideHandler(viewController: ViewControllerUtils.getCenterViewController(), riderRideId: rideInvitation!.rideId, riderId: rideInvitation!.riderId, passengerRideId: rideInvitation!.passenegerRideId, passengerId: rideInvitation!.passengerId, rideType: rideInvitation!.rideType!, pickupAddress: matchedUser.pickupLocationAddress, pickupLatitude: matchedUser.pickupLocationLatitude!, pickupLongitude: matchedUser.pickupLocationLongitude!, pickupTime: rideInvitation!.pickupTime, dropAddress: matchedUser.dropLocationAddress, dropLatitude: matchedUser.dropLocationLatitude!, dropLongitude: matchedUser.dropLocationLongitude!, dropTime: rideInvitation!.dropTime, matchingDistance: matchedUser.distance!, points: matchedUser.points!,newFare:  matchedUser.newFare, noOfSeats: rideInvitation!.noOfSeats, rideInvitationId: rideInvitation!.rideInvitationId,invitingUserName :rideInvitation!.invitingUserName!,invitingUserId : rideInvitation!.invitingUserId,displayPointsConfirmationAlert: displayPointsConfirmation, riderHasHelmet: riderHasHelmet, pickupTimeRecalculationRequired: matchedUser.pickupTimeRecalculationRequired, passengerRouteMatchPercentage: rideInvitation!.matchPercentageOnPassengerRoute, riderRouteMatchPercentage: rideInvitation!.matchPercentageOnRiderRoute , moderatorId: nil, listener: self)
        joinPassengerToRideHandler.joinPassengerToRide(invitation: rideInvitation!)
    }
    override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?) {
        
        self.userNotification = userNotification
        self.viewController = ViewControllerUtils.getCenterViewController()
        viewController?.dismiss(animated: false, completion: nil)
        let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
        if rideInvitation == nil{
            return
        }
        var rideType : String?
        if rideInvitation!.rideType == Ride.RIDER_RIDE
        {
            rideType = Ride.PASSENGER_RIDE
        }
        else
        {
            rideType = Ride.RIDER_RIDE
        }
        let rejectReasonAlertController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "RejectCustomAlertController")as! RejectCustomAlertController
        rejectReasonAlertController.initializeDataBeforePresentingView(title: Strings.do_u_have_reason, positiveBtnTitle: Strings.confirm_caps, negativeBtnTitle: Strings.skip_caps, viewController: self.viewController, rideType: rideType) { (text, result) in
            if result == Strings.confirm_caps
            {
                if rideInvitation!.rideType == Ride.RIDER_RIDE{
                    RideMatcherServiceClient.passengerRejectedRiderInvitation(riderRideId: rideInvitation!.rideId, riderId: rideInvitation!.riderId, passengerRideId: rideInvitation!.passenegerRideId, passengerId: rideInvitation!.passengerId, rideInvitationId: rideInvitation!.rideInvitationId, rideType: rideInvitation!.rideType!, rejectReason: text, viewController: ViewControllerUtils.getCenterViewController(), complitionHandler: { (responseObject, error) in
                        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"
                        {
                            super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
                            UIApplication.shared.keyWindow?.makeToast( Strings.ride_invite_rejected)
                            
                        }
                        else
                        {
                            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                        }
                        
                    })
                }
                else
                {
                    RideMatcherServiceClient.riderRejectedPassengerInvitation(riderRideId: rideInvitation!.rideId, riderId: rideInvitation!.riderId, passengerRideId: rideInvitation!.passenegerRideId, passengerId: rideInvitation!.passengerId, rideInvitationId: rideInvitation!.rideInvitationId, rideType: rideInvitation!.rideType!, rejectedReason: text, moderatorId: nil, viewController: ViewControllerUtils.getCenterViewController(), completeionHandler: { (responseObject, error) in
                        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"
                        {
                            super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
                            UIApplication.shared.keyWindow?.makeToast( Strings.ride_invite_rejected)
                            
                        }
                        else
                        {
                            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                        }
                    })
                }
            }
        }
    }
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        
        self.viewController = viewController
        if self.viewController == nil{
            self.viewController = ViewControllerUtils.getCenterViewController()
        }
        self.userNotification = userNotification
        let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
        if rideInvitation == nil {
            return
        }
        if rideInvitation!.startTime == 0{
            rideInvitation?.startTime = NSDate().timeIntervalSince1970*1000
        }
        ride = Ride(userId : Double(QRSessionManager.getInstance()!.getUserId())!,  rideType : rideInvitation!.rideType!,  startAddress : rideInvitation!.pickupAddress!,
                    startLatitude : rideInvitation!.pickupLatitude,  startLongitude : rideInvitation!.pickupLongitude,  endAddress : rideInvitation!.dropAddress!,
                    endLatitude :rideInvitation!.dropLatitude ,  endLongitude : rideInvitation!.dropLongitude, startTime : rideInvitation!.startTime)
        ride?.distance = rideInvitation!.matchedDistance
        
        if Ride.RIDER_RIDE == rideInvitation!.rideType{
            matchedUserRideId = rideInvitation!.rideId
            matchedUserUserId = rideInvitation!.riderId
            matchedUserRole = MatchedUser.RIDER
            ride!.rideType = Ride.PASSENGER_RIDE
        }else{
            matchedUserRideId = rideInvitation!.passenegerRideId
            matchedUserUserId = rideInvitation!.passengerId
            matchedUserRole = MatchedUser.PASSENGER
            ride!.rideType = Ride.RIDER_RIDE
        }
        getInvitedUserInfo(viewController: viewController)
    }
    
    func getInvitedUserInfo(viewController: UIViewController?){
        if ride == nil{
            return
        }
        let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
        if ride!.rideType == Ride.RIDER_RIDE || ride?.rideType == Ride.REGULAR_PASSENGER_RIDE{
            
            QuickRideProgressSpinner.startSpinner()
            RouteMatcherServiceClient.validateInviteByContactFromPassengerAndGetMatchedPassenger(invitationId: StringUtils.getStringFromDouble(decimalNumber: rideInvitation!.rideInvitationId), passengerRideId: StringUtils.getStringFromDouble(decimalNumber: rideInvitation!.passenegerRideId), riderId: StringUtils.getStringFromDouble(decimalNumber: ride!.userId), passengerUserId: StringUtils.getStringFromDouble(decimalNumber: rideInvitation!.passengerId), points: StringUtils.getStringFromDouble(decimalNumber: rideInvitation!.riderPoints), viewController: viewController, completionhandler: { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"
                {
                    let matchedPassenger = Mapper<MatchedPassenger>().map(JSONObject: responseObject!["resultData"])
                    if matchedPassenger == nil{
                        self.showRideClosedDialog()
                    }else{
                        self.moveToMatchedRideDetailView(matchedUser: matchedPassenger!, ride: self.ride!, viewController: viewController, inviteId: rideInvitation!.rideInvitationId)
                    }
                }
                else
                {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                    if responseObject != nil
                    {
                        
                        let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                        if responseError != nil && RideValidationUtils.validateResponseErrorCodeAndReturnStatus(responseError: responseError!){
                            super.handlePositiveAction(userNotification: self.userNotification!, viewController: self.viewController)
                        }
                    }
                }
            })
        }else{
            QuickRideProgressSpinner.startSpinner()
            RouteMatcherServiceClient.validateInviteByContactFromRiderAndGetMatchedRider(invitationId: StringUtils.getStringFromDouble(decimalNumber: rideInvitation?.rideInvitationId), riderRideId: StringUtils.getStringFromDouble(decimalNumber: rideInvitation?.rideId), riderId: StringUtils.getStringFromDouble(decimalNumber: rideInvitation!.riderId), passengerUserId: StringUtils.getStringFromDouble(decimalNumber:rideInvitation?.passengerId), noOfSeats: "1", viewController: viewController, completionhandler: { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"
                {
                    let matchedRider = Mapper<MatchedRider>().map(JSONObject: responseObject!["resultData"])
                    if matchedRider == nil{
                        self.showRideClosedDialog()
                    }else{
                        self.moveToMatchedRideDetailView(matchedUser: matchedRider!, ride: self.ride!, viewController: viewController, inviteId: rideInvitation!.rideInvitationId)
                    }
                }
                    
                else
                {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewController, handler: nil)
                    if responseObject != nil
                    {
                        let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                        
                        if responseError != nil && RideValidationUtils.validateResponseErrorCodeAndReturnStatus(responseError: responseError!){
                            super.handlePositiveAction(userNotification: self.userNotification!, viewController: self.viewController)
                        }
                        
                    }
                }
            })
        }
    }
    func moveToMatchedRideDetailView(matchedUser : MatchedUser,ride : Ride, viewController: UIViewController?,inviteId : Double){
        
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
        
        var startAndEndChangeRequired = false
        if matchedUser.userRole == MatchedUser.PASSENGER{
            startAndEndChangeRequired = true
        }
        
        if ride.rideType == Ride.RIDER_RIDE{
            var vehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
            if vehicle == nil{
                vehicle = Vehicle.getDeFaultVehicle()
            }
            let
            rideToPass = RiderRide(ride: ride)
            (rideToPass ).additionalFacilities = vehicle!.additionalFacilities
            (rideToPass ).makeAndCategory = vehicle!.additionalFacilities
            (rideToPass ).vehicleNumber = vehicle!.registrationNumber
            (rideToPass ).vehicleModel = vehicle!.vehicleModel
            (rideToPass ).vehicleType = vehicle!.vehicleType
            mainContentVC.initializeData(ride: rideToPass, matchedUserList: [matchedUser], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: startAndEndChangeRequired,  selectedUserDelegate: self,rideInviteId: inviteId)
            ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
            
        }else{
            let rideToPass = PassengerRide(ride: ride)
            mainContentVC.initializeData(ride: rideToPass, matchedUserList: [matchedUser], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: startAndEndChangeRequired, selectedUserDelegate: self,rideInviteId: inviteId)
            ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
        }
        
        
    }
    func showRideClosedDialog() {
        MessageDisplay.displayAlert(messageString: "This ride is already closed or not mathing with your ride preferences", viewController: ViewControllerUtils.getCenterViewController()) { (result) in
        }
        super.handlePositiveAction(userNotification: userNotification!, viewController: viewController)
    }
    func matchingRidersRetrievalFailed( requestSeqId : Int,responseObject :NSDictionary?,error : NSError?){
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
    }
    func matchingPassengersRetrievalFailed(requestSeqId : Int,responseObject :NSDictionary?,error : NSError?){
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
    }
    func selectedUser(selectedUser : MatchedUser){
        viewController?.dismiss(animated: false, completion: nil)
        let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
        self.selectedUser = selectedUser
        if rideInvitation == nil{
            return
        }
        if rideInvitation!.startTime == 0{
            rideInvitation?.startTime = NSDate().timeIntervalSince1970*1000
        }
        
        rideInvitation?.pickupLatitude = selectedUser.pickupLocationLatitude!
        rideInvitation?.pickupLongitude = selectedUser.pickupLocationLongitude!
        rideInvitation?.dropLatitude = selectedUser.dropLocationLatitude!
        rideInvitation?.dropLongitude = selectedUser.dropLocationLongitude!
        rideInvitation?.pickupAddress = selectedUser.pickupLocationAddress
        rideInvitation?.dropAddress = selectedUser.dropLocationAddress
        rideInvitation?.points = selectedUser.points!
        if selectedUser.userRole == MatchedUser.RIDER{
            if selectedUser.matchPercentage != nil{
                rideInvitation?.matchPercentageOnPassengerRoute = selectedUser.matchPercentage!
                rideInvitation?.matchPercentageOnRiderRoute = selectedUser.matchPercentageOnMatchingUserRoute
            }
        }else if selectedUser.userRole == MatchedUser.PASSENGER{
            rideInvitation?.matchPercentageOnPassengerRoute = selectedUser.matchPercentageOnMatchingUserRoute
            rideInvitation?.matchPercentageOnRiderRoute = selectedUser.matchPercentage!
            rideInvitation?.riderPoints = selectedUser.points!
        }
        if Ride.RIDER_RIDE == rideInvitation!.rideType{
            var passengerRide = PassengerRide(ride : ride!)
            let existingRide = MyActiveRidesCache.getRidesCacheInstance()?.getRedundantRide(ride: passengerRide)
            if existingRide != nil{
                passengerRide = existingRide as! PassengerRide
            }
            if passengerRide.rideId == 0{
                CreatePassengerRideHandler(ride: passengerRide, rideRoute: nil, isFromInviteByContact: true, targetViewController: viewController, parentRideId: nil,relayLegSeq: nil).createPassengerRide(handler: { (passengerRide, error) in
                    if error != nil{
                        MessageDisplay.displayErrorAlert(responseError: error!, targetViewController: self.viewController, handler:nil)
                    }else{
                        rideInvitation!.passenegerRideId = passengerRide!.rideId
                        rideInvitation!.passengerId = passengerRide!.userId
                        if selectedUser.userRole == MatchedUser.RIDER && selectedUser.newFare != rideInvitation!.newFare{
                            rideInvitation?.newRiderFare = selectedUser.newFare
                            var selectedRiders = [MatchedRider]()
                            selectedRiders.append(selectedUser as! MatchedRider)
                            InviteRiderHandler(passengerRide: passengerRide! , selectedRiders: selectedRiders, displaySpinner: true, selectedIndex: nil, viewController: ViewControllerUtils.getCenterViewController()).inviteSelectedRiders(inviteHandler: { (error,nserror) in
                                if error == nil && nserror == nil{
                                    super.handlePositiveAction(userNotification: self.userNotification!,viewController : ViewControllerUtils.getCenterViewController())
                                }
                            })
                        }else{
                            rideInvitation?.newFare = selectedUser.newFare
                            self.joinPassengerToRide(rideInvitation: rideInvitation,matchedUser: selectedUser, ignoringPointsConformation: true)
                        }
                        
                    }
                })
            }else{
                rideInvitation!.passenegerRideId = passengerRide.rideId
                rideInvitation!.passengerId = passengerRide.userId
                if selectedUser.userRole == MatchedUser.RIDER && selectedUser.newFare != rideInvitation!.newFare{
                    
                    rideInvitation?.newRiderFare = selectedUser.newFare
                    var selectedRiders = [MatchedRider]()
                    selectedRiders.append(selectedUser as! MatchedRider)
                    InviteRiderHandler(passengerRide: passengerRide , selectedRiders: selectedRiders, displaySpinner: true, selectedIndex: nil, viewController: ViewControllerUtils.getCenterViewController()).inviteSelectedRiders(inviteHandler: { (error,nserror) in
                        if error == nil  && nserror == nil{
                            super.handlePositiveAction(userNotification: self.userNotification!,viewController : ViewControllerUtils.getCenterViewController())
                        }
                    })
                }else{
                    rideInvitation?.newRiderFare = selectedUser.newFare
                    self.joinPassengerToRide(rideInvitation: rideInvitation,matchedUser: selectedUser, ignoringPointsConformation: true)
                }
            }
            
        }else{
            var riderRide = RiderRide(ride:ride!)
            let exisitingRide = MyActiveRidesCache.getRidesCacheInstance()?.getRedundantRide(ride: riderRide)
            if exisitingRide != nil{
                riderRide = exisitingRide as! RiderRide
            }else{
                let vehicle = UserDataCache.getInstance()!.getCurrentUserVehicle()
                if vehicle.vehicleId == 0 || vehicle.registrationNumber.isEmpty == true
                {
                    MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.vehicle_details, message2: nil, positiveActnTitle: Strings.configure_caps, negativeActionTitle : Strings.cancel_caps,linkButtonText: nil, viewController: viewController, handler: { (result) in
                        if Strings.configure_caps == result{
                    let vehicleSavingViewController = UIStoryboard(name: StoryBoardIdentifiers.vehicle_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.vehicleSavingViewController) as! VehicleSavingViewController
                            vehicleSavingViewController.initializeDataBeforePresentingView(presentedFromActivationView: false, rideConfigurationDelegate: nil,vehicle : nil,listener : self)
                            ViewControllerUtils.displayViewController(currentViewController: self.viewController, viewControllerToBeDisplayed: vehicleSavingViewController, animated: false)
                        }
                        else{
                            return
                        }
                    })
                    return
                }
                else
                {
                    riderRide.availableSeats = vehicle.capacity
                    riderRide.vehicleModel = vehicle.vehicleModel
                    riderRide.vehicleType = vehicle.vehicleType
                    riderRide.farePerKm = vehicle.fare
                    riderRide.vehicleNumber = vehicle.registrationNumber
                }
            }
            createRiderRideAfterCheckingVehicle(riderRide: riderRide,selectedUser: selectedUser)
        }
    }
    func saveRide(ride: Ride) {
        self.ride = ride
    }
    func VehicleDetailsUpdated()
    {
        let riderRide = RiderRide(ride:ride!)
        let vehicle = UserDataCache.getInstance()?.getCurrentUserVehicle()
        riderRide.availableSeats = vehicle!.capacity
        riderRide.vehicleModel = vehicle!.vehicleModel
        riderRide.vehicleType = vehicle!.vehicleType
        riderRide.farePerKm = vehicle!.fare
        riderRide.vehicleNumber = vehicle?.registrationNumber
        riderRide.riderHasHelmet = vehicle!.riderHasHelmet
        createRiderRideAfterCheckingVehicle(riderRide : riderRide,selectedUser: selectedUser!)
    }
    func createRiderRideAfterCheckingVehicle(riderRide : RiderRide, selectedUser : MatchedUser)
    {
        let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
        if selectedUser.userRole == MatchedUser.RIDER{
            if selectedUser.matchPercentage != nil{
                rideInvitation?.matchPercentageOnPassengerRoute = selectedUser.matchPercentage!
                rideInvitation?.matchPercentageOnRiderRoute = selectedUser.matchPercentageOnMatchingUserRoute
            }
        }else if selectedUser.userRole == MatchedUser.PASSENGER{
            rideInvitation?.matchPercentageOnPassengerRoute = selectedUser.matchPercentageOnMatchingUserRoute
            rideInvitation?.matchPercentageOnRiderRoute = selectedUser.matchPercentage!
        }
        if riderRide.availableSeats < (rideInvitation?.noOfSeats)!{
            MessageDisplay.displayAlert(messageString: Strings.insufficient_seats_error+" \(String(describing: rideInvitation!.noOfSeats)) seats", viewController: ViewControllerUtils.getCenterViewController(),handler: nil)
            return
        }
        
        if (riderRide.rideId == 0){
            CreateRiderRideHandler(ride: riderRide, rideRoute: nil, isFromInviteByContact: true, targetViewController: ViewControllerUtils.getCenterViewController()).createRiderRide(handler: { (riderRide, error) in
                if error != nil{
                    MessageDisplay.displayErrorAlert(responseError: error!, targetViewController: self.viewController, handler: nil)
                }else{
                    rideInvitation!.rideId = riderRide!.rideId
                    rideInvitation!.riderId = riderRide!.userId
                    rideInvitation!.pickupTime = selectedUser.pickupTime!
                    rideInvitation!.dropTime = selectedUser.dropTime!
                    if selectedUser.userRole == MatchedUser.PASSENGER && selectedUser.newFare != -1{
                        rideInvitation?.newFare = selectedUser.newFare
                        var selectedPassengers = [MatchedPassenger]()
                        selectedPassengers.append(selectedUser as! MatchedPassenger)
                        
                        InviteSelectedPassengersAsyncTask(riderRide: riderRide!, selectedUsers: selectedPassengers, viewController: ViewControllerUtils.getCenterViewController(), displaySpinner: true, selectedIndex: nil, invitePassengersCompletionHandler: { (error,nserror) in
                            if error == nil && nserror == nil{
                                super.handlePositiveAction(userNotification: self.userNotification!,viewController : ViewControllerUtils.getCenterViewController())
                            }
                        }).invitePassengersFromMatches()
                        
                    }else{
                        rideInvitation?.newRiderFare = selectedUser.newFare
                        self.joinPassengerToRide(rideInvitation: rideInvitation,matchedUser: selectedUser, ignoringPointsConformation: true)
                    }
                    
                }
            })
            
        }else{
            rideInvitation!.rideId = riderRide.rideId
            rideInvitation!.riderId = riderRide.userId
            if selectedUser.userRole == MatchedUser.PASSENGER && selectedUser.newFare !=  -1{
                rideInvitation?.newFare = selectedUser.newFare
                var selectedPassengers = [MatchedPassenger]()
                selectedPassengers.append(selectedUser as! MatchedPassenger)
                
                InviteSelectedPassengersAsyncTask(riderRide: riderRide, selectedUsers: selectedPassengers, viewController: ViewControllerUtils.getCenterViewController(), displaySpinner: true, selectedIndex: nil, invitePassengersCompletionHandler: { (error,nserror) in
                    if error == nil && nserror == nil{
                        super.handlePositiveAction(userNotification: self.userNotification!,viewController : ViewControllerUtils.getCenterViewController())
                    }
                }).invitePassengersFromMatches()
                
            }else{
                rideInvitation?.newRiderFare = selectedUser.newFare
                self.joinPassengerToRide(rideInvitation: rideInvitation,matchedUser: selectedUser, ignoringPointsConformation: true)
            }
            
        }
        
    }
    func rideInviteAcceptCompleted(rideInvitationId : Double){
        super.handlePositiveAction(userNotification: userNotification!, viewController: viewController)
    }
    func rideInviteRejectCompleted(rideInvitation : RideInvitation){
        super.handleNegativeAction(userNotification: userNotification!, viewController: viewController)
    }
    func rideInviteActionFailed(rideInvitationId: Double, responseError: ResponseError?,error:NSError?, isNotificationRemovable : Bool){
        if isNotificationRemovable
        {
            super.handlePositiveAction(userNotification: userNotification!, viewController: viewController)
        }
    }
    
    func rideInviteActionCancelled() { }
    
    func rejectUser(selectedUser: MatchedUser) {
        handleNegativeAction(userNotification: userNotification!, viewController: viewController)
    }
}
