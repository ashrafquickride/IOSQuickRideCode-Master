//
//  EidtAndCancelCardViewModel.swift
//  Quickride
//
//  Created by Quick Ride on 7/21/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class EidtAndCancelCardViewModel
{
    var currentUserRide : Ride
    var outGoingRideInvites = [RideInvitation]()
    var isModerator = false
    var rideDetailInfo : RideDetailInfo?
    
    init(currentUserRide : Ride) {
        self.currentUserRide = currentUserRide
        self.rideDetailInfo = MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoIfExist(riderRideId: LiveRideViewModelUtil.getRiderRideId(currentUserRide: currentUserRide))
        getOutGoingInvitesForRide(ride: currentUserRide)
        guard let rideParticipants = rideDetailInfo?.rideParticipants else {
            return
        }
        isModerator = RideViewUtils.checkIfPassengerEnabledRideModerator(ride: currentUserRide, rideParticipantObjects: rideParticipants)
        
    }
    
    init(){
        self.currentUserRide = Ride()
    }
    
    private func getOutGoingInvitesForRide(ride: Ride) { 
        if isModerator {
            outGoingRideInvites.removeAll()
            return
        }
        if let rideType = ride.rideType {
            var invites = RideInviteCache.getInstance().getInvitationsForRide(rideId: ride.rideId, rideType: rideType)
            invites.sort(by: {$0.invitationTime < $1.invitationTime})
            
            outGoingRideInvites = invites
        }
    }
    func getMatchedUserForOutGoingInvite(rideInvitation: RideInvitation,handler : @escaping(_ matchedUser : MatchedUser?, _ responseError : ResponseError?, _ error : NSError?) -> Void) {
        
        var rideType: String
        var rideId = 0.0
        var userId = 0.0
        if currentUserRide.rideType == Ride.RIDER_RIDE || isModerator{
            rideType = Ride.PASSENGER_RIDE
            rideId = rideInvitation.passenegerRideId
            userId = rideInvitation.passengerId
        }else{
            rideType = Ride.RIDER_RIDE
            rideId = rideInvitation.rideId
            userId = rideInvitation.riderId
        }
        if rideId == 0 && rideInvitation.invitingUserId == currentUserRide.userId{
            if currentUserRide.rideType == Ride.RIDER_RIDE {
                validateAndGetMatchedPassenger(rideInvitation: rideInvitation, handler: handler)
            }else {
                validateAndGetMatchedRider(rideInvitation: rideInvitation, handler: handler)
            }
            return
        }
        if rideId == 0 && userId == 0 {
            return handler(nil,nil,nil)
        }
        let matchedUserRetrievalTask = MatchedUserRetrievalTask(userId: userId, rideId: rideId, rideType: rideType, rideInvitation: rideInvitation) { (matchedUser, rideInvitation, responseError, error) in
            if let errorCode = responseError?.errorCode {
                if errorCode == RideValidationUtils.PASSENGER_ALREADY_JOINED_THIS_RIDE ||
                    errorCode == RideValidationUtils.PASSENGER_ENGAGED_IN_OTHER_RIDE ||
                    errorCode == RideValidationUtils.INSUFFICIENT_SEATS_ERROR ||
                    errorCode == RideValidationUtils.RIDE_ALREADY_COMPLETED ||
                    errorCode == RideValidationUtils.RIDE_CLOSED_ERROR ||
                    errorCode == RideValidationUtils.RIDER_ALREADY_CROSSED_PICK_UP_POINT_ERROR {
                    self.removeRideInvitation(rideInvitation: rideInvitation)
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: nil)
                }
            }
            handler(matchedUser,responseError,error)
        }
        matchedUserRetrievalTask.getMatchedUser()
        
    }
    func removeRideInvitation(rideInvitation : RideInvitation){
        NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: rideInvitation.rideInvitationId)
        RideInviteCache.getInstance().removeInvitation(id: rideInvitation.rideInvitationId)

    }
    func validateAndGetMatchedPassenger(rideInvitation : RideInvitation,handler : @escaping(_ matchedUser : MatchedUser?, _ responseError : ResponseError?, _ error : NSError?) -> Void) {
                   UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvitation.passengerId, handler: { (userBasicInfo, responseError, error) in
                       if let userBasicInfo = userBasicInfo{
                        let matchedPassenger = MatchedPassenger(ride: self.currentUserRide, rideInvitation: rideInvitation, userProfile: userBasicInfo)
                           handler(matchedPassenger,nil,nil)
                       }else{
                           handler(nil,responseError,error)
                       }
                   })
                    
    }
    func validateAndGetMatchedRider(rideInvitation : RideInvitation, handler : @escaping(_ matchedUser : MatchedUser?, _ responseError : ResponseError?, _ error : NSError?) -> Void){
        UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvitation.riderId, handler: { (userBasicInfo, responseError, error) in
            if let userBasicInfo = userBasicInfo{
                let matchedRider = MatchedRider(ride: self.currentUserRide, rideInvitation: rideInvitation, userProfile: userBasicInfo)
                handler(matchedRider,nil,nil)
            }else{
                handler(nil,responseError,error)
            }
        })
    }
}
