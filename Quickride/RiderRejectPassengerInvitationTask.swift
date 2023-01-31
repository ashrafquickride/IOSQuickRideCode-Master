//
//  RiderRejectPassengerInvitationTask.swift
//  Quickride
//
//  Created by QuickRideMac on 17/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import Foundation
class RiderRejectPassengerInvitationTask {
    
    var rideInvitation : RideInvitation?
    var viewController : UIViewController?
    var rideInvitationActionCompletionListener: RideInvitationActionCompletionListener?
    var rideRejectReason: String?
    var moderatorId: String?
    
    init(rideInvitation : RideInvitation, moderatorId: String?, viewController : UIViewController?,rideRejectReason: String?,rideInvitationActionCompletionListener: RideInvitationActionCompletionListener?){
        self.rideInvitation = rideInvitation
        self.moderatorId = moderatorId
        self.viewController = viewController
        self.rideInvitationActionCompletionListener = rideInvitationActionCompletionListener
        self.rideRejectReason = rideRejectReason
    }
    
    func rejectPassengerInvitation(){
        AppDelegate.getAppDelegate().log.debug("rider rejecting passenger invitation: \(self.rideInvitation)")
        
        if Ride.REGULAR_PASSENGER_RIDE == self.rideInvitation!.rideType{
            QuickRideProgressSpinner.startSpinner()
            RegularRideMatcherServiceClient.riderRejectedPassengerInvitation(riderRideId: self.rideInvitation!.rideId, riderId: self.rideInvitation!.riderId, passengerRideId: self.rideInvitation!.passenegerRideId, passengerId: self.rideInvitation!.passengerId, rideInvitationId: self.rideInvitation!.rideInvitationId,rejectReason: rideRejectReason, viewController:viewController, completionHandler: { (responseObject, error) in
                self.handleResponse(responseObject: responseObject, error: error)
            })
        }
        else
        {
            QuickRideProgressSpinner.startSpinner()
            RideMatcherServiceClient.riderRejectedPassengerInvitation(riderRideId: self.rideInvitation!.rideId, riderId: self.rideInvitation!.riderId, passengerRideId: self.rideInvitation!.passenegerRideId, passengerId: self.rideInvitation!.passengerId, rideInvitationId: self.rideInvitation!.rideInvitationId, rideType: self.rideInvitation!.rideType!, rejectedReason: rideRejectReason, moderatorId: moderatorId, viewController: viewController, completeionHandler: { (responseObject, error) in
                self.handleResponse(responseObject: responseObject, error: error)
            })
        }
    }
    func handleResponse(responseObject : NSDictionary?,error:NSError?){
        QuickRideProgressSpinner.stopSpinner()
        AppDelegate.getAppDelegate().log.debug("handleResponse()")
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.RIDE_INVITE_REJECTED, params: ["userId" : QRSessionManager.getInstance()?.getUserId() ?? "","requestedUserId" : String(self.rideInvitation?.invitingUserId ?? 0.0),"from" : self.rideInvitation?.fromLoc ?? "","to" : self.rideInvitation?.toLoc ?? ""], uniqueField: User.FLD_USER_ID)
            rideInvitationActionCompletionListener?.rideInviteRejectCompleted(rideInvitation: rideInvitation!)
        }else{
            AppDelegate.getAppDelegate().log.error("\(String(describing: error))")
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            rideInvitationActionCompletionListener?.rideInviteActionFailed(rideInvitationId: rideInvitation!.rideInvitationId, responseError: nil, error: error, isNotificationRemovable: false)
        }
    }
}
