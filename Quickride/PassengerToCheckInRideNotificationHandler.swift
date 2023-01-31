//
//  PassengerToCheckInRideNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PassengerToCheckInRideNotificationHandler : RideNotificationHandler,RideActionComplete, RideParticipantsListener {
  var riderRideId : Double? = nil
  var notification : UserNotification?
  var viewController : UIViewController?
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let groupValue = clientNotification.groupValue, !groupValue.isEmpty, let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance(), let passengerRideId = Double(groupValue) else {
                return handler(false)
            }
            
            guard let ride = myActiveRidesCache.getPassengerRide(passengerRideId: passengerRideId) else {
                return handler(false)
            }
            return handler(ride.status == Ride.RIDE_STATUS_SCHEDULED || ride.status == Ride.RIDE_STATUS_DELAYED)
        }
        
    }


  override func handlePositiveAction(userNotification:UserNotification, viewController : UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")
    
    self.notification = userNotification
    self.viewController = viewController
    riderRideId = Double(userNotification.msgObjectJson! as String)
    let passengerRideId = userNotification.groupValue
    
    RideManagementUtils.startPassengerRide(passengerRideId: Double(passengerRideId!)!, riderRideId:riderRideId!, rideCompleteAction: self, viewController: viewController)
  }
    override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?)
    {
        self.notification = userNotification
        self.viewController = viewController
        riderRideId = Double(userNotification.msgObjectJson! as String)
        MyActiveRidesCache.getRidesCacheInstance()?.getRideParicipants(riderRideId: riderRideId!, rideParticipantsListener: self)
    }
  override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
    self.notification = userNotification
    self.viewController = viewController
    super.handleTap(userNotification: userNotification, viewController: viewController)
    riderRideId = Double(userNotification.msgObjectJson! as String)
    super.navigateToLiveRideView(riderRideId: riderRideId!)
  }
  
  func rideActionCompleted(status: String) {
    AppDelegate.getAppDelegate().log.debug("Passenger ride started successfully")
    super.handlePositiveAction(userNotification: self.notification!, viewController: viewController)
    super.navigateToLiveRideView(riderRideId: riderRideId!)
  }
  
  func rideActionFailed(status: String, error : ResponseError?) {
    AppDelegate.getAppDelegate().log.error("Could not start passenger ride : \(String(describing: error))")
  }
  
  override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    let passengerRideId = userNotification.groupValue
    if passengerRideId == nil || passengerRideId?.isEmpty == true{
      return nil
    }
    let passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: Double(passengerRideId!)!)
    if passengerRide == nil {
      return nil
    }
    if passengerRide?.status == Ride.RIDE_STATUS_STARTED{
      return nil
    }
    
    return Strings.checkin_action
  }
    override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        let passengerRideId = userNotification.groupValue
        if passengerRideId == nil || passengerRideId?.isEmpty == true{
            return nil
        }
        let passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: Double(passengerRideId!)!)
        if passengerRide == nil || passengerRide?.status == Ride.RIDE_STATUS_STARTED{
            return nil
        }
        return Strings.unjoin
    }
  override func getNotificationAudioFilePath()-> String?{
    AppDelegate.getAppDelegate().log.debug("")
    if notification?.type == UserNotification.NOT_TYPE_RE_PASSENGER_TO_CHECKIN_RIDE{
        return Bundle.main.path(forResource: "carunlock", ofType: "mp3")
    }
    return nil
  }
    func getRideParticipants(rideParticipants : [RideParticipant]){
        AppDelegate.getAppDelegate().log.debug("")
        let passengerRideId = notification!.groupValue
        let ride = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: Double(passengerRideId!)!)
        if ride == nil
        {
            super.handleNegativeAction(userNotification: self.notification!, viewController: ViewControllerUtils.getCenterViewController())
            return
        }
        RideViewUtils.removeRideParticipant(effectingUserId: ride!.riderId, unjoiningUserId: Double(QRSessionManager.getInstance()!.getUserId())! , rideParticipants: rideParticipants, riderRideId: riderRideId!, ride: ride, viewController: ViewControllerUtils.getCenterViewController(), completionHandler: {
            super.handleNegativeAction(userNotification: self.notification!, viewController: ViewControllerUtils.getCenterViewController())
        })
    }
    func onFailure(responseObject: NSDictionary?, error: NSError?) {
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
    }

}
