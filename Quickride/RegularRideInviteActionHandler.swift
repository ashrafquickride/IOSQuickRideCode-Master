//
//  RegularRiderInviteToPassengerActionHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 08/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RegularRideInviteActionHandler {
  
  var rideInvitationNotificationId : Int?
  init(){
    
  }
  
  public func joinPassengerToRegularRide(rideInvitation : RideInvitation,viewController : UIViewController?){
      var points: Double = 0
      if rideInvitation.rideType == Ride.PASSENGER_RIDE || rideInvitation.rideType == Ride.REGULAR_PASSENGER_RIDE {
          points = rideInvitation.riderPoints
      }else{
          points = rideInvitation.points
      }
    RegularRideMatcherServiceClient.addPassengerToRiderRide(riderRideId: rideInvitation.rideId, riderId: rideInvitation.riderId, passengerRideId: rideInvitation.passenegerRideId, passengerId: rideInvitation.passengerId, pickupAddress: rideInvitation.pickupAddress, pickupLatitude: rideInvitation.pickupLatitude, pickupLongitude: rideInvitation.pickupLongitude, pickupTime: rideInvitation.pickupTime, dropAddress: rideInvitation.dropAddress, dropLatitude: rideInvitation.dropLatitude, dropLongitude: rideInvitation.dropLongitude, dropTime: rideInvitation.dropTime, matchingDistance: rideInvitation.matchedDistance, points: points, noOfSeats: rideInvitation.noOfSeats, rideInvitationId: rideInvitation.rideInvitationId, viewController: viewController) { (responseObject, error) -> Void in
      AppDelegate.getAppDelegate().log.debug("joinPassengerToRegularRide()")
      
      
        QuickRideProgressSpinner.stopSpinner()
      if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
        ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: viewController, handler: nil)
      }else if responseObject!["result"] as! String == "SUCCESS"{
        if self.rideInvitationNotificationId != nil{
          NotificationStore.getInstance().deleteNotification(notificationId: self.rideInvitationNotificationId!)
        }
      }
    }
  }
  public func passengerRejectedInvitation(rideInvitation : RideInvitation,rejectReason: String?,viewController : UIViewController?){
    AppDelegate.getAppDelegate().log.debug("passengerRejectedInvitation()")
    QuickRideProgressSpinner.startSpinner()
    RegularRideMatcherServiceClient.passengerRejectedRiderInvitation(riderRideId: rideInvitation.rideId, riderId: rideInvitation.riderId, passengerRideId: rideInvitation.passenegerRideId, passengerId: rideInvitation.passengerId, rideInvitationId: rideInvitation.rideInvitationId,rejectReason: rejectReason, viewController: viewController) { (responseObject, error) -> Void in
        QuickRideProgressSpinner.stopSpinner()
      if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
        ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: viewController, handler: nil)
      }else{
        if self.rideInvitationNotificationId != nil{
          NotificationStore.getInstance().deleteNotification(notificationId: self.rideInvitationNotificationId!)
        }
      }
    }
  }
  public func riderRejectedInvitation(rideInvitation : RideInvitation,rejectReason: String?,viewController : UIViewController?){
    AppDelegate.getAppDelegate().log.debug("riderRejectedInvitation()")
    QuickRideProgressSpinner.startSpinner()
    RegularRideMatcherServiceClient.riderRejectedPassengerInvitation(riderRideId: rideInvitation.rideId, riderId: rideInvitation.riderId, passengerRideId: rideInvitation.passenegerRideId, passengerId: rideInvitation.passengerId, rideInvitationId: rideInvitation.rideInvitationId,rejectReason: rejectReason, viewController: viewController) { (responseObject, error) -> Void in
        QuickRideProgressSpinner.stopSpinner()
      if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
        ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: viewController, handler: nil)
      }else{
        if self.rideInvitationNotificationId != nil{
          NotificationStore.getInstance().deleteNotification(notificationId: self.rideInvitationNotificationId!)
        }
        
      }
    }
  }
}
