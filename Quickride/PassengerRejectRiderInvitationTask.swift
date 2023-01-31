//
//  PassengerRejectRiderInvitationTask.swift
//  Quickride
//
//  Created by QuickRideMac on 17/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import Foundation
class PassengerRejectRiderInvitationTask {
    
    
    var rideInvitation : RideInvitation?
    var viewController : UIViewController?
    var rideInvitationActionCompletionListener: RideInvitationActionCompletionListener?
    var rideRejectReason: String?
    
    init(rideInvitation : RideInvitation,viewController : UIViewController?,rideRejectReason: String?,rideInvitationActionCompletionListener: RideInvitationActionCompletionListener?){
        self.rideInvitation = rideInvitation
        self.viewController = viewController
        self.rideInvitationActionCompletionListener = rideInvitationActionCompletionListener
        self.rideRejectReason = rideRejectReason
    }
    func rejectRiderInvitation(){
        AppDelegate.getAppDelegate().log.debug("rejectRiderInvitation() : \(String(describing: self.rideInvitation))")
        if Ride.REGULAR_RIDER_RIDE == rideInvitation!.rideType{
            QuickRideProgressSpinner.startSpinner()
            RegularRideMatcherServiceClient.passengerRejectedRiderInvitation(riderRideId: rideInvitation!.rideId, riderId: rideInvitation!.riderId, passengerRideId: rideInvitation!.passenegerRideId, passengerId: rideInvitation!.passengerId, rideInvitationId: rideInvitation!.rideInvitationId,rejectReason: rideRejectReason, viewController: viewController, completionHandler: { (responseObject, error) in
                self.handleResponse(responseObject: responseObject, error: error)
            })
        }else{
            QuickRideProgressSpinner.startSpinner()
            RideMatcherServiceClient.passengerRejectedRiderInvitation(riderRideId: rideInvitation!.rideId, riderId: rideInvitation!.riderId, passengerRideId: rideInvitation!.passenegerRideId, passengerId: rideInvitation!.passengerId, rideInvitationId: rideInvitation!.rideInvitationId, rideType: rideInvitation!.rideType!, rejectReason: rideRejectReason, viewController: viewController, complitionHandler: { (responseObject, error) in
                self.handleResponse(responseObject: responseObject, error: error)
            })
        }
    }
    func handleResponse(responseObject : NSDictionary?,error:NSError?){
        AppDelegate.getAppDelegate().log.debug("handleResponse()")
        QuickRideProgressSpinner.stopSpinner()
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            rideInvitationActionCompletionListener?.rideInviteRejectCompleted(rideInvitation: rideInvitation!)
        }else{
            AppDelegate.getAppDelegate().log.error("\(String(describing: error))")
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            rideInvitationActionCompletionListener?.rideInviteActionFailed(rideInvitationId: rideInvitation!.rideInvitationId, responseError: nil, error: error, isNotificationRemovable: false)
        }
    }
    
}
