//
//  ConversationChatViewModel.swift
//  Quickride
//
//  Created by Ashutos on 16/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ConversationChatViewModel {
    
    var ride: Ride?
    var userBasicInfo: UserBasicInfo?
    
    init(ride: Ride?) {
        self.ride = ride
    }
    init() {}
    func getChatSuggestions(userId: Double?) -> [String] {
        guard let ride = ride,let oppositePersonId = userId else { return Strings.common_msg_for_group_chat }
        let inviteDetails = RideInviteCache.getInstance().checkIsRideInviteIsPresent(rideId: ride.rideId, rideType: ride.rideType ?? Ride.PASSENGER_RIDE, chatPersonUserId: oppositePersonId)
        if inviteDetails.1 == Strings.incoming { //Incoming Invitation
            if inviteDetails.0 == RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED {
                if ride.status ==  Ride.RIDE_STATUS_SCHEDULED {
                    if ride.rideType == Ride.RIDER_RIDE {
                        return Strings.personal_chat_ride_giver_before_ride_receive_invite_confirmed
                    }else{
                        return Strings.personal_chat_ride_taker_before_start_ride_receive_invite_confirmed
                    }
                }else if ride.status == Ride.RIDE_STATUS_STARTED {
                    if ride.rideType == Ride.RIDER_RIDE{
                        return Strings.personal_chat_ride_giver_recieved_after_ride_start_invite_confirmed
                    }else{
                        return Strings.personal_chat_ride_taker_after_start_ride_received_invite_confirmed
                    }
                }
            }else if inviteDetails.0 == RideInvitation.RIDE_INVITATION_STATUS_RECEIVED ||  inviteDetails.0 == RideInvitation.RIDE_INVITATION_STATUS_READ {
                if ride.status ==  Ride.RIDE_STATUS_SCHEDULED{
                    if ride.rideType == Ride.RIDER_RIDE{
                        return Strings.personal_chat_ride_giver_receive_invite_not_confirmed
                    }else{
                        return Strings.personal_chat_ride_taker_before_start_ride_receive_invite_not_confirmed
                    }
                }else if ride.status == Ride.RIDE_STATUS_STARTED {
                    if ride.rideType == Ride.RIDER_RIDE {
                        return Strings.personal_chat_ride_giver_recieved_after_ride_start_invite_not_confirmed
                    }else{
                        return Strings.personal_chat_ride_taker_after_start_ride_received_invite_not_confirmed
                    }
                }
            }
        }else if inviteDetails.1 == Strings.outgoing {  //OutGoing Invitation
            if inviteDetails.0 == RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED {
                if ride.status ==  Ride.RIDE_STATUS_SCHEDULED  || ride.status ==  Ride.RIDE_STATUS_REQUESTED {
                    if ride.rideType == Ride.RIDER_RIDE {
                        return Strings.personal_chat_ride_giver_before_ride_send_invite_confirm
                    }else{
                        return Strings.personal_chat_ride_taker_before_start_ride_invite_confirmed
                    }
                }else if ride.status == Ride.RIDE_STATUS_STARTED  || ride.status ==  Ride.RIDE_STATUS_DELAYED {
                    if ride.rideType == Ride.RIDER_RIDE {
                        return Strings.personal_chat_ride_giver_after_ride_start_invite_confirm
                    }else{
                        return Strings.personal_chat_ride_taker_after_start_ride_sent_invite_confirmed
                    }
                }
            }else if inviteDetails.0 == RideInvitation.RIDE_INVITATION_STATUS_RECEIVED || inviteDetails.0 == RideInvitation.RIDE_INVITATION_STATUS_READ {
                if ride.status ==  Ride.RIDE_STATUS_SCHEDULED || ride.status ==  Ride.RIDE_STATUS_DELAYED {
                    if ride.rideType == Ride.RIDER_RIDE {
                        return Strings.personal_chat_ride_giver_before_ride_send_invite_not_confirm
                    }else{
                        return Strings.personal_chat_ride_taker_before_start_ride_invite_not_confirmed
                    }
                } else if ride.status == Ride.RIDE_STATUS_STARTED {
                    if ride.rideType == Ride.RIDER_RIDE {
                        return Strings.personal_chat_ride_giver_after_ride_start_invite_not_confirm
                    }else{
                        return Strings.personal_chat_ride_taker_after_start_ride_sent_invite_confirmed
                    }
                }
            }
        }else{
            return chatSuggestionsWithoutInvite(currentRide: ride)
        }
        return Strings.common_msg_for_group_chat
    }
    
    private func chatSuggestionsWithoutInvite(currentRide: Ride) -> [String] {
        if currentRide.status == Ride.RIDE_STATUS_SCHEDULED {
            if currentRide.rideType == Ride.RIDER_RIDE {
                return Strings.personal_chat_ride_giver_before_ride_send_invite_confirm
            }else{
                return Strings.personal_chat_ride_taker_before_start_ride_invite_confirmed
            }
        }else if currentRide.status == Ride.RIDE_STATUS_STARTED || currentRide.status == Ride.RIDE_STATUS_DELAYED {
            if currentRide.rideType == Ride.RIDER_RIDE {
                return Strings.personal_chat_ride_giver_after_ride_start_invite_confirm
            }else{
                return Strings.personal_chat_ride_taker_after_start_ride_sent_invite_confirmed
            }
        }
        return Strings.common_msg_for_group_chat
    }
    func getUserbasicInfo(userId: Double){
        UserDataCache.getInstance()?.getUserBasicInfo(userId: userId, handler: { (userBasicInfo, responseError, error) in
            if let userBasicInfo = userBasicInfo{
                self.userBasicInfo = userBasicInfo
                NotificationCenter.default.post(name: .userBasicInfoReceived, object: nil)
            }else{
                var userInfo = [String : Any]()
                userInfo["responseError"] = responseError
                userInfo["error"] = error
                NotificationCenter.default.post(name: .failedToGetUserBasicInfo, object: nil, userInfo: userInfo)
            }
        })
    }
}
extension Notification.Name{
    static let userBasicInfoReceived = NSNotification.Name("userBasicInfoReceived")
    static let  failedToGetUserBasicInfo = NSNotification.Name("failedToGetUserBasicInfo")
}

