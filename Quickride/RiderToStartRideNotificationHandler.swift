//
//  RiderToStartRideNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RiderToStartRideNotificationHandler : RideNotificationHandler,RideActionComplete {
    
    let RIDE_DELAY_SPEAK_TEXT = Strings.your_ride_delayed
    var userNotification : UserNotification?
    var viewController : UIViewController?
    
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
        return Strings.start_action
    }
    override func handlePositiveAction(userNotification:UserNotification, viewController : UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")
        self.userNotification = userNotification
        self.viewController = viewController
        guard let riderRideId = getRiderRideId(userNotification: userNotification), let riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: riderRideId) else {
            MessageDisplay.displayAlert(messageString: Strings.ride_completed_or_cancelled_msg, viewController: viewController,handler: nil)
            return
        }
        
        
        if riderRide.status == Ride.RIDE_STATUS_STARTED {
            MessageDisplay.displayAlert(messageString: Strings.ride_started_msg, viewController: ViewControllerUtils.getCenterViewController(),handler: nil)
        }
        QuickRideProgressSpinner.startSpinner()
        RideManagementUtils.startRiderRide(rideId: riderRideId,rideComplteAction: self,viewController: ViewControllerUtils.getCenterViewController())
    }
    override func getNeutralActionNameWhenApplicable(userNotification: UserNotification)-> String?{
        if(userNotification.type !=  UserNotification.NOT_TYPE_RE_RIDER_TO_START_RIDE_REMAINDER){
            return Strings.reschedule
        }else{
            return nil
        }
        
    }
    override func getNegativeActionNameWhenApplicable(userNotification: UserNotification)-> String?{
        if(userNotification.type ==  UserNotification.NOT_TYPE_RE_RIDER_TO_START_RIDE_REMAINDER){
            return Strings.cancel
            
        }else{
            return nil
        }
    }
    override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?) {
        self.userNotification = userNotification
        self.viewController = viewController
        guard let riderRideId = getRiderRideId(userNotification: userNotification) else {
            super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
            return
        }
        guard let riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: riderRideId) else {
            super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
            return
        }
        handleRideCancellation(userNotification: userNotification,viewController: viewController, rideObj: riderRide)
    }
    
    func handleRideCancellation(userNotification: UserNotification, viewController: UIViewController?,rideObj : RiderRide) {
        let rideCancellationAndUnJoinViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RideCancellationAndUnJoinViewController") as! RideCancellationAndUnJoinViewController
        rideCancellationAndUnJoinViewController.initializeDataBeforePresenting(rideParticipants: nil, rideType: rideObj.rideType, isFromCancelRide: true,ride: rideObj,vehicelType: rideObj.vehicleType, rideUpdateListener: nil, completionHandler: { 
            super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationAndUnJoinViewController)
    }
    
    override func handleNeutralAction(userNotification:UserNotification, viewController : UIViewController?){
        
        self.userNotification = userNotification
        self.viewController = viewController
        super.handleNeutralAction(userNotification: userNotification, viewController: viewController)
        if QRReachability.isConnectedToNetwork(){
            NotificationStore.getInstance().removeNotificationFromLocalList(userNotification: userNotification)
        }
        if let riderRideId = getRiderRideId(userNotification: userNotification), let riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: riderRideId) {
            navigateToLiveRideView(riderRideId: riderRideId)
            RescheduleRide(ride: riderRide, viewController: ViewControllerUtils.getCenterViewController(),moveToRideView: false).rescheduleRide()
        }
        
    }
    
    func getRiderRideId(userNotification : UserNotification?) -> Double?{
        if let id = userNotification?.msgObjectJson, let rideId = Double(id){
            return rideId
        }
        return nil
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        self.userNotification = userNotification
        self.viewController = viewController
        super.handleTap(userNotification: userNotification, viewController: viewController)
        if let rideId = userNotification.msgObjectJson, let riderRideId = Double(rideId) {
            navigateToLiveRideView(riderRideId: riderRideId)
        }
    }
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let rideRideId = self.getRiderRideId(userNotification: clientNotification), let ride = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideRideId) else {
                return handler(false)
            }
            return handler(ride.status == Ride.RIDE_STATUS_SCHEDULED || ride.status == Ride.RIDE_STATUS_DELAYED)
        }
        
    }
    override func handleTextToSpeechMessage(userNotification : UserNotification)
    {
        let rideRideId = getRiderRideId(userNotification: userNotification)
        let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
        if myActiveRidesCache == nil || rideRideId == nil{
            return
        }
        if let ride = myActiveRidesCache!.getRiderRide(rideId: rideRideId!), (ride.status == Ride.RIDE_STATUS_SCHEDULED || ride.status == Ride.RIDE_STATUS_DELAYED)
        {
            if userNotification.title!.contains("delay") && UserNotification.NOT_TYPE_RE_RIDE_DELAYED_SECOND_ALERT_TO_RIDER != userNotification.type{
                checkRiderRideStatusAndSpeakInvitation(text: RIDE_DELAY_SPEAK_TEXT, time: NotificationHandler.delay_time)
            }
        }
    }
    func rideActionCompleted(status: String) {
        AppDelegate.getAppDelegate().log.debug("Rider ride started successfully")
        super.handlePositiveAction(userNotification: self.userNotification!, viewController: self.viewController)
        guard let riderRideId = getRiderRideId(userNotification: userNotification), let riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: riderRideId) else {
           
            return
        }
        super.navigateToLiveRideView(riderRideId: riderRideId)
    }
    
    func rideActionFailed(status: String, error : ResponseError?) {
        AppDelegate.getAppDelegate().log.error("Could not start rider ride : \(String(describing: error))")
    }
}
