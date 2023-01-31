//
//  RiderInvitationNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RiderInvitationNotificationHandlerToPassenger :RideInvitationNotificationHandler{
    
    var rideInvitation : RideInvitation?
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            self.userNotification = clientNotification
            guard let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: clientNotification),
                  let rideType = rideInvitation.rideType, rideInvitation.passenegerRideId != 0,  !rideType.isEmpty  else {
                return handler(false)
            }
            let rideId = rideInvitation.passenegerRideId
            if Ride.RIDER_RIDE == rideType
            {
                guard let _ = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: rideId) else {
                    return handler(false)
                }
            }
            else
            {
                guard let ride = MyRegularRidesCache.singleInstance?.getRegularPassengerRide(passengerRideId: rideId) else {
                    return handler(false)
                }
                guard ride.status != Ride.RIDE_STATUS_REQUESTED else {
                    return handler(false)
                }
            }
            
            RideInviteCache.getInstance().getRideInviteFromServer(id: rideInvitation.rideInvitationId) { (invite,responseError, error) in
                if responseError != nil || error != nil {
                    return handler(true)
                }
                return handler(invite != nil)
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
        rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
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
        rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
        if let invitation = rideInvitation {
            if !FareChangeUtils.isFareChangeApplicable(rideInvitation : invitation){
                super.handleNeutralAction(userNotification: userNotification,viewController : viewController)
            }else{
                let matchedUserRetrievalTask = MatchedUserRetrievalTask(userId: invitation.riderId,rideId: invitation.rideId, rideType: Ride.RIDER_RIDE,rideInvitation: invitation) { (matchedUser,rideInvitation,responseError,error) in
                    if  let matchedRider = matchedUser as? MatchedRider {
                        let fareChangeViewController = UIStoryboard(name: "LiveRide", bundle: nil).instantiateViewController(withIdentifier: "FareChangeViewController") as! FareChangeViewController
                        fareChangeViewController.initializeDataBeforePresenting(rideType: Ride.PASSENGER_RIDE,actualFare : rideInvitation.points, distance: rideInvitation.matchedDistance,selectedSeats: rideInvitation.noOfSeats, farePerKm: matchedRider.fare ?? 0.0) { (actualFare, requestedFare) in
                            rideInvitation.newFare = requestedFare
                            var selectedRiders = [MatchedRider]()
                            let matchedRider = MatchedRider(rideInvitation : rideInvitation)
                            matchedRider.fareChange = true
                            selectedRiders.append(matchedRider)
                            let ride = MyActiveRidesCache.singleCacheInstance?.getPassengerRide(passengerRideId : rideInvitation.passenegerRideId)
                            if ride == nil{
                                return
                            }
                            if actualFare > requestedFare
                            {
                                InviteRiderHandler(passengerRide: ride! , selectedRiders: selectedRiders, displaySpinner: true, selectedIndex: nil, viewController: self.targetViewController ?? ViewControllerUtils.getCenterViewController()).inviteSelectedRiders(inviteHandler: { (error,nserror) in
                                    if error == nil && nserror == nil && self.userNotification != nil {
                                        NotificationStore.getInstance().removeNotificationFromLocalList(userNotification: self.userNotification!)
                                    }
                                })
                            }
                            else{
                                self.completeRideJoin(rideInvitation: rideInvitation, displayPointsConfirmation: false)
                            }
                        }
                        ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: fareChangeViewController, animated: false, completion: nil)
                    }
                }
                matchedUserRetrievalTask.getMatchedUser()
            }
        }
        
    }
}
