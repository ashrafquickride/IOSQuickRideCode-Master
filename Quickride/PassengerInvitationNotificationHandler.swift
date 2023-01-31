//
//  PassengerInvitationNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper

public class PassengerInvitationNotificationHandlerToRider :RideInvitationNotificationHandler{

    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            
            guard let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: clientNotification), rideInvitation.rideId != 0, let rideType = rideInvitation.rideType, !rideType.isEmpty  else {return handler(false)}
           
            let rideId = rideInvitation.rideId
            
            if Ride.PASSENGER_RIDE == rideType
            {
                guard let _ = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId : rideId) else {
                    return handler(false)
                }
            }
            else
            {
                guard let _ = MyRegularRidesCache.singleInstance?.getRegularRiderRide(riderRideId: rideId) else {
                    return handler(false)
                }
            }
            RideInviteCache.getInstance().getRideInviteFromServer(id: rideInvitation.rideInvitationId) {
                (invite,responeError,error)  in
                if responeError != nil || error != nil {
                    return handler(true)
                }
                return handler(invite != nil)
            }
        }
    }
    override func handleTextToSpeechMessage(userNotification : UserNotification)
    {
        let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
        if rideInvitation == nil
        {
            return
        }
        let rideId = rideInvitation!.rideId
        let rideType = rideInvitation!.rideType
        
        if rideId == 0 || rideType == nil || rideType!.isEmpty
        {
            return
        }
        if Ride.PASSENGER_RIDE == rideType
        {
            let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
            if myActiveRidesCache == nil{
                return
            }
            let ride = myActiveRidesCache!.getRiderRide(rideId: rideId)
            if ride != nil
            {
                if Ride.RIDE_STATUS_STARTED == ride!.status{
                    checkRiderRideStatusAndSpeakInvitation(text: userNotification.title!, time: NotificationHandler.delay_time)
                }
            }
        }
    }
  
  override public func handleTap(userNotification clientNotification : UserNotification,viewController : UIViewController?){
    AppDelegate.getAppDelegate().log.debug("handleTap()")
    super.userNotification = clientNotification
    super.targetViewController  = viewController
    super.handleNeutralAction(userNotification: userNotification!, viewController: viewController)
  }
  
  override func getNeutralActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
    if FareChangeUtils.isFareChangeApplicable(rideInvitation : rideInvitation!){

      return Strings.REQUEST_FARE_CHANGE
    }else{
      return super.getNeutralActionNameWhenApplicable(userNotification: userNotification)
    }
  }
  
  override func handleNeutralAction(userNotification: UserNotification, viewController: UIViewController?) {
    self.userNotification = userNotification
    if viewController == nil{
      self.targetViewController = ViewControllerUtils.getCenterViewController()
    }else{
      self.targetViewController = viewController
    }
    let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
    if !FareChangeUtils.isFareChangeApplicable(rideInvitation : rideInvitation!){
      super.handleNeutralAction(userNotification: userNotification,viewController : viewController)

    }else{
      let ride = MyActiveRidesCache.singleCacheInstance?.getRiderRide(rideId: rideInvitation!.rideId)
      let fareChangeViewController = UIStoryboard(name: "LiveRide", bundle: nil).instantiateViewController(withIdentifier: "FareChangeViewController") as! FareChangeViewController
        fareChangeViewController.initializeDataBeforePresenting(rideType : Ride.RIDER_RIDE,actualFare : rideInvitation!.points,distance: rideInvitation!.matchedDistance,selectedSeats: rideInvitation!.noOfSeats, farePerKm: ride?.farePerKm) { (actualFare, requestedFare) in
        rideInvitation?.newFare = requestedFare
        var selectedPassengers = [MatchedPassenger]()
        let matchedPassenger = MatchedPassenger(rideInvitation : rideInvitation!)
        matchedPassenger.fareChange = true
        selectedPassengers.append(matchedPassenger)
        if ride == nil{
            return
        }
        if actualFare < requestedFare
        {
            InviteSelectedPassengersAsyncTask(riderRide: ride!, selectedUsers: selectedPassengers, viewController: self.targetViewController!, displaySpinner: true, selectedIndex: nil, invitePassengersCompletionHandler: { (error,nserror) in
            if error == nil && nserror == nil{
          NotificationStore.getInstance().removeNotificationFromLocalList(userNotification: userNotification)
            }
        }).invitePassengersFromMatches()
       }
        else
        {
            self.completeRideJoin(rideInvitation: rideInvitation!, displayPointsConfirmation: false)
        }
    }
        ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: fareChangeViewController, animated: false, completion: nil)
    }
  }

  override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
  
    return Strings.ACCEPT
  }
  
}
