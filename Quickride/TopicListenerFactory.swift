//
//  TopicListenerFactory.swift
//  Quickride
//
//  Created by KNM Rao on 21/10/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class TopicListenerFactory {
    
    static let passengerRideInstanceListener = PassengerRideInstanceListener()
    static let riderRideInstanceListener = RiderRideInstanceListener()
    static let rideStatusUpdateListener = RideStatusUpdateListener()
    static let conversationListener =  ConversationListener()
    static let rideInvitationStatusUpdateListener = RideInvitationStatusUpdateListener()
    static let profileUpdateListener = ProfileUpdateListener()
    static let userNotificationListener = UserNotificationTopicListener()
    static let ridePreferencesUpdateListener = RidePreferencesUpdateListener()
    static let rideVehicleUpdateListener = RideVehicleUpdateListener()
    static let rideParticipantUpdateListener = RideParticipantUpdateListener()
    static let blockedUserStatusListener = BlockedUserStatusListener()
    static let profileVerificationDataUpdateListener = ProfileVerificationDataUpdateListener()
    static let userUpdateListener = UserUpdateListener()
    static let linkedWalletListener = LinkedWalletListener()
    static let freezeRideListener = FreezeRideTopicListener()
    static let securityPreferencesUpdateListener = SecurityPreferencesUpdateListener()
    static let linkedWalletTransactionStatusListner = LinkedWalletTransactionStatusListener()
    static let rideModeratorStatusListner = RideModeratorStatusUpdateListener()
    static let taxiPoolInviteReceiveListner = TaxiPoolInviteReceivedTopicListener()
    static let rideRouteUpdateListener = RideRouteUpdateListener()
    static let taxiRideStatusUpdateListener = TaxiPoolRideUpdateTopicListener()
    static let taxiGroupUpdateTopicListener = TaxiGroupUpdateTopicListener()
    static let taxiGroupSuggestionUpdateTopicListener = TaxiRideGroupSuggestionUpdateTopicListener()
    static let taxipoolInviteStatusUpdate = TaxipoolInviteStatusUpdate()
    static let taxiRideCreatedTopicListener = TaxiRideCreatedTopicListener()
    static let taxiRidePaymentStatusUpdate = TaxiRidePaymentStatusUpdate()
    static let taxiAllocationStatusUpdate = TaxiAllocationStatusUpdate()
    
    //Quick Share listeners
    static let productOrderUpdateListener = ProductOrderUpdateListener()
    static let productCommentsUpdateListener = ProductCommentsUpdateListener()
    static let callCreditTopicListener = CallCreditUpdateTopicListener()
    
    static func  getTopicListener(type : String?) -> TopicListener?{
        
        if QuickRideMessageEntity.CHAT_ENTITY == type{
            return conversationListener
        }
        else if QuickRideMessageEntity.INVITE_STATUS_ENTITY == type{
            return rideInvitationStatusUpdateListener
        }
        else if QuickRideMessageEntity.PASSENGER_RIDE_INSTANCE_ENTITY == type{
            return passengerRideInstanceListener
        }
        else if QuickRideMessageEntity.RIDER_RIDE_INSTNACE_ENTITY == type{
            return riderRideInstanceListener
        }
        else if QuickRideMessageEntity.RIDE_STATUS_ENTITY == type{
            return rideStatusUpdateListener
        }
        else if QuickRideMessageEntity.USER_PROFILE_ENTITY == type{
            return profileUpdateListener
        }
        else if QuickRideMessageEntity.USER_NOTIFICATION_ENTITY == type{
            return userNotificationListener
        }
        else if QuickRideMessageEntity.RIDE_PREFERENCES_INSTANCE_ENTITY == type{
            return ridePreferencesUpdateListener
        }else if QuickRideMessageEntity.RIDE_VEHICLE_ENTITY == type{
            return rideVehicleUpdateListener
        }
        else if QuickRideMessageEntity.RIDEPARTICIPANT_ENTITY == type{
            return rideParticipantUpdateListener
        }
        else if QuickRideMessageEntity.BLOCKED_USER_LISTNER_ENTITY == type{
            return blockedUserStatusListener
        }
        else if QuickRideMessageEntity.PROFILE_VERIFICATION_DATA_LISTENER_ENTITY == type{
            return profileVerificationDataUpdateListener
        }
        else if QuickRideMessageEntity.USER_ENTITY == type{
            return userUpdateListener
        }else if QuickRideMessageEntity.LINKED_WALLET_ENTITY == type{
            return linkedWalletListener
        }else if QuickRideMessageEntity.FREEZE_RIDE_STATUS_LISTNER_ENTITY == type{
            return freezeRideListener
        }else if QuickRideMessageEntity.SECURITY_PREFERENCES_INSTANCE_ENTITY == type{
            return securityPreferencesUpdateListener
        } else if QuickRideMessageEntity.LINKED_WALLET_TRANSACTION_STATUS_ENTITY == type {
            return linkedWalletTransactionStatusListner
        } else if QuickRideMessageEntity.RIDE_MODERATION_STATUS_ENTITY == type {
            return rideModeratorStatusListner
        } else if QuickRideMessageEntity.RIDE_UPDATE_ENTITY == type {
            return rideRouteUpdateListener
        }else if QuickRideMessageEntity.TAXI_RIDE_PASSENGER_STATUS == type {
            return taxiRideStatusUpdateListener
        }else if QuickRideMessageEntity.TAXI_RIDE_GROUP_STATUS == type {
            return taxiGroupUpdateTopicListener
        }else if QuickRideMessageEntity.PRODUCT_COMMENTS_ENTITY == type{
            return productCommentsUpdateListener
        }else if QuickRideMessageEntity.PRODUCT_ORDER_EVENT_ENTITY == type{
            return productOrderUpdateListener
        }else if QuickRideMessageEntity.TAXI_RIDE_GROUP_SUGGESTION_UPDATE == type{
            return taxiGroupSuggestionUpdateTopicListener
        }else if QuickRideMessageEntity.TAXIPOOL_INVITE_STATUS == type{
            return taxipoolInviteStatusUpdate
        }else if QuickRideMessageEntity.CALL_CREDIT_DETAILS_UPDATE == type{
            return callCreditTopicListener
        }else if QuickRideMessageEntity.NEW_TAXI_RIDE_CREATED == type{
            return taxiRideCreatedTopicListener
        }else if QuickRideMessageEntity.TAXI_RIDE_PAYMENT_STATUS_UPDATE == type || QuickRideMessageEntity.TAXI_PAYMENT_STATUS_UPDATE == type {
            return taxiRidePaymentStatusUpdate
        }else if QuickRideMessageEntity.DRIVER_ALLOCATION_STATUS == type {
            return taxiAllocationStatusUpdate
        }else {
            return nil
        }
    }
}
