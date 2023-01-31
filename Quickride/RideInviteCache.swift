//
//  RideInviteCache.swift
//  Quickride
//
//  Created by QuickRideMac on 10/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import StoreKit
import CloudKit


class RideInviteCache {
    
    var totalInvitations = [Double: RideInvitation]()
    static var singleRideInviteInstance : RideInviteCache?
    var rideInvitationUpdateListener : RideInvitationUpdateListener?

    init() {
        let invites = NotificationStore.getInstance().getPendingRideInvites()
        for invite in invites {
            totalInvitations[invite.rideInvitationId] = invite
        }
    }
    
    static func getInstance() -> RideInviteCache{
        if singleRideInviteInstance == nil {
            singleRideInviteInstance = RideInviteCache()
        }
        return singleRideInviteInstance!
    }
  
    func deletePendingInvitationsOfRide(rideId : Double)
    {
        let rideInvites = getPendingInvitesOfRide(rideId: rideId)
        for invite in rideInvites{
            removeInvitation(id: invite.rideInvitationId)
        }
    }
    
    func getPendingInvitesOfRide(rideId: Double) -> [RideInvitation]{
        
        var invitations = [RideInvitation]()
        for invitation in totalInvitations{
            let rideInvitation = invitation.1
            if isInviteExpired(rideInvitation.invitationStatus){
                continue
            }
            if rideId == rideInvitation.rideId
            {
                invitations.append(rideInvitation)
            }
        }
        return invitations
    }
    
    
    func removeInvitation(id : Double){
        AppDelegate.getAppDelegate().log.debug("removeInvitation() : \(String(describing: id))")
        totalInvitations.removeValue(forKey: id)
        RideMatcherServiceClient.updateRideInvitationStatus(invitationId: id, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED, viewController: nil, completionHandler: { (responseObject, error) in
        })
    }
    
    func syncRideInvites( rideInvitations : [RideInvitation]){
        AppDelegate.getAppDelegate().log.debug("updateOrSaveRideInvites() \(rideInvitations)")
        self.totalInvitations.removeAll()
        if rideInvitations.isEmpty {
            return
        }
        
        for rideInvitation in rideInvitations{
            let expired = isInviteExpired(rideInvitation.invitationStatus)
            if expired{
                NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: rideInvitation.rideInvitationId)
                totalInvitations.removeValue(forKey: rideInvitation.rideInvitationId)
            }
            let rideInvitationStatus =  RideInviteStatus(rideInvitation: rideInvitation)
            if totalInvitations[rideInvitation.rideInvitationId] == nil{
                if expired{
                    continue
                }
                totalInvitations[rideInvitation.rideInvitationId] = rideInvitation
               
            }else{
                updateRideInviteStatus(invitationStatus: rideInvitationStatus)
            }
            
        }
         notifyRideInviteStatusChangesToListeners()
    }
    
    
    
    func updateRideInviteStatus( invitationStatus : RideInviteStatus)
    {
        AppDelegate.getAppDelegate().log.debug("updateRideInviteStatus()")
        let rideInvitation = totalInvitations[invitationStatus.invitationId]
        if rideInvitation == nil{
            AppDelegate.getAppDelegate().log.debug("No ride invitation found")
            let expired = isInviteExpired(invitationStatus.invitationStatus)
            if !expired {
                RideInvitationsSyncOfRide().syncRideInvitations()
            }
            return
        }
        if checkRedundancyOfStatus(invitationStatus: invitationStatus){
            AppDelegate.getAppDelegate().log.debug("There is redundant status update")
            return
        }
        rideInvitation!.invitationStatus = invitationStatus.invitationStatus
        if invitationStatus.invitationStatus == RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED_AND_PAYMENT_PENDING, invitationStatus.riderUserId == UserDataCache.getCurrentUserId() {
            rideInvitation?.rideId = invitationStatus.riderRideId
        }
        totalInvitations[invitationStatus.invitationId] = rideInvitation        
        notifyRideInviteStatusChangesToListeners()
    }
    
    
    private func checkRedundancyOfStatus( invitationStatus : RideInviteStatus) -> Bool{
        AppDelegate.getAppDelegate().log.debug("checkRedundancyOfStatus()")
        let rideInvitation = totalInvitations[invitationStatus.invitationId]
        if rideInvitation == nil{
            return false
        }
        if rideInvitation!.invitationStatus == invitationStatus.invitationStatus{
            return true
        }
        else {
            return false
        }
    }

    func notifyRideInviteStatusChangesToListeners(){
        AppDelegate.getAppDelegate().log.debug("notifyRideInviteStatusChangesToListeners()")
        rideInvitationUpdateListener?.rideInvitationStatusUpdated()
    }
    
    func clearUserSession()
    {
        AppDelegate.getAppDelegate().log.debug("clearUserSession()")
        if RideInviteCache.singleRideInviteInstance == nil{
            return
        }
        RideInviteCache.singleRideInviteInstance!.totalInvitations.removeAll()
    }
    func getOutGoingInvitationPresentBetweenRide(riderRideId : Double,passengerRideId: Double, rideType : String,userId :Double) -> RideInvitation?
    {
        AppDelegate.getAppDelegate().log.debug("getOutGoingInvitationPresentBetweenRide()")
        
        for invite in totalInvitations{
            
            let invitation = invite.1
            if isInviteExpired(invitation.invitationStatus){
                continue
            }
            if invitation.rideId == riderRideId && invitation.passenegerRideId == passengerRideId {
                
                if Ride.RIDER_RIDE == rideType{
                    if invitation.passenegerRideId != 0 && invitation.passenegerRideId == passengerRideId{
                        return invitation
                    }else if invitation.passengerId == userId{
                        return invitation
                    }
                }else if Ride.PASSENGER_RIDE == rideType{
                    if invitation.rideId != 0 && invitation.rideId == riderRideId{
                        return invitation
                    }else if invitation.riderId == userId{
                        return invitation
                    }
                }else if rideType == TaxiPoolConstants.Taxi{
                    if invitation.rideId != 0 && invitation.rideId == riderRideId{
                        return invitation
                    }else if invitation.riderId == userId{
                        return invitation
                    }
                }
            }
        }
        return nil
    }
    func getAnyInvitationSentByMatchedUserForTheRide( rideId : Double, rideType :  String, matchedUserRideId: Double, matchedUserTaxiRideId: Int?) -> RideInvitation?{
        for invitation in totalInvitations{
            let rideInvitation = invitation.1
            if isInviteExpired(rideInvitation.invitationStatus){
                continue
            }
            if Ride.RIDER_RIDE == rideType && rideId==rideInvitation.rideId
            {
                if let matchedUserTaxiRideId = matchedUserTaxiRideId, Double(matchedUserTaxiRideId) == rideInvitation.passenegerRideId {
                    return rideInvitation
                } else if Ride.PASSENGER_RIDE == rideInvitation.rideType &&  matchedUserRideId == rideInvitation.passenegerRideId {
                    return rideInvitation
                }
                
            }
            else if Ride.PASSENGER_RIDE == rideType && Ride.RIDER_RIDE == rideInvitation.rideType && rideId == rideInvitation.passenegerRideId && matchedUserRideId == rideInvitation.rideId{
                return rideInvitation
            }
        }
        return nil
    }
    func getInvitationIdSentByMatchedUserForTheRide(rideId : Double, rideType :String?, matchedUserRideId : Double) -> Double{
        AppDelegate.getAppDelegate().log.debug("rideId : \(rideId), rideType : \(String(describing: rideType)), matchedUserRideId : \(matchedUserRideId)")
        for invitation in totalInvitations{
            let rideInvitation = invitation.1
            
            if isInviteExpired(rideInvitation.invitationStatus){
                continue
            }
            if Ride.RIDER_RIDE == rideType
                && Ride.PASSENGER_RIDE == rideInvitation.rideType
                && rideId == rideInvitation.rideId
                && matchedUserRideId == rideInvitation.passenegerRideId {
                return rideInvitation.rideInvitationId
                
            }else if Ride.PASSENGER_RIDE == rideType && Ride.RIDER_RIDE == rideInvitation.rideType && rideId == rideInvitation.passenegerRideId && matchedUserRideId == rideInvitation.rideId{
                return rideInvitation.rideInvitationId
            }
        }
        return 0
    }
    func getInvitationsForRide( rideId : Double, rideType : String) -> [RideInvitation]{
        AppDelegate.getAppDelegate().log.debug("getInvitationsForRide() : \(rideId)")
        var invitations = [RideInvitation]()
        for invite in totalInvitations{
            let rideInvitation = invite.1
            if  isInviteExpired(rideInvitation.invitationStatus){
                continue
            }
            if rideType == rideInvitation.rideType{
                if Ride.RIDER_RIDE == rideType && Ride.RIDER_RIDE == rideInvitation.rideType && rideInvitation.rideId == rideId{
                    invitations.append(rideInvitation)
                }else if Ride.PASSENGER_RIDE == rideType && Ride.PASSENGER_RIDE == rideInvitation.rideType && rideInvitation.passenegerRideId == rideId{
                    invitations.append(rideInvitation)
                }
            }
        }
        return invitations
    }
    
    
    func isRejectedInvitationPresentBetweenRide(rideId : Double, userId : Double, rideType : String) -> Bool
    {
        AppDelegate.getAppDelegate().log.debug("isRejectedInvitationPresentBetweenRide() : \(rideId) \(userId) \(rideType)")
        var isPresent = false
        for invite in totalInvitations{
            let rideInvitation = invite.1
            if Ride.RIDER_RIDE == rideType && RideInvitation.RIDE_INVITATION_STATUS_REJECTED == rideInvitation.invitationStatus && rideInvitation.rideId == rideId && rideInvitation.invitingUserId  != userId
            {
                isPresent = true
                break
            }
            else if Ride.PASSENGER_RIDE == rideType && RideInvitation.RIDE_INVITATION_STATUS_REJECTED == rideInvitation.invitationStatus && rideInvitation.passenegerRideId == rideId && rideInvitation.invitingUserId != userId{
                isPresent = true
                break
            }
        }
        return isPresent
    }
    
    func isPaymentPendingRide( rideId : Double) -> Bool {
        let invites  =   Array(totalInvitations.values)
        if let invite = invites.first(where: {$0.rideId == rideId }), invite.invitationStatus == RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED_AND_PAYMENT_PENDING {
            return true
        }
        return false
    }
    
    func getReceivedInvitationsOfRide( rideId : Double, rideType : String) -> [RideInvitation]{
        AppDelegate.getAppDelegate().log.debug("getReceivedInvitationsOfRide() : \(rideId) \(rideType)")
        var invitations = [RideInvitation]()
        for invite in totalInvitations
        {
            let rideInvitation = invite.1
            
            if isInviteExpired(rideInvitation.invitationStatus){
                continue
            }
            if Ride.RIDER_RIDE == rideType && (Ride.PASSENGER_RIDE == rideInvitation.rideType || TaxiPoolConstants.Taxi == rideInvitation.rideType) && rideId == rideInvitation.rideId{
                invitations.append(rideInvitation)
            }else if Ride.PASSENGER_RIDE == rideType && Ride.RIDER_RIDE == rideInvitation.rideType && rideId == rideInvitation.passenegerRideId{
                invitations.append(rideInvitation)
            }
        }
        return invitations
    }
    func saveNewInvitation( rideInvitation : RideInvitation){
        AppDelegate.getAppDelegate().log.debug("\(String(describing: rideInvitation.rideInvitationId))")
        rideInvitation.invitationStatus = RideInvitation.RIDE_INVITATION_STATUS_RECEIVED
        totalInvitations[rideInvitation.rideInvitationId] = rideInvitation
        if rideInvitation.passengerId == UserDataCache.getCurrentUserId(){
            UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvitation.riderId, handler: { (info, resError, error) in
            })
        }else{
            UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvitation.passengerId, handler: { (info, resError, error) in
            })
        }
    }
    
    func clearLocalMemoryOnSessionInitializationFailure(){ 
        AppDelegate.getAppDelegate().log.debug("clearLocalMemoryOnSessionInitializationFailure()")
        totalInvitations.removeAll()
    }
    
    func updateRiderRideInvitesStatus(rideId : Double, passengerId : Double,status : String)
    {
        for invitation in totalInvitations{
            let rideInvitation = invitation.1
            
            if isInviteExpired(rideInvitation.invitationStatus){
                continue
            }
            if(rideId==rideInvitation.rideId && passengerId==rideInvitation.passengerId)
            {
                let rideInvitationStatus =  RideInviteStatus(rideInvitation: rideInvitation)
                updateRideInviteStatus(invitationStatus: rideInvitationStatus)
            }
        }
    }
    
    func addRideInviteStatusListener( rideInvitationUpdateListener : RideInvitationUpdateListener)
    {
        AppDelegate.getAppDelegate().log.debug("addRideInviteStatusListener()")
        self.rideInvitationUpdateListener = rideInvitationUpdateListener
    }
    
    func removeRideInviteStatusListener()
    {
        AppDelegate.getAppDelegate().log.debug("removeRideInviteStatusListener()")
        rideInvitationUpdateListener = nil
    }
    
    func checkIsRideInviteIsPresent(rideId: Double,rideType: String,chatPersonUserId: Double) -> (String?,String?) {//returns - invitation Status , type of invitation
        let incomingInvites = RideInviteCache.getInstance().getReceivedInvitationsOfRide(rideId: rideId, rideType: rideType)
        for invitation in incomingInvites {
            if invitation.invitingUserId == chatPersonUserId {
                return (invitation.invitationStatus, Strings.incoming)
            }
        }
        
        let allInvitedRides = RideInviteCache.getInstance().getInvitationsForRide(rideId: rideId, rideType: rideType)
        for invitation in allInvitedRides {
            if rideType == Ride.RIDER_RIDE {
            if invitation.passengerId == chatPersonUserId {
                return (invitation.invitationStatus, Strings.outgoing)
            }
            }else{
                if invitation.riderId == chatPersonUserId {
                    return (invitation.invitationStatus, Strings.outgoing)
                }
            }
        }
        return(nil, nil)
    }
    func isInviteExpired(_ status: String?) -> Bool {
        guard let status = status else {
            return true
        }
        return status != RideInvitation.RIDE_INVITATION_STATUS_NEW && status != RideInvitation.RIDE_INVITATION_STATUS_RECEIVED && status != RideInvitation.RIDE_INVITATION_STATUS_READ && status != RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED_AND_PAYMENT_PENDING
    }
    func getActiveInvite(inviteId: Double) -> RideInvitation? {
        if let invite = totalInvitations[inviteId], !isInviteExpired(invite.invitationStatus) {
            return invite
        }
        return nil
    }

    func getRideInviteFromServer(id: Double,handler: @escaping(_ invite: RideInvitation?, _ responseError: ResponseError?, _ error: NSError?)->Void){
        RideMatcherServiceClient.getRideInvite(userId: UserDataCache.getCurrentUserId(), inviteId: id, completionHandler: {(responseObject, error) in
            let result = RestResponseParser<RideInvitation>().parse(responseObject: responseObject, error: error)
            
            if let invite = result.0 {
                if self.isInviteExpired(invite.invitationStatus) {
                    NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: invite.rideInvitationId)
                    self.totalInvitations.removeValue(forKey: invite.rideInvitationId)
                    self.notifyRideInviteStatusChangesToListeners()
                    return handler(nil,nil,nil)
                }else{
                    self.totalInvitations[id] = invite
                    return handler(invite,nil,nil)
                }
            }else{
                return handler(nil,result.1,result.2)
            }
        })
    }
}


protocol  RideInvitationUpdateListener{
    func rideInvitationStatusUpdated()
}
