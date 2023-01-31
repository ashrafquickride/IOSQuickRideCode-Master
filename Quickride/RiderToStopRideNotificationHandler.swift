//
//  RiderToStopRideNotificationHandler.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RiderToStopRideNotificationHandler : RideNotificationHandler,PassengerPickupDelegate, RideActionComplete{
    
    var userNotification : UserNotification?
    var viewController : UIViewController?
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let groupValue = clientNotification.groupValue, !groupValue.isEmpty,let riderRideId = Double(groupValue),
                let ride = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: riderRideId) else {
                return handler(false)
            }
            return handler(ride.status == Ride.RIDE_STATUS_STARTED)
        }
        
    }

  override func handlePositiveAction(userNotification:UserNotification, viewController : UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")
   
    self.userNotification = userNotification
    self.viewController = viewController
    
    let riderRideId = userNotification.msgObjectJson
    if riderRideId == nil{
      return
    }
    let rideId = Double(riderRideId!)
    if rideId == nil{
      return
    }
    completeRiderRide(riderRideId: rideId!)
  }
  func completeRiderRide(riderRideId : Double){
    let passengerToPickup = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerToPickUp(riderRideId: riderRideId)
    if passengerToPickup == nil || passengerToPickup!.isEmpty{
        QuickRideProgressSpinner.startSpinner()
      
      RideManagementUtils.completeRiderRide(riderRideId: riderRideId, targetViewController: ViewControllerUtils.getCenterViewController(),rideActionCompletionDelegate: self)
    }else{
        var ride: RiderRide?
        if let rideId = userNotification?.groupValue, let riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: Double(rideId)!) {
            ride = riderRide
        }
        let passengerPickUpViewController = UIStoryboard(name: "LiveRide", bundle: nil).instantiateViewController(withIdentifier: "PassengersToPickupViewController") as! PassengersToPickupViewController
        passengerPickUpViewController.initializeDataBeforePresenting(riderRideId : riderRideId, ride: ride, passengerToBePickup: passengerToPickup!, passengerPickupDelegate: self)
        viewController?.view.addSubview(passengerPickUpViewController.view)
        viewController?.addChild(passengerPickUpViewController)
        passengerPickUpViewController.view!.layoutIfNeeded()
    }
  }
  override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
    self.userNotification = userNotification
    self.viewController = viewController
    super.handleTap(userNotification: userNotification, viewController: viewController)
    let rideId = userNotification.msgObjectJson
    if rideId == nil{
      return
    }
    let riderRideId = Double(rideId!)
    if riderRideId == nil{
      return
    }
    navigateToLiveRideView(riderRideId: riderRideId!)
  }
  
  override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
    return Strings.end_ride
  }
  func passengerPickedUp(riderRideId : Double){
    RideManagementUtils.completeRiderRide(riderRideId: riderRideId, targetViewController: ViewControllerUtils.getCenterViewController(),rideActionCompletionDelegate: self)
  }
    func rideActionCompleted(status: String) {
        if userNotification != nil{
           super.handlePositiveAction(userNotification: self.userNotification!, viewController: self.viewController)
        }
    }
    
    func rideActionFailed(status: String, error: ResponseError?) {
        
    }
    
}
