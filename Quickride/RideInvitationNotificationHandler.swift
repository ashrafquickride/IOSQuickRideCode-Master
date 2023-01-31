 //
 //  RideInvitationNotificationHandler.swift
 //  Quickride
 //
 //  Created by KNM Rao on 29/01/16.
 //  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
 //

 import Foundation
 import ObjectMapper
 import CoreLocation

 public class RideInvitationNotificationHandler:NotificationHandler , UserSelectedDelegate,RideInvitationActionCompletionListener,SelectedUserDelegate{

    var userNotification: UserNotification?
    var targetViewController: UIViewController?
    var rideInvitationActionCompletionListener: RideInvitationActionCompletionListener?

     
    override public func handleNewUserNotification(clientNotification: UserNotification) {
        super.handleNewUserNotification(clientNotification: clientNotification)
        let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: clientNotification)
        if rideInvitation == nil{
          return
        }
    }

    override func displayNotification(clientNotification: UserNotification) {
        if UserDataCache.SUBSCRIPTION_STATUS {
            return
        }
        if let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: clientNotification) {
            self.userNotification = clientNotification
            if rideInvitation.rideType == RegularRide.REGULAR_RIDER_RIDE || rideInvitation.rideType == RegularRide.REGULAR_PASSENGER_RIDE || RideViewUtils.isModetatorNotification(userNotification: clientNotification) {
                super.displayNotification(clientNotification: clientNotification)
            } else {
                self.getMatchedUserAndNavigate(isHighAlert: true)
            }
        }
    }

    override public func handleTap(userNotification clientNotification : UserNotification,viewController : UIViewController?){
        AppDelegate.getAppDelegate().log.debug("handleTap()")
        self.userNotification = clientNotification
        self.targetViewController = ViewControllerUtils.getCenterViewController()
        handleNeutralAction(userNotification: userNotification!, viewController: self.targetViewController)
    }

    func handleAcceptAction(userNotification: UserNotification, rideInvitationActionCompletionListener: RideInvitationActionCompletionListener?, viewController : UIViewController?) {
        self.rideInvitationActionCompletionListener = rideInvitationActionCompletionListener
        handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }

    func handleRejectAction(userNotification:UserNotification, rideInvitationActionCompletionListener: RideInvitationActionCompletionListener?, viewController : UIViewController?) {
        self.rideInvitationActionCompletionListener = rideInvitationActionCompletionListener
        handleNegativeAction(userNotification: userNotification, viewController: viewController)
    }

    override func handlePositiveAction(userNotification:UserNotification,viewController : UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")

        self.userNotification = userNotification
        self.targetViewController = ViewControllerUtils.getCenterViewController()
        let rideInvitation:RideInvitation? = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
        if rideInvitation == nil{
            AppDelegate.getAppDelegate().log.error("rideInvitation is nil : \(String(describing: userNotification.msgObjectJson))")
            return
        }
        completeRideJoin(rideInvitation: rideInvitation!,displayPointsConfirmation: true)
    }
    func completeRideJoin(rideInvitation : RideInvitation,displayPointsConfirmation : Bool){

        if UserDataCache.getInstance() != nil {
            QuickRideProgressSpinner.startSpinner()
            UserDataCache.getInstance()!.getUserBasicInfo(userId: rideInvitation.invitingUserId, handler: { (userBasicInfo, responseError, error) in
                QuickRideProgressSpinner.stopSpinner()
                if userBasicInfo != nil && userBasicInfo!.verificationStatus == false && SharedPreferenceHelper.getJoinWithUnverifiedUsersStatus() == false && SharedPreferenceHelper.getCurrentUserGender() == User.USER_GENDER_FEMALE{

                    let alertControllerWithCheckBox = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AlertControllerWithCheckBox") as! AlertControllerWithCheckBox
                    alertControllerWithCheckBox.initializeDataBeforePresenting(alertTitle: Strings.dont_show_again_title, checkBoxText: Strings.dont_show_again_checkBox_text, handler: { (result,dontShow) in
                        SharedPreferenceHelper.setJoinWithUnverifiedUsersStatus(status: dontShow)
                        if Strings.yes_caps == result{
                            self.continueJoinRide(rideInvitation: rideInvitation, displayPointsConfirmation: displayPointsConfirmation)
                        }
                    })
                    ViewControllerUtils.addSubView(viewControllerToDisplay: alertControllerWithCheckBox)
                }else{
                    self.continueJoinRide(rideInvitation: rideInvitation,displayPointsConfirmation:displayPointsConfirmation)
                }
            })
        }else{
            continueJoinRide(rideInvitation: rideInvitation,displayPointsConfirmation : displayPointsConfirmation)
        }

    }
    func continueJoinRide(rideInvitation : RideInvitation,displayPointsConfirmation :Bool){
        if RideValidationUtils.isRegularRide(rideType: rideInvitation.rideType!) == true{
            checkAndDisplayHelmetAlert(rideInvitation: rideInvitation,viewController: self.targetViewController)
        }else{
            handleNormalRideJoin(rideInvitation: rideInvitation, displayPointsConfirmation: displayPointsConfirmation,viewController: self.targetViewController)
        }
    }
    func checkAndDisplayHelmetAlert(rideInvitation : RideInvitation,viewController :UIViewController?)
    {
        if rideInvitation.riderHasHelmet
        {
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.helmet_required_alert, message2: nil, positiveActnTitle: Strings.helmet_positive_action, negativeActionTitle: Strings.helmet_negative_action, linkButtonText: nil, viewController: nil, handler: { (result) in
                if result == Strings.helmet_positive_action{
                    self.handleRegularRideJoin(rideInvitation: rideInvitation,viewController: self.targetViewController)
                }
            })
            return
        }
        else
        {
            self.handleRegularRideJoin(rideInvitation: rideInvitation,viewController: self.targetViewController)
        }
    }
    override func getActionParams(userNotification: UserNotification) -> [String : String] {
        AppDelegate.getAppDelegate().log.debug("getActionParams()")
        let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
        return rideInvitation!.getParams()
    }
    func handleNormalRideJoin(rideInvitation : RideInvitation,displayPointsConfirmation: Bool,viewController :UIViewController?){
        AppDelegate.getAppDelegate().log.debug("handleNormalRideJoin()")
        let isModerator = RideViewUtils.isModetatorNotification(userNotification: userNotification)
        var points: Double = 0
        var newFare: Double = 0
        if rideInvitation.rideType == Ride.PASSENGER_RIDE || rideInvitation.rideType == Ride.REGULAR_PASSENGER_RIDE{
            points = rideInvitation.riderPoints
            newFare = rideInvitation.newRiderFare
        }else {
            points = rideInvitation.points
            newFare = rideInvitation.newFare
        }
        let joinPassengerToRideHandler = JoinPassengerToRideHandler(viewController: targetViewController, riderRideId: rideInvitation.rideId, riderId: rideInvitation.riderId, passengerRideId: rideInvitation.passenegerRideId, passengerId: rideInvitation.passengerId, rideType: rideInvitation.rideType!, pickupAddress: rideInvitation.pickupAddress, pickupLatitude: rideInvitation.pickupLatitude, pickupLongitude: rideInvitation.pickupLongitude, pickupTime: rideInvitation.pickupTime, dropAddress: rideInvitation.dropAddress, dropLatitude: rideInvitation.dropLatitude, dropLongitude: rideInvitation.dropLongitude, dropTime: rideInvitation.dropTime, matchingDistance: rideInvitation.matchedDistance, points: points, newFare: newFare, noOfSeats: rideInvitation.noOfSeats, rideInvitationId: rideInvitation.rideInvitationId,invitingUserName :rideInvitation.invitingUserName!,invitingUserId :rideInvitation.invitingUserId,displayPointsConfirmationAlert: displayPointsConfirmation, riderHasHelmet: rideInvitation.riderHasHelmet, pickupTimeRecalculationRequired: rideInvitation.pickupTimeRecalculationRequired, passengerRouteMatchPercentage: rideInvitation.matchPercentageOnPassengerRoute, riderRouteMatchPercentage: rideInvitation.matchPercentageOnRiderRoute, moderatorId: isModerator ? QRSessionManager.getInstance()?.getUserId() : nil, listener: self)

        joinPassengerToRideHandler.joinPassengerToRide(invitation: rideInvitation)
    }
    func handleRegularRideJoin(rideInvitation : RideInvitation,viewController :UIViewController?) {
        let regularRideInviteActionHandler : RegularRideInviteActionHandler = RegularRideInviteActionHandler()
        regularRideInviteActionHandler.rideInvitationNotificationId = userNotification!.notificationId
        regularRideInviteActionHandler.joinPassengerToRegularRide(rideInvitation: rideInvitation, viewController: self.targetViewController)
    }
    func completeNegativeAction(userNotification: UserNotification,rideInvitation : RideInvitation,rejectReason : String?,viewController:UIViewController?){
        AppDelegate.getAppDelegate().log.debug("completeInviteReject()")

        if rideInvitation.rideType == Ride.REGULAR_PASSENGER_RIDE{

            RegularRideInviteActionHandler().riderRejectedInvitation(rideInvitation: rideInvitation, rejectReason:rejectReason,viewController: viewController)
            super.handleNegativeAction(userNotification: userNotification, viewController: viewController)

        }else if  rideInvitation.rideType == Ride.REGULAR_RIDER_RIDE{
            RegularRideInviteActionHandler().passengerRejectedInvitation(rideInvitation: rideInvitation,rejectReason:rejectReason, viewController: viewController)
            super.handleNegativeAction(userNotification: userNotification, viewController: viewController)

        }else if Ride.RIDER_RIDE == rideInvitation.rideType {

            let passengerRejectRiderInvitationTask = PassengerRejectRiderInvitationTask(rideInvitation: rideInvitation, viewController: viewController, rideRejectReason: rejectReason, rideInvitationActionCompletionListener: self)
            passengerRejectRiderInvitationTask.rejectRiderInvitation()
        } else if Ride.PASSENGER_RIDE == rideInvitation.rideType || TaxiPoolConstants.Taxi == rideInvitation.rideType {
            let isModerator = RideViewUtils.isModetatorNotification(userNotification: userNotification)
            let riderRejectPassengerInvitationTask = RiderRejectPassengerInvitationTask(rideInvitation: rideInvitation, moderatorId: isModerator ? QRSessionManager.getInstance()?.getUserId() : nil, viewController: viewController, rideRejectReason: rejectReason, rideInvitationActionCompletionListener: self)
            riderRejectPassengerInvitationTask.rejectPassengerInvitation()
        }
    }

    override func handleNegativeAction(userNotification: UserNotification,viewController:UIViewController? ) {
        AppDelegate.getAppDelegate().log.debug("handleNegativeAction()")
        self.userNotification = userNotification
        var rideType : String?
        let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
        if rideInvitation == nil{
            return
        }

        self.targetViewController = ViewControllerUtils.getCenterViewController()

        if rideInvitation!.rideType == Ride.RIDER_RIDE {
            rideType = Ride.PASSENGER_RIDE
        } else {
            rideType = Ride.RIDER_RIDE
        }
        let rejectReasonAlertController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "RejectCustomAlertController")as! RejectCustomAlertController
        rejectReasonAlertController.initializeDataBeforePresentingView(title: Strings.do_u_have_reason, positiveBtnTitle: Strings.confirm_caps, negativeBtnTitle: Strings.skip_caps, viewController: self.targetViewController, rideType: rideType) { (text, result) in
            if result == Strings.confirm_caps
            {
                self.completeNegativeAction(userNotification: userNotification, rideInvitation : rideInvitation!,rejectReason: text,viewController: self.targetViewController)
            }
        }

    }

    override func handleNeutralAction(userNotification:UserNotification, viewController : UIViewController?) {

        AppDelegate.getAppDelegate().log.debug("handleNeutralAction")
        self.userNotification = userNotification
        self.targetViewController = ViewControllerUtils.getCenterViewController()
        getMatchedUserAndNavigate(isHighAlert: false)
    }

    func getMatchedUserAndNavigate(isHighAlert: Bool) {
        let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)

        if rideInvitation == nil{
            AppDelegate.getAppDelegate().log.error("rideInvitation is nil : \(String(describing: userNotification?.msgObjectJson))")
            return
        }
        if !isHighAlert{
                    QuickRideProgressSpinner.startSpinner()
                   }
        switch (rideInvitation!.rideType)! {

        case Ride.RIDER_RIDE:

            RouteMatcherServiceClient.getMatchingRider(riderRideId: rideInvitation!.rideId, passengerRideId: rideInvitation!.passenegerRideId, targetViewController: targetViewController,complitionHandler: { (responseObject, error) -> Void in
                self.checkResponseAndNavigateToRideDetailView(responseObject: responseObject, error: error, rideInvitation: rideInvitation!, isHighAlert: isHighAlert)
            })
            break
        case Ride.PASSENGER_RIDE:
            RouteMatcherServiceClient.getMatchingPassenger(passengerRideId: rideInvitation!.passenegerRideId, riderRideId: rideInvitation!.rideId, targetViewController: targetViewController, complitionHandler: { (responseObject, error) -> Void in
                self.checkResponseAndNavigateToRideDetailView(responseObject: responseObject, error: error, rideInvitation: rideInvitation!, isHighAlert: isHighAlert)
            })
            break
        case Ride.REGULAR_PASSENGER_RIDE:
            RegularRideMatcherServiceClient.getMatchingRegularPassenger(rideId: rideInvitation!.passenegerRideId, riderRideId: rideInvitation!.rideId, viewController: targetViewController, completionHandler: { (responseObject, error) -> Void in
                self.checkResponseAndNavigateToRideDetailView(responseObject: responseObject, error: error, rideInvitation: rideInvitation!, isHighAlert: isHighAlert)

            })
        case Ride.REGULAR_RIDER_RIDE:
            RegularRideMatcherServiceClient.getMathchingRegularRider(rideId: rideInvitation!.rideId, passengerRideId: rideInvitation!.passenegerRideId, viewController: targetViewController, completionHandler: { (responseObject, error) -> Void in
                self.checkResponseAndNavigateToRideDetailView(responseObject: responseObject, error: error, rideInvitation: rideInvitation!, isHighAlert: isHighAlert)
            })
        case TaxiPoolConstants.Taxi:
            TaxiSharingRestClient.getTaxiPassenger(taxiRidePassengerId: rideInvitation!.passenegerRideId, passengerUserId: rideInvitation?.passengerId ?? 0, riderRideId: rideInvitation?.rideId ?? 0) { (responseObject, error) -> Void in
                self.checkResponseAndNavigateToRideDetailView(responseObject: responseObject, error: error, rideInvitation: rideInvitation!, isHighAlert: isHighAlert)
            }
        default:
            QuickRideProgressSpinner.stopSpinner()
            AppDelegate.getAppDelegate().log.debug("Ride type is not set appropriately in ride invitation : \(String(describing: rideInvitation!.rideType))")
            break
        }
    }

    private func checkResponseAndNavigateToRideDetailView(responseObject: NSDictionary?, error: NSError?, rideInvitation: RideInvitation, isHighAlert: Bool) {
        AppDelegate.getAppDelegate().log.debug("checkResponseAndNavigateToRideDetailView()")
        QuickRideProgressSpinner.stopSpinner()
        if responseObject != nil{
            if responseObject!["result"] as! String == "SUCCESS" {
                var matchedUser : MatchedUser?
                var ride :Ride?

                switch (rideInvitation.rideType)! {
                case Ride.RIDER_RIDE:
                    matchedUser = Mapper<MatchedRider>().map(JSONObject: responseObject!["resultData"])! as MatchedRider
                    matchedUser!.userid = rideInvitation.riderId
                    matchedUser!.rideid = rideInvitation.rideId
                    ride = MyActiveRidesCache.singleCacheInstance?.getPassengerRide(passengerRideId: rideInvitation.passenegerRideId)

                    break
                case Ride.PASSENGER_RIDE:
                    matchedUser = Mapper<MatchedPassenger>().map(JSONObject: responseObject!["resultData"])! as MatchedPassenger
                    matchedUser!.userid = rideInvitation.passengerId
                    matchedUser!.rideid = rideInvitation.passenegerRideId
                    if RideViewUtils.isModetatorNotification(userNotification: userNotification) {
                        ride = MyActiveRidesCache.singleCacheInstance?.getRiderRideFromRideDetailInfo(rideId: rideInvitation.rideId)
                    } else {
                        ride = MyActiveRidesCache.singleCacheInstance?.getRiderRide(rideId: rideInvitation.rideId)
                    }

                    break
                case Ride.REGULAR_RIDER_RIDE:
                    matchedUser = Mapper<MatchedRegularRider>().map(JSONObject: responseObject!["resultData"])! as MatchedRegularRider
                    matchedUser!.userid = rideInvitation.riderId
                    matchedUser!.rideid = rideInvitation.rideId

                    ride = MyRegularRidesCache.getInstance().getRegularPassengerRide(passengerRideId : rideInvitation.passenegerRideId)


                case Ride.REGULAR_PASSENGER_RIDE:
                    matchedUser = Mapper<MatchedRegularPassenger>().map(JSONObject: responseObject!["resultData"])! as MatchedRegularPassenger
                    matchedUser!.userid = rideInvitation.passengerId
                    matchedUser!.rideid = rideInvitation.passenegerRideId
                    ride = MyRegularRidesCache.getInstance().getRegularRiderRide(riderRideId: rideInvitation.rideId)
                case TaxiPoolConstants.Taxi:
                    matchedUser = Mapper<MatchedPassenger>().map(JSONObject: responseObject!["resultData"])! as MatchedPassenger
                    matchedUser!.userid = rideInvitation.passengerId
                    matchedUser!.rideid = rideInvitation.passenegerRideId
                    ride = MyActiveRidesCache.singleCacheInstance?.getRiderRide(rideId: rideInvitation.rideId)
                    break
                default:
                    break
                }
                if ride == nil{
                    return
                }

                if rideInvitation.rideType == Ride.PASSENGER_RIDE || rideInvitation.rideType == Ride.REGULAR_PASSENGER_RIDE {
                    matchedUser!.newFare = rideInvitation.newRiderFare
                }else {
                    matchedUser!.newFare = rideInvitation.newFare
                }



                if rideInvitation.pickupAddress != nil{
                    matchedUser!.pickupLocationAddress = rideInvitation.pickupAddress!
                }
                if rideInvitation.pickupAddress != nil{
                    matchedUser!.pickupLocationAddress = rideInvitation.pickupAddress!
                }

                matchedUser!.pickupLocationLatitude = rideInvitation.pickupLatitude
                matchedUser!.pickupLocationLongitude = rideInvitation.pickupLongitude

                if rideInvitation.dropAddress != nil{
                    matchedUser!.dropLocationAddress = rideInvitation.dropAddress!
                }

                matchedUser!.dropLocationLatitude = rideInvitation.dropLatitude
                matchedUser!.dropLocationLongitude = rideInvitation.dropLongitude

                if matchedUser!.pickupTime == nil || rideInvitation.pickupTime > matchedUser!.pickupTime!{
                    matchedUser!.pickupTime = rideInvitation.pickupTime
                }

                if matchedUser!.dropTime == nil || rideInvitation.dropTime > matchedUser!.dropTime!{
                    matchedUser!.dropTime = rideInvitation.dropTime
                }

                matchedUser!.distance = rideInvitation.matchedDistance
                if rideInvitation.matchedDistance != matchedUser?.distance{

                    if matchedUser?.rideDistance != 0 && matchedUser?.passengerDistance != 0{
                        if matchedUser!.userRole == MatchedUser.RIDER{
                            var percentage = Int((matchedUser!.distance!/matchedUser!.rideDistance)*100)

                            if percentage > 100{
                                percentage = 100
                            }
                            matchedUser!.matchPercentageOnMatchingUserRoute = percentage
                            percentage = Int((matchedUser!.distance!/matchedUser!.passengerDistance)*100)
                            if percentage > 100{
                                percentage = 100
                            }
                            matchedUser!.matchPercentage = percentage

                        }else{
                            var percentage = Int((matchedUser!.distance!/matchedUser!.passengerDistance)*100)
                            if percentage > 100{
                                percentage = 100
                            }
                            matchedUser!.matchPercentage = percentage
                            percentage = Int((matchedUser!.distance!/matchedUser!.rideDistance)*100)
                            if percentage > 100{
                                percentage = 100
                            }

                            matchedUser!.matchPercentageOnMatchingUserRoute = percentage

                        }
                    }
                }

                if rideInvitation.rideType == Ride.PASSENGER_RIDE || rideInvitation.rideType == Ride.REGULAR_PASSENGER_RIDE{
                    matchedUser!.points = rideInvitation.riderPoints
                }else {
                    matchedUser!.points = rideInvitation.points
                }

                if isHighAlert {
                    RideMatcherServiceClient.updateRideInvitationStatus(invitationId: rideInvitation.rideInvitationId, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_READ, viewController: nil) { (responseObject, error) in
                    rideInvitation.invitationStatus = RideInvitation.RIDE_INVITATION_STATUS_READ
                    let rideInvitationStatus = RideInviteStatus(rideInvitation: rideInvitation)
                    RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
                }
                    let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
                    mainContentVC.initializeData(ride: ride!, matchedUserList: [matchedUser!], viewType: DetailViewType.RideInviteView, selectedIndex: 0, startAndEndChangeRequired: false,  selectedUserDelegate: nil,rideInviteId: rideInvitation.rideInvitationId)
                    ViewControllerUtils.displayViewController(currentViewController: self.targetViewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
                } else {
                    let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
                    mainContentVC.initializeData(ride: ride!, matchedUserList: [matchedUser!], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, selectedUserDelegate: self,rideInviteId: rideInvitation.rideInvitationId)
                    ViewControllerUtils.displayViewController(currentViewController: self.targetViewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
                }

            }else {
                if isHighAlert {
                    return
                }
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                if responseError!.errorCode == RideValidationUtils.RIDER_ALREADY_CROSSED_PICK_UP_POINT_ERROR{
                    MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.crossed_pick_up_error, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle: Strings.no_caps, linkButtonText: nil, viewController: self.targetViewController) { (actionText) in
                        if actionText == Strings.yes_caps{
                          if RideValidationUtils.isRegularRide(rideType: rideInvitation.rideType!) == true{
                            self.checkAndDisplayHelmetAlert(rideInvitation: rideInvitation,viewController: self.targetViewController)
                          }else{
                            self.handleNormalRideJoin(rideInvitation: rideInvitation, displayPointsConfirmation: false,viewController: self.targetViewController)
                          }
                        }
                    }
                }else{
                    MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: self.targetViewController, handler: nil)
                }
            }
        }else{
            if isHighAlert {
                return
            }
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: targetViewController, handler: nil)
        }
    }

    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
        return Strings.ACCEPT
    }
    override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        AppDelegate.getAppDelegate().log.debug("getNegativeActionNameWhenApplicable()")
        return Strings.REJECT
    }
    override func getNeutralActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        AppDelegate.getAppDelegate().log.debug("getNeutralActionNameWhenApplicable()")
        return Strings.VIEW
    }
    override func addActions(uiLocalNotification: UILocalNotification) {
        AppDelegate.getAppDelegate().log.debug("addActions()")
        uiLocalNotification.category = NotificationHandler.THREE_ACTION_CATEGORY
    }

    @objc func selectedUser(selectedUser : MatchedUser) {
        AppDelegate.getAppDelegate().log.debug("selectedUser()")
        let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification : userNotification)
        if rideInvitation == nil{
            return
        }
        if selectedUser.userRole! == MatchedUser.RIDER || selectedUser.userRole! == MatchedUser.REGULAR_RIDER{
            if selectedUser.matchPercentage != nil{
                rideInvitation?.matchPercentageOnPassengerRoute = selectedUser.matchPercentage!
                rideInvitation?.matchPercentageOnRiderRoute = selectedUser.matchPercentageOnMatchingUserRoute
            }
            if (rideInvitation!.fareChange)
            {
                if (selectedUser.newFare < rideInvitation!.newFare){
                    inviteRider(rideInvitation : rideInvitation! , selectedUser: selectedUser)
                }
                else
                {
                    joinedTheRide(rideInvitation: rideInvitation!, selectedUser: selectedUser)
                }
            }
            else if (selectedUser.newFare != -1) && (selectedUser.newFare < selectedUser.points!)
            {
                inviteRider(rideInvitation : rideInvitation! , selectedUser: selectedUser)
            }
            else{
                joinedTheRide(rideInvitation: rideInvitation!, selectedUser: selectedUser)
            }

        }else if selectedUser.userRole! == MatchedUser.PASSENGER || selectedUser.userRole! == MatchedUser.REGULAR_PASSENGER{

            if selectedUser.matchPercentage != nil{
                rideInvitation?.matchPercentageOnPassengerRoute = selectedUser.matchPercentageOnMatchingUserRoute
                rideInvitation?.matchPercentageOnRiderRoute = selectedUser.matchPercentage!
            }

            if rideInvitation!.fareChange
            {
                if (selectedUser.newFare > rideInvitation!.newFare){
                    invitePassenger(rideInvitation : rideInvitation! , selectedUser: selectedUser)
                }
                else
                {
                    joinedTheRide(rideInvitation: rideInvitation!, selectedUser: selectedUser)
                }
            }
            else if (selectedUser.newFare != -1) && (selectedUser.newFare > selectedUser.points!)
            {
                invitePassenger(rideInvitation : rideInvitation! , selectedUser: selectedUser)
            }
            else{
                joinedTheRide(rideInvitation : rideInvitation! , selectedUser : selectedUser)
            }
        }
    }
    func joinedTheRide(rideInvitation : RideInvitation , selectedUser : MatchedUser)
    {
        rideInvitation.pickupTime = selectedUser.pickupTime!
        rideInvitation.dropTime = selectedUser.dropTime!
        rideInvitation.pickupLatitude = selectedUser.pickupLocationLatitude!
        rideInvitation.pickupLongitude = selectedUser.pickupLocationLongitude!
        rideInvitation.dropLatitude = selectedUser.dropLocationLatitude!
        rideInvitation.dropLongitude = selectedUser.dropLocationLongitude!
        rideInvitation.pickupAddress = selectedUser.pickupLocationAddress
        rideInvitation.dropAddress = selectedUser.dropLocationAddress
        rideInvitation.newFare = selectedUser.newFare
        rideInvitation.points = selectedUser.points!
        if rideInvitation.rideType == Ride.PASSENGER_RIDE || rideInvitation.rideType == Ride.REGULAR_PASSENGER_RIDE{
            rideInvitation.newRiderFare = selectedUser.newFare
            rideInvitation.riderPoints = selectedUser.points!
        }
        rideInvitation.pickupTimeRecalculationRequired = false
        completeRideJoin(rideInvitation: rideInvitation,displayPointsConfirmation : true)
    }
    func invitePassenger(rideInvitation : RideInvitation , selectedUser : MatchedUser)
    {
        let ride = MyActiveRidesCache.singleCacheInstance?.getRiderRide(rideId: rideInvitation.rideId)
        if ride == nil{
            return
        }
        var selectedPassengers = [MatchedPassenger]()
        selectedPassengers.append(selectedUser as! MatchedPassenger)

        InviteSelectedPassengersAsyncTask(riderRide: ride!, selectedUsers: selectedPassengers, viewController: self.targetViewController!, displaySpinner: true, selectedIndex: nil, invitePassengersCompletionHandler: { (error,nserror) in
            if error == nil && nserror == nil{
                super.handlePositiveAction(userNotification: self.userNotification!,viewController : self.targetViewController)
            }
        }).invitePassengersFromMatches()

    }
    func inviteRider(rideInvitation : RideInvitation , selectedUser : MatchedUser)
    {
        let ride = MyActiveRidesCache.singleCacheInstance?.getPassengerRide(passengerRideId: rideInvitation.passenegerRideId)
        if ride == nil{
            return
        }
        var selectedRiders = [MatchedRider]()
        selectedRiders.append(selectedUser as! MatchedRider)

        InviteRiderHandler(passengerRide: ride! , selectedRiders: selectedRiders, displaySpinner: true, selectedIndex: nil, viewController: self.targetViewController!).inviteSelectedRiders(inviteHandler: { (error,nserror) in
            if error == nil && nserror == nil{
                super.handlePositiveAction(userNotification: self.userNotification!,viewController : self.targetViewController)
            }
        })
    }
    func userSelected() {
        AppDelegate.getAppDelegate().log.debug("userSelected()")
        self.handlePositiveAction(userNotification: self.userNotification!,viewController : self.targetViewController)
    }
    static func prepareRideInvitation(notification : UserNotification?) -> RideInvitation?{
        if notification == nil || notification!.msgObjectJson == nil {
            return nil
        }
        let rideInvitation = Mapper<RideInvitation>().map(JSONString: notification!.msgObjectJson!)
        let timeData = Mapper<TimeData>().map(JSONString: notification!.msgObjectJson!)
        if rideInvitation?.pickupTime == nil || rideInvitation?.pickupTime == 0{
            if let pickUpDate = AppUtil.createNSDate(dateString: timeData?.pickupTime){
                rideInvitation!.pickupTime = pickUpDate.getTimeStamp()
            }
        }
        if rideInvitation?.dropTime == nil || rideInvitation?.dropTime == 0{
            if let dropDate = AppUtil.createNSDate(dateString: timeData?.dropTime){
                rideInvitation!.dropTime = dropDate.getTimeStamp()
            }
        }
        if rideInvitation?.startTime == nil{

            let startDate = AppUtil.createNSDate(dateString: timeData?.startTime)
            if startDate != nil{
                rideInvitation!.startTime = startDate!.getTimeStamp()
            }
        }
        if rideInvitation?.newRiderFare == 0 && notification?.type != UserNotification.NOT_TYPE_RM_PASSENGER_INVITATION{
            rideInvitation!.newRiderFare = -1
        }else if rideInvitation?.newFare == 0 && notification!.type == UserNotification.NOT_TYPE_RM_PASSENGER_INVITATION && notification!.title!.contains("accept this fare") == false{
            rideInvitation!.newFare = -1
        }

        return rideInvitation
    }
    func userNotSelected(){

    }
    func rejectUser(selectedUser : MatchedUser)
    {
        AppDelegate.getAppDelegate().log.debug("Rejecting \(selectedUser)")
        self.handleNegativeAction(userNotification: self.userNotification!,viewController : self.targetViewController)
    }
    func rideInviteAcceptCompleted(rideInvitationId : Double)
    {
        super.handlePositiveAction(userNotification: self.userNotification!, viewController: targetViewController)
        rideInvitationActionCompletionListener?.rideInviteAcceptCompleted(rideInvitationId: rideInvitationId)
    }
    func rideInviteRejectCompleted(rideInvitation : RideInvitation)
    {
        super.handlePositiveAction(userNotification: self.userNotification!, viewController: targetViewController)
        rideInvitationActionCompletionListener?.rideInviteRejectCompleted(rideInvitation: rideInvitation)
    }
    func rideInviteActionFailed(rideInvitationId : Double, responseError: ResponseError?,error:NSError?, isNotificationRemovable : Bool){
        if isNotificationRemovable
        {
            super.handlePositiveAction(userNotification: userNotification!, viewController: targetViewController)
        }
        rideInvitationActionCompletionListener?.rideInviteActionFailed(rideInvitationId: rideInvitationId, responseError: responseError, error: error, isNotificationRemovable: isNotificationRemovable)
    }
    func rideInviteActionCancelled() {
        rideInvitationActionCompletionListener?.rideInviteActionCancelled()
    }
 }
