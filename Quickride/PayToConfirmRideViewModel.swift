//
//  PayToConfirmRideViewModel.swift
//  Quickride
//
//  Created by Rajesab on 24/12/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PayToConfirmRideViewModel {
    var rideInvitation: RideInvitation?
    var riderBasicInfo: UserBasicInfo?
    private var rideInviteActionCompletionListener : RideInvitationActionCompletionListener?
    
    init(){
        
    }
    
    init(rideInvitation: RideInvitation?, rideInviteActionCompletionListener : RideInvitationActionCompletionListener?){
        self.rideInvitation = rideInvitation
        self.rideInviteActionCompletionListener = rideInviteActionCompletionListener
    }
    
    func payForRideToConfirmRide(){
        guard let rideInvitation = rideInvitation else {
            return
        }
        JoinPassengerToRideHandler(viewController: nil, riderRideId: rideInvitation.rideId, riderId: rideInvitation.riderId, passengerRideId: rideInvitation.passenegerRideId , passengerId: UserDataCache.getCurrentUserId(),rideType: Ride.RIDER_RIDE, pickupAddress: rideInvitation.pickupAddress, pickupLatitude: rideInvitation.pickupLatitude, pickupLongitude: rideInvitation.pickupLongitude, pickupTime: rideInvitation.pickupTime, dropAddress: rideInvitation.dropAddress, dropLatitude: rideInvitation.dropLatitude, dropLongitude: rideInvitation.dropLongitude, dropTime: rideInvitation.dropTime, matchingDistance: rideInvitation.matchedDistance, points: rideInvitation.points,newFare: rideInvitation.newFare, noOfSeats: rideInvitation.noOfSeats , rideInvitationId: rideInvitation.rideInvitationId,invitingUserName : rideInvitation.invitingUserName!,invitingUserId : rideInvitation.invitingUserId,displayPointsConfirmationAlert: false, riderHasHelmet: rideInvitation.passengerRequiresHelmet, pickupTimeRecalculationRequired: rideInvitation.pickupTimeRecalculationRequired, passengerRouteMatchPercentage: rideInvitation.matchPercentageOnPassengerRoute, riderRouteMatchPercentage: rideInvitation.matchPercentageOnRiderRoute, moderatorId: nil,listener: rideInviteActionCompletionListener).joinPassengerToRide(invitation: rideInvitation)
    }
    
    func cancelRideInvitation(){
        guard let rideInvitation = rideInvitation else { return }
        RideMatcherServiceClient.updateRideInvitationStatus(invitationId: rideInvitation.rideInvitationId, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED, viewController: nil) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast(Strings.invite_cancelled_toast)
                rideInvitation.invitationStatus = RideInvitation.RIDE_INVITATION_STATUS_CANCELLED
                let rideInvitationStatus = RideInviteStatus(rideInvitation: rideInvitation)
                RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
                NotificationCenter.default.post(name: .cancelRideInvitationSuccess,  object: nil, userInfo: nil)
            }else{
                var userInfo = [String: Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .cancelRideInvitationFailed, object: nil, userInfo: userInfo)
            }
        }
    }
}

