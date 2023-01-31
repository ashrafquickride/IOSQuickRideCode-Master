//
//  InviteCarpoolRideGiverCollectionViewCellModel.swift
//  Quickride
//
//  Created by HK on 15/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class InviteCarpoolRideGiverCollectionViewCellModel{
    
    var matchedRider: MatchedRider?
    var taxiRide: TaxiRidePassenger?
    
    init() {}
    init(matchedRider: MatchedRider,taxiRide: TaxiRidePassenger?){
        self.matchedRider = matchedRider
        self.taxiRide = taxiRide
    }
    func getOutGoingInviteForRide() -> RideInvitation? {
        var getTheInvitation: RideInvitation?
        let allInvitedRides = RideInviteCache.getInstance().getInvitationsForRide(rideId: taxiRide?.id ?? 0, rideType: Ride.PASSENGER_RIDE)
        for invite in allInvitedRides{
            if Ride.PASSENGER_RIDE == invite.rideType && invite.rideId == matchedRider?.rideid {
                getTheInvitation = invite
                break
            }
            if Ride.RIDER_RIDE == invite.rideType && invite.passenegerRideId == matchedRider?.rideid {
                getTheInvitation = invite
                break
            }
        }
        
        return getTheInvitation
        
    }
    
    func cancelSentInvite(invitation: RideInvitation,complitionHandler: @escaping( _ responseObject: NSDictionary?, _ error: NSError?) -> ()){
        RideMatcherServiceClient.updateRideInvitationStatus(invitationId: invitation.rideInvitationId, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED, viewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast(Strings.invite_cancelled_toast)
                invitation.invitationStatus = RideInvitation.RIDE_INVITATION_STATUS_CANCELLED
                let rideInvitationStatus = RideInviteStatus(rideInvitation: invitation)
                RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
                complitionHandler(nil,nil)
            }else{
                complitionHandler(responseObject,error)
            }
        }
    }
}
