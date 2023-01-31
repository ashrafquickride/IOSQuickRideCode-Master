//
//  InviteTaxiPoolCellViewModel.swift
//  Quickride
//
//  Created by Ashutos on 9/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class InviteTaxiPoolCellViewModel {
    var ride : Ride?
    var row:Int?
    var matchedPassengerData: MatchedPassenger?
    var allInvites: [TaxiInviteEntity]?
    
    init(ride : Ride?, matchedPassengerData: MatchedPassenger?,row: Int,allInvites: [TaxiInviteEntity]?) {
        self.ride = ride
        self.matchedPassengerData = matchedPassengerData
        self.row = row
        self.allInvites = allInvites
    }
    
    func createInviteObject() -> TaxiInviteEntity? {
        guard let currentRide = ride as? PassengerRide else {return nil}
        let inviteEntity = TaxiInviteEntity()
        inviteEntity.taxiShareId = currentRide.taxiRideId ?? 0.0
        inviteEntity.invitingUserId = currentRide.userId
        inviteEntity.invitingRideId = currentRide.rideId
        inviteEntity.invitingRideType = Ride.PASSENGER_RIDE
        inviteEntity.invitedUserId = matchedPassengerData?.userid
        inviteEntity.invitedRideId = matchedPassengerData?.rideid
        inviteEntity.invitedRideType = Ride.PASSENGER_RIDE
        inviteEntity.fare = matchedPassengerData?.points
        inviteEntity.distance = matchedPassengerData?.distance
        inviteEntity.finalDistance = matchedPassengerData?.distance
        inviteEntity.pickupTime = matchedPassengerData?.pickupTime
        return inviteEntity
    }
    
    func getCompanyName(data: MatchedPassenger) -> String {
        if data.companyName != nil && data.companyName?.isEmpty == false {
            return data.companyName!.capitalized
        }else if UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: data.profileVerificationData, companyName: nil) == Strings.personal_id_verified {
            return Strings.govt_id_verified
        } else {
            return Strings.hyphen
        }
    }
    
    func checkInviteIsExist() -> Bool{
        if self.allInvites == [] {
            return false
        }else{
            for data in self.allInvites ?? [] {
                if data.invitedUserId == self.matchedPassengerData?.userid {
                    return true
                }
            }
            return false
        }
    }
    
    func getTheInviteForCancel() -> String? {
        for data in self.allInvites ?? [] {
            if data.invitedUserId == self.matchedPassengerData?.userid {
                return data.id ?? nil
            }
        }
        return nil
    }
    
    func getErrorMessageForCall() -> String?{
        if (matchedPassengerData?.userRole == MatchedUser.RIDER || matchedPassengerData?.userRole == MatchedUser.REGULAR_RIDER) && !RideManagementUtils.getUserQualifiedToDisplayContact(){
            return Strings.link_wallet_for_call_msg
        }else if let enableChatAndCall = matchedPassengerData?.enableChatAndCall, !enableChatAndCall{
            return Strings.chat_and_call_disable_msg
        }else if matchedPassengerData?.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED{
            return Strings.call_joined_partner_msg
        }else if matchedPassengerData?.callSupport == UserProfile.SUPPORT_CALL_NEVER{
            return Strings.no_call_please_msg
        }
        return nil
    }
    
    func callTheRespectiveMatchUser() {
        guard let ride = ride, let rideType = ride.rideType else { return }
        let refID = rideType+StringUtils.getStringFromDouble(decimalNumber: ride.rideId)
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: matchedPassengerData!.userid), refId: refID, name: matchedPassengerData?.name ?? "", targetViewController: ViewControllerUtils.getCenterViewController())
    }
    
    func updateRideInViteCacheAfterInvite(invitationData: TaxiInviteEntity) {
        TaxiPoolInvitationCache.getInstance().insertNewInvitationToCache(rideId: ride?.rideId ?? 0.0, rideInviteData: invitationData)
    }
}
